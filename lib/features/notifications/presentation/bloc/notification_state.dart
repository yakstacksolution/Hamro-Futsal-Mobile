part of 'notification_bloc.dart';

enum NotificationStatus { idle, loading, success, failure }

final class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationStatus.idle,
    this.filter = NotificationFilter.all,
    this.notifications = const <NotificationModel>[],
    this.unreadCount = 0,
    this.errorMessage,
    this.refreshTick = 0,
  });

  final NotificationStatus status;
  final NotificationFilter filter;
  final List<NotificationModel> notifications;
  final int unreadCount;
  final String? errorMessage;

  /// Bumped after every completed fetch so pull-to-refresh can await it.
  final int refreshTick;

  NotificationState copyWith({
    NotificationStatus? status,
    NotificationFilter? filter,
    List<NotificationModel>? notifications,
    int? unreadCount,
    String? errorMessage,
    bool clearError = false,
    int? refreshTick,
  }) {
    return NotificationState(
      status: status ?? this.status,
      filter: filter ?? this.filter,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    filter,
    notifications,
    unreadCount,
    errorMessage,
    refreshTick,
  ];
}
