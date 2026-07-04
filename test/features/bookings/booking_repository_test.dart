import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/features/bookings/data/data_source/booking_data_source.dart';
import 'package:hamro_footsall/features/bookings/data/repositories/booking_repository_impl.dart';

void main() {
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
}

final class _FakeBookingRemoteDataSource implements BookingRemoteDataSource {
  _FakeBookingRemoteDataSource(this.detailResponse);

  final Result detailResponse;
  int? requestedBookingId;

  @override
  Future<Result> getBookingDetails(int bookingId) async {
    requestedBookingId = bookingId;
    return detailResponse;
  }

  @override
  Future<Result> getMyBookings() async =>
      Result<dynamic, dynamic>.success(<dynamic>[]);

  @override
  Future<Result> getFutsalBookings() async =>
      Result<dynamic, dynamic>.success(<dynamic>[]);
}
