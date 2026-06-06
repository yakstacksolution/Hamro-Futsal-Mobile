import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/chat_message_model.dart';

/// One chat bubble — mine: filled accent, right-aligned with read receipt;
/// theirs: white card, left-aligned.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessageModel message;

  String get _time {
    final t = message.sentAt;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isMe = message.isMe;

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
        border: isMe ? null : Border.all(color: LightColor.dividerColor),
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              message.text,
              style: textTheme.bodyTextSmall?.copyWith(
                color: isMe
                    ? LightColor.whiteColor
                    : LightColor.primaryTextColor,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _time,
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
                  message.seen ? Icons.done_all_rounded : Icons.done_rounded,
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
