import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/features/bookings/data/data_source/booking_data_source.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';

void main() {
  test('parses my-booking pagination and forwards page size', () async {
    final _FakeBookingRemoteDataSource source =
        _FakeBookingRemoteDataSource(
            Result<dynamic, dynamic>.success(<String, dynamic>{}),
          )
          ..myBookingsResponse = Result<dynamic, dynamic>.success(
            _paginatedBookingResponse(total: 3, hasMorePages: false),
          );
    final BookingRepositoryImpl repository = BookingRepositoryImpl(
      remoteDataSource: source,
    );

    final result = await repository.getMyBookings(
      page: 1,
      perPage: 10,
      status: 'pending',
    );

    expect(source.requestedMyPage, 1);
    expect(source.requestedMyPerPage, 10);
    // The status filter belongs on the request, not on the rows that come back.
    expect(source.requestedMyStatus, 'pending');
    result.fold((error) => fail(error.errorMessage), (page) {
      expect(page.items.single.id, 46);
      expect(page.perPage, 10);
      expect(page.total, 3);
      expect(page.hasMorePages, isFalse);
    });
  });

  test('parses futsal booking pagination and forwards page size', () async {
    final _FakeBookingRemoteDataSource source =
        _FakeBookingRemoteDataSource(
            Result<dynamic, dynamic>.success(<String, dynamic>{}),
          )
          ..futsalResponse = Result<dynamic, dynamic>.success(<String, dynamic>{
            'status': 'success',
            'data': <String, dynamic>{
              'items': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 46,
                  'booking_date': '2026-08-31',
                  'start_time': '13:00:00',
                  'end_time': '14:00:00',
                  'booking_status': 'cancelled',
                  'total_amount': 1600,
                },
              ],
              'pagination': <String, dynamic>{
                'current_page': 1,
                'last_page': 2,
                'per_page': 10,
                'total': 18,
                'has_more_pages': true,
              },
            },
          });
    final BookingRepositoryImpl repository = BookingRepositoryImpl(
      remoteDataSource: source,
    );

    final result = await repository.getFutsalBookings(
      page: 1,
      perPage: 10,
      status: 'completed',
    );

    expect(source.requestedPage, 1);
    expect(source.requestedPerPage, 10);
    expect(source.requestedStatus, 'completed');
    result.fold((error) => fail(error.errorMessage), (page) {
      expect(page.items.single.id, 46);
      expect(page.currentPage, 1);
      expect(page.lastPage, 2);
      expect(page.total, 18);
      expect(page.hasMorePages, isTrue);
    });
  });

  test('parses a booking detail response from data.booking', () async {
    final _FakeBookingRemoteDataSource source = _FakeBookingRemoteDataSource(
      Result<dynamic, dynamic>.success(<String, dynamic>{
        'status': 'success',
        'message': 'Booking fetched successfully.',
        'data': <String, dynamic>{
          'booking': <String, dynamic>{
            'id': 7,
            'booking_code': 'BK-9BSUCLB3',
            'booking_date': '2026-08-12',
            'start_time': '18:00:00',
            'end_time': '19:00:00',
            'booking_status': 'pending',
            'total_amount': 1080,
            'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sports'},
            'court': <String, dynamic>{'id': 6, 'name': 'Shidartha'},
          },
        },
      }),
    );
    final BookingRepositoryImpl repository = BookingRepositoryImpl(
      remoteDataSource: source,
    );

    final result = await repository.getBookingDetails(7);

    expect(source.requestedBookingId, 7);
    result.fold((error) => fail(error.errorMessage), (booking) {
      expect(booking.id, 7);
      expect(booking.bookingRef, 'BK-9BSUCLB3');
      expect(booking.futsalName, 'Dhananjay sports');
      expect(booking.courtName, 'Shidartha');
    });
  });

  test('reads cancel-boundary flag from the data field', () async {
    final _FakeBookingRemoteDataSource source = _FakeBookingRemoteDataSource(
      Result<dynamic, dynamic>.success(<String, dynamic>{}),
    );
    // Matches the live API: {status, message, data: true}
    source.cancelBoundaryResponse =
        Result<dynamic, dynamic>.success(<String, dynamic>{
          'status': 'success',
          'message': 'Booking cancellation boundary fetched successfully.',
          'data': true,
        });
    final BookingRepositoryImpl repository = BookingRepositoryImpl(
      remoteDataSource: source,
    );

    final resultTrue = await repository.getCancelBoundary(1);
    expect(resultTrue.getOrElse(() => false), isTrue);

    source.cancelBoundaryResponse = Result<dynamic, dynamic>.success(
      <String, dynamic>{'status': 'success', 'data': false},
    );
    final resultFalse = await repository.getCancelBoundary(1);
    expect(resultFalse.getOrElse(() => true), isFalse);
  });

  test(
    'sends actual amount and remarks when verifying payment proof',
    () async {
      final _FakeBookingRemoteDataSource source = _FakeBookingRemoteDataSource(
        Result<dynamic, dynamic>.success(<String, dynamic>{}),
      );
      final BookingRepositoryImpl repository = BookingRepositoryImpl(
        remoteDataSource: source,
      );

      await repository.verifyBookingPayment(
        bookingId: 5,
        paymentId: 13,
        actualAmount: 1050,
        note: 'Verified with bank statement',
      );

      expect(source.verifiedBookingId, 5);
      expect(source.verifiedPaymentId, 13);
      expect(source.verifyPaymentPayload, <String, dynamic>{
        'actual_amount': 1050,
        'payment_note': 'Verified with bank statement',
      });
    },
  );
}

