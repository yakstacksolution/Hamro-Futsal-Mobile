import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/bookings/data/model/booking_model.dart';

void main() {
  test('parses the live /api/futsal-bookings payload', () {
    final dynamic payload = jsonDecode(_json);
    final List<BookingModel> bookings = BookingModel.listFromResponse(payload);

    expect(bookings, hasLength(2));

    final BookingModel manual = bookings.first;
    expect(manual.id, 28);
    expect(manual.bookingType, 'manual');
    expect(manual.playerId, isNull);
    expect(manual.playerName, 'RAKESH');
    expect(manual.amount, 1320);
    expect(manual.extraAmount, 120);
    expect(manual.completionDiscount, 0);
    expect(manual.partialAmount, 0);
    expect(manual.extraItemsTotal, 120);
    expect(manual.extraItemsCount, 4);
    // total_amount already includes extra_amount — no double counting.
    expect(manual.bookingTotal, 1200);
    expect(manual.grandTotal, 1320);
    expect(manual.status, BookingStatus.completed);
    expect(manual.amountDueForCollection, 35);
    expect(manual.payments, hasLength(2));
    expect(manual.payments.first.type, 'cash');
    expect(
      manual.payments.last.createdAt,
      DateTime.parse('2026-07-27 22:01:20'),
    );
    expect(manual.extraItems.first.productPrice, 25);
    expect(manual.extraItems.first.productIsActive, isTrue);
    expect(manual.createdAt, DateTime.parse('2026-07-26 10:08:05'));

    final BookingModel recurring = bookings.last;
    expect(recurring.bookingType, 'online');
    expect(recurring.isRecurring, isTrue);
    expect(recurring.isSeriesAnchor, isFalse);
    expect(recurring.seriesParentId, 15);
    expect(recurring.recurrenceType, 'weekly');
    expect(recurring.extraAmount, 0);
    expect(recurring.totalsIncludeExtras, isFalse);
    expect(recurring.bookingTotal, 1200);
    expect(recurring.grandTotal, 1200);
    expect(recurring.remainingBookingBalance, 1200);
  });

  test('prefers booking_status over generic status for booking state', () {
    final List<BookingModel> bookings = BookingModel.listFromResponse(
      <String, dynamic>{
        'status': 'success',
        'message': 'Futsal bookings fetched successfully.',
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 237,
              'booking_code': 'BK-JLURIQQJ',
              'booking_date': '2026-08-24',
              'start_time': '14:00:00',
              'end_time': '15:00:00',
              'total_amount': 1200,
              'payment_status': 'pending',
              'booking_status': 'cancelled',
              'status': 'unconfirmed',
              'payments': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 257,
                  'payment_method': 'cash',
                  'amount': 1200,
                  'status': 'failed',
                  'verification_status': 'rejected',
                },
              ],
              'venue': <String, dynamic>{'id': 47, 'name': 'Rising 4 Futsal'},
              'court': <String, dynamic>{'id': 47, 'name': 'Court A'},
            },
          ],
        },
      },
    );

    final BookingModel booking = bookings.single;
    expect(booking.status, BookingStatus.cancelled);
    expect(booking.paymentStatus, 'pending');
    expect(booking.payment?.status, 'failed');
  });

  test('tolerates a payload where every optional field is null', () {
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 99,
      'user_id': null,
      'booking_code': null,
      'booking_type': null,
      'series_parent_id': null,
      'is_recurring': null,
      'is_series_anchor': null,
      'recurrence_type': null,
      'recurrence_start_date': null,
      'recurrence_end_date': null,
      'booking_date': null,
      'start_time': null,
      'end_time': null,
      'slot_count': null,
      'price_per_slot': null,
      'subtotal': null,
      'discount_amount': null,
      'completion_discount': null,
      'tax_amount': null,
      'extra_amount': null,
      'advance_amount': null,
      'partial_amount': null,
      'payable_now': null,
      'balance_due_later': null,
      'total_amount': null,
      'payment_status': null,
      'booking_status': null,
      'status': null,
      'notes': null,
      'customer_name': null,
      'customer_phone': null,
      'customer_email': null,
      'created_at': null,
      'venue': null,
      'court': <String, dynamic>{'id': null, 'name': null},
      'coupon': null,
      'payments': null,
      'paid_amount': null,
      'balance_due': null,
      'booking_slots': null,
      'extra_items': null,
    });

    expect(booking.bookingType, isNull);
    expect(booking.isRecurring, isFalse);
    expect(booking.courtName, '');
    expect(booking.extraAmount, 0);
    expect(booking.status, BookingStatus.pending);
    expect(booking.payments, isEmpty);
    expect(booking.extraItems, isEmpty);
    expect(booking.payment, isNull);
  });

  test('money getters always return a double, never an int or null', () {
    // `num.clamp` hands back the limit object, so a clamped-to-zero figure used
    // to leak an `int` out of these `double` getters and blow up the details
    // page's type check.
    final BookingModel booking = BookingModel.fromJson(<String, dynamic>{
      'id': 28,
      'booking_status': 'confirmed',
      // Products exceed the recorded balance, forcing every floor-at-zero path.
      'extra_amount': 500,
      'total_amount': 300,
      'balance_due': 100,
      'balance_due_later': 100,
      'paid_amount': 900,
      'extra_items': <Map<String, dynamic>>[
        <String, dynamic>{
          'product_id': 4,
          'name': 'Churot',
          'quantity': 1,
          'unit_price': 25,
          'total_amount': 25,
        },
      ],
    });

    for (final double value in <double>[
      booking.bookingTotal,
      booking.grandTotal,
      booking.extraItemsTotal,
      booking.effectivePaidAmount,
      booking.remainingBookingBalance,
      booking.amountDueForCompletion,
      booking.amountDueForCollection,
    ]) {
      expect(value, isA<double>());
    }
    expect(booking.remainingBookingBalance, 0.0);
    expect(booking.bookingTotal, 0.0);
  });
}

