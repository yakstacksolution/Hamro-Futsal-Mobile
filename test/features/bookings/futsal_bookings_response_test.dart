import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/paginated_bookings.dart';

/// The live `/futsal-bookings?date_filter=all&status=all` response (the
/// vendor's view), trimmed to the rows that each show a different shape.
const String _json = r'''
{
  "status": "success",
  "message": "Futsal bookings fetched successfully.",
  "data": {
    "items": [
      {
        "id": 536, "user_id": null, "venue_id": 1, "vendor_id": 4,
        "booking_code": "BK-T0N2JOM4", "booking_type": "manual",
        "series_parent_id": 536, "is_recurring": false, "is_series_anchor": true,
        "recurrence_type": null, "recurrence_start_date": null, "recurrence_end_date": null,
        "booking_date": "2026-10-03", "start_time": "18:00:00", "end_time": "19:00:00",
        "slot_count": 1, "price_per_slot": 2500, "subtotal": 2500,
        "discount_amount": 0, "completion_discount": 0, "tax_amount": 0, "extra_amount": 0,
        "advance_amount": 1250, "partial_amount": 0, "payable_now": 1250,
        "balance_due_later": 1250, "total_amount": 2500,
        "payment_status": "paid", "booking_status": "completed",
        "cancellation_reason": null, "status": "completed",
        "can_review": false, "review_submitted": false, "notes": null,
        "customer_name": "laxmi", "customer_phone": "986524252", "customer_email": null,
        "created_at": "2026-09-28 21:01:35",
        "venue": {"id": 1, "name": "Dhananjay sport"},
        "court": {"id": 6, "name": "Shidartha"},
        "coupon": null,
        "payments": [
          {"id": 612, "payment_method": "cash", "payment_type": "cash", "amount": 1250,
           "status": "success", "verification_status": "verified", "payment_proof": null,
           "payment_proof_url": null, "has_payment_proof": false, "payment_note": null,
           "created_at": "2026-09-28 21:01:35"},
          {"id": 616, "payment_method": "cash", "payment_type": "cash", "amount": 650,
           "status": "success", "verification_status": "verified", "payment_proof": null,
           "payment_proof_url": null, "has_payment_proof": false,
           "payment_note": "Received at counter (manual booking)",
           "created_at": "2026-09-28 21:01:37"},
          {"id": 643, "payment_method": "cash", "payment_type": "cash", "amount": 600,
           "status": "success", "verification_status": "verified", "payment_proof": null,
           "payment_proof_url": null, "has_payment_proof": false,
           "payment_note": "Captured on booking completion.",
           "created_at": "2026-09-30 11:33:31"}
        ],
        "paid_amount": 2500, "cash_paid_amount": 2500, "online_paid_amount": 0,
        "payment_breakdown": [
          {"payment_method": "cash", "payment_type": "cash", "amount": 2500, "count": 3}
        ],
        "balance_due": 0, "review": null,
        "booking_slots": [
          {"id": 537, "slot_date": "2026-10-03", "slot_start": "18:00:00",
           "slot_end": "19:00:00", "slot_price": 2500, "status": "completed"}
        ],
        "extra_items": []
      },
      {
        "id": 557, "user_id": null, "venue_id": 1, "vendor_id": 4,
        "booking_code": "BK-QL8E1MXW", "booking_type": "manual",
        "booking_date": "2026-10-01", "start_time": "20:33:00", "end_time": "21:33:00",
        "slot_count": 1, "price_per_slot": 1200, "subtotal": 1200,
        "extra_amount": 0, "advance_amount": 600, "partial_amount": 0, "payable_now": 600,
        "balance_due_later": 600, "total_amount": 1200,
        "payment_status": "partial", "booking_status": "confirmed",
        "cancellation_reason": null, "status": "confirmed",
        "customer_name": "raj", "customer_phone": "9853552655", "customer_email": null,
        "created_at": "2026-09-30 22:37:02",
        "venue": {"id": 1, "name": "Dhananjay sport"},
        "court": {"id": 6, "name": "Shidartha"},
        "coupon": null,
        "payments": [
          {"id": 646, "payment_method": "cash", "payment_type": "cash", "amount": 600,
           "status": "pending", "verification_status": "pending", "payment_proof": null,
           "payment_proof_url": null, "has_payment_proof": false, "payment_note": null,
           "created_at": "2026-09-30 22:37:02"}
        ],
        "paid_amount": 0, "cash_paid_amount": 0, "online_paid_amount": 0,
        "payment_breakdown": [],
        "balance_due": 1200, "review": null,
        "booking_slots": [
          {"id": 558, "slot_date": "2026-10-01", "slot_start": "20:33:00",
           "slot_end": "21:33:00", "slot_price": 1200, "status": "confirmed"}
        ],
        "extra_items": []
      },
      {
        "id": 529, "user_id": null, "venue_id": 2, "vendor_id": 4,
        "booking_code": "BK-H6NZ8IP5", "booking_type": "manual",
        "booking_date": "2026-10-01", "start_time": "12:00:00", "end_time": "13:00:00",
        "slot_count": 1, "price_per_slot": 1200, "subtotal": 1200,
        "extra_amount": 0, "advance_amount": 600, "payable_now": 600,
        "balance_due_later": 600, "total_amount": 1200,
        "payment_status": "paid", "booking_status": "confirmed", "status": "confirmed",
        "customer_name": "Ram", "customer_phone": "98546464",
        "created_at": "2026-09-28 16:14:10",
        "venue": {"id": 2, "name": "Dhanawantary Sports"},
        "court": {"id": 14, "name": "Court 1"},
        "coupon": null,
        "payments": [
          {"id": 603, "payment_method": "cash", "payment_type": "cash", "amount": 1200,
           "status": "success", "verification_status": "verified", "payment_proof": null,
           "payment_proof_url": null, "has_payment_proof": false, "payment_note": "Hi",
           "created_at": "2026-09-28 16:14:10"}
        ],
        "paid_amount": 1200, "cash_paid_amount": 1200, "online_paid_amount": 0,
        "payment_breakdown": [
          {"payment_method": "cash", "payment_type": "cash", "amount": 1200, "count": 1}
        ],
        "balance_due": 0, "review": null,
        "booking_slots": [], "extra_items": []
      },
      {
        "id": 549, "user_id": 19, "venue_id": 1, "vendor_id": 4,
        "booking_code": "BK-9HVOVA9M", "booking_type": "regular",
        "booking_date": "2026-09-30", "start_time": "20:33:00", "end_time": "21:33:00",
        "total_amount": 1200, "payment_status": "paid",
        "booking_status": "completed", "status": "completed",
        "can_review": true, "review_submitted": false,
        "customer_name": "Rosnnnnn", "customer_phone": "900088",
        "customer_email": "test01@gmail.com",
        "created_at": "2026-09-28 21:52:23",
        "venue": {"id": 1, "name": "Dhananjay sport"},
        "court": {"id": 6, "name": "Shidartha"},
        "payments": [
          {"id": 629, "payment_method": "cash", "payment_type": "cash", "amount": 600,
           "status": "success", "verification_status": "verified",
           "payment_proof": "payment-proofs/19/z.jpg",
           "payment_proof_url": "/storage/payment-proofs/19/z.jpg",
           "has_payment_proof": true, "payment_note": "Hamro-Futsal :- Shidartha :- PAID",
           "created_at": "2026-09-28 21:52:23"}
        ],
        "paid_amount": 1200, "cash_paid_amount": 1200, "online_paid_amount": 0,
        "payment_breakdown": [
          {"payment_method": "cash", "payment_type": "cash", "amount": 1200, "count": 2}
        ],
        "balance_due": 0, "review": null, "booking_slots": [], "extra_items": []
      }
    ],
    "pagination": {"current_page": 1, "last_page": 4, "per_page": 10,
                   "total": 39, "from": 1, "to": 10, "has_more_pages": true}
  }
}
''';

