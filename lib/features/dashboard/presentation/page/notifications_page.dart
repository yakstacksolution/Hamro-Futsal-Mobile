import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const List<_NotificationData> _notifications = <_NotificationData>[
    _NotificationData(
      id: 'booking-confirmed',
      title: StringConstants.bookingConfirmed,
      body: StringConstants.bookingConfirmedNotification,
      timeLabel: StringConstants.twoMinutesAgo,
      icon: Icons.event_available_rounded,
      accentColor: LightColor.secondaryColor,
      isToday: true,
    ),
    _NotificationData(
      id: 'new-message',
      title: StringConstants.newMessage,
      body: StringConstants.newMessageNotification,
      timeLabel: StringConstants.twentyMinutesAgo,
      icon: Icons.chat_bubble_rounded,
      accentColor: LightColor.blueColor,
      isToday: true,
    ),
    _NotificationData(
      id: 'payment-received',
      title: StringConstants.paymentReceived,
      body: StringConstants.paymentReceivedNotification,
      timeLabel: StringConstants.oneHourAgo,
      icon: Icons.account_balance_wallet_rounded,
      accentColor: LightColor.purpleColor,
      isToday: true,
    ),
    _NotificationData(
      id: 'match-reminder',
      title: StringConstants.matchReminder,
      body: StringConstants.matchReminderNotification,
      timeLabel: StringConstants.yesterday,
      icon: Icons.sports_soccer_rounded,
      accentColor: LightColor.yellowColor,
      isToday: false,
      initiallyRead: true,
    ),
    _NotificationData(
      id: 'opponent-request',
      title: StringConstants.opponentRequestReceived,
      body: StringConstants.opponentRequestNotification,
      timeLabel: StringConstants.yesterday,
      icon: Icons.groups_rounded,
      accentColor: LightColor.blueColor,
      isToday: false,
      initiallyRead: true,
    ),
    _NotificationData(
      id: 'weekend-offer',
      title: StringConstants.weekendOffer,
      body: StringConstants.weekendOfferNotification,
      timeLabel: StringConstants.twoDaysAgo,
      icon: Icons.local_offer_rounded,
      accentColor: LightColor.purpleColor,
      isToday: false,
      initiallyRead: true,
    ),
  ];

  late final Set<String> _readNotificationIds = <String>{
    for (final _NotificationData notification in _notifications)
      if (notification.initiallyRead) notification.id,
  };

  _NotificationFilter _selectedFilter = _NotificationFilter.all;

  int get _unreadCount => _notifications
      .where(
        (_NotificationData notification) =>
            !_readNotificationIds.contains(notification.id),
      )
      .length;

  List<_NotificationData> get _visibleNotifications {
    if (_selectedFilter == _NotificationFilter.all) return _notifications;
    return _notifications
        .where(
          (_NotificationData notification) =>
              !_readNotificationIds.contains(notification.id),
        )
        .toList(growable: false);
  }

  void _markAllAsRead() {
    if (_unreadCount == 0) return;
    setState(() {
      _readNotificationIds.addAll(
        _notifications.map((_NotificationData notification) => notification.id),
      );
    });
  }

  void _markAsRead(_NotificationData notification) {
    if (_readNotificationIds.contains(notification.id)) return;
    setState(() => _readNotificationIds.add(notification.id));
  }

  @override
  Widget build(BuildContext context) {
    final List<_NotificationData> visibleNotifications = _visibleNotifications;
    final List<_NotificationData> todayNotifications = visibleNotifications
        .where((_NotificationData notification) => notification.isToday)
        .toList(growable: false);
    final List<_NotificationData> earlierNotifications = visibleNotifications
        .where((_NotificationData notification) => !notification.isToday)
        .toList(growable: false);

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(
        title: StringConstants.notifications,
        actions: <Widget>[
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppDimens.paddingX8),
              child: Tooltip(
                message: StringConstants.markAllAsRead,
                child: IconButton(
                  onPressed: _markAllAsRead,
                  icon: const Icon(
                    Icons.done_all_rounded,
                    color: LightColor.secondaryColor,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.paddingX20,
                AppDimens.paddingX8,
                AppDimens.paddingX20,
                AppDimens.paddingX16,
              ),
              child: _NotificationFilterBar(
                selectedFilter: _selectedFilter,
                unreadCount: _unreadCount,
                onChanged: (_NotificationFilter filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: visibleNotifications.isEmpty
                    ? _NotificationEmptyState(
                        key: ValueKey<_NotificationFilter>(_selectedFilter),
                        unreadOnly:
                            _selectedFilter == _NotificationFilter.unread,
                      )
                    : ListView(
                        key: ValueKey<_NotificationFilter>(_selectedFilter),
                        padding: const EdgeInsets.fromLTRB(
                          AppDimens.paddingX20,
                          0,
                          AppDimens.paddingX20,
                          AppDimens.paddingX28,
                        ),
                        physics: const BouncingScrollPhysics(),
                        children: <Widget>[
                          if (todayNotifications.isNotEmpty)
                            _NotificationSection(
                              title: StringConstants.today,
                              notifications: todayNotifications,
                              readNotificationIds: _readNotificationIds,
                              onNotificationTap: _markAsRead,
                            ),
                          if (todayNotifications.isNotEmpty &&
                              earlierNotifications.isNotEmpty)
                            const SizedBox(height: AppDimens.sizeX22),
                          if (earlierNotifications.isNotEmpty)
                            _NotificationSection(
                              title: StringConstants.earlier,
                              notifications: earlierNotifications,
                              readNotificationIds: _readNotificationIds,
                              onNotificationTap: _markAsRead,
                            ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationFilterBar extends StatelessWidget {
  const _NotificationFilterBar({
    required this.selectedFilter,
    required this.unreadCount,
    required this.onChanged,
  });

  final _NotificationFilter selectedFilter;
  final int unreadCount;
  final ValueChanged<_NotificationFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimens.sizeX44,
      padding: const EdgeInsets.all(AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _FilterButton(
              label: StringConstants.all,
              selected: selectedFilter == _NotificationFilter.all,
              onTap: () => onChanged(_NotificationFilter.all),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX4),
          Expanded(
            child: _FilterButton(
              label: StringConstants.unread,
              selected: selectedFilter == _NotificationFilter.unread,
              count: unreadCount,
              onTap: () => onChanged(_NotificationFilter.unread),
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
                const SizedBox(width: AppDimens.sizeX6),
                Container(
                  constraints: const BoxConstraints(
                    minWidth: AppDimens.sizeX20,
                    minHeight: AppDimens.sizeX20,
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

class _NotificationSection extends StatelessWidget {
  const _NotificationSection({
    required this.title,
    required this.notifications,
    required this.readNotificationIds,
    required this.onNotificationTap,
  });

  final String title;
  final List<_NotificationData> notifications;
  final Set<String> readNotificationIds;
  final ValueChanged<_NotificationData> onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            left: AppDimens.paddingX4,
            bottom: AppDimens.paddingX10,
          ),
          child: Row(
            children: <Widget>[
              Text(
                title,
                style: textTheme.bodyTextMedium?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w700,
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
            borderRadius: BorderRadius.circular(AppDimens.radiusX16),
            border: Border.all(color: LightColor.dividerColor),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: AppDimens.radiusX14,
                offset: Offset(0, AppDimens.sizeX6),
              ),
            ],
          ),
          child: Column(
            children: <Widget>[
              for (int index = 0; index < notifications.length; index++) ...[
                _NotificationTile(
                  notification: notifications[index],
                  isRead: readNotificationIds.contains(notifications[index].id),
                  onTap: () => onNotificationTap(notifications[index]),
                ),
                if (index < notifications.length - 1)
                  const Divider(
                    height: AppDimens.sizeX1,
                    thickness: AppDimens.sizeX1,
                    indent: AppDimens.sizeX72,
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

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isRead,
    required this.onTap,
  });

  final _NotificationData notification;
  final bool isRead;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Semantics(
      button: true,
      label:
          '${notification.title}. ${notification.body}. '
          '${notification.timeLabel}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            color: isRead
                ? LightColor.cardColor
                : LightColor.secondaryColor.withValues(alpha: 0.045),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX44,
                  height: AppDimens.sizeX44,
                  decoration: BoxDecoration(
                    color: notification.accentColor.withValues(alpha: 0.11),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    notification.icon,
                    color: notification.accentColor,
                    size: AppDimens.sizeX20,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              notification.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextMedium?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!isRead) ...<Widget>[
                            const SizedBox(width: AppDimens.sizeX8),
                            Container(
                              width: AppDimens.sizeX8,
                              height: AppDimens.sizeX8,
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
                      const SizedBox(height: AppDimens.sizeX4),
                      Text(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: AppDimens.sizeX6),
                      Text(
                        notification.timeLabel,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

class _NotificationEmptyState extends StatelessWidget {
  const _NotificationEmptyState({super.key, required this.unreadOnly});

  final bool unreadOnly;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimens.paddingX32),
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

enum _NotificationFilter { all, unread }

class _NotificationData {
  const _NotificationData({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    required this.icon,
    required this.accentColor,
    required this.isToday,
    this.initiallyRead = false,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final IconData icon;
  final Color accentColor;
  final bool isToday;
  final bool initiallyRead;
}
