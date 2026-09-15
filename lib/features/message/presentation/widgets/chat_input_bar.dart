import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/message/data/model/chat_message_model.dart';
import 'package:hamro_futsal/features/message/domain/model/message_mentions.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({
    super.key,
    required this.onSend,
    this.onTypingChanged,
    this.sending = false,
    this.focusNode,
    this.onAttach,
    this.attachmentNames = const <String>[],
    this.onRemoveAttachment,
    this.replyingTo,
    this.onCancelReply,
    this.enabled = true,
    this.disabledHint = 'You cannot send messages in this conversation.',
    this.mentionCandidates = const <MentionCandidate>[],
    this.currentUserId,
  });

  /// Sends the typed body along with whatever it mentions.
  final void Function(String body, ResolvedMentions mentions) onSend;

  /// People who can be mentioned here. Empty in a direct chat, where `@` is
  /// just a character.
  final List<MentionCandidate> mentionCandidates;

  /// The signed-in user, kept out of their own mention picker.
  final int? currentUserId;
  final ValueChanged<bool>? onTypingChanged;
  final bool sending;
  final FocusNode? focusNode;
  final VoidCallback? onAttach;
  final List<String> attachmentNames;
  final ValueChanged<int>? onRemoveAttachment;
  final ChatMessageModel? replyingTo;
  final VoidCallback? onCancelReply;
  final bool enabled;
  final String disabledHint;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _ctrl = TextEditingController();
  Timer? _typingTimer;
  bool _typingSent = false;

  /// The `@…` the caret is currently inside, or null. Drives the suggestion
  /// list above the composer.
  ({int start, String query})? _mentionQuery;

  bool get _supportsMentions => widget.mentionCandidates.isNotEmpty;

  /// `@all` plus every participant, filtered by what has been typed so far.
  List<MentionCandidate> get _mentionSuggestions {
    final String query = _mentionQuery?.query ?? '';
    final List<MentionCandidate> people = widget.mentionCandidates
        .where(
          (MentionCandidate person) =>
              person.userId != widget.currentUserId &&
              person.matchesQuery(query),
        )
        .toList(growable: false);
    final bool offersAll = 'all'.startsWith(query.trim().toLowerCase());
    return <MentionCandidate>[
      if (offersAll) const MentionCandidate(userId: -1, name: 'all'),
      ...people,
    ];
  }

  void _syncMentionQuery() {
    if (!_supportsMentions) return;
    final TextSelection selection = _ctrl.selection;
    final ({int start, String query})? next = selection.isCollapsed
        ? activeMentionQuery(_ctrl.text, selection.baseOffset)
        : null;
    if (next?.start != _mentionQuery?.start ||
        next?.query != _mentionQuery?.query) {
      setState(() => _mentionQuery = next);
    }
  }

  void _applyMention(MentionCandidate candidate) {
    final ({int start, String query})? query = _mentionQuery;
    if (query == null) return;

    final ({String text, int caret}) result = insertMention(
      text: _ctrl.text,
      start: query.start,
      caret: _ctrl.selection.baseOffset,
      handle: candidate.handle,
    );
    _ctrl.value = TextEditingValue(
      text: result.text,
      selection: TextSelection.collapsed(offset: result.caret),
    );
    setState(() => _mentionQuery = null);
  }

  bool get _canSend =>
      (_ctrl.text.trim().isNotEmpty || widget.attachmentNames.isNotEmpty) &&
      !widget.sending &&
      widget.enabled;

  @override
  void dispose() {
    _typingTimer?.cancel();
    _stopTyping();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String _) {
    setState(() {});
    _syncMentionQuery();

    if (widget.onTypingChanged == null) return;

    if (_ctrl.text.trim().isEmpty) {
      _typingTimer?.cancel();
      _stopTyping();
      return;
    }

    if (!_typingSent) {
      _typingSent = true;
      widget.onTypingChanged!(true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1800), _stopTyping);
  }

  void _stopTyping() {
    if (!_typingSent) return;

    _typingSent = false;
    widget.onTypingChanged?.call(false);
  }

  void _send() {
    final text = _ctrl.text.trim();

    if ((text.isEmpty && widget.attachmentNames.isEmpty) ||
        widget.sending ||
        !widget.enabled) {
      return;
    }

    HapticFeedback.selectionClick();

    _typingTimer?.cancel();
    _stopTyping();

    widget.onSend(text, resolveMentions(text, widget.mentionCandidates));

    _ctrl.clear();
    setState(() => _mentionQuery = null);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return SafeArea(
      top: false,
      maintainBottomViewPadding: true,
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX12,
            AppDimens.paddingX6,
            AppDimens.paddingX12,
            AppDimens.paddingX12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The picker sits directly above the composer, so the name being
              // typed and the list of names are in the same place.
              if (_mentionQuery != null && _mentionSuggestions.isNotEmpty)
                _MentionSuggestions(
                  candidates: _mentionSuggestions,
                  onSelected: _applyMention,
                ),
              if (widget.replyingTo != null)
                _ReplyPreview(
                  message: widget.replyingTo!,
                  onCancel: widget.onCancelReply,
                ),
              if (widget.attachmentNames.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: AppDimens.paddingX6,
                    runSpacing: AppDimens.paddingX4,
                    children: [
                      for (var i = 0; i < widget.attachmentNames.length; i++)
                        InputChip(
                          avatar: const Icon(
                            Icons.attach_file_rounded,
                            size: 15,
                          ),
                          label: Text(
                            widget.attachmentNames[i],
                            overflow: TextOverflow.ellipsis,
                          ),
                          onDeleted: widget.onRemoveAttachment == null
                              ? null
                              : () => widget.onRemoveAttachment!(i),
                        ),
                    ],
                  ),
                ),
              if (widget.replyingTo != null ||
                  widget.attachmentNames.isNotEmpty)
                const SizedBox(height: AppDimens.paddingX6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(
                        minHeight: 46,
                        maxHeight: 118,
                      ),
                      decoration: BoxDecoration(
                        color: context.appColors.inputFill,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX24,
                        ),
                        border: Border.all(
                          color: context.appColors.inputBorder,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: LightColor.shadowColor,
                            blurRadius: 12,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _PillIcon(
                            icon: Icons.emoji_emotions_outlined,
                            onTap: () {},
                          ),
                          Expanded(
                            child: TextField(
                              enabled: widget.enabled,
                              controller: _ctrl,
                              focusNode: widget.focusNode,
                              onChanged: _onChanged,
                              onTap: _syncMentionQuery,
                              minLines: 1,
                              maxLines: 4,
                              textAlignVertical: TextAlignVertical.center,
                              textCapitalization: TextCapitalization.sentences,
                              cursorColor: LightColor.secondaryColor,
                              style: textTheme.bodyTextSmall?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 13.5,
                                height: 1.4,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: context.appColors.inputFill,
                                isDense: true,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintText: widget.enabled
                                    ? 'Type here'
                                    : widget.disabledHint,
                                hintStyle: textTheme.bodyTextSmall?.copyWith(
                                  color: LightColor.hintTextColor,
                                  fontSize: 13.5,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),

                          _PillIcon(
                            icon: Icons.attach_file_rounded,
                            onTap: widget.enabled
                                ? widget.onAttach ?? () {}
                                : () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: AppDimens.paddingX8),

                  AnimatedScale(
                    scale: _canSend ? 1 : 0.92,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _canSend
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  LightColor.secondaryColor,
                                  LightColor.secondaryColor.withValues(
                                    alpha: 0.8,
                                  ),
                                ],
                              )
                            : null,
                        color: _canSend ? null : LightColor.cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: _canSend
                                ? LightColor.secondaryColor.withValues(
                                    alpha: 0.35,
                                  )
                                : LightColor.shadowColor,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _canSend ? _send : null,
                          child: widget.sending
                              ? const Padding(
                                  padding: EdgeInsets.all(13),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: LightColor.secondaryColor,
                                  ),
                                )
                              : Icon(
                                  Icons.send_rounded,
                                  size: 20,
                                  color: _canSend
                                      ? LightColor.inverseTextColor
                                      : LightColor.hintTextColor,
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The list of people an `@` can resolve to, shown while one is being typed.
class _MentionSuggestions extends StatelessWidget {
  const _MentionSuggestions({
    required this.candidates,
    required this.onSelected,
  });

  final List<MentionCandidate> candidates;
  final ValueChanged<MentionCandidate> onSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.paddingX8),
      constraints: const BoxConstraints(maxHeight: 196),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          itemCount: candidates.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, indent: 52, color: LightColor.dividerColor),
          itemBuilder: (BuildContext context, int index) {
            final MentionCandidate candidate = candidates[index];
            final bool isAll = candidate.userId < 0;
            return InkWell(
              onTap: () => onSelected(candidate),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX12,
                  vertical: AppDimens.paddingX10,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: AppDimens.sizeX28,
                      height: AppDimens.sizeX28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: LightColor.secondaryColor.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      child: isAll
                          ? Icon(
                              Icons.campaign_rounded,
                              size: AppDimens.sizeX16,
                              color: LightColor.secondaryColor,
                            )
                          : Text(
                              candidate.name.isEmpty
                                  ? '?'
                                  : candidate.name
                                        .trim()
                                        .substring(0, 1)
                                        .toUpperCase(),
                              style: textTheme.bodyTextSmall?.copyWith(
                                color: LightColor.secondaryColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    const SizedBox(width: AppDimens.paddingX10),
                    Expanded(
                      child: Text(
                        isAll ? 'all' : candidate.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isAll)
                      Text(
                        'Notify everyone',
                        style: textTheme.bodySubTitle?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReplyPreview extends StatelessWidget {
  const _ReplyPreview({required this.message, this.onCancel});

  final ChatMessageModel message;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final body = message.isDeleted
        ? 'Deleted message'
        : message.body.trim().isNotEmpty
        ? message.body.trim()
        : message.media.isNotEmpty
        ? message.media.first.name
        : 'Message';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.reply_rounded,
            size: 17,
            color: LightColor.secondaryColor,
          ),
          const SizedBox(width: AppDimens.paddingX6),
          Expanded(
            child: Text(
              'Replying to ${message.senderName.isEmpty ? 'message' : message.senderName}: $body',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onCancel,
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

/// Muted inline icon inside the composer pill.
class _PillIcon extends StatelessWidget {
  const _PillIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX12,
          vertical: 12,
        ),
        child: Icon(icon, size: 21, color: LightColor.iconGrey),
      ),
    );
  }
}
