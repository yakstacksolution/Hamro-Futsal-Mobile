import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetVenueDescriptionUseCase {
  const GetVenueDescriptionUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, VenueDescriptionModel>> call({
    required int venueId,
  }) async => await repository.getVenueDescription(venueId: venueId);
}
