import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/notifications/data/model/notification_model.dart';
import 'package:hamro_footsall/features/notifications/domain/repository/notification_repository.dart';

final class NotificationUseCase {
  const NotificationUseCase(this._repository);

  final NotificationRepository _repository;

  Future<Either<AppException, NotificationPage>> getNotifications({
    required NotificationFilter filter,
    int perPage = 20,
  }) => _repository.getNotifications(filter: filter, perPage: perPage);

  Future<Either<AppException, Unit>> markAllRead() => _repository.markAllRead();

  Future<Either<AppException, Unit>> markRead(String notificationId) =>
      _repository.markRead(notificationId);

  Future<Either<AppException, Unit>> markUnread(String notificationId) =>
      _repository.markUnread(notificationId);
}
