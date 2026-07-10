import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';

abstract class BookingRepository {
  Future<Either<AppException, List<BookingModel>>> getMyBookings();
  Future<Either<AppException, BookingModel>> getBookingDetails(int bookingId);
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings();
  Future<Either<AppException, BookingModel?>> cancelBooking(int bookingId);

  Future<Either<AppException, bool>> getCancelBoundary(int bookingId);

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
