import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_quote_model.dart';
import 'package:hamro_futsal/features/futsal_details/presentation/bloc/booking_hold/booking_hold_bloc.dart';

/// `POST /booking-holds` for one range, as staging answers it.
const String _single = '''
{
  "status": "success",
  "message": "Booking hold created successfully.",
  "data": {
    "hold": {
      "id": "dc4b8075-78bf-438f-987f-9a5f9388a6e9",
      "hold_token": "394985a1-fee3-4ee7-9e91-98737d4a0ec0",
      "venue_id": 1,
      "court_id": 6,
      "booking_date": "2026-10-02",
      "booking_dates": ["2026-10-02"],
      "start_time": "18:00:00",
      "end_time": "19:00:00",
      "status": "unavailable",
      "hold_status": "holding",
      "reason": "booking_hold",
      "is_recurring": false,
      "repeat_weeks": 1,
      "recurrence_type": null,
      "held_by_me": true,
      "expires_at": "2026-09-30T22:02:36+05:45",
      "step": "slot_selected",
      "metadata": []
    },
    "quote": {
      "price_details": {
        "subtotal": 1200,
        "discount_amount": 0,
        "extra_amount": 0,
        "booking_total": 1200,
        "advance_payable_now": 600,
        "balance_due_later": 600,
        "tax_amount": 0
      }
    }
  }
}
''';

Map<String, dynamic> _item(String id, int courtId, String start) =>
    <String, dynamic>{
      'hold': <String, dynamic>{
        'id': id,
        'hold_token': 'token-$id',
        'court_id': courtId,
        'booking_date': '2026-10-02',
        'start_time': start,
      },
      'quote': <String, dynamic>{
        'price_details': <String, dynamic>{'booking_total': 1200},
      },
    };

/// `POST /booking-holds` as staging answers it now: bare holds in
/// `data.holds`, each paired with its quote in `data.items`.
const String _holdsWithItems = """
{
  "status": "success",
  "message": "Booking holds created successfully.",
  "data": {
    "holds": [
      {
        "id": "bd053e40-833a-4466-a12f-b2f9c29abc53",
        "hold_token": "8957f6e9-64c0-4e9d-87b5-c0f9300eaf15",
        "venue_id": 34, "court_id": 35, "booking_date": "2026-10-07",
        "booking_dates": ["2026-10-07"],
        "start_time": "17:00:00", "end_time": "18:00:00",
        "status": "unavailable", "hold_status": "holding",
        "reason": "booking_hold", "is_recurring": false, "repeat_weeks": 1,
        "recurrence_type": null, "held_by_me": true,
        "expires_at": "2026-10-04T23:06:11+05:45", "step": "slot_selected",
        "metadata": {"hold_group": "bfa7c346-a235-4dfe-8f4b-e3a5810cf1cd"}
      }
    ],
    "items": [
      {
        "hold": {
          "id": "bd053e40-833a-4466-a12f-b2f9c29abc53",
          "hold_token": "8957f6e9-64c0-4e9d-87b5-c0f9300eaf15",
          "venue_id": 34, "court_id": 35, "booking_date": "2026-10-07",
          "booking_dates": ["2026-10-07"],
          "start_time": "17:00:00", "end_time": "18:00:00",
          "status": "unavailable", "hold_status": "holding",
          "reason": "booking_hold", "is_recurring": false, "repeat_weeks": 1,
          "recurrence_type": null, "held_by_me": true,
          "expires_at": "2026-10-04T23:06:11+05:45", "step": "slot_selected",
          "metadata": {"hold_group": "bfa7c346-a235-4dfe-8f4b-e3a5810cf1cd"}
        },
        "quote": {
          "booking_summary": {
            "venue_id": 34, "court_id": 35, "venue_name": "Goal zone futsal",
            "court_name": "Court A", "court_image": null, "surface_type": null,
            "capacity": 15, "session_count": 1,
            "booking_dates": ["2026-10-07"],
            "start_time": "17:00:00", "end_time": "18:00:00",
            "payment_qr": [{"id": 607, "url": "https://example.com/qr.jpg"}]
          },
          "coupon": null,
          "price_details": {
            "subtotal": 1150, "discount_amount": 0, "extra_amount": 0,
            "booking_total": 1150, "advance_payable_now": 575,
            "balance_due_later": 575, "tax_amount": 0
          },
          "calculation_list": [
            {"label": "Subtotal (1 sessions)", "key": "subtotal", "amount": 1150},
            {"label": "Coupon discount", "key": "discount_amount", "amount": 0},
            {"label": "Extra items", "key": "extra_amount", "amount": 0},
            {"label": "Booking total", "key": "booking_total", "amount": 1150},
            {"label": "Advance payable now", "key": "advance_payable_now", "amount": 575},
            {"label": "Balance due later", "key": "balance_due_later", "amount": 575}
          ],
          "extra_items": [],
          "items": [
            {"booking_date": "2026-10-07", "slot_count": 1, "subtotal": 1150,
             "discount_amount": 0, "extra_amount": 0, "advance_amount": 575,
             "total_amount": 1150, "extra_items": []}
          ]
        },
        "created": true
      }
    ]
  }
}
""";

