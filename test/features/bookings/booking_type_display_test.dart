import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_details_widgets.dart';
import 'package:hamro_footsall/features/bookings/presentation/widgets/booking_shared_widgets.dart';

BookingModel _booking({String? bookingType, bool isRecurring = false}) {
  return BookingModel.fromJson(<String, dynamic>{
    'id': 28,
    'booking_code': 'BK-OPN6VT1G',
    'booking_type': bookingType,
    'booking_date': '2026-07-27',
    'start_time': '06:00:00',
    'end_time': '07:00:00',
    'is_recurring': isRecurring,
    'recurrence_type': isRecurring ? 'weekly' : null,
    'total_amount': 1320,
    'booking_status': 'completed',
    'customer_name': 'RAKESH',
    'venue': <String, dynamic>{'id': 2, 'name': 'Dhanawantary Sports'},
    'court': <String, dynamic>{'id': 14, 'name': 'Court 1'},
  });
}

Future<void> _pumpCard(WidgetTester tester, BookingModel booking) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: BookingCard(booking: booking)),
      ),
    ),
  );
}

void main() {
  group('bookingTypeLabel', () {
    test('maps the API values to labels', () {
      expect(bookingTypeLabel('manual'), 'Walk-in');
      expect(bookingTypeLabel('online'), 'Online');
      expect(bookingTypeLabel('MANUAL'), 'Walk-in');
      expect(bookingTypeLabel('walk_in'), 'Walk-in');
      expect(bookingTypeLabel('some_new_type'), 'Some New Type');
    });

    test('returns null for a missing or blank type', () {
      expect(bookingTypeLabel(null), isNull);
      expect(bookingTypeLabel(''), isNull);
      expect(bookingTypeLabel('   '), isNull);
    });
  });

  group('BookingCard booking type badge', () {
    testWidgets('shows Walk-in for a manual booking', (
      WidgetTester tester,
    ) async {
      await _pumpCard(tester, _booking(bookingType: 'manual'));
      expect(find.text('Walk-in'), findsOneWidget);
    });

    testWidgets('shows Online alongside the recurring badge', (
      WidgetTester tester,
    ) async {
      await _pumpCard(
        tester,
        _booking(bookingType: 'online', isRecurring: true),
      );
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Weekly booking'), findsOneWidget);
    });

    testWidgets('renders no badge when the type is null', (
      WidgetTester tester,
    ) async {
      await _pumpCard(tester, _booking());
      expect(find.text('Walk-in'), findsNothing);
      expect(find.text('Online'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