const String _json = '''
{
  "status": "success",
  "data": [
    {
      "id": 28, "user_id": null, "booking_code": "BK-OPN6VT1G", "booking_type": "manual",
      "series_parent_id": 28, "is_recurring": false, "is_series_anchor": true,
      "recurrence_type": null, "booking_date": "2026-07-27",
      "start_time": "06:00:00", "end_time": "07:00:00", "slot_count": 1,
      "price_per_slot": 1200, "subtotal": 1200, "discount_amount": 0,
      "completion_discount": 0, "tax_amount": 0, "extra_amount": 120,
      "advance_amount": 600, "partial_amount": 0, "payable_now": 600,
      "balance_due_later": 720, "total_amount": 1320, "payment_status": "partial",
      "booking_status": "completed", "status": "completed", "notes": null,
      "customer_name": "RAKESH", "customer_phone": "986454694",
      "customer_email": "officialdilli1@gmail.com", "created_at": "2026-07-26 10:08:05",
      "venue": {"id": 2, "name": "Dhanawantary Sports"},
      "court": {"id": 14, "name": "Court 1"}, "coupon": null,
      "payments": [
        {"id": 37, "payment_method": "cash", "payment_type": "cash", "amount": 1200,
         "status": "success", "verification_status": "verified", "payment_proof": null,
         "payment_proof_url": null, "has_payment_proof": false,
         "payment_note": "Paid at counter", "created_at": "2026-07-26 10:08:07"},
        {"id": 40, "payment_method": "cash", "payment_type": "cash", "amount": 85,
         "status": "success", "verification_status": "verified", "payment_proof": null,
         "payment_proof_url": null, "has_payment_proof": false,
         "payment_note": "Captured on booking completion.", "created_at": "2026-07-27 22:01:20"}
      ],
      "paid_amount": 1285, "balance_due": 35,
      "booking_slots": [
        {"id": 28, "slot_date": "2026-07-27", "slot_start": "06:00:00",
         "slot_end": "07:00:00", "slot_price": 1200, "status": "completed"}
      ],
      "extra_items": [
        {"id": 49, "product_id": 4, "name": "Churot", "quantity": 2, "unit_price": 25,
         "total_amount": 50,
         "product": {"id": 4, "name": "Churot", "price": 25, "is_active": true}},
        {"id": 50, "product_id": 2, "name": "Water", "quantity": 2, "unit_price": 35,
         "total_amount": 70,
         "product": {"id": 2, "name": "Water", "price": 35, "is_active": true}}
      ]
    },
    {
      "id": 26, "user_id": 4, "booking_code": "BK-8ZYZNZLN", "booking_type": "online",
      "series_parent_id": 15, "is_recurring": true, "is_series_anchor": false,
      "recurrence_type": "weekly", "recurrence_start_date": "2026-07-17",
      "recurrence_end_date": "2026-10-02", "booking_date": "2026-10-02",
      "start_time": "18:00:00", "end_time": "19:00:00", "slot_count": 1,
      "price_per_slot": 1200, "subtotal": 1200, "discount_amount": 0,
      "completion_discount": 0, "tax_amount": 0, "extra_amount": 0,
      "advance_amount": 600, "partial_amount": 0, "payable_now": 600,
      "balance_due_later": 600, "total_amount": 1200, "payment_status": "partial",
      "booking_status": "pending", "status": "pending", "notes": null,
      "customer_name": "Dilli Bhandari", "customer_phone": "985655336655",
      "customer_email": "officialdilli1@gmail.com", "created_at": "2026-07-16 19:24:06",
      "venue": {"id": 1, "name": "Dhananjay sport"},
      "court": {"id": 6, "name": "Shidartha"}, "coupon": null,
      "payments": [
        {"id": 34, "payment_method": "cash", "payment_type": "cash", "amount": 600,
         "status": "pending", "verification_status": "pending",
         "payment_proof": "payment-proofs/4/a.jpg",
         "payment_proof_url": "/storage/payment-proofs/4/a.jpg",
         "has_payment_proof": true, "payment_note": null,
         "created_at": "2026-07-16 19:24:06"}
      ],
      "paid_amount": 0, "balance_due": 1200,
      "booking_slots": [
        {"id": 26, "slot_date": "2026-10-02", "slot_start": "18:00:00",
         "slot_end": "19:00:00", "slot_price": 1200, "status": "active"}
      ],
      "extra_items": []
    }
  ]
}
''';
