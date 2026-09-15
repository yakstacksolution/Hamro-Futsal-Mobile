import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';

abstract class BookingRepository {
  /// [query] carries the whole request: the page, the status, the date
  /// window and the sort order.
  Future<Either<AppException, PaginatedBookings>> getMyBookings(
    BookingListQuery query,
  );
  Future<Either<AppException, BookingModel>> getBookingDetails(int bookingId);
  Future<Either<AppException, PaginatedBookings>> getFutsalBookings(
    BookingListQuery query,
  );
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
