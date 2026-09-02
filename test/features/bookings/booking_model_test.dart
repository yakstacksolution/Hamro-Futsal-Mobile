import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';

void main() {
  group('BookingModel', () {
    test('parses the live booking-details response identities and totals', () {
      final BookingModel booking = BookingModel.fromResponse(<String, dynamic>{
        'status': 'success',
        'message': 'Booking fetched successfully.',
        'data': <String, dynamic>{
          'id': 36,
          'user_id': 19,
          'venue_id': 37,
          'vendor_id': 19,
          'booking_code': 'BK-LHXCJVCO',
          'booking_type': 'online',
          'series_parent_id': 36,
          'is_recurring': false,
          'is_series_anchor': true,
          'booking_date': '2026-08-05',
          'start_time': '13:00:00',
          'end_time': '14:00:00',
          'slot_count': 1,
          'price_per_slot': 1600,
          'subtotal': 1600,
          'advance_amount': 800,
          'payable_now': 800,
          'balance_due_later': 800,
          'total_amount': 1600,
          'payment_status': 'partial',
          'booking_status': 'pending',
          'status': 'pending',
          'customer_name': 'Rosnnnnn',
          'customer_phone': '9000',
          'customer_email': 'test01@gmail.com',
          'venue': <String, dynamic>{'id': 37, 'name': 'Arena futsa'},
          'court': <String, dynamic>{'id': 38, 'name': 'Delxu court'},
          'payments': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 49,
              'payment_method': 'cash',
              'payment_type': 'cash',
              'amount': 800,
              'status': 'pending',
              'verification_status': 'pending',
              'payment_proof': 'payment-proofs/19/proof.jpg',
              'payment_proof_url': '/storage/payment-proofs/19/proof.jpg',
              'has_payment_proof': true,
            },
          ],
          'paid_amount': 0,
          'balance_due': 1600,
          'booking_slots': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 36,
              'slot_date': '2026-08-05',
              'slot_start': '13:00:00',
              'slot_end': '14:00:00',
              'slot_price': 1600,
              'status': 'active',
            },
          ],
          'extra_items': <dynamic>[],
        },
      });

      expect(booking.id, 36);
      expect(booking.playerId, 19);
      expect(booking.vendorId, 19);
      expect(booking.venueId, 37);
      expect(booking.courtId, 38);
      expect(booking.bookingRef, 'BK-LHXCJVCO');
      expect(booking.futsalName, 'Arena futsa');
      expect(booking.courtName, 'Delxu court');
      expect(booking.amount, 1600);
      expect(booking.payableNow, 800);
      expect(booking.balanceDueLater, 800);
      expect(booking.payment?.id, 49);
      expect(booking.payment?.hasPaymentProof, isTrue);
      expect(booking.bookingSlots.single.price, 1600);
      expect(booking.toJson()['user_id'], 19);
      expect(booking.toJson()['vendor_id'], 19);
    });

    test('parses customer user id from candidate-shaped futsal payload', () {
      final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
        'id': 9,
        'booking_date': '2026-08-12',
        'candidate': <String, dynamic>{'id': 73, 'name': 'Dilli Bhandari'},
      });

      expect(booking.playerId, 73);
      expect(booking.playerName, 'Dilli Bhandari');
    });

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
              'venue': <String, dynamic>{
                'id': 1,
                'name': 'Dhananjay sports',
                'vendor': <String, dynamic>{'id': 41},
              },
              'customer': <String, dynamic>{'id': 73, 'name': 'Dilli Bhandari'},
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
      expect(booking.vendorId, 41);
      expect(booking.playerId, 73);
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
      expect(bookings.single.status, BookingStatus.rejected);
    });

    test('parses booked extras even when product uses legacy field names', () {
      final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
        'id': 26,
        'booking_date': '2026-10-02',
        'booking_extra_items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 41,
            'venue_product_id': 9,
            'product_name': 'Archived water',
            'qty': 3,
            'price': 50,
          },
        ],
      });

      expect(booking.extraItems, hasLength(1));
      expect(booking.extraItems.single.productId, 9);
      expect(booking.extraItems.single.name, 'Archived water');
      expect(booking.extraItems.single.quantity, 3);
      expect(booking.extraItems.single.unitPrice, 50);
      expect(booking.extraItems.single.totalAmount, 150);
      expect(booking.extraItemsCount, 3);
      expect(booking.extraItemsTotal, 150);
    });

    test('adds products once when calculating confirmed completion amount', () {
      final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
        'id': 26,
        'booking_status': 'confirmed',
        'total_amount': 2000,
        'paid_amount': 500,
        'balance_due': 1500,
        'extra_items': <Map<String, dynamic>>[
          <String, dynamic>{
            'product_id': 9,
            'name': 'Water',
            'quantity': 2,
            'unit_price': 50,
          },
        ],
      });

      expect(booking.bookingTotal, 2000);
      expect(booking.grandTotal, 2100);
      expect(booking.amountDueForCompletion, 1600);
    });

    test('does not add products again to a completed booking due', () {
      final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
        'id': 26,
        'booking_status': 'completed',
        'payment_status': 'partial',
        'total_amount': 2000,
        'paid_amount': 600,
        // The server's final due already includes every completed charge.
        'balance_due': 1500,
        'extra_items': <Map<String, dynamic>>[
          <String, dynamic>{
            'product_id': 9,
            'name': 'Water',
            'quantity': 2,
            'unit_price': 50,
          },
        ],
      });

      expect(booking.extraItemsTotal, 100);
      expect(booking.amountDueForCollection, 1500);
    });

    test('fully paid completed booking has no collectible due', () {
      final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
        'id': 26,
        'booking_status': 'completed',
        'payment_status': 'paid',
        'total_amount': 2000,
        'paid_amount': 2000,
        'balance_due': 0,
      });

      expect(booking.amountDueForCollection, 0);
    });
  });
}
