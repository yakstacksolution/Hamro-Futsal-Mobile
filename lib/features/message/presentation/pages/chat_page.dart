import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/helper/device_location_helper.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/chat_send_request.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_bubble.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_input_bar.dart';
import 'package:hamro_footsall/features/message/presentation/pages/group_profile_page.dart';
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

  /// Trailing entry of the reversed list — i.e. the visual top of the thread —
  /// showing the older-history spinner or its retry row.
  static const Object _loadOlderEntry = Object();
  final _scrollCtrl = ScrollController();

  /// Newest rendered message. Auto-scroll-to-bottom keys off this so loading
  /// older history (which also grows `messages`) never yanks the viewport.
  int _newestMessageId = 0;
  late final MessageBloc _bloc;
  final List<UploadAttachment> _attachments = <UploadAttachment>[];
  bool _composerSendInFlight = false;
  ChatMessageModel? _replyingTo;
  Timer? _presenceTimer;
  bool? _peerOnline;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _bloc = context.read<MessageBloc>();
    _scrollCtrl.addListener(_onScroll);
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
    _scrollCtrl.removeListener(_onScroll);
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
      attachments: List<UploadAttachment>.unmodifiable(_attachments),
      replyToMessageId: _replyingTo?.id,
    );
    if (!request.isValid) return;
    _composerSendInFlight = true;
    _bloc.add(SendMessageEvent(widget.conversation.id, request));
  }

  Future<void> _pickAttachments() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null || !mounted) return;
    final availableSlots = ChatSendRequest.maxFiles - _attachments.length;
    final bool exceededLimit = result.files.length > availableSlots;
    final List<UploadAttachment> accepted = <UploadAttachment>[];
    String? validationMessage;
    const UploadPolicy policy = UploadPolicy(
      allowedExtensions: ChatSendRequest.allowedExtensions,
      maxInputBytes: ChatSendRequest.maxFileBytes,
    );
    for (final PlatformFile file in result.files.take(availableSlots)) {
      try {
        final Uint8List? pickedBytes = file.bytes;
        accepted.add(
          pickedBytes != null && pickedBytes.isNotEmpty
              ? await normalizeUploadAttachment(
                  bytes: pickedBytes,
                  filename: file.name,
                  sourcePath: file.path,
                  originalSize: file.size,
                  policy: policy,
                )
              : await loadUploadAttachment(
                  path: file.path ?? '',
                  filename: file.name,
                  policy: policy,
                ),
        );
      } on UploadValidationException catch (error) {
        validationMessage ??= error.message;
      }
    }
    if (!mounted) return;
    setState(() {
      final Set<String> known = _attachments.map(_attachmentKey).toSet();
      for (final file in accepted) {
        if (_attachments.length >= ChatSendRequest.maxFiles) break;
        if (known.add(_attachmentKey(file))) _attachments.add(file);
      }
    });
    if (validationMessage != null) {
      AppUtils().showSnackBar(context, MsgType.error, validationMessage);
    }
    if (exceededLimit) {
      AppUtils().showSnackBar(
        context,
        MsgType.info,
        'A message can contain at most 5 files.',
      );
    }
  }

  String _attachmentKey(UploadAttachment attachment) =>
      '${attachment.sourcePath ?? attachment.filename}:${attachment.originalSize}';

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
      case _ConversationActionType.groupInfo:
        await _openGroupProfile(conversation);
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

  /// The group behind this chat: its picture, name and members, plus leaving
  /// it. Opened by tapping the header — the gesture that opens the other
  /// person's profile in a direct chat.
  ///
  /// Leaving pops this chat too: the thread is no longer the user's to read.
  Future<void> _openGroupProfile(ConversationModel group) async {
    final bool left = await openGroupProfilePage(
      context: context,
      conversation: group,
    );
    if (!left || !mounted) return;

    DashboardScreen.selectedNavIndex.value = 2;
    context.goNamed(AppRouterParams.dashboard.name);
  }

  /// The list is reversed, so its max scroll extent is the *top* of the
  /// thread — that is where the next page of older messages is requested.
  void _onScroll() {
    if (!_scrollCtrl.hasClients || _bloc.isClosed) return;
    final position = _scrollCtrl.position;
    if (position.pixels < position.maxScrollExtent - 240) return;
    _loadOlder();
  }

  void _loadOlder() {
    final state = _bloc.state;
    if (_bloc.isClosed ||
        state.messagesLoadingOlder ||
        !state.messagesHasMorePages ||
        state.messagesLoadOlderError != null) {
      return;
    }
    _bloc.add(LoadOlderMessagesEvent(widget.conversation.id));
  }

  void _retryLoadOlder() {
    if (_bloc.isClosed) return;
    _bloc.add(LoadOlderMessagesEvent(widget.conversation.id));
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
        onOpenGroupProfile: _openGroupProfile,
      ),
      body: SafeArea(
        top: false,
        child: BlocConsumer<MessageBloc, MessageState>(
          buildWhen: (MessageState previous, MessageState current) =>
              previous.chatStatus != current.chatStatus ||
              previous.activeConversation != current.activeConversation ||
              previous.messages != current.messages ||
              previous.sending != current.sending ||
              previous.peerTyping != current.peerTyping ||
              previous.messagesLoadingOlder != current.messagesLoadingOlder ||
              previous.messagesHasMorePages != current.messagesHasMorePages ||
              previous.messagesLoadOlderError != current.messagesLoadOlderError,
          listenWhen: (prev, curr) =>
              curr.messages.length > prev.messages.length ||
              curr.actionMessage != prev.actionMessage ||
              (prev.actionBusy &&
                  !curr.actionBusy &&
                  curr.errorMessage != prev.errorMessage) ||
              (prev.sending && !curr.sending),
          listener: (context, state) {
            if (_composerSendInFlight && !state.sending) {
              final bool succeeded = state.errorMessage == null;
              setState(() {
                if (succeeded) {
                  _attachments.clear();
                  _replyingTo = null;
                }
                _composerSendInFlight = false;
              });
            }
            // Only follow the thread down for genuinely new messages at the
            // bottom; a prepended history page must leave the viewport alone.
            final newestId = state.messages.isEmpty
                ? 0
                : state.messages.last.id;
            if (newestId != _newestMessageId) {
              _newestMessageId = newestId;
              _scrollToBottom();
            }
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
                  onAttach: state.sending ? null : _showAddMenu,
                  attachmentNames: _attachments
                      .map((file) => file.name)
                      .toList(growable: false),
                  onRemoveAttachment: state.sending
                      ? null
                      : (index) => setState(() => _attachments.removeAt(index)),
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
    final reversed = entries.reversed.toList();
    // Last in a reversed list renders at the top of the thread. The strip is
    // reserved as soon as older pages exist — not only while one is in flight —
    // so the spinner fades in at a spot already on screen instead of being
    // inserted above the viewport, and the scroll extent never jumps.
    if (state.messagesHasMorePages ||
        state.messagesLoadingOlder ||
        state.messagesLoadOlderError != null) {
      reversed.add(_loadOlderEntry);
    }

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
        if (identical(entry, _loadOlderEntry)) {
          return _OlderMessagesHeader(
            loading: state.messagesLoadingOlder,
            error: state.messagesLoadOlderError,
            onRetry: _retryLoadOlder,
          );
        }

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

/// Top-of-thread strip: the older-history spinner, or a retry row when that
/// page failed.
class _OlderMessagesHeader extends StatelessWidget {
  const _OlderMessagesHeader({
    required this.loading,
    required this.error,
    required this.onRetry,
  });

  final bool loading;
  final String? error;
  final VoidCallback onRetry;

  /// Height the idle strip holds so the spinner does not shift the thread.
  static const double _stripHeight = 22;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX12,
      ),
      child: Center(
        child: error == null
            // The app's spinner. `LoadingWidget` itself wraps this in a
            // Scaffold, which cannot sit inline in a list row.
            ? AnimatedOpacity(
                opacity: loading ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: CustomLoading(
                  color: LightColor.secondaryColor,
                  size: _stripHeight,
                  strokeWidth: 2.5,
                  secondCircleColor: LightColor.secondaryLight,
                  thirdCircleColor: LightColor.secondaryLight,
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: Text(StringConstants.retry),
                    style: TextButton.styleFrom(
                      foregroundColor: LightColor.secondaryColor,
                    ),
                  ),
                ],
              ),
      ),
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
    required this.onOpenGroupProfile,
  });

  final ConversationModel conversation;
  final bool? peerOnline;
  final VoidCallback onActions;
  final ValueChanged<ConversationModel> onOpenGroupProfile;

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

          // Tapping the header opens who this chat is with: the other user's
          // view-only profile in a direct chat, the group's own page in a
          // group — name, picture, members and leaving it.
          if (active.isGroup) {
            return InkWell(
              onTap: () => onOpenGroupProfile(active),
              child: Semantics(
                button: true,
                label: StringConstants.groupInfo,
                child: header,
              ),
            );
          }
          if (peer == null || peer.userId <= 0) return header;
          return InkWell(
            onTap: () => openUserProfilePage(
              context: context,
              userId: peer.userId,
              fallbackName: title,
              fallbackImageUrl: avatar,
              // This chat *is* the conversation with them; a Message button
              // here would only lead back one route.
              canMessage: false,
              isOnline: peerOnline,
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

enum _ConversationActionType { mute, archive, block, addMembers, groupInfo }

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
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text(StringConstants.groupInfo),
            onTap: () => Navigator.of(
              context,
            ).pop(const _ConversationAction(_ConversationActionType.groupInfo)),
          ),
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
        // Group chats keep only the actions that apply to the thread here.
        // The member list — and blocking one of them — moved to the group's
        // own page, reached by tapping the chat header, where there is room
        // for all of them rather than a strip of a sheet.
        if (!conversation.isGroup && participants.isNotEmpty) ...[
          const Divider(),
          for (final participant in participants)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
