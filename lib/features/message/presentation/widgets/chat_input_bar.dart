import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';

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
  });

  final ValueChanged<String> onSend;
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

    widget.onSend(text);

    _ctrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return SafeArea(
      top: false,
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
                        avatar: const Icon(Icons.attach_file_rounded, size: 15),
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
            if (widget.replyingTo != null || widget.attachmentNames.isNotEmpty)
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX24),
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
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
                              fillColor: Colors.white,
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
                                    ? LightColor.whiteColor
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
