import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

BookingModel _booking({String? createdAt, String date = '2026-08-12'}) {
  return BookingModel.fromJson(<String, dynamic>{
    'id': 1,
    'booking_date': date,
    'start_time': '18:00:00',
    'end_time': '19:00:00',
    'booking_status': 'pending',
    'total_amount': 1000,
    if (createdAt != null) 'created_at': createdAt,
  });
}

void main() {
  final DateTime now = DateTime(2026, 8, 12, 12);

  test('counts minutes and hours for the first 12 hours', () {
    expect(
      bookingTimeAgo(_booking(createdAt: '2026-08-12T11:59:30'), now: now),
      'Just now',
    );
    expect(
      bookingTimeAgo(_booking(createdAt: '2026-08-12T11:15:00'), now: now),
      '45 m ago',
    );
    expect(
      bookingTimeAgo(_booking(createdAt: '2026-08-12T10:00:00'), now: now),
      '2 hr ago',
    );
    expect(
      bookingTimeAgo(_booking(createdAt: '2026-08-12T00:00:00'), now: now),
      '12 hr ago',
    );
  });

  test('switches to an absolute stamp past 12 hours', () {
    expect(
      bookingTimeAgo(_booking(createdAt: '2026-08-11T18:30:00'), now: now),
      '11 Aug, 6:30 PM',
    );
    // A different year is spelled out.
    expect(
      bookingTimeAgo(_booking(createdAt: '2025-12-31T09:05:00'), now: now),
      '31 Dec 2025, 9:05 AM',
    );
  });

  test('falls back to the slot date and marks upcoming bookings', () {
    expect(bookingTimeAgo(_booking(date: '2026-08-12'), now: now), '12 hr ago');
    expect(
      bookingTimeAgo(_booking(date: '2026-08-15'), now: now),
      '15 Aug, 12:00 AM',
    );
  });
}
