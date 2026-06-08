import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';
import 'package:hamro_footsall/features/message/presentation/utils/message_fmt.dart';

/// One chat bubble — mine: filled accent, right-aligned with delivery ticks;
/// theirs: white card, left-aligned (sender name shown in groups).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showSender = false,
  });

  final ChatMessageModel message;
  final bool isMe;

  /// Show the sender's name above the bubble (group chats).
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * 0.76,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX12,
        AppDimens.paddingX10,
        AppDimens.paddingX12,
        AppDimens.paddingX6,
      ),
      decoration: BoxDecoration(
        color: isMe ? LightColor.secondaryColor : LightColor.cardColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(AppDimens.radiusX14),
          topRight: const Radius.circular(AppDimens.radiusX14),
          // Small "tail" corner on the sender's side.
          bottomLeft: Radius.circular(isMe ? AppDimens.radiusX14 : 4),
          bottomRight: Radius.circular(isMe ? 4 : AppDimens.radiusX14),
        ),
        boxShadow: const [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSender && !isMe)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName,
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w700,
                    color: LightColor.secondaryColor,
                  ),
                ),
              ),
            ),
          if (message.body.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.body,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isMe
                      ? LightColor.whiteColor
                      : LightColor.primaryTextColor,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ),
          // Attachments as compact file chips (streamed via authed API).
          for (final m in message.media)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _MediaChip(media: m, isMe: isMe),
              ),
            ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited)
                Text(
                  'edited · ',
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: isMe
                        ? LightColor.whiteColor.withValues(alpha: 0.7)
                        : LightColor.hintTextColor,
                  ),
                ),
              Text(
                MessageFmt.clock(message.createdAt),
                style: textTheme.bodyTextSmall?.copyWith(
                  fontSize: 10,
                  color: isMe
                      ? LightColor.whiteColor.withValues(alpha: 0.75)
                      : LightColor.hintTextColor,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: AppDimens.paddingX4),
                Icon(
                  message.isRead
                      ? Icons.done_all_rounded
                      : Icons.done_rounded,
                  size: 13,
                  color: LightColor.whiteColor.withValues(alpha: 0.85),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX16,
        vertical: AppDimens.paddingX4,
      ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    );
  }
}

/// Attachment row inside a bubble: type icon, file name and size.
class _MediaChip extends StatelessWidget {
  const _MediaChip({required this.media, required this.isMe});

  final ChatMediaModel media;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final fg = isMe ? LightColor.whiteColor : LightColor.secondaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: (isMe ? LightColor.whiteColor : LightColor.secondaryColor)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            media.isImage
                ? Icons.image_outlined
                : Icons.insert_drive_file_outlined,
            size: 15,
            color: fg,
          ),
          const SizedBox(width: AppDimens.paddingX6),
          Flexible(
            child: Text(
              media.humanReadableSize.isEmpty
                  ? media.name
                  : '${media.name} · ${media.humanReadableSize}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextSmall?.copyWith(
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w600,
                color: isMe ? LightColor.whiteColor : LightColor.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centered day separator chip (`Today`, `Yesterday`, `2 Jun`).
class ChatDayChip extends StatelessWidget {
  const ChatDayChip({super.key, required this.date});

  final DateTime date;

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String get _label {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${day.day} ${_months[day.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppDimens.paddingX10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: LightColor.dividerColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        ),
        child: Text(
          _label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            fontSize: AppDimens.fontBodySubTitle,
            fontWeight: FontWeight.w600,
            color: LightColor.secondaryTextColor,
          ),
        ),
      ),
    );
  }
}
