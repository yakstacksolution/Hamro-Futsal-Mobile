import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/helper/device_location_helper.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_bubble.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_input_bar.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/group_conversation_sheet.dart';
import 'package:hamro_footsall/features/message/presentation/pages/user_profile_page.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversation});

  final ConversationModel conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  static const Object _typingEntry = Object();
  final _scrollCtrl = ScrollController();
  late final MessageBloc _bloc;
  final List<PlatformFile> _attachments = <PlatformFile>[];
  ChatMessageModel? _replyingTo;
  Timer? _presenceTimer;
  bool? _peerOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = context.read<MessageBloc>();
    _bloc.add(
      LoadChatEvent(widget.conversation.id, conversation: widget.conversation),
    );
    _refreshPresence();
    if (!widget.conversation.isGroup) {
      _presenceTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _refreshPresence(),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!_bloc.isClosed) {
      _bloc.add(SendTypingEvent(widget.conversation.id, false));
    }
    if (!_bloc.isClosed) _bloc.add(const CloseChatEvent());
    _presenceTimer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_bloc.isClosed) return;
    if (state == AppLifecycleState.resumed) {
      _bloc.add(
        LoadChatEvent(
          widget.conversation.id,
          conversation: widget.conversation,
        ),
      );
      _refreshPresence();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _bloc.add(SendTypingEvent(widget.conversation.id, false));
    }
  }

  Future<void> _refreshPresence() async {
    if (widget.conversation.isGroup || _bloc.isClosed) return;
    final participant = widget.conversation.otherParticipant(
      _bloc.state.currentUserId,
    );
    if (participant == null || participant.userId <= 0) return;

    final result = await _bloc.useCase.getUserPresence(participant.userId);
    if (!mounted) return;
    result.fold((_) {}, (online) {
      if (_peerOnline != online) setState(() => _peerOnline = online);
    });
  }

  void _send(String text) {
    final request = ChatSendRequest(
      body: text,
      filePaths: _attachments
          .map((file) => file.path)
          .whereType<String>()
          .toList(growable: false),
      replyToMessageId: _replyingTo?.id,
    );
    if (!request.isValid) return;
    _bloc.add(SendMessageEvent(widget.conversation.id, request));
    setState(() {
      _attachments.clear();
      _replyingTo = null;
    });
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: false,
    );
    if (result == null || !mounted) return;
    final accepted = result.files
        .where(
          (file) =>
              file.path != null &&
              file.size <= ChatSendRequest.maxFileBytes &&
              ChatSendRequest.allowedExtensions.contains(
                ChatSendRequest.extensionOf(file.name),
              ),
        )
        .toList(growable: false);
    final availableSlots = ChatSendRequest.maxFiles - _attachments.length;
    final exceededLimit = accepted.length > availableSlots;
    setState(() {
      final knownPaths = _attachments.map((file) => file.path).toSet();
      for (final file in accepted) {
        if (_attachments.length >= ChatSendRequest.maxFiles) break;
        if (knownPaths.add(file.path)) _attachments.add(file);
      }
    });
    if (accepted.length != result.files.length) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Choose JPG, JPEG, PNG, PDF, DOC or DOCX files up to 10 MB.',
      );
    }
    if (exceededLimit) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'A message can contain at most 5 files.',
      );
    }
  }

  Future<void> _showAddMenu() async {
    final action = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.attach_file_rounded),
            title: const Text(StringConstants.attachFiles),
            onTap: () => Navigator.of(sheetContext).pop('files'),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text(StringConstants.shareCurrentLocation),
            onTap: () => Navigator.of(sheetContext).pop('location'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'files') {
      await _pickAttachments();
    } else if (action == 'location') {
      await _shareLocation();
    }
  }

  Future<void> _shareLocation() async {
    await DeviceLocationHelper.instance.ensurePosition();
    if (!mounted) return;
    final position = DeviceLocationHelper.instance.position.value;
    if (position == null) {
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Location is unavailable. Check location permission and services.',
      );
      return;
    }
    _bloc.add(
      SendMessageEvent(
        widget.conversation.id,
        ChatSendRequest(
          body: 'Shared location',
          type: 'location',
          metadata: <String, dynamic>{
            'latitude': position.latitude,
            'longitude': position.longitude,
          },
          replyToMessageId: _replyingTo?.id,
        ),
      ),
    );
    setState(() => _replyingTo = null);
  }

  Future<void> _showMessageActions(ChatMessageModel message) async {
    final action = await showAppBottomSheet<String>(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.reply_rounded),
            title: const Text(StringConstants.reply),
            onTap: () => Navigator.of(sheetContext).pop('reply'),
          ),
          if (message.isMine(_bloc.state.currentUserId))
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded),
              title: const Text(StringConstants.deleteMessageAction),
              textColor: LightColor.redColor,
              iconColor: LightColor.redColor,
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'reply') {
      setState(() => _replyingTo = message);
    } else if (action == 'delete') {
      final confirmed = await showDeleteDialog(
        context: context,
        title: StringConstants.deleteMessage,
        message: StringConstants
            .thisMessageWillBePermanentlyRemovedFromTheConversation,
        confirmText: StringConstants.delete,
      );
      if (confirmed && mounted) {
        _bloc.add(DeleteMessageEvent(message.id));
      }
    }
  }

  /// Fetches the authed bytes for an attachment for inline rendering; returns
  /// null on failure so the bubble can fall back to a file chip.
  Future<Uint8List?> _loadMediaBytes(ChatMediaModel media) async {
    final result = await _bloc.useCase.getMediaBytes(media.id);
    return result.fold((_) => null, (bytes) => bytes);
  }

  Future<void> _openMedia(ChatMediaModel media) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    final result = await _bloc.useCase.getMediaBytes(media.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    await result.fold(
      (failure) async =>
          AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage),
      (bytes) async {
        if (media.isImage) {
          await _showImage(bytes);
        } else {
          await FilePicker.platform.saveFile(
            dialogTitle: 'Save ${media.name}',
            fileName: media.name,
            bytes: bytes,
          );
        }
      },
    );
  }

  Future<void> _showImage(Uint8List bytes) => showDialog<void>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: Colors.black,
      child: Stack(
        children: [
          InteractiveViewer(child: Center(child: Image.memory(bytes))),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              color: Colors.white,
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _showConversationActions() async {
    final state = _bloc.state;
    final conversation = state.activeConversation ?? widget.conversation;
    final action = await showAppBottomSheet<_ConversationAction>(
      context: context,
      builder: (_) => _ConversationActions(
        conversation: conversation,
        currentUserId: state.currentUserId,
      ),
    );
    if (!mounted || action == null) return;
    switch (action.type) {
      case _ConversationActionType.mute:
        _bloc.add(
          SetConversationMutedEvent(conversation.id, !conversation.isMuted),
        );
      case _ConversationActionType.archive:
        _bloc.add(
          SetConversationArchivedEvent(
            conversation.id,
            !conversation.isArchived,
          ),
        );
      case _ConversationActionType.block:
        final participant = action.participant!;
        _bloc.add(
          SetParticipantBlockedEvent(
            conversationId: conversation.id,
            userId: participant.userId,
            blocked: !participant.isBlocked,
          ),
        );
      case _ConversationActionType.addMembers:
        final existingIds =
            conversation.participants
                .map((participant) => participant.userId)
                .toSet()
              ..add(state.currentUserId);
        final ids = await showAddGroupMembersSheet(
          context: context,
          excludedUserIds: existingIds,
          participants: state.conversations.expand((item) => item.participants),
        );
        if (ids != null && ids.isNotEmpty && mounted) {
          _bloc.add(AddGroupMembersEvent(conversation.id, ids));
        }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: _ChatAppBar(
        conversation: widget.conversation,
        peerOnline: _peerOnline,
        onActions: _showConversationActions,
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<MessageBloc, MessageState>(
          buildWhen: (MessageState previous, MessageState current) =>
              previous.chatStatus != current.chatStatus ||
              previous.activeConversation != current.activeConversation ||
              previous.messages != current.messages ||
              previous.sending != current.sending ||
              previous.peerTyping != current.peerTyping,
          listenWhen: (prev, curr) =>
              curr.messages.length > prev.messages.length ||
              curr.actionMessage != prev.actionMessage ||
              (prev.actionBusy &&
                  !curr.actionBusy &&
                  curr.errorMessage != prev.errorMessage) ||
              (prev.sending &&
                  !curr.sending &&
                  curr.errorMessage != prev.errorMessage),
          listener: (context, state) {
            _scrollToBottom();
            if (state.actionMessage != null) {
              AppUtils().showSnackBar(
                context,
                MsgType.success,
                state.actionMessage!,
              );
              _bloc.add(const ClearMessageActionEvent());
            } else if (!state.actionBusy && state.errorMessage != null) {
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                state.errorMessage!,
              );
              _bloc.add(const ClearMessageActionEvent());
            }
          },
          builder: (context, state) {
            final active = state.activeConversation ?? widget.conversation;
            final blocked = active.participants.any(
              (participant) =>
                  participant.userId != state.currentUserId &&
                  participant.isBlocked,
            );
            return Column(
              children: [
                Expanded(child: _thread(state)),
                if (blocked)
                  Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Text(
                      StringConstants
                          .youBlockedThisUserUnblockThemToSendMessages,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: LightColor.redColor),
                    ),
                  ),
                ChatInputBar(
                  onSend: _send,
                  sending: state.sending,
                  onTypingChanged: (typing) => _bloc.add(
                    SendTypingEvent(widget.conversation.id, typing),
                  ),
                  onAttach: _showAddMenu,
                  attachmentNames: _attachments
                      .map((file) => file.name)
                      .toList(growable: false),
                  onRemoveAttachment: (index) =>
                      setState(() => _attachments.removeAt(index)),
                  replyingTo: _replyingTo,
                  onCancelReply: () => setState(() => _replyingTo = null),
                  enabled: !blocked,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _thread(MessageState state) {
    if (state.chatStatus == MessageStatus.initial ||
        state.chatStatus == MessageStatus.loading) {
      return const LoadingWidget(isTransparentBackground: true);
    }
    if (state.chatStatus == MessageStatus.failure) {
      return _ThreadError(
        message: state.errorMessage ?? 'Could not load messages.',
        onRetry: () => context.read<MessageBloc>().add(
          LoadChatEvent(
            widget.conversation.id,
            conversation: widget.conversation,
          ),
        ),
      );
    }
    if (state.messages.isEmpty) {
      return const _EmptyThread();
    }

    // Bubbles + day chips, newest at the bottom (reversed list keeps the
    // viewport pinned there).
    final entries = <Object>[];
    DateTime? lastDay;
    for (final m in state.messages) {
      final day = DateTime(
        m.createdAt.year,
        m.createdAt.month,
        m.createdAt.day,
      );
      if (lastDay == null || day != lastDay) {
        entries.add(day);
        lastDay = day;
      }
      entries.add(m);
    }
    if (state.peerTyping) entries.add(_typingEntry);
    final reversed = entries.reversed.toList(growable: false);

    return ListView.builder(
      controller: _scrollCtrl,
      reverse: true,
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX12),
      itemCount: reversed.length,
      itemBuilder: (_, int index) {
        final Object entry = reversed[index];
        if (entry is DateTime) return ChatDayChip(date: entry);
        if (identical(entry, _typingEntry)) return const _TypingBubble();

        final ChatMessageModel message = entry as ChatMessageModel;
        return ChatBubble(
          message: message,
          isMe: message.isMine(state.currentUserId),
          showSender: widget.conversation.isGroup,
          onLongPress: () => _showMessageActions(message),
          onMediaTap: _openMedia,
          mediaBytesLoader: _loadMediaBytes,
        );
      },
    );
  }
}

/// Left-aligned "typing…" indicator bubble.
class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX4,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            boxShadow: [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            StringConstants.typing,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyThread extends StatelessWidget {
  const _EmptyThread();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.waving_hand_outlined,
                size: 30,
                color: LightColor.secondaryColor.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              StringConstants.noMessagesYet,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              StringConstants.sayHelloAndStartTheConversation,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadError extends StatelessWidget {
  const _ThreadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: AppUtils().getPadding(all: AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: LightColor.hintTextColor,
            ),
            const SizedBox(height: AppDimens.paddingX14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX18),
            CustomButton(
              text: StringConstants.retry,
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

/// Contact header: avatar, title and live subtitle (typing… / members).
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({
    required this.conversation,
    required this.peerOnline,
    required this.onActions,
  });

  final ConversationModel conversation;
  final bool? peerOnline;
  final VoidCallback onActions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return AppBar(
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 0,
      shape: Border(
        bottom: BorderSide(
          color: LightColor.dividerColor.withValues(alpha: 0.8),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: LightColor.primaryTextColor,
        ),
      ),
      actions: [
        IconButton(
          tooltip: StringConstants.conversationSettings,
          onPressed: onActions,
          icon: const Icon(Icons.more_vert_rounded),
        ),
      ],
      title: BlocBuilder<MessageBloc, MessageState>(
        builder: (context, state) {
          final active = state.activeConversation ?? conversation;
          final title = active.displayTitle(state.currentUserId);
          final avatar = active.displayAvatar(state.currentUserId);
          final peer = active.isGroup
              ? null
              : active.otherParticipant(state.currentUserId);
          final String subtitle;
          if (state.peerTyping) {
            subtitle = 'typing…';
          } else if (active.isGroup) {
            final n = active.participants.length;
            subtitle = '$n ${n == 1 ? 'member' : 'members'}';
          } else {
            subtitle = switch (peerOnline) {
              true => 'Online',
              false => 'Offline',
              null => 'Checking presence…',
            };
          }

          final header = Row(
            children: [
              if (active.isGroup || avatar.isEmpty)
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: active.isGroup
                      ? const Icon(
                          Icons.groups_2_outlined,
                          size: 19,
                          color: LightColor.secondaryColor,
                        )
                      : Text(
                          title.isEmpty
                              ? '?'
                              : title.substring(0, 1).toUpperCase(),
                          style: textTheme.bodyTextMedium?.copyWith(
                            color: LightColor.secondaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                )
              else
                ClipOval(
                  child: CustomImageView(
                    url: avatar,
                    width: 38,
                    height: 38,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      style: textTheme.bodyTextSmall?.copyWith(
                        fontSize: AppDimens.fontBodySubTitle,
                        color: state.peerTyping
                            ? LightColor.secondaryColor
                            : LightColor.hintTextColor,
                        fontWeight: FontWeight.w500,
                        fontStyle: state.peerTyping
                            ? FontStyle.italic
                            : FontStyle.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          // Direct chats: tapping the header opens the other user's
          // view-only profile. Groups have no single counterpart.
          if (peer == null || peer.userId <= 0) return header;
          return InkWell(
            onTap: () => openUserProfilePage(
              context: context,
              userId: peer.userId,
              fallbackName: title,
              fallbackImageUrl: avatar,
            ),
            child: Semantics(
              button: true,
              label: StringConstants.viewProfile,
              child: header,
            ),
          );
        },
      ),
    );
  }
}

enum _ConversationActionType { mute, archive, block, addMembers }

final class _ConversationAction {
  const _ConversationAction(this.type, [this.participant]);

  final _ConversationActionType type;
  final ParticipantModel? participant;
}

class _ConversationActions extends StatelessWidget {
  const _ConversationActions({
    required this.conversation,
    required this.currentUserId,
  });

  final ConversationModel conversation;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    final participants = conversation.participants
        .where((participant) => participant.userId != currentUserId)
        .toList(growable: false);
    return ListView(
      shrinkWrap: true,
      children: [
        if (conversation.isGroup)
          ListTile(
            leading: const Icon(Icons.person_add_alt_1_rounded),
            title: const Text(StringConstants.addMembers),
            onTap: () => Navigator.of(context).pop(
              const _ConversationAction(_ConversationActionType.addMembers),
            ),
          ),
        ListTile(
          leading: Icon(
            conversation.isMuted
                ? Icons.volume_up_outlined
                : Icons.volume_off_outlined,
          ),
          title: Text(
            conversation.isMuted
                ? StringConstants.unmute
                : StringConstants.mute,
          ),
          onTap: () => Navigator.of(
            context,
          ).pop(const _ConversationAction(_ConversationActionType.mute)),
        ),
        ListTile(
          leading: Icon(
            conversation.isArchived
                ? Icons.unarchive_outlined
                : Icons.archive_outlined,
          ),
          title: Text(
            conversation.isArchived
                ? StringConstants.unarchive
                : StringConstants.archive,
          ),
          onTap: () => Navigator.of(
            context,
          ).pop(const _ConversationAction(_ConversationActionType.archive)),
        ),
        if (participants.isNotEmpty) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              StringConstants.participants,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          for (final participant in participants)
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16),

              leading: CircleAvatar(
                child: Text(
                  participant.name.isEmpty
                      ? '?'
                      : participant.name.substring(0, 1).toUpperCase(),
                ),
              ),
              title: Text(
                participant.name,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall,
              ),

              subtitle: participant.role.isEmpty
                  ? null
                  : Text(
                      participant.role,
                      style: FutsalTheme.getTextTheme(
                        context,
                      ).bodySubTitle?.copyWith(fontWeight: FontWeight.w400),
                    ),
              titleAlignment: ListTileTitleAlignment.center,
              trailing: InkWell(
                onTap: participant.userId <= 0
                    ? null
                    : () => Navigator.of(context).pop(
                        _ConversationAction(
                          _ConversationActionType.block,
                          participant,
                        ),
                      ),
                child: Text(
                  participant.isBlocked
                      ? StringConstants.unblock
                      : StringConstants.block,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
