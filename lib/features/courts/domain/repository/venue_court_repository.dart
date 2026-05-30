import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

abstract class VenueCourtRepository {
  Future<Either<AppException, List<VenueCourtModel>>> getVenueCourt();
  Future<Either<AppException, CourtDraft>> getCourtDetails(int courtId);
}
