import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';

final class GetPublicVenuesUseCase {
  const GetPublicVenuesUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, PublicListingVenuePage>> call({
    int page = 1,
    int perPage = kVenueListPerPage,
    VenueFilter? filter,
    double? latitude,
    double? longitude,
  }) async => await repository.getVenueList(
    page: page,
    perPage: perPage,
    filter: filter,
    latitude: latitude,
    longitude: longitude,
  );
}
