import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';

final class GetPublicVenuesUseCase {
  const GetPublicVenuesUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, PublicVenuePage>> call({
    int page = 1,
    int perPage = 10,
  }) async => await repository.getVenueList(page: page, perPage: perPage);
}
