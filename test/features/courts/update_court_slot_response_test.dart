import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_api_payload.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

/// The real `/auth/vendor/onboarding/update-court-slot` response.
const String _response = '''
{
  "message": "Slot pricing updated successfully.",
  "data": {
    "court_id": 14,
    "slot_id": 298,
    "slot": {
      "id": 298,
      "court_id": 14,
      "label": "6Am - 7Ams",
      "days": ["sun","mon","tue","wed","thu","fri","sat"],
      "start_time": "06:00:00",
      "end_time": "07:00:00",
      "sort_order": 0,
      "is_active": true,
      "slot_pricing": {
        "price": null,
        "weekend_price": 1200,
        "holiday_price": 1250,
        "is_discount_available": true,
        "discount_type": "flat",
        "discount_value": 100,
        "discount_start_time": null,
        "discount_end_time": null,
        "discount_price": 100,
        "payment_percent": null,
        "custom_date_prices": []
      },
      "created_at": "2026-07-16 19:26:52",
      "updated_at": "2026-09-13 22:01:40"
    }
  }
}
''';

/// The real `/auth/vendor/onboarding/get-court-slots/14` response: the same
/// slot, delivered as a bare list under `data`.
const String _listResponse = '''
{
  "message": "Court slots fetched successfully.",
  "data": [
    {
      "id": 298,
      "court_id": 14,
      "label": "6Am - 7Ams",
      "days": ["sun","mon","tue","wed","thu","fri","sat"],
      "start_time": "06:00:00",
      "end_time": "07:00:00",
      "sort_order": 0,
      "is_active": true,
      "slot_pricing": {
        "price": null,
        "weekend_price": 1200,
        "holiday_price": 1250,
        "is_discount_available": true,
        "discount_type": "flat",
        "discount_value": 100,
        "discount_start_time": null,
        "discount_end_time": null,
        "discount_price": 100,
        "payment_percent": null,
        "custom_date_prices": []
      },
      "created_at": "2026-07-16 19:26:52",
      "updated_at": "2026-09-13 22:01:40"
    }
  ]
}
''';

void main() {
  List<SlotPricingDraft> parse(String body) =>
      VenueCourtModel.slotsFromResponse(
        jsonDecode(body) as Map<String, dynamic>,
      );

  test('the updated slot comes back as one draft', () {
    final List<SlotPricingDraft> slots = parse(_response);

    expect(slots, hasLength(1));
    final SlotPricingDraft slot = slots.single;
    expect(slot.id, '298');
    expect(slot.label, '6Am - 7Ams');
    expect(slot.days, hasLength(7));
    expect(slot.startTime, isNotEmpty);
    expect(slot.endTime, isNotEmpty);
  });

  test('a null base price stays null rather than becoming zero', () {
    expect(parse(_response).single.price, isNull);
    expect(parse(_response).single.weekendPrice, 1200);
    expect(parse(_response).single.holidayPrice, 1250);
  });

  test('the discount comes back on, typed and valued', () {
    final SlotPricingDraft slot = parse(_response).single;

    expect(slot.hasDiscount, isTrue);
    expect(slot.discountType.toLowerCase(), 'flat');
    expect(slot.discountPrice, 100);
    expect(slot.discountStartsAt, isNull);
    expect(slot.discountEndsAt, isNull);
    expect(
      slot.discountProblem,
      isNull,
      reason: 'a discount with a type and a value is valid without a window',
    );
  });

  test('the slot keeps the active flag the server sent', () {
    expect(parse(_response).single.isActive, isTrue);

    final String off = _response.replaceFirst(
      '"is_active": true',
      '"is_active": false',
    );
    expect(parse(off).single.isActive, isFalse);
  });

  test('the discount round-trips back to the endpoint unchanged', () {
    final SlotPricingDraft slot = parse(_response).single;

    final Map<String, dynamic> body = courtSlotPricingBody(slot, courtId: 14);

    expect(body['slot_id'], 298);
    expect(body['is_discount_available'], isTrue);
    expect(body['discount_type'], 'flat');
    expect(body['discount_value'], 100);
    expect(body['weekend_price'], 1200);
    expect(body['holiday_price'], 1250);
    expect(body['price'], isNull);
    // No window was set, so none is sent.
    expect(body.containsKey('discount_start_time'), isFalse);
    expect(body.containsKey('discount_end_time'), isFalse);
  });

  test('editing the times keeps the slot switched off', () {
    final SlotPricingDraft off = parse(
      _response.replaceFirst('"is_active": true', '"is_active": false'),
    ).single;

    expect(courtSlotBody(off, courtId: 14)['is_active'], isFalse);
    expect(courtSlotBody(off, courtId: 14)['slot_id'], 298);
  });

  test('the fetch list reads the same as the single-slot response', () {
    final SlotPricingDraft fetched = parse(_listResponse).single;
    final SlotPricingDraft updated = parse(_response).single;

    expect(fetched.id, updated.id);
    expect(fetched.label, updated.label);
    expect(fetched.days, updated.days);
    expect(fetched.startTime, updated.startTime);
    expect(fetched.endTime, updated.endTime);
    expect(fetched.price, updated.price);
    expect(fetched.weekendPrice, updated.weekendPrice);
    expect(fetched.holidayPrice, updated.holidayPrice);
    expect(fetched.hasDiscount, updated.hasDiscount);
    expect(fetched.discountPrice, updated.discountPrice);
    expect(fetched.isActive, updated.isActive);
    expect(fetched.sortOrder, 0);
    expect(fetched.customDatePrices, isEmpty);
  });

  test('slots keep the order the server sorted them in', () {
    const String list = '''
{"data":{"slots":[
  {"id":2,"label":"Second","sort_order":2,"is_active":true,
   "start_time":"08:00:00","end_time":"09:00:00","days":["sun"],
   "slot_pricing":{"price":500}},
  {"id":1,"label":"First","sort_order":1,"is_active":true,
   "start_time":"06:00:00","end_time":"07:00:00","days":["sun"],
   "slot_pricing":{"price":400}}
]}}
''';

    expect(parse(list).map((SlotPricingDraft slot) => slot.label), <String>[
      'First',
      'Second',
    ]);
  });
}
