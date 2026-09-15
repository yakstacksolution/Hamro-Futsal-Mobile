import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_shared_widgets.dart';

/// The live `/bookings` list response, verbatim (trimmed only of repeated
/// rows that add no new shape).
const String _json = r'''
{
  "status": "success",
  "message": "Bookings fetched successfully.",
  "data": {
    "items": [
      {
        "id": 419, "user_id": 4, "venue_id": 40, "vendor_id": 20,
        "booking_code": "BK-RQOFZJPT", "booking_type": "regular",
        "series_parent_id": 419, "is_recurring": false, "is_series_anchor": true,
        "recurrence_type": null, "recurrence_start_date": null, "recurrence_end_date": null,
        "booking_date": "2026-09-15", "start_time": "07:00:00", "end_time": "08:00:00",
        "slot_count": 1, "price_per_slot": 1150, "subtotal": 1150,
        "discount_amount": 0, "completion_discount": 0, "tax_amount": 0, "extra_amount": 0,
        "advance_amount": 230, "partial_amount": 0, "payable_now": 230,
        "balance_due_later": 920, "total_amount": 1150,
        "payment_status": "paid", "booking_status": "completed",
        "cancellation_reason": null, "status": "completed",
        "can_review": true, "review_submitted": false, "notes": null,
        "customer_name": "Dilli Bhandari", "customer_phone": "985655336655",
        "customer_email": "officialdilli1@gmail.com",
        "created_at": "2026-09-12 19:20:52",
        "venue": {"id": 40, "name": "Harisiddhi futsal"},
        "court": {"id": 41, "name": "Court 1"},
        "coupon": null,
        "payments": [
          {"id": 452, "payment_method": "cash", "payment_type": "cash", "amount": 230,
           "status": "success", "verification_status": "verified",
           "payment_proof": "payment-proofs/4/a.jpg",
           "payment_proof_url": "/storage/payment-proofs/4/a.jpg",
           "has_payment_proof": true, "payment_note": "Hamro-Futsal :- Court 1 :- TEST",
           "created_at": "2026-09-12 19:20:53"},
          {"id": 453, "payment_method": "cash", "payment_type": "cash", "amount": 920,
           "status": "success", "verification_status": "verified",
           "payment_proof": null, "payment_proof_url": null, "has_payment_proof": false,
           "payment_note": "Captured on booking completion.",
           "created_at": "2026-09-12 19:24:16"}
        ],
        "paid_amount": 1150, "balance_due": 0, "review": null,
        "booking_slots": [
          {"id": 420, "slot_date": "2026-09-15", "slot_start": "07:00:00",
           "slot_end": "08:00:00", "slot_price": 1150, "status": "completed"}
        ],
        "extra_items": []
      },
      {
        "id": 395, "user_id": 4, "venue_id": 38, "vendor_id": 20,
        "booking_code": "BK-GR3SD2PS", "booking_type": "regular",
        "booking_date": "2026-09-13", "start_time": "06:00:00", "end_time": "07:00:00",
        "slot_count": 1, "price_per_slot": 1400, "subtotal": 1400,
        "discount_amount": 500, "completion_discount": 0, "tax_amount": 0,
        "extra_amount": 0, "advance_amount": 180, "payable_now": 180,
        "balance_due_later": 720, "total_amount": 900,
        "payment_status": "paid", "booking_status": "completed", "status": "completed",
        "can_review": false, "review_submitted": true, "notes": null,
        "customer_name": "Dilli Bhandari", "customer_phone": "985655336655",
        "created_at": "2026-09-11 22:01:29",
        "venue": {"id": 38, "name": "UN park futsal"},
        "court": {"id": 39, "name": "court A"},
        "coupon": {"id": 6, "code": "FTL-VSWRQIWA", "title": "Reward coupon"},
        "payments": [],
        "paid_amount": 900, "balance_due": 0,
        "review": {"id": 9, "booking_id": 395, "rating": 5,
                   "review": "This is the best court ever", "status": "approved",
                   "created_at": "2026-09-11 22:21:12"},
        "booking_slots": [], "extra_items": []
      },
      {
        "id": 247, "user_id": 4, "venue_id": 38, "vendor_id": 20,
        "booking_code": "BK-5SDVDMKP", "booking_type": "regular",
        "booking_date": "2026-08-28", "start_time": "08:00:00", "end_time": "09:00:00",
        "total_amount": 1400, "payment_status": "paid",
        "booking_status": "completed", "status": "completed",
        "can_review": false, "review_submitted": true,
        "created_at": "2026-08-25 10:16:52",
        "venue": {"id": 38, "name": "UN park futsal"},
        "court": {"id": 39, "name": "court A"},
        "coupon": null, "payments": [], "paid_amount": 1400, "balance_due": 0,
        "review": {"id": 9, "booking_id": 395, "rating": 5,
                   "review": "This is the best court ever", "status": "approved",
                   "created_at": "2026-09-11 22:21:12"},
        "booking_slots": [], "extra_items": []
      },
      {
        "id": 242, "user_id": 4, "venue_id": 34, "vendor_id": 19,
        "booking_code": "BK-C7LBYLJ5", "booking_type": "regular",
        "booking_date": "2026-08-25", "start_time": "17:00:00", "end_time": "18:00:00",
        "slot_count": 1, "price_per_slot": 1150, "subtotal": 1150,
        "extra_amount": 100, "advance_amount": 575, "payable_now": 575,
        "balance_due_later": 675, "total_amount": 1250,
        "payment_status": "paid", "booking_status": "completed", "status": "completed",
        "can_review": false, "review_submitted": true,
        "created_at": "2026-08-24 21:50:38",
        "venue": {"id": 34, "name": "Goal zone futsal"},
        "court": {"id": 35, "name": "Court A"},
        "coupon": null, "payments": [], "paid_amount": 1250, "balance_due": 0,
        "review": {"id": 6, "booking_id": 242, "rating": 5, "review": "Sweet",
                   "status": "pending", "created_at": "2026-08-24 23:12:56"},
        "booking_slots": [],
        "extra_items": [
          {"id": 57, "product_id": 25, "name": "Water", "quantity": 4,
           "unit_price": 25, "total_amount": 100,
           "product": {"id": 25, "name": "Water", "price": 25, "is_active": true}}
        ]
      }
    ],
    "pagination": {"current_page": 1, "last_page": 1, "per_page": 10,
                   "total": 6, "from": 1, "to": 6, "has_more_pages": false}
  }
}
''';

