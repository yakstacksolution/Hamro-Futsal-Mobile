import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/data_source/message_data_source.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/data/model/message_model.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_bubble.dart';
import 'package:hamro_footsall/features/message/presentation/widgets/chat_input_bar.dart';

/// One conversation thread: contact header, date-grouped chat bubbles and
/// the message composer.
class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
    required this.conversation,
    this.dataSource,
    this.autofocusComposer = false,
  });

  final MessageModel conversation;
  final MessageDataSource? dataSource;

  /// Opens with the keyboard up (used by the list's "Reply" quick action).
  final bool autofocusComposer;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final MessageDataSource _dataSource =
      widget.dataSource ?? MessageLocalDataSourceImpl();
  final _scrollCtrl = ScrollController();
  late final _composerFocus = FocusNode();

  List<ChatMessageModel> _messages = const [];

  @override
  void initState() {
    super.initState();
    _dataSource.fetchChat(widget.conversation).then((messages) {
      if (mounted) setState(() => _messages = messages);
    });
    if (widget.autofocusComposer) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _composerFocus.requestFocus(),
      );
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _composerFocus.dispose();
    super.dispose();
  }

  void _send(String text) {
    setState(() {
      _messages = [
        ..._messages,
        ChatMessageModel(
          id: 'c${DateTime.now().microsecondsSinceEpoch}',
          text: text,
          sentAt: DateTime.now(),
          isMe: true,
        ),
      ];
    });
    // The list is reversed, so the newest message sits at offset 0.
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

  /// Thread entries (bubbles + day chips) in chronological order.
  List<Widget> _buildEntries() {
    final entries = <Widget>[];
    DateTime? lastDay;
    for (final m in _messages) {
      final day = DateTime(m.sentAt.year, m.sentAt.month, m.sentAt.day);
      if (lastDay == null || day != lastDay) {
        entries.add(ChatDayChip(date: m.sentAt));
        lastDay = day;
      }
      entries.add(ChatBubble(message: m));
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final entries = _buildEntries().reversed.toList(growable: false);

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: _ChatAppBar(conversation: widget.conversation),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingX12,
                ),
                itemCount: entries.length,
                itemBuilder: (_, i) => entries[i],
              ),
            ),
            ChatInputBar(onSend: _send, focusNode: _composerFocus),
          ],
        ),
      ),
    );
  }
}

/// Contact header: avatar with presence dot, name, activity line and the
/// booking tag when relevant.
class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.conversation});

  final MessageModel conversation;

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
      title: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipOval(
                child: CustomImageView(
                  url: conversation.avatarUrl,
                  width: 38,
                  height: 38,
                  fit: BoxFit.cover,
                ),
              ),
              if (conversation.isActive)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: LightColor.cardColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  conversation.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  conversation.isActive
                      ? 'Active now'
                      : 'Last seen ${conversation.time}',
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    color: conversation.isActive
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (conversation.isBooking)
          Container(
            margin: const EdgeInsets.only(right: AppDimens.paddingX12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sports_soccer_rounded,
                  size: 12,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: 3),
                Text(
                  'Booking',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
