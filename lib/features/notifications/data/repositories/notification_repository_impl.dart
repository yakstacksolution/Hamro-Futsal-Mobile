import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/notifications/data/data_source/notification_data_source.dart';
import 'package:hamro_futsal/features/notifications/data/model/notification_model.dart';
import 'package:hamro_futsal/features/notifications/domain/repository/notification_repository.dart';

final class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({NotificationRemoteDataSource? remoteDataSource})
    : _remoteDataSource =
          remoteDataSource ?? NotificationRemoteDataSourceImpl();

  final NotificationRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, NotificationPage>> getNotifications({
    required NotificationFilter filter,
    int perPage = 20,
  }) async {
    final response = await _remoteDataSource.getNotifications(
      filter.value,
      perPage,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(NotificationPage.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseNotificationsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Unit>> markAllRead() async {
    final response = await _remoteDataSource.markAllRead();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(unit);
  }

  @override
  Future<Either<AppException, Unit>> markRead(String notificationId) async {
    final response = await _remoteDataSource.markRead(notificationId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(unit);
  }

  @override
  Future<Either<AppException, Unit>> markUnread(String notificationId) async {
    final response = await _remoteDataSource.markUnread(notificationId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(unit);
  }
}
