import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_description_model.dart';

abstract class FutsalDetailsRepository {
  Future<Either<AppException, HostedByModel>> getHostedBy({
    required int venueId,
  });
  Future<Either<AppException, VenueDescriptionModel>> getVenueDescription({
    required int venueId,
  });
  Future<Either<AppException, VenueAmenitiesFacilitiesModel>>
  getVenueAmenitiesFacilities({required int venueId});
}