PaginatedBookings _page() => PaginatedBookings.fromResponse(jsonDecode(_json));

BookingModel _byId(int id) => _page().items.firstWhere((b) => b.id == id);

void main() {
  group('futsal bookings response', () {
    test('reads the page and its pagination', () {
      final PaginatedBookings page = _page();
      expect(page.items, hasLength(4));
      expect(page.currentPage, 1);
      expect(page.lastPage, 4);
      expect(page.perPage, 10);
      expect(page.total, 39);
      expect(page.hasMorePages, isTrue);
    });

    test('reads a walk-in booking with no player account', () {
      final BookingModel b = _byId(536);
      expect(b.bookingRef, 'BK-T0N2JOM4');
      expect(b.bookingType, 'manual');
      expect(b.playerId, isNull);
      expect(b.vendorId, 4);
      expect(b.playerName, 'laxmi');
      expect(b.playerPhone, '986524252');
      expect(b.playerEmail, isNull);
      expect(b.futsalName, 'Dhananjay sport');
      expect(b.courtName, 'Shidartha');
      expect(b.courtId, 6);
      expect(b.status, BookingStatus.completed);
      expect(b.cancellationReason, isNull);
      expect(b.payments, hasLength(3));
      expect(b.bookingSlots.single.price, 2500);
    });

    test('reads the cash/online split and the payment breakdown', () {
      final BookingModel b = _byId(536);
      expect(b.paidAmount, 2500);
      expect(b.cashPaidAmount, 2500);
      expect(b.onlinePaidAmount, 0);
      expect(b.paymentBreakdown, hasLength(1));
      expect(b.paymentBreakdown.single.method, 'cash');
      expect(b.paymentBreakdown.single.amount, 2500);
      expect(b.paymentBreakdown.single.count, 3);

      expect(_byId(557).paymentBreakdown, isEmpty);
    });

    test('a reported zero balance is settled, not the planned balance', () {
      // Confirmed and paid in full up front: nothing left to collect, even
      // though `balance_due_later` still says 600.
      final BookingModel paid = _byId(529);
      expect(paid.balanceDue, 0);
      expect(paid.balanceDueLater, 600);
      expect(paid.remainingBookingBalance, 0);
      expect(paid.amountDueForCompletion, 0);

      expect(_byId(536).remainingBookingBalance, 0);
      expect(_byId(536).amountDueForCollection, 0);
    });

    test('a pending advance leaves the whole amount due', () {
      final BookingModel b = _byId(557);
      expect(b.paymentStatus, 'partial');
      expect(b.paidAmount, 0);
      expect(b.effectivePaidAmount, 0);
      expect(b.remainingBookingBalance, 1200);
      expect(b.amountDueForCompletion, 1200);
    });

    test('keeps the new fields through toJson', () {
      final BookingModel b = _byId(536);
      expect(BookingModel.fromJson(b.toJson()), b);
    });
  });
}
