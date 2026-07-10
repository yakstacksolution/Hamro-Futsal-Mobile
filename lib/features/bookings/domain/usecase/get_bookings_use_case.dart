import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';

final class GetBookingsUseCase {
  const GetBookingsUseCase(this._repository);

  final BookingRepository _repository;

  Future<Either<AppException, List<BookingModel>>> getMyBookings() =>
      _repository.getMyBookings();

  Future<Either<AppException, BookingModel>> getBookingDetails(int bookingId) =>
      _repository.getBookingDetails(bookingId);

  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() =>
      _repository.getFutsalBookings();

  Future<Either<AppException, BookingModel?>> cancelBooking(int bookingId) =>
      _repository.cancelBooking(bookingId);

  Future<Either<AppException, bool>> getCancelBoundary(int bookingId) =>
      _repository.getCancelBoundary(bookingId);

  Future<Either<AppException, BookingModel?>> verifyBookingPayment({
    required int bookingId,
    required int paymentId,
    required double actualAmount,
    String? note,
  }) => _repository.verifyBookingPayment(
    bookingId: bookingId,
    paymentId: paymentId,
    actualAmount: actualAmount,
    note: note,
  );

  Future<Either<AppException, BookingModel?>> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    String? note,
  }) => _repository.rejectBookingPayment(
    bookingId: bookingId,
    paymentId: paymentId,
    note: note,
  );

  Future<Either<AppException, BookingModel?>> acceptBooking({
    required int bookingId,
  }) => _repository.acceptBooking(bookingId: bookingId);

  Future<Either<AppException, BookingModel?>> rejectBooking({
    required int bookingId,
    String? note,
  }) => _repository.rejectBooking(bookingId: bookingId, note: note);
}