List<BookingModel> _bookings() =>
    BookingModel.listFromResponse(jsonDecode(_json));

BookingModel _byId(int id) => _bookings().firstWhere((b) => b.id == id);

void main() {
  group('booking list response', () {
    test('parses every booking with its venue, court and slot', () {
      final list = _bookings();
      expect(list, hasLength(4));

      final b = _byId(419);
      expect(b.bookingRef, 'BK-RQOFZJPT');
      expect(b.futsalName, 'Harisiddhi futsal');
      expect(b.courtName, 'Court 1');
      expect(b.venueId, 40);
      expect(b.courtId, 41);
      expect(b.vendorId, 20);
      expect(b.playerId, 4);
      expect(b.date, DateTime(2026, 9, 15));
      expect(b.startTime, '07:00:00');
      expect(b.endTime, '08:00:00');
      expect(b.status, BookingStatus.completed);
      expect(b.amount, 1150);
      expect(b.paidAmount, 1150);
      expect(b.balanceDue, 0);
      expect(b.paymentStatus, 'paid');
      expect(b.bookingType, 'regular');
      expect(b.playerName, 'Dilli Bhandari');
      expect(b.playerPhone, '985655336655');
      expect(b.playerEmail, 'officialdilli1@gmail.com');
    });

    test('reads created_at as when the booking was placed', () {
      // Placed on the 12th for a slot on the 15th — the two differ, which is
      // exactly why the card shows both.
      final b = _byId(419);
      expect(b.createdAt, DateTime.parse('2026-09-12 19:20:52').toLocal());
      expect(b.date, DateTime(2026, 9, 15));

      for (final booking in _bookings()) {
        expect(booking.createdAt, isNotNull, reason: 'every row sends one');
      }
    });

    test('carries the money breakdown, coupon and extras', () {
      final discounted = _byId(395);
      expect(discounted.subtotal, 1400);
      expect(discounted.discountAmount, 500);
      expect(discounted.amount, 900);
      expect(discounted.advanceAmount, 180);
      expect(discounted.balanceDueLater, 720);
      expect(discounted.coupon?.code, 'FTL-VSWRQIWA');
      expect(discounted.coupon?.title, 'Reward coupon');

      final withExtras = _byId(242);
      expect(withExtras.extraAmount, 100);
      expect(withExtras.extraItems, hasLength(1));
      expect(withExtras.extraItems.single.name, 'Water');
      expect(withExtras.extraItems.single.quantity, 4);
      expect(withExtras.extraItemsCount, 4);
    });

    test('reads the payment rows', () {
      final b = _byId(419);
      expect(b.payments, hasLength(2));
      expect(b.payments.first.amount, 230);
      expect(b.payments.first.hasPaymentProof, isTrue);
      expect(b.payments.last.amount, 920);
      expect(b.payments.last.hasPaymentProof, isFalse);
      expect(
        b.payments.first.createdAt,
        DateTime.parse('2026-09-12 19:20:53').toLocal(),
      );
    });

    test('reads the review flags', () {
      expect(_byId(419).canReview, isTrue);
      expect(_byId(419).reviewSubmitted, isFalse);
      expect(_byId(419).review, isNull);

      expect(_byId(395).canReview, isFalse);
      expect(_byId(395).reviewSubmitted, isTrue);
      expect(_byId(395).review?.rating, 5);
      expect(_byId(395).review?.review, 'This is the best court ever');
    });

    test("another booking's review is not shown on this card", () {
      // The server sends booking 247 the review of booking 395; attaching it
      // would put someone else's words under the wrong booking.
      final b = _byId(247);
      expect(b.reviewSubmitted, isTrue);
      expect(b.review, isNull);

      // A review whose booking_id does match is kept.
      expect(_byId(242).review?.bookingId, 242);
    });

    testWidgets('the card shows both dates', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(411, 900);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: BookingCard(booking: _byId(419)),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final String text = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text t) => t.data ?? '')
          .join(' | ');

      expect(tester.takeException(), isNull);
      // The slot …
      expect(find.text('DATE'), findsOneWidget);
      expect(text, contains('Sep 15, 2026'));
      expect(find.text('TIME'), findsOneWidget);
      // … and when it was booked.
      expect(find.text('BOOKED ON'), findsOneWidget);
      // How the booking was taken — `booking_type: regular`.
      expect(find.text('TYPE'), findsOneWidget);
      expect(text, contains('Regular'));
      expect(text, contains('Sep 12, 2026 · 7:20 PM'));
      expect(text, contains('NPR 1,150'));
      expect(text, contains('COMPLETED'));
    });

    test('reads booking_type', () {
      for (final b in _bookings()) {
        expect(b.bookingType, 'regular');
      }
    });

    testWidgets('every booking in the response lays out as a clean grid', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 2400);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  for (final BookingModel b in _bookings())
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: BookingCard(booking: b),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      // Four cards, each a full 2x2: every row of the response carries a
      // date, a time, a reference and a created_at.
      expect(find.byType(BookingCard), findsNWidgets(4));
      expect(find.text('DATE'), findsNWidgets(4));
      expect(find.text('TIME'), findsNWidgets(4));
      expect(find.text('REFERENCE'), findsNWidgets(4));
      expect(find.text('TYPE'), findsNWidgets(4));
      expect(find.text('BOOKED ON'), findsNWidgets(4));
      expect(find.text('Regular'), findsNWidgets(4));
      // Every row in this response is settled, so each card's last pair is
      // completed by what was paid — six cells, three full rows, no gaps.
      expect(find.text('PAID'), findsNWidgets(4));
      expect(find.byType(DataCardCell), findsNWidgets(24));
    });
  });
}
