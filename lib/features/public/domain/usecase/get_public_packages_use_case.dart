import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_package_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetPublicPackagesUseCase {
  const GetPublicPackagesUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<PublicPackageModel>>> getPackages() async =>
      await repository.getPackages();
}
