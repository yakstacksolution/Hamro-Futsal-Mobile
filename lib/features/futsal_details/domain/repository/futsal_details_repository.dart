import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/available_courts_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_result_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/recurring_availability_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/review_change_request.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_review_model.dart';

abstract class FutsalDetailsRepository {
  Future<Either<AppException, HostedByModel>> getHostedBy({
    required int venueId,
  });

  /// Addressed by the venue's slug — see `ApiClient.getVenueDescription`.
  Future<Either<AppException, VenueDescriptionModel>> getVenueDescription({
    required String venueSlug,
  });

  /// One page of `/venues/{venue_id}/reviews`.
  Future<Either<AppException, VenueReviewPageModel>> getVenueReviews({
    required int venueId,
    int page,
    int perPage,
  });

  /// `POST /reviews/{review}/change-request` — asks for the signed-in user's
  /// own review to be edited or removed. Resolves to the server's message.
  Future<Either<AppException, String>> submitReviewChangeRequest({
    required int reviewId,
    required ReviewChangeRequestInput input,
  });

  Future<Either<AppException, VenueAmenitiesFacilitiesModel>>
  getVenueAmenitiesFacilities({required int venueId});
  Future<Either<AppException, AvailableCourtsModel>> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotStartTime,
    String? slotEndTime,
    String bookingType,
  });
  Future<Either<AppException, List<TimeSlotModel>>> getVenueSlots({
    required int venueId,
    required String date,
    String bookingType,
  });
  Future<Either<AppException, PaymentQrModel>> getCourtPaymentQr({
    required int courtId,
  });
  Future<Either<AppException, BookingResultModel>> createBooking(
    CreateBookingRequest request,
  );
  Future<Either<AppException, RecurringAvailabilityModel>>
  checkRecurringAvailability({
    required int? venueId,
    required int? courtId,
    required String bookingDate,
    required String slotStartTime,
    String? slotEndTime,
    List<String> recurringDates = const <String>[],
  });

  /// Holds every slot in [holds] in one `POST /booking-holds`, sent as
  /// `{"holds": [...]}`. The holds come back in the order sent.
  Future<Either<AppException, List<BookingHoldModel>>> createBookingHolds({
    required List<BookingHoldRequest> holds,
  });

  /// Releases the holds with [holdIds] in one `DELETE /booking-holds`.
  Future<Either<AppException, Unit>> releaseBookingHolds({
    required List<String> holdIds,
  });
}
