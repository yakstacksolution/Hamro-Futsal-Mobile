import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

abstract class VenueCourtRepository {
  Future<Either<AppException, List<VenueCourtModel>>> getVenueCourt();
  Future<Either<AppException, CourtDraft>> getCourtDetails(int courtId);
  Future<Either<AppException, List<SlotPricingDraft>>> getCourtSlots(
    int courtId,
  );
  Future<Either<AppException, List<SlotPricingDraft>>> createCourtSlot(
    Map<String, dynamic> data,
  );
  Future<Either<AppException, List<SlotPricingDraft>>> updateCourtSlot(
    Map<String, dynamic> data,
  );
  Future<Either<AppException, List<SlotPricingDraft>>> deleteCourtSlot(
    Map<String, dynamic> data,
  );
  Future<Either<AppException, Unit>> updateCourtStatus(
    int courtId,
    String status,
  );
  Future<Either<AppException, Unit>> deleteCourt(int courtId);
}
