import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<AppException, ProfileModel>> getProfile();
  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  );
}
