import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';

/// The live `GET /api/futsal-bookings?status=confirmed` answer: manual
/// bookings with split cash/online payments, a booking whose slots are not
/// back to back, and a fully paid one.
void main() {
  late PaginatedBookings page;

  setUpAll(() {
    final String raw = File(
      'test/fixtures/futsal_bookings_confirmed_response.json',
    ).readAsStringSync();
    page = PaginatedBookings.fromResponse(jsonDecode(raw));
  });

  test('reads the items and the pagination block', () {
    expect(page.items.map((BookingModel b) => b.id), <int>[561, 560, 559]);
    expect(page.currentPage, 1);
    expect(page.lastPage, 1);
    expect(page.perPage, 10);
    expect(page.total, 3);
    expect(page.hasMorePages, isFalse);
  });

  test('a split cash + online partial payment', () {
    final BookingModel b = page.items[0];
    expect(b.bookingRef, 'BK-UDAXKICK');
    expect(b.bookingType, 'manual');
    expect(b.status, BookingStatus.confirmed);
    expect(b.venueId, 1);
    expect(b.courtId, 6);
    expect(b.vendorId, 4);
    expect(b.futsalName, 'Dhananjay sport');
    expect(b.courtName, 'Shidartha');
    // A walk-in: no app user, the customer comes from customer_* fields.
    expect(b.playerId, isNull);
    expect(b.playerName, 'Fte');
    expect(b.playerPhone, '9852353522');
    expect(b.playerEmail, isNull);
    expect(b.date, DateTime(2026, 10, 3));
    expect(b.startTime, '20:33:00');
    expect(b.endTime, '21:33:00');
    expect(b.seriesParentId, 561);
    expect(b.isRecurring, isFalse);
    expect(b.isSeriesAnchor, isTrue);

    expect(b.amount, 2500);
    expect(b.subtotal, 2500);
    expect(b.pricePerSlot, 2500);
    expect(b.advanceAmount, 1250);
    expect(b.payableNow, 1250);
    expect(b.balanceDueLater, 1250);
    expect(b.paymentStatus, 'partial');
    expect(b.paidAmount, 700);
    expect(b.cashPaidAmount, 200);
    expect(b.onlinePaidAmount, 500);
    expect(b.balanceDue, 1800);
    expect(b.reportsBalanceDue, isTrue);
    // What is left is the server's balance_due, not balance_due_later.
    expect(b.remainingBookingBalance, 1800);
    expect(b.amountDueForCompletion, 1800);

    expect(b.payments, hasLength(2));
    expect(b.payments[0].id, 652);
    expect(b.payments[0].type, 'cash');
    expect(b.payments[0].amount, 200);
    expect(b.payments[0].verificationStatus, 'verified');
    expect(b.payments[0].hasPaymentProof, isFalse);
    expect(b.payments[1].type, 'online');
    expect(b.payments[1].amount, 500);

    expect(b.paymentBreakdown, hasLength(2));
    expect(b.paymentBreakdown[0].type, 'cash');
    expect(b.paymentBreakdown[0].amount, 200);
    expect(b.paymentBreakdown[0].count, 1);
    expect(b.paymentBreakdown[1].type, 'online');
    expect(b.paymentBreakdown[1].amount, 500);

    expect(b.coupon, isNull);
    expect(b.review, isNull);
    expect(b.canReview, isFalse);
    expect(b.reviewSubmitted, isFalse);
    expect(b.extraItems, isEmpty);
    expect(b.createdAt, DateTime(2026, 10, 1, 20, 46, 22));
  });

  test('a booking whose slots are not back to back keeps each slot', () {
    final BookingModel b = page.items[1];
    expect(b.slotCount, 3);
    expect(b.startTime, '18:00:00');
    expect(b.endTime, '23:33:00');
    expect(
      b.bookingSlots.map((BookingSlotModel s) => (s.startTime, s.endTime)),
      <(String, String)>[
        ('18:00:00', '19:00:00'),
        ('20:33:00', '21:33:00'),
        ('22:34:00', '23:33:00'),
      ],
    );
    expect(b.bookingSlots.first.id, 561);
    expect(b.bookingSlots.first.date, DateTime(2026, 10, 2));
    expect(b.bookingSlots.first.price, 1200);
    expect(b.bookingSlots.first.status, 'confirmed');
    expect(b.amount, 3600);
    expect(b.paidAmount, 600);
    expect(b.balanceDue, 3000);
    expect(b.amountDueForCompletion, 3000);
  });

  test('a fully paid booking owes nothing', () {
    final BookingModel b = page.items[2];
    expect(b.paymentStatus, 'paid');
    expect(b.paidAmount, 1200);
    expect(b.balanceDue, 0);
    // A reported zero is settled — it must not fall back to balance_due_later.
    expect(b.reportsBalanceDue, isTrue);
    expect(b.remainingBookingBalance, 0);
    expect(b.amountDueForCompletion, 0);
  });
}
