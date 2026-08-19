import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/change_password/domain/repository/change_password_repository.dart';

final class ChangePasswordUseCase {
  const ChangePasswordUseCase(this.repository);

  final ChangePasswordRepository repository;

  Future<Either<AppException, String>> call({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async => await repository.changePassword(
    oldPassword: oldPassword,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );
}
