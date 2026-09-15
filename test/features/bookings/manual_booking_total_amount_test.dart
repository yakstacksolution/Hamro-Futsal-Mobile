import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/data/model/manual_booking_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/create_booking_request.dart';

CreateBookingRequest _request({double? totalAmount}) => CreateBookingRequest(
  venueId: 1,
  courtId: 2,
  bookingDate: '2026-09-10',
  startTime: '18:00',
  paymentMethod: 'cash',
  bookingType: 'manual',
  customerName: 'Dhanan',
  customerPhone: '9800000000',
  totalAmount: totalAmount,
);

void main() {
  group('total_amount on the booking request', () {
    test('is sent when the counter agreed a price', () {
      expect(_request(totalAmount: 1200).toFields()['total_amount'], 1200);
      expect(_request(totalAmount: 1200.5).toFields()['total_amount'], 1200.5);
    });

    // A blank box must not reach the server as 0, or a free booking is
    // created; the key is dropped so the server prices the slots itself.
    test('is absent entirely when left blank', () {
      final Map<String, dynamic> fields = _request().toFields();
      expect(fields.containsKey('total_amount'), isFalse);
    });

    test('the rest of the payload is unaffected either way', () {
      for (final double? amount in <double?>[null, 1200]) {
        final Map<String, dynamic> fields = _request(
          totalAmount: amount,
        ).toFields();
        expect(fields['booking_type'], 'manual');
        expect(fields['payment_method'], 'cash');
        expect(fields['customer_name'], 'Dhanan');
      }
    });
  });

  group('ManualBookingDetails', () {
    test('leaves the total optional', () {
      const ManualBookingDetails details = ManualBookingDetails(
        customerName: 'Dhanan',
        customerPhone: '9800000000',
        paymentMethod: 'cash',
        paymentType: 'cash',
        paymentStatus: 'paid',
        bookingStatus: 'confirmed',
        paymentNote: 'Paid at counter',
      );
      expect(details.totalAmount, isNull);
    });

    test('carries the total when one was entered', () {
      const ManualBookingDetails details = ManualBookingDetails(
        customerName: 'Dhanan',
        customerPhone: '9800000000',
        totalAmount: 1500,
        paymentMethod: 'cash',
        paymentType: 'cash',
        paymentStatus: 'paid',
        bookingStatus: 'confirmed',
        paymentNote: 'Paid at counter',
      );
      expect(details.totalAmount, 1500);
    });
  });
}
