import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_service_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetPublicServicesUseCase {
  const GetPublicServicesUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<PublicServiceModel>>> call() async =>
      await repository.getServices();
}
