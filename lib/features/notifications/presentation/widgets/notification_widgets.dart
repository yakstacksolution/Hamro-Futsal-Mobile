import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_menu_item.dart';
import 'package:hamro_footsall/features/notifications/data/model/notification_model.dart';
import 'package:hamro_footsall/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_footsall/features/notifications/presentation/bloc/notification_bloc.dart';

class NotificationFilterBar extends StatelessWidget {
  const NotificationFilterBar({
    super.key,
    required this.selectedFilter,
    required this.unreadCount,
    required this.onChanged,
  });

  final NotificationFilter selectedFilter;
  final int unreadCount;
  final ValueChanged<NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.sizeX42,
      padding: const EdgeInsets.all(AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _FilterButton(
              label: StringConstants.all,
              selected: selectedFilter == NotificationFilter.all,
              onTap: () => onChanged(NotificationFilter.all),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX4),
          Expanded(
            child: _FilterButton(
              label: StringConstants.unread,
              selected: selectedFilter == NotificationFilter.unread,
              count: unreadCount,
              onTap: () => onChanged(NotificationFilter.unread),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: selected
                ? LightColor.secondaryColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                label,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: selected
                      ? LightColor.secondaryColor
                      : LightColor.secondaryTextColor,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (count != null && count! > 0) ...<Widget>[
                const SizedBox(width: AppDimens.sizeX4),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: AppDimens.sizeX18,
                    minHeight: AppDimens.sizeX18,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.paddingX6,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? LightColor.secondaryColor
                        : LightColor.inputFillColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                  ),
                  child: Text(
                    count.toString(),
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: selected
                          ? LightColor.inverseTextColor
                          : LightColor.secondaryTextColor,
                      fontSize: AppDimens.fontBodySubTitle,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationSection extends StatelessWidget {
  const NotificationSection({
    super.key,
    required this.title,
    required this.notifications,
  });

  final String title;
  final List<NotificationModel> notifications;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.paddingX2,
            bottom: AppDimens.paddingX8,
          ),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                  fontSize: AppDimens.fontBodyTextSmall,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(
                notifications.length.toString(),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: Column(
            children: <Widget>[
              for (int index = 0; index < notifications.length; index++) ...[
                NotificationTile(notification: notifications[index]),
                if (index < notifications.length - 1)
                  const Divider(
                    height: AppDimens.sizeX1,
                    thickness: AppDimens.sizeX1,
                    indent: AppDimens.sizeX60,
                    color: LightColor.dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isRead = notification.isRead;
    final Color accent = _accentColor(notification.type);
    final String title = notification.title.isNotEmpty
        ? notification.title
        : StringConstants.notifications;
    final NotificationBloc bloc = context.read<NotificationBloc>();

    return Semantics(
      button: true,
      label: '$title. ${notification.body}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isRead
              ? null
              : () => bloc.add(MarkNotificationReadEvent(notification.id)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.fromLTRB(
              AppDimens.paddingX12,
              AppDimens.paddingX12,
              AppDimens.paddingX4,
              AppDimens.paddingX12,
            ),
            color: isRead
                ? LightColor.cardColor
                : LightColor.secondaryColor.withValues(alpha: 0.035),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX36,
                  height: AppDimens.sizeX36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isRead ? 0.07 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _iconFor(notification.type),
                    color: accent,
                    size: AppDimens.sizeX18,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextMedium?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontSize: AppDimens.fontBodyTextMedium,
                                fontWeight: isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!isRead) ...<Widget>[
                            const SizedBox(width: AppDimens.sizeX6),
                            Container(
                              width: AppDimens.sizeX6,
                              height: AppDimens.sizeX6,
                              margin: const EdgeInsets.only(
                                top: AppDimens.marginX4,
                              ),
                              decoration: const BoxDecoration(
                                color: LightColor.secondaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (notification.body.isNotEmpty) ...<Widget>[
                        const SizedBox(height: AppDimens.sizeX4),
                        Text(
                          notification.body,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.secondaryTextColor,
                            height: 1.42,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppDimens.sizeX6),
                      Text(
                        _timeAgo(notification.createdAt),
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _NotificationMenu(notification: notification),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationMenu extends StatelessWidget {
  const _NotificationMenu({required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {
    final NotificationBloc bloc = context.read<NotificationBloc>();
    return PopupMenuButton<bool>(
      key: Key('notification-menu-${notification.id}'),
      tooltip: '',
      padding: EdgeInsets.zero,
      color: LightColor.cardColor,
      surfaceTintColor: LightColor.cardColor,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        side: const BorderSide(color: LightColor.dividerColor),
      ),
      icon: const Icon(
        Icons.more_vert_rounded,
        color: LightColor.hintTextColor,
        size: AppDimens.sizeX18,
      ),
      onSelected: (bool markRead) {
        if (markRead) {
          bloc.add(MarkNotificationReadEvent(notification.id));
        } else {
          bloc.add(MarkNotificationUnreadEvent(notification.id));
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<bool>>[
        if (!notification.isRead)
          const PopupMenuItem<bool>(
            value: true,
            child: CustomMenuItem(label: StringConstants.markAsRead),
          )
        else
          const PopupMenuItem<bool>(
            value: false,
            child: CustomMenuItem(label: StringConstants.markAsUnread),
          ),
      ],
    );
  }
}

class NotificationEmptyView extends StatelessWidget {
  const NotificationEmptyView({super.key, required this.unreadOnly});

  final bool unreadOnly;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX80,
              height: AppDimens.sizeX80,
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX36,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX18),
            Text(
              unreadOnly
                  ? StringConstants.noUnreadNotifications
                  : StringConstants.noNotificationsYet,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX8),
            Text(
              unreadOnly
                  ? StringConstants.youHaveReadEveryNotification
                  : StringConstants.notificationsWillAppearHere,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationErrorView extends StatelessWidget {
  const NotificationErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX80,
              height: AppDimens.sizeX80,
              decoration: BoxDecoration(
                color: LightColor.redColor.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: AppDimens.sizeX36,
                color: LightColor.redColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Text(
              StringConstants.somethingWentWrong,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX20),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Text(
                  StringConstants.tryAgain,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSkeletonLoader extends StatefulWidget {
  const NotificationSkeletonLoader({super.key});

  @override
  State<NotificationSkeletonLoader> createState() =>
      _NotificationSkeletonLoaderState();
}

class _NotificationSkeletonLoaderState extends State<NotificationSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: _anim.value,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            0,
            AppDimens.paddingX20,
            0,
          ),
          itemCount: 6,
          separatorBuilder: (_, __) =>
              const SizedBox(height: AppDimens.paddingX12),
          itemBuilder: (_, __) => Container(
            height: 84,
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            decoration: BoxDecoration(
              color: LightColor.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX16),
              border: Border.all(color: LightColor.dividerColor),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _Bone(width: 44, height: 44, radius: 22),
                const SizedBox(width: AppDimens.sizeX14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      _Bone(width: 140, height: 12),
                      SizedBox(height: 10),
                      _Bone(width: double.infinity, height: 10),
                      SizedBox(height: 8),
                      _Bone(width: 80, height: 9),
                    ],
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

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.radius = 4});
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.dividerColor,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ── Presentation helpers ──

IconData _iconFor(String type) {
  final String t = type.toLowerCase();
  if (t.contains('booking')) return Icons.event_available_rounded;
  if (t.contains('payment')) return Icons.account_balance_wallet_rounded;
  if (t.contains('message') || t.contains('chat')) {
    return Icons.chat_bubble_rounded;
  }
  if (t.contains('opponent') || t.contains('match')) {
    return Icons.sports_soccer_rounded;
  }
  if (t.contains('offer') || t.contains('promo') || t.contains('coupon')) {
    return Icons.local_offer_rounded;
  }
  return Icons.notifications_rounded;
}

Color _accentColor(String type) {
  final String t = type.toLowerCase();
  if (t.contains('payment')) return LightColor.purpleColor;
  if (t.contains('message') || t.contains('chat')) return LightColor.blueColor;
  if (t.contains('opponent') || t.contains('match')) {
    return LightColor.blueColor;
  }
  if (t.contains('offer') || t.contains('promo') || t.contains('coupon')) {
    return LightColor.yellowColor;
  }
  return LightColor.secondaryColor;
}

String _timeAgo(DateTime? date) {
  if (date == null) return '';
  final Duration diff = DateTime.now().difference(date);
  if (diff.inSeconds < 60) return StringConstants.justNow;
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes} min ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
  }
  const List<String> months = <String>[
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
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
