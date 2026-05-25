import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/domain/repository/profile_repository.dart';

final class ProfileUseCase {
  const ProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<Either<AppException, ProfileModel>> getProfile() async =>
      await repository.getProfile();

  Future<Either<AppException, ProfileModel>> updateProfile(
    Map<String, dynamic> data,
  ) async => await repository.updateProfile(data);
}
