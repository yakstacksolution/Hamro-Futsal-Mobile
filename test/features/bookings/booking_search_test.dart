import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/utils/booking_search.dart';

void main() {
  final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
    'id': 7,
    'booking_code': 'BK-9BSUCLB3',
    'booking_date': '2026-08-12',
    'start_time': '18:00:00',
    'end_time': '19:00:00',
    'booking_status': 'pending',
    'payment_status': 'partial',
    'customer_name': 'Dilli Bhandari',
    'customer_phone': '9800000000',
    'venue': <String, dynamic>{
      'name': 'Dhananjay Sports',
      'address': 'Kathmandu',
    },
    'court': <String, dynamic>{'name': 'Court A'},
  });

  test('matches booking identity, venue and customer values', () {
    expect(bookingMatchesSearch(booking, '9bsuclb3'), isTrue);
    expect(bookingMatchesSearch(booking, 'dhananjay'), isTrue);
    expect(bookingMatchesSearch(booking, 'court a'), isTrue);
    expect(bookingMatchesSearch(booking, 'dilli'), isTrue);
    expect(bookingMatchesSearch(booking, '9800000000'), isTrue);
  });

  test('matches status, date and display time', () {
    expect(bookingMatchesSearch(booking, 'pending'), isTrue);
    expect(bookingMatchesSearch(booking, '12/08/2026'), isTrue);
    expect(bookingMatchesSearch(booking, '6:00 pm'), isTrue);
  });

  test('returns false when no searchable value matches', () {
    expect(bookingMatchesSearch(booking, 'pokhara'), isFalse);
  });

  test('includes both boundaries of a selected date range', () {
    expect(
      bookingFallsWithinDateRange(
        booking,
        fromDate: DateTime(2026, 8, 12),
        toDate: DateTime(2026, 8, 12),
      ),
      isTrue,
    );
    expect(
      bookingFallsWithinDateRange(booking, fromDate: DateTime(2026, 8, 13)),
      isFalse,
    );
    expect(
      bookingFallsWithinDateRange(booking, toDate: DateTime(2026, 8, 11)),
      isFalse,
    );
  });

  test('sorts bookings by date in ascending and descending order', () {
    final BookingModel earlier = BookingModel.fromJson(<String, dynamic>{
      'id': 1,
      'booking_date': '2026-07-01',
      'start_time': '10:00:00',
      'booking_status': 'pending',
    });
    final BookingModel later = BookingModel.fromJson(<String, dynamic>{
      'id': 2,
      'booking_date': '2026-09-01',
      'start_time': '08:00:00',
      'booking_status': 'confirmed',
    });

    expect(
      sortBookingsByDate(<BookingModel>[
        later,
        earlier,
      ], BookingDateOrder.ascending).map((BookingModel item) => item.id),
      <int>[1, 2],
    );
    expect(
      sortBookingsByDate(<BookingModel>[
        earlier,
        later,
      ], BookingDateOrder.descending).map((BookingModel item) => item.id),
      <int>[2, 1],
    );
  });
}
