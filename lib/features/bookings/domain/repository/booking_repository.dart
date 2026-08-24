import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_footsall/features/bookings/domain/model/paginated_bookings.dart';

abstract class BookingRepository {
  /// [status] is the endpoint's `status` filter — `all`, `pending`,
  /// `confirmed`, `completed`, `cancelled`, `rejected`. Null sends none.
  Future<Either<AppException, PaginatedBookings>> getMyBookings({
    required int page,
    required int perPage,
    String? status,
  });
  Future<Either<AppException, BookingModel>> getBookingDetails(int bookingId);
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings({
    required int page,
    required int perPage,
    String? status,
  });
  Future<Either<AppException, BookingModel?>> cancelBooking(int bookingId);

  Future<Either<AppException, bool>> getCancelBoundary(int bookingId);

  /// The customer's review of this booking, or null when they have not left
  /// one yet.
  Future<Either<AppException, BookingReviewModel?>> getBookingReview(
    int bookingId,
  );

  Future<Either<AppException, BookingReviewModel>> submitBookingReview({
    required int bookingId,
    required double rating,
    required String review,
  });

  Future<Either<AppException, BookingModel?>> verifyBookingPayment({
    required int bookingId,
    required int paymentId,
    required double actualAmount,
    String? note,
  });

  Future<Either<AppException, BookingModel?>> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    String? note,
  });

  Future<Either<AppException, BookingModel?>> acceptBooking({
    required int bookingId,
  });

  Future<Either<AppException, BookingModel?>> rejectBooking({
    required int bookingId,
    String? note,
  });
}
