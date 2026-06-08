import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/presentation/bloc/message_bloc/message_bloc.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_bubble.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_input_bar.dart';

/// One conversation thread driven by [MessageBloc]: messages from
/// `GET /conversations/{id}/messages`, sending via the multipart endpoint,
/// typing broadcast and realtime updates via the socket service.
class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.conversation});

  final ConversationModel conversation;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<MessageBloc>().add(LoadChatEvent(widget.conversation.id));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Leaving the thread: drop socket subscriptions and refresh the inbox.
    // The bloc may already be closed when it was page-scoped (ChatLauncher).
    final bloc = context.read<MessageBloc>();
    if (!bloc.isClosed) bloc.add(const CloseChatEvent());
    super.deactivate();
  }

  void _send(String text) {
    context
        .read<MessageBloc>()
        .add(SendMessageEvent(widget.conversation.id, text));
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
      appBar: _ChatAppBar(conversation: widget.conversation),
      body: SafeArea(
        top: false,
        child: BlocConsumer<MessageBloc, MessageState>(
          listenWhen: (prev, curr) =>
              curr.messages.length > prev.messages.length,
          listener: (context, state) => _scrollToBottom(),
          builder: (context, state) {
            return Column(
              children: [
                Expanded(child: _thread(state)),
                ChatInputBar(
                  onSend: _send,
                  sending: state.sending,
                  onTypingChanged: (typing) => context
                      .read<MessageBloc>()
                      .add(SendTypingEvent(widget.conversation.id, typing)),
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
          LoadChatEvent(widget.conversation.id),
        ),
      );
    }
    if (state.messages.isEmpty) {
      return const _EmptyThread();
    }

    // Bubbles + day chips, newest at the bottom (reversed list keeps the
    // viewport pinned there).
    final entries = <Widget>[];
    DateTime? lastDay;
    for (final m in state.messages) {
      final day = DateTime(m.createdAt.year, m.createdAt.month, m.createdAt.day);
      if (lastDay == null || day != lastDay) {
        entries.add(ChatDayChip(date: m.createdAt));
        lastDay = day;
      }
      entries.add(
        ChatBubble(
          message: m,
          isMe: m.isMine(state.currentUserId),
          showSender: widget.conversation.isGroup,
        ),
      );
    }
    if (state.peerTyping) entries.add(const _TypingBubble());
    final reversed = entries.reversed.toList(growable: false);

    return ListView.builder(
      controller: _scrollCtrl,
      reverse: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX12),
      itemCount: reversed.length,
      itemBuilder: (_, i) => reversed[i],
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
            boxShadow: const [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 6,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            'typing…',
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
              'No messages yet',
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              'Say hello and start the conversation.',
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
            const Icon(
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
              text: 'Retry',
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
  const _ChatAppBar({required this.conversation});

  final ConversationModel conversation;

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
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: LightColor.primaryTextColor,
        ),
      ),
      title: BlocBuilder<MessageBloc, MessageState>(
        builder: (context, state) {
          final title = conversation.displayTitle(state.currentUserId);
          final avatar = conversation.displayAvatar(state.currentUserId);
          final String subtitle;
          if (state.peerTyping) {
            subtitle = 'typing…';
          } else if (conversation.isGroup) {
            final n = conversation.participants.length;
            subtitle = '$n ${n == 1 ? 'member' : 'members'}';
          } else {
            final role =
                conversation.otherParticipant(state.currentUserId)?.role ?? '';
            subtitle = role.isEmpty ? 'Direct message' : role;
          }

          return Row(
            children: [
              if (conversation.isGroup || avatar.isEmpty)
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: LightColor.secondaryColor.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: conversation.isGroup
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
        },
      ),
    );
  }
}
