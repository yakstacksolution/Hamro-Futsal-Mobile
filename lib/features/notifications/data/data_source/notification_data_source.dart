import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

abstract class NotificationRemoteDataSource {
  Future<Result> getNotifications(String filter, int perPage);
  Future<Result> markAllRead();
  Future<Result> markRead(String notificationId);
  Future<Result> markUnread(String notificationId);
}

final class NotificationRemoteDataSourceImpl
    implements NotificationRemoteDataSource {
  @override
  Future<Result> getNotifications(String filter, int perPage) async =>
      await Client.instance().getAuthManager().getNotifications(
        filter,
        perPage,
      );

  @override
  Future<Result> markAllRead() async =>
      await Client.instance().getAuthManager().markAllNotificationsRead();

  @override
  Future<Result> markRead(String notificationId) async =>
      await Client.instance().getAuthManager().markNotificationRead(
        notificationId,
      );

  @override
  Future<Result> markUnread(String notificationId) async =>
      await Client.instance().getAuthManager().markNotificationUnread(
        notificationId,
      );
}
