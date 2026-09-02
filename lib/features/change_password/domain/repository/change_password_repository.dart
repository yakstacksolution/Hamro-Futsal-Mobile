import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';

abstract class ChangePasswordRepository {
  /// Changes the signed-in user's password. Returns the server's success
  /// message (or a sensible default) on the right side.
  Future<Either<AppException, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
