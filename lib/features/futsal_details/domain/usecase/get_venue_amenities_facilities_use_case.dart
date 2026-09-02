import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetVenueAmenitiesFacilitiesUseCase {
  const GetVenueAmenitiesFacilitiesUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, VenueAmenitiesFacilitiesModel>> call({
    required int venueId,
  }) async => await repository.getVenueAmenitiesFacilities(venueId: venueId);
}
