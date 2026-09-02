import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class BookingHoldUseCase {
  const BookingHoldUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, BookingHoldModel>> createHold({
    required int? venueId,
    required int? courtId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    List<String> bookingDates = const <String>[],
  }) async => await repository.createBookingHold(
    venueId: venueId,
    courtId: courtId,
    bookingDate: bookingDate,
    startTime: startTime,
    endTime: endTime,
    bookingDates: bookingDates,
  );

  Future<Either<AppException, Unit>> releaseHold(String holdToken) async =>
      await repository.releaseBookingHold(holdToken: holdToken);
}
