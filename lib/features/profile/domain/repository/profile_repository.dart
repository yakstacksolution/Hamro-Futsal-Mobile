import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<AppException, ProfileModel>> getProfile();
  Future<Either<AppException, String>> requestVendorUpgrade(
    Map<String, dynamic> data,
  );
  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  );
  Future<Either<AppException, bool>> updateNotificationPreferences(
    NotificationPreferences preferences,
  );

  /// Deletes the current account and clears the local session.
  Future<Either<AppException, bool>> deleteAccount({required String reason});
}
