import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/change_password/data/data_source/change_password_data_source.dart';
import 'package:hamro_futsal/features/change_password/domain/repository/change_password_repository.dart';

final class ChangePasswordRepositoryImpl extends ChangePasswordRepository {
  ChangePasswordRepositoryImpl({
    ChangePasswordRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? ChangePasswordDataSourceImpl();

  final ChangePasswordRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _remoteDataSource.changePassword({
      'old_password': oldPassword,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });

    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      // A 204 No Content reply still means the password was changed.
      if (error.statusCode != 204) return left(error);
      return right('Password updated successfully.');
    }

    final dynamic payload = response.getValue();
    final String message = payload is Map && payload['message'] is String
        ? (payload['message'] as String)
        : 'Password updated successfully.';
    return right(message);
  }
}
