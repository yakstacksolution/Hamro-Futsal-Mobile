import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/message/data/model/conversation_model.dart';
import 'package:hamro_footsall/features/message/presentation/utils/message_fmt.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.conversation,
    required this.currentUserId,
    required this.onTap,
    this.onAcceptInvitation,
    this.onDeclineInvitation,
    this.invitationBusy = false,
  });

  final ConversationModel conversation;
  final int currentUserId;
  final VoidCallback onTap;

  /// Answering a pending group invitation. Both are null on rows that carry
  /// no invitation, which is what keeps the footer off ordinary threads.
  final VoidCallback? onAcceptInvitation;
  final VoidCallback? onDeclineInvitation;

  /// A response is in flight — the buttons go quiet so one tap cannot be
  /// filed twice.
  final bool invitationBusy;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isUnread = conversation.isUnread;
    final bool pendingInvite = conversation.isInvitePending;
    final title = conversation.displayTitle(currentUserId);
    final isOnline = conversation.isPeerOnline(currentUserId);

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        // An unanswered invitation is not a thread yet: the row states the
        // invitation and offers the two answers instead of opening a chat the
        // server would refuse to serve.
        onTap: pendingInvite ? null : onTap,
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: pendingInvite
                  ? LightColor.secondaryColor.withValues(alpha: 0.45)
                  : isUnread
                  ? LightColor.secondaryColor.withValues(alpha: 0.18)
                  : LightColor.dividerColor,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppDimens.paddingX14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
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
                              Icon(
                                Icons.push_pin_rounded,
                                size: 12,
                                color: LightColor.hintTextColor,
                              ),
                            ],
                            if (conversation.isMuted) ...[
                              const SizedBox(width: AppDimens.paddingX4),
                              Icon(
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
                          pendingInvite
                              ? StringConstants.groupInvitationPrompt
                              : conversation.preview(currentUserId),
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
              if (pendingInvite) ...[
                const SizedBox(height: AppDimens.paddingX12),
                Divider(color: LightColor.dividerColor, height: 1),
                const SizedBox(height: AppDimens.paddingX10),
                _InvitationActions(
                  busy: invitationBusy,
                  onAccept: conversation.canAcceptInvitation
                      ? onAcceptInvitation
                      : null,
                  onDecline: conversation.canDeclineInvitation
                      ? onDeclineInvitation
                      : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The two answers to a group invitation, shown under the row that carries it.
class _InvitationActions extends StatelessWidget {
  const _InvitationActions({
    required this.busy,
    required this.onAccept,
    required this.onDecline,
  });

  final bool busy;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onDecline != null)
          Expanded(
            child: _InviteButton(
              label: StringConstants.decline,
              icon: Icons.close_rounded,
              onTap: busy ? null : onDecline,
            ),
          ),
        if (onDecline != null && onAccept != null)
          const SizedBox(width: AppDimens.paddingX8),
        if (onAccept != null)
          Expanded(
            child: _InviteButton(
              label: StringConstants.accept,
              icon: Icons.check_rounded,
              filled: true,
              onTap: busy ? null : onAccept,
            ),
          ),
      ],
    );
  }
}

class _InviteButton extends StatelessWidget {
  const _InviteButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final Color accent = filled
        ? LightColor.secondaryColor
        : LightColor.secondaryTextColor;
    final Color foreground = filled ? LightColor.onBrandSurface : accent;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: filled ? accent : accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            height: AppDimens.sizeX36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              border: filled
                  ? null
                  : Border.all(color: accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppDimens.sizeX16, color: foreground),
                const SizedBox(width: AppDimens.paddingX6),
                Text(
                  label,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: foreground,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
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
              color: isOnline ? LightColor.successColor : LightColor.iconGrey,
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
      color: isOnline ? LightColor.successColor : LightColor.hintTextColor,
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
        StringConstants.group,
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
        style: TextStyle(
          color: LightColor.inverseTextColor,
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
      ),
    );
  }
}
