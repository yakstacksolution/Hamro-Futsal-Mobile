import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class BookingHoldUseCase {
  const BookingHoldUseCase(this.repository);

  final FutsalDetailsRepository repository;

  /// Holds the slot on [bookingDate], or on every date in [bookingDates]
  /// for a recurring booking — one list item per date, all in one request.
  Future<Either<AppException, List<BookingHoldModel>>> createHold({
    required int? venueId,
    required int? courtId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    List<String> bookingDates = const <String>[],
  }) async {
    final List<String> dates = bookingDates.isEmpty
        ? <String>[bookingDate]
        : bookingDates;
    final Either<AppException, List<BookingHoldModel>> result = await repository
        .createBookingHolds(
          holds: <BookingHoldRequest>[
            for (final String date in dates)
              BookingHoldRequest(
                venueId: venueId,
                courtId: courtId,
                bookingDate: date,
                startTime: startTime,
                endTime: endTime,
              ),
          ],
        );
    return result.flatMap(
      (List<BookingHoldModel> holds) => holds.isEmpty
          ? left(
              DefaultException(
                errorMessage: 'Could not hold this slot. Please try again.',
                statusCode: 0,
              ),
            )
          : right(holds),
    );
  }

  /// Releases the holds with [holdIds] in one request.
  Future<Either<AppException, Unit>> releaseHolds(List<String> holdIds) async =>
      await repository.releaseBookingHolds(holdIds: holdIds);
}
