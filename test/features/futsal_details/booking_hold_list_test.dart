import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';

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
}