void main() {
  test('a hold request is one list item, with no booking_dates', () {
    const BookingHoldRequest request = BookingHoldRequest(
      venueId: 1,
      courtId: 6,
      bookingDate: '2026-10-02',
      startTime: '18:00',
      endTime: '19:00',
    );
    expect(request.toJson(), <String, dynamic>{
      'venue_id': 1,
      'court_id': 6,
      'booking_date': '2026-10-02',
      'start_time': '18:00',
      'end_time': '19:00',
    });
  });

  test('the single-hold answer reads as a list of one', () {
    final List<BookingHoldModel> holds = BookingHoldModel.listFromResponse(
      jsonDecode(_single),
    );
    expect(holds, hasLength(1));
    final BookingHoldModel hold = holds.single;
    expect(hold.id, 'dc4b8075-78bf-438f-987f-9a5f9388a6e9');
    expect(hold.hasId, isTrue);
    expect(hold.holdToken, '394985a1-fee3-4ee7-9e91-98737d4a0ec0');
    expect(hold.courtId, 6);
    expect(hold.startTime, '18:00:00');
    expect(hold.quote?.priceDetails?.bookingTotal, 1200);
  });

  test('several holds come back in the order sent', () {
    for (final Map<String, dynamic> payload in <Map<String, dynamic>>[
      // `data` is the list…
      <String, dynamic>{
        'data': <Map<String, dynamic>>[
          _item('a', 6, '18:00:00'),
          _item('b', 7, '19:00:00'),
        ],
      },
      // …or `data.holds` is.
      <String, dynamic>{
        'data': <String, dynamic>{
          'holds': <Map<String, dynamic>>[
            _item('a', 6, '18:00:00'),
            _item('b', 7, '19:00:00'),
          ],
        },
      },
    ]) {
      final List<BookingHoldModel> holds = BookingHoldModel.listFromResponse(
        payload,
      );
      expect(holds.map((BookingHoldModel h) => h.id), <String>['a', 'b']);
      expect(holds.map((BookingHoldModel h) => h.courtId), <int>[6, 7]);
      expect(holds.first.quote?.priceDetails?.bookingTotal, 1200);
    }
  });

  group('the booking price from several holds', () {
    test('the quote beside the list prices the booking', () {
      // Each hold carries only a booking_total; the whole booking's quote,
      // with its advance, sits beside the list. Reading the per-hold quote
      // showed "Advance to pay: Rs 0".
      final List<BookingHoldModel> holds = BookingHoldModel.listFromResponse(
        <String, dynamic>{
          'data': <String, dynamic>{
            'holds': <Map<String, dynamic>>[
              _item('a', 6, '18:00'),
              _item('b', 6, '18:00'),
            ],
            'quote': <String, dynamic>{
              'price_details': <String, dynamic>{
                'booking_total': 2400,
                'advance_payable_now': 1200,
                'balance_due_later': 1200,
              },
            },
          },
        },
      );
      // Each hold keeps its own quote; the booking's sits beside it.
      expect(
        holds.every((BookingHoldModel h) => h.bookingQuote != null),
        isTrue,
      );
      final BookingQuoteModel? quote = BookingHoldState(
        status: BookingHoldStatus.held,
        holds: holds,
      ).quote;
      expect(quote?.priceDetails?.advancePayableNow, 1200);
      // The booking's total, not the sum of two copies of it.
      expect(quote?.priceDetails?.bookingTotal, 2400);
    });

    test('without a shared quote, the holds\' own quotes add up', () {
      Map<String, dynamic> priced(String id) => <String, dynamic>{
        'hold': <String, dynamic>{'id': id, 'hold_token': 't-$id'},
        'quote': <String, dynamic>{
          'price_details': <String, dynamic>{
            'booking_total': 1200,
            'advance_payable_now': 600,
          },
          'calculation_list': <Map<String, dynamic>>[
            <String, dynamic>{
              'label': 'Pay now (advance)',
              'key': 'advance_payable_now',
              'amount': 600,
            },
          ],
        },
      };
      final List<BookingHoldModel> holds = BookingHoldModel.listFromResponse(
        <String, dynamic>{
          'data': <String, dynamic>{
            'holds': <Map<String, dynamic>>[priced('a'), priced('b')],
          },
        },
      );
      final BookingQuoteModel? quote = BookingHoldState(
        status: BookingHoldStatus.held,
        holds: holds,
      ).quote;
      expect(quote?.priceDetails?.bookingTotal, 2400);
      expect(quote?.priceDetails?.advancePayableNow, 1200);
      expect(quote?.calculationList.single.amount, 1200);
    });

    test('the advance falls back to the per-session items', () {
      final BookingQuoteModel quote = BookingQuoteModel.fromJson(
        <String, dynamic>{
          'price_details': <String, dynamic>{'booking_total': 2400},
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'booking_date': '2026-10-02',
              'advance_amount': 600,
            },
            <String, dynamic>{
              'booking_date': '2026-10-09',
              'advance_amount': 600,
            },
          ],
        },
      );
      expect(quote.priceDetails?.advancePayableNow, isNull);
      expect(quote.itemsAdvance, 1200);
    });
  });

  group('every way the server spells the advance', () {
    double? advanceOf(Map<String, dynamic> details) =>
        BookingQuoteModel.fromJson(<String, dynamic>{
          'price_details': details,
        }).priceDetails?.advancePayableNow;

    test('advance_payable_now, payable_now, advance_amount', () {
      expect(advanceOf(<String, dynamic>{'advance_payable_now': 600}), 600);
      expect(advanceOf(<String, dynamic>{'payable_now': 600}), 600);
      expect(advanceOf(<String, dynamic>{'advance_amount': 600}), 600);
    });

    test('total and balance give the rest as the advance', () {
      expect(
        advanceOf(<String, dynamic>{
          'total_amount': 1200,
          'balance_due_later': 700,
        }),
        500,
      );
    });

    test('an explicit 0 stays 0; nothing at all stays unknown', () {
      expect(advanceOf(<String, dynamic>{'advance_payable_now': 0}), 0);
      expect(advanceOf(<String, dynamic>{'booking_total': 1200}), isNull);
    });

    test('calculation lines with other keys count as the advance', () {
      final BookingQuoteModel quote = BookingQuoteModel.fromJson(
        <String, dynamic>{
          'calculation_list': <Map<String, dynamic>>[
            <String, dynamic>{'key': 'payable_now', 'amount': 600},
            <String, dynamic>{'key': 'total_amount', 'amount': 1200},
          ],
        },
      );
      expect(
        quote.calculationList.map((BookingCalculationLineModel l) => l.key),
        <String>['advance_payable_now', 'booking_total'],
      );
    });
  });

  test('holds are read with their quotes from data.items', () {
    // Reading the bare data.holds left the hold without a quote, so the
    // checkout showed "Advance to pay" 0, then "—".
    final List<BookingHoldModel> holds = BookingHoldModel.listFromResponse(
      jsonDecode(_holdsWithItems),
    );
    expect(holds, hasLength(1));
    final BookingHoldModel hold = holds.single;
    expect(hold.id, 'bd053e40-833a-4466-a12f-b2f9c29abc53');
    expect(hold.hasToken, isTrue);
    expect(hold.courtId, 35);

    final BookingQuoteModel? quote = BookingHoldState(
      status: BookingHoldStatus.held,
      holds: holds,
    ).quote;
    expect(quote?.priceDetails?.bookingTotal, 1150);
    expect(quote?.priceDetails?.advancePayableNow, 575);
    expect(
      quote?.calculationList
          .firstWhere(
            (BookingCalculationLineModel l) => l.key == 'advance_payable_now',
          )
          .amount,
      575,
    );
  });
}
