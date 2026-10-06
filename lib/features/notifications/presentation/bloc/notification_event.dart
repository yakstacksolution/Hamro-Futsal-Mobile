part of 'notification_bloc.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FetchNotificationsEvent extends NotificationEvent {
  const FetchNotificationsEvent({this.silent = false});

  final bool silent;

  @override
  List<Object?> get props => <Object?>[silent];
}

final class ChangeNotificationFilterEvent extends NotificationEvent {
  const ChangeNotificationFilterEvent(this.filter);

  final NotificationFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

final class MarkAllNotificationsReadEvent extends NotificationEvent {
  const MarkAllNotificationsReadEvent();
}

final class MarkNotificationReadEvent extends NotificationEvent {
  const MarkNotificationReadEvent(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => <Object?>[notificationId];
}

final class MarkNotificationUnreadEvent extends NotificationEvent {
  const MarkNotificationUnreadEvent(this.notificationId);

  final String notificationId;

  @override
  List<Object?> get props => <Object?>[notificationId];
}
