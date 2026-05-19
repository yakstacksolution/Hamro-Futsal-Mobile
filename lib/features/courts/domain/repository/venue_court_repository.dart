import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';

abstract class VenueCourtRepository {
  Future<Either<AppException, List<VenueCourtModel>>> getVenueCourt();
}
