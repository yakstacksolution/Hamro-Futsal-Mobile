import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_option_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetCourtOptionsUseCase {
  const GetCourtOptionsUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<PublicOptionModel>>> getCourtTypes() async =>
      await repository.getCourtTypes();

  Future<Either<AppException, List<PublicOptionModel>>>
  getMatchFormats() async => await repository.getMatchFormats();

  Future<Either<AppException, List<PublicOptionModel>>> getAmenities() async =>
      await repository.getAmenities();

  Future<Either<AppException, List<PublicOptionModel>>> getFacilities() async =>
      await repository.getFacilities();
}
