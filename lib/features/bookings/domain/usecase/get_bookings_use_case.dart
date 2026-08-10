import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/features/bookings/domain/model/paginated_bookings.dart';

final class GetBookingsUseCase {
  const GetBookingsUseCase(this._repository);

  final BookingRepository _repository;

  Future<Either<AppException, PaginatedBookings>> getMyBookings({
    required int page,
    int perPage = 10,
  }) => _repository.getMyBookings(page: page, perPage: perPage);

  Future<Either<AppException, BookingModel>> getBookingDetails(int bookingId) =>
      _repository.getBookingDetails(bookingId);

  Future<Either<AppException, PaginatedBookings>> getFutsalBookings({
    required int page,
    int perPage = 10,
  }) => _repository.getFutsalBookings(page: page, perPage: perPage);

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
