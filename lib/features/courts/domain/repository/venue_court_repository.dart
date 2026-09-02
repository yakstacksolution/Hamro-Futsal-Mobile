import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

abstract class VenueCourtRepository {
  Future<Either<AppException, VenueCourtPageModel>> getVenueCourt({
    required int page,
    required int perPage,
  });
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
    Map<String, dynamic> data,
  );
  Future<Either<AppException, Unit>> deleteCourt(int courtId);
}
