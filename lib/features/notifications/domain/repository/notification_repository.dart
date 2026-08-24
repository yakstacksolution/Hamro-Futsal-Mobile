import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/notifications/data/model/notification_model.dart';

/// Which set of notifications to fetch.
enum NotificationFilter {
  all('all'),
  unread('unread');

  const NotificationFilter(this.value);
  final String value;
}

abstract class NotificationRepository {
  Future<Either<AppException, NotificationPage>> getNotifications({
    required NotificationFilter filter,
    int perPage,
  });

  Future<Either<AppException, Unit>> markAllRead();

  Future<Either<AppException, Unit>> markRead(String notificationId);

  Future<Either<AppException, Unit>> markUnread(String notificationId);
}
