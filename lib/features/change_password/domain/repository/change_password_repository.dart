import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';

abstract class ChangePasswordRepository {
  Future<Either<AppException, String>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
}
