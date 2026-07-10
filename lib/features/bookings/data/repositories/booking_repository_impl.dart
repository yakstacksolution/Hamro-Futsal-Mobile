import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/bookings/data/data_source/booking_data_source.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

final class BookingRepositoryImpl implements BookingRepository {
  BookingRepositoryImpl({BookingRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? BookingRemoteDataSourceImpl();

  final BookingRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<BookingModel>>> getMyBookings() async {
    final response = await _remoteDataSource.getMyBookings();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseBookingsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(
    int bookingId,
  ) async {
    final response = await _remoteDataSource.getBookingDetails(bookingId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseBookingDetailsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<BookingModel>>> getFutsalBookings() async {
    final response = await _remoteDataSource.getFutsalBookings();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseFutsalBookingsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, BookingModel?>> cancelBooking(
    int bookingId,
  ) async {
    final response = await _remoteDataSource.cancelBooking(bookingId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.fromResponse(response.getValue()));
    } catch (_) {
      return right(null);
    }
  }

  @override
  Future<Either<AppException, bool>> getCancelBoundary(int bookingId) async {
    final response = await _remoteDataSource.getBookingCancelBoundary(
      bookingId,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(_parseCancelBoundary(response.getValue()));
    } catch (_) {
      return right(false);
    }
  }

  /// Flexibly resolves the cancel-boundary payload to a boolean. Accepts a bare
  /// bool/number/string, or a map exposing the flag under common keys
  /// (optionally nested under `data`).
  bool _parseCancelBoundary(dynamic value) {
    dynamic current = value;
    for (int depth = 0; depth < 6; depth++) {
      if (current is bool) return current;
      if (current is num) return current != 0;
      if (current is String) {
        final String s = current.trim().toLowerCase();
        return s == 'true' || s == '1' || s == 'yes';
      }
      if (current is Map) {
        for (final String key in const <String>[
          'can_cancel',
          'cancellable',
          'can_be_cancelled',
          'allowed',
          'is_within_boundary',
          'within_boundary',
          'result',
          'value',
        ]) {
          if (current.containsKey(key)) {
            return _parseCancelBoundary(current[key]);
          }
        }
        if (current.containsKey('data')) {
          current = current['data'];
          continue;
        }
      }
      break;
    }
    return false;
  }

  @override
  Future<Either<AppException, BookingModel?>> verifyBookingPayment({
    required int bookingId,
    required int paymentId,
    required double actualAmount,
    String? note,
  }) async {
    final response = await _remoteDataSource
        .verifyBookingPayment(bookingId, paymentId, <String, dynamic>{
          'actual_amount': actualAmount,
          if (note?.trim().isNotEmpty == true) 'payment_note': note!.trim(),
        });
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.fromResponse(response.getValue()));
    } catch (_) {
      return right(null);
    }
  }

  @override
  Future<Either<AppException, BookingModel?>> rejectBookingPayment({
    required int bookingId,
    required int paymentId,
    String? note,
  }) async {
    final response = await _remoteDataSource.rejectBookingPayment(
      bookingId,
      paymentId,
      <String, dynamic>{
        if (note?.trim().isNotEmpty == true) 'payment_note': note!.trim(),
      },
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.fromResponse(response.getValue()));
    } catch (_) {
      return right(null);
    }
  }

  @override
  Future<Either<AppException, BookingModel?>> acceptBooking({
    required int bookingId,
  }) async {
    final response = await _remoteDataSource.acceptBooking(
      bookingId,
      const <String, dynamic>{},
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.fromResponse(response.getValue()));
    } catch (_) {
      return right(null);
    }
  }

  @override
  Future<Either<AppException, BookingModel?>> rejectBooking({
    required int bookingId,
    String? note,
  }) async {
    final response = await _remoteDataSource.rejectBooking(
      bookingId,
      <String, dynamic>{
        if (note?.trim().isNotEmpty == true) 'note': note!.trim(),
      },
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(BookingModel.fromResponse(response.getValue()));
    } catch (_) {
      return right(null);
    }
  }
}
