import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';

void main() {
  group('BookingModel', () {
    test('parses the my-bookings API response', () {
      final List<BookingModel> bookings = BookingModel.listFromResponse(
        <String, dynamic>{
          'status': 'success',
          'message': 'Bookings fetched successfully.',
          'data': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 7,
              'booking_code': 'BK-9BSUCLB3',
              'series_parent_id': 1,
              'is_recurring': true,
              'is_series_anchor': false,
              'recurrence_type': 'weekly',
              'recurrence_start_date': '2026-07-01',
              'recurrence_end_date': '2026-08-19',
              'booking_date': '2026-08-12',
              'start_time': '18:00:00',
              'end_time': '19:00:00',
              'slot_count': 1,
              'price_per_slot': 1200,
              'subtotal': 1200,
              'discount_amount': 120,
              'tax_amount': 0,
              'advance_amount': 600,
              'payable_now': 600,
              'balance_due_later': 480,
              'total_amount': 1080,
              'payment_status': 'partial',
              'booking_status': 'pending',
              'customer_name': 'Dilli Bhandari',
              'customer_phone': '985655336655',
              'customer_email': 'officialdilli1@gmail.com',
              'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sports'},
              'court': <String, dynamic>{'id': 6, 'name': 'Shidartha'},
              'coupon': <String, dynamic>{
                'id': 1,
                'code': 'FIRSTBOOK',
                'title': 'First book',
              },
              'payment': <String, dynamic>{
                'id': 7,
                'payment_method': 'cash',
                'amount': 600,
                'status': 'pending',
                'verification_status': 'pending',
                'payment_proof': 'payment-proofs/1/payment-proof-example.jpg',
                'payment_proof_url':
                    '/storage/payment-proofs/1/payment-proof-example.jpg',
                'has_payment_proof': true,
                'payment_note': null,
              },
              'booking_slots': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 7,
                  'slot_date': '2026-08-12',
                  'slot_start': '18:00:00',
                  'slot_end': '19:00:00',
                  'slot_price': 1200,
                  'status': 'active',
                },
              ],
            },
          ],
        },
      );

      expect(bookings, hasLength(1));
      final BookingModel booking = bookings.single;
      expect(booking.id, 7);
      expect(booking.bookingRef, 'BK-9BSUCLB3');
      expect(booking.date, DateTime(2026, 8, 12));
      expect(booking.courtName, 'Shidartha');
      expect(booking.futsalName, 'Dhananjay sports');
      expect(booking.venueId, 1);
      expect(booking.courtId, 6);
      expect(booking.status, BookingStatus.pending);
      expect(booking.amount, 1080);
      expect(booking.playerName, 'Dilli Bhandari');
      expect(booking.playerPhone, '985655336655');
      expect(booking.playerEmail, 'officialdilli1@gmail.com');
      expect(booking.isRecurring, isTrue);
      expect(booking.isSeriesAnchor, isFalse);
      expect(booking.recurrenceType, 'weekly');
      expect(booking.recurrenceStartDate, DateTime(2026, 7, 1));
      expect(booking.recurrenceEndDate, DateTime(2026, 8, 19));
      expect(booking.displayTimeRange, '6:00 PM – 7:00 PM');
      expect(booking.subtotal, 1200);
      expect(booking.discountAmount, 120);
      expect(booking.payableNow, 600);
      expect(booking.balanceDueLater, 480);
      expect(booking.paymentStatus, 'partial');
      expect(booking.coupon?.code, 'FIRSTBOOK');
      expect(booking.payment?.method, 'cash');
      expect(booking.payment?.amount, 600);
      expect(booking.payment?.hasPaymentProof, isTrue);
      expect(
        booking.payment?.paymentProofUrl,
        '/storage/payment-proofs/1/payment-proof-example.jpg',
      );
      expect(booking.bookingSlots, hasLength(1));
      expect(booking.bookingSlots.single.price, 1200);
    });

    test('parses player details from a futsal booking', () {
      final List<BookingModel> bookings = BookingModel.listFromResponse(
        <String, dynamic>{
          'data': <String, dynamic>{
            'futsal_bookings': <Map<String, dynamic>>[
              <String, dynamic>{
                'booking_id': '21',
                'booking_ref': 'HF-0021',
                'booking_date': '2026-07-05T00:00:00.000Z',
                'slot': <String, dynamic>{
                  'start_time': '07:00',
                  'end_time': '08:00',
                },
                'status': 'rejected',
                'booking_total': 2200,
                'venue_court': <String, dynamic>{'title': 'Court B'},
                'futsal': <String, dynamic>{'title': 'Hamro Futsal'},
                'customer': <String, dynamic>{
                  'full_name': 'Player One',
                  'phone_number': '9800000000',
                },
              },
            ],
          },
        },
      );

      expect(bookings, hasLength(1));
      expect(bookings.single.id, 21);
      expect(bookings.single.courtName, 'Court B');
      expect(bookings.single.futsalName, 'Hamro Futsal');
      expect(bookings.single.playerName, 'Player One');
      expect(bookings.single.playerPhone, '9800000000');
      expect(bookings.single.status, BookingStatus.cancelled);
    });
  });
}
