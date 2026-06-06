import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/message_model.dart';

/// One conversation: avatar + name + activity, message preview and the
/// reply / mark-read quick actions.
class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onReply,
    required this.onMarkRead,
  });

  final MessageModel item;
  final VoidCallback onTap;
  final VoidCallback onReply;
  final VoidCallback onMarkRead;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isUnread = item.isUnread;

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX14),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(
              color: isUnread
                  ? LightColor.secondaryColor.withValues(alpha: 0.18)
                  : LightColor.dividerColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX14,
            AppDimens.paddingX14,
            AppDimens.paddingX14,
            AppDimens.paddingX8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context),
              const SizedBox(height: AppDimens.paddingX10),
              Text(
                item.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: isUnread
                      ? LightColor.primaryTextColor
                      : LightColor.secondaryTextColor,
                  fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppDimens.paddingX12),
              const Divider(
                height: 1,
                thickness: 1,
                color: LightColor.dividerColor,
              ),
              _actionRow(context, isUnread: isUnread),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isUnread = item.isUnread;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _Avatar(url: item.avatarUrl, isActive: item.isActive),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: isUnread
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ),
                  if (item.isBooking) ...[
                    const SizedBox(width: AppDimens.paddingX6),
                    const _BookingTag(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    item.isActive ? Icons.circle : Icons.access_time_rounded,
                    size: 9,
                    color: item.isActive
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                  ),
                  const SizedBox(width: AppDimens.paddingX4),
                  Text(
                    item.isActive ? 'Active now · ${item.time}' : item.time,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        if (isUnread) _UnreadBadge(count: item.unreadCount),
      ],
    );
  }

  Widget _actionRow(BuildContext context, {required bool isUnread}) {
    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.reply_rounded,
            label: 'Reply',
            onTap: onReply,
          ),
        ),
        Container(width: 1, height: 18, color: LightColor.dividerColor),
        Expanded(
          child: _QuickAction(
            icon: isUnread
                ? Icons.mark_email_read_outlined
                : Icons.check_circle_outline_rounded,
            label: isUnread ? 'Mark read' : 'Read',
            onTap: isUnread ? onMarkRead : null,
            emphasised: isUnread,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.emphasised = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool enabled = onTap != null;
    final Color color = !enabled
        ? LightColor.disabledTextColor
        : (emphasised
              ? LightColor.secondaryColor
              : LightColor.secondaryTextColor);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: AppDimens.sizeX16, color: color),
            const SizedBox(width: AppDimens.paddingX6),
            Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: color,
                fontWeight: emphasised ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingTag extends StatelessWidget {
  const _BookingTag();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.sports_soccer_rounded,
            size: 10,
            color: LightColor.secondaryColor,
          ),
          const SizedBox(width: 3),
          Text(
            'Booking',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.isActive});

  final String url;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: CustomImageView(
            url: url,
            width: 44,
            height: 44,
            fit: BoxFit.cover,
          ),
        ),
        if (isActive)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: LightColor.cardColor, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: LightColor.whiteColor,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
