import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/presentation/utils/message_fmt.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
  });

  final ConversationModel conversation;
  final int currentUserId;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isUnread = conversation.isUnread;
    final title = conversation.displayTitle(currentUserId);
    final isOnline = conversation.isPeerOnline(currentUserId);

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
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
          padding: const EdgeInsets.all(AppDimens.paddingX14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                title: title,
                url: conversation.displayAvatar(currentUserId),
                isGroup: conversation.isGroup,
                isOnline: isOnline,
              ),
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
                            title,
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
                        if (conversation.isPinned) ...[
                          const SizedBox(width: AppDimens.paddingX6),
                          const Icon(
                            Icons.push_pin_rounded,
                            size: 12,
                            color: LightColor.hintTextColor,
                          ),
                        ],
                        if (conversation.isMuted) ...[
                          const SizedBox(width: AppDimens.paddingX4),
                          const Icon(
                            Icons.volume_off_rounded,
                            size: 12,
                            color: LightColor.hintTextColor,
                          ),
                        ],
                        if (conversation.isGroup) ...[
                          const SizedBox(width: AppDimens.paddingX6),
                          const _GroupTag(),
                        ] else ...[
                          const SizedBox(width: AppDimens.paddingX6),
                          _PresenceLabel(isOnline: isOnline),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      conversation.preview(currentUserId),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: isUnread
                            ? LightColor.primaryTextColor
                            : LightColor.secondaryTextColor,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    MessageFmt.friendly(
                      conversation.lastMessageAt ?? conversation.createdAt,
                    ),
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontSize: AppDimens.fontBodySubTitle,
                      color: isUnread
                          ? LightColor.secondaryColor
                          : LightColor.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (isUnread)
                    _UnreadBadge(count: conversation.unreadCount)
                  else
                    const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.title,
    required this.url,
    required this.isGroup,
    required this.isOnline,
  });

  final String title;
  final String url;
  final bool isGroup;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    if (isGroup || url.isEmpty) {
      return _withPresence(
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: isGroup
              ? const Icon(
                  Icons.groups_2_outlined,
                  size: 22,
                  color: LightColor.secondaryColor,
                )
              : Text(
                  title.isEmpty ? '?' : title.substring(0, 1).toUpperCase(),
                  style: FutsalTheme.getTextTheme(context).bodyTextMedium
                      ?.copyWith(
                        color: LightColor.secondaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
        ),
      );
    }
    return _withPresence(
      ClipOval(
        child: CustomImageView(
          url: url,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _withPresence(Widget avatar) => Stack(
    clipBehavior: Clip.none,
    children: [
      avatar,
      if (!isGroup)
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: LightColor.cardColor, width: 2),
            ),
          ),
        ),
    ],
  );
}

class _PresenceLabel extends StatelessWidget {
  const _PresenceLabel({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) => Text(
    isOnline ? 'Online' : 'Offline',
    style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
      color: isOnline ? Colors.green : LightColor.hintTextColor,
      fontSize: AppDimens.fontBodySubTitle,
      fontWeight: FontWeight.w500,
    ),
  );
}

class _GroupTag extends StatelessWidget {
  const _GroupTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      ),
      child: Text(
        'Group',
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.secondaryColor,
          fontWeight: FontWeight.w600,
          fontSize: AppDimens.fontBodySubTitle,
        ),
      ),
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
