import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/available_courts_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_result_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/payment_qr_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/recurring_availability_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_amenities_facilities_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_review_model.dart';

abstract class FutsalDetailsRepository {
  Future<Either<AppException, HostedByModel>> getHostedBy({
    required int venueId,
  });
  Future<Either<AppException, VenueDescriptionModel>> getVenueDescription({
    required int venueId,
  });

  /// One page of `/venues/{venue_id}/reviews`.
  Future<Either<AppException, VenueReviewPageModel>> getVenueReviews({
    required int venueId,
    int page,
    int perPage,
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
  Future<Either<AppException, BookingHoldModel>> createBookingHold({
    required int? venueId,
    required int? courtId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    List<String> bookingDates,
  });
  Future<Either<AppException, Unit>> releaseBookingHold({
    required String holdToken,
  });
}
