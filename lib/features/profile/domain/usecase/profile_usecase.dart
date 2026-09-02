import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';
import 'package:hamro_futsal/features/profile/domain/repository/profile_repository.dart';

final class ProfileUseCase {
  const ProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<Either<AppException, ProfileModel>> getProfile() async =>
      await repository.getProfile();

  Future<Either<AppException, String>> requestVendorUpgrade(
    Map<String, dynamic> data,
  ) async => await repository.requestVendorUpgrade(data);

  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async => await repository.updateProfile(data);

  Future<Either<AppException, bool>> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async => await repository.updateNotificationPreferences(preferences);

  Future<Either<AppException, bool>> deleteAccount({
    required String reason,
  }) async => await repository.deleteAccount(reason: reason);
}