Map<String, dynamic> _paginatedBookingResponse({
  required int total,
  required bool hasMorePages,
}) => <String, dynamic>{
  'status': 'success',
  'data': <String, dynamic>{
    'items': <Map<String, dynamic>>[
      <String, dynamic>{
        'id': 46,
        'booking_date': '2026-08-31',
        'start_time': '13:00:00',
        'end_time': '14:00:00',
        'booking_status': 'cancelled',
        'total_amount': 1600,
      },
    ],
    'pagination': <String, dynamic>{
      'current_page': 1,
      'last_page': hasMorePages ? 2 : 1,
      'per_page': 10,
      'total': total,
      'has_more_pages': hasMorePages,
    },
  },
};

final class _FakeBookingRemoteDataSource implements BookingRemoteDataSource {
  @override
  Future<Result> getBookingReview(int bookingId) async =>
      Result.success(<String, dynamic>{'data': null});

  @override
  Future<Result> submitBookingReview(
    int bookingId,
    Map<String, dynamic> data,
  ) async => Result.success(<String, dynamic>{'data': data});

  _FakeBookingRemoteDataSource(this.detailResponse);

  final Result detailResponse;
  Result cancelBoundaryResponse = Result<dynamic, dynamic>.success(
    <String, dynamic>{'data': true},
  );
  int? requestedBookingId;
  int? verifiedBookingId;
  int? verifiedPaymentId;
  Map<String, dynamic>? verifyPaymentPayload;
  Result futsalResponse = Result<dynamic, dynamic>.success(<dynamic>[]);
  Result myBookingsResponse = Result<dynamic, dynamic>.success(<dynamic>[]);
  int? requestedPage;
  int? requestedPerPage;
  int? requestedMyPage;
  int? requestedMyPerPage;

  String? requestedMyStatus;
  String? requestedStatus;

  @override
  Future<Result> getBookingDetails(int bookingId) async {
    requestedBookingId = bookingId;
    return detailResponse;
  }

  @override
  Future<Result> getMyBookings({
    required int page,
    required int perPage,
    String? status,
  }) async {
    requestedMyPage = page;
    requestedMyPerPage = perPage;
    requestedMyStatus = status;
    return myBookingsResponse;
  }

  @override
  Future<Result> getFutsalBookings({
    required int page,
    required int perPage,
    String? status,
  }) async {
    requestedPage = page;
    requestedPerPage = perPage;
    requestedStatus = status;
    return futsalResponse;
  }

  @override
  Future<Result> cancelBooking(int bookingId) async =>
      Result<dynamic, dynamic>.success(<String, dynamic>{});

  @override
  Future<Result> getBookingCancelBoundary(int bookingId) async =>
      cancelBoundaryResponse;

  @override
  Future<Result> verifyBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  ) async {
    verifiedBookingId = bookingId;
    verifiedPaymentId = paymentId;
    verifyPaymentPayload = data;
    return Result<dynamic, dynamic>.success(<String, dynamic>{});
  }

  @override
  Future<Result> rejectBookingPayment(
    int bookingId,
    int paymentId,
    Map<String, dynamic> data,
  ) async => Result<dynamic, dynamic>.success(<String, dynamic>{});

  @override
  Future<Result> acceptBooking(
    int bookingId,
    Map<String, dynamic> data,
  ) async => Result<dynamic, dynamic>.success(<String, dynamic>{});

  @override
  Future<Result> rejectBooking(
    int bookingId,
    Map<String, dynamic> data,
  ) async => Result<dynamic, dynamic>.success(<String, dynamic>{});
}
