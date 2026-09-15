import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/available_courts_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_court_item_model.dart';

/// The real `/available-courts?...&venue_id=2` response, trimmed to the two
/// courts it returns: one discounted, one not.
const String _response = '''
{
  "status": "success",
  "message": "Available courts fetched successfully.",
  "data": {
    "venue_id": 2,
    "date": "2026-09-15",
    "start_time": "06:00:00",
    "end_time": "07:00:00",
    "total_courts": 2,
    "available_count": 2,
    "available_courts": [
      {
        "id": 14, "venue_id": 2, "name": "Court 1", "slug": "court-1",
        "surface_type": null, "capacity": 10, "base_price": 1200,
        "actual_price": {
          "amount": 1100, "original_amount": 1200, "price_type": "base",
          "has_discount": true,
          "discount": {"type": "flat", "value": 100, "amount": 100, "label": "Rs. 100 off"}
        },
        "start_time": "06:00:00", "end_time": "07:00:00",
        "slot_duration_minutes": 60, "is_available": true,
        "availability_status": "available", "availability_reason": "available",
        "court_type": "Indoor Turf", "match_format": "5v5", "feature_image": null,
        "matching_slot": {"id": 298, "label": "6Am - 7Ams", "start_time": "06:00:00", "end_time": "07:00:00"}
      },
      {
        "id": 33, "venue_id": 2, "name": "Court 1", "slug": "court-1-5",
        "surface_type": null, "capacity": 10, "base_price": 250,
        "actual_price": {
          "amount": 250, "original_amount": 250, "price_type": "base",
          "has_discount": false, "discount": null
        },
        "start_time": "06:00:00", "end_time": "07:00:00",
        "slot_duration_minutes": 60, "is_available": true,
        "availability_status": "available", "availability_reason": "available",
        "court_type": "Indoor Turf", "match_format": "5v5", "feature_image": null,
        "matching_slot": {"id": 352, "label": "Morning slot", "start_time": "06:00:00", "end_time": "07:00:00"}
      }
    ],
    "fallback_type": null
  }
}
''';

void main() {
  List<VenueCourtItemModel> courts() =>
      AvailableCourtsModel.fromResponse(
        jsonDecode(_response) as Map<String, dynamic>,
      ).courts;

  final DateTime date = DateTime(2026, 9, 15);

  test('the response summary is carried, not just the court list', () {
    final AvailableCourtsModel model = AvailableCourtsModel.fromResponse(
      jsonDecode(_response) as Map<String, dynamic>,
    );

    expect(model.venueId, 2);
    expect(model.date, '2026-09-15');
    expect(model.startTime, '06:00:00');
    expect(model.endTime, '07:00:00');
    expect(model.totalCourts, 2);
    expect(model.availableCount, 2);
    expect(model.fallbackType, isNull);
    expect(model.isFallback, isFalse);
    expect(model.courtCount, 2);
    expect(model.freeCourtCount, 2);
    expect(model.availableCourts, hasLength(2));
  });

  test('a fallback answer is flagged as one', () {
    final AvailableCourtsModel model = AvailableCourtsModel.fromResponse(
      jsonDecode(
            _response.replaceFirst(
              '"fallback_type": null',
              '"fallback_type": "nearest_slot"',
            ),
          )
          as Map<String, dynamic>,
    );

    expect(model.fallbackType, 'nearest_slot');
    expect(model.isFallback, isTrue);
  });

  test('both courts are parsed with their identity and slot', () {
    final List<VenueCourtItemModel> list = courts();

    expect(list, hasLength(2));
    expect(list.first.id, 14);
    expect(list.first.slug, 'court-1');
    expect(list.first.maxPlayers, 10);
    expect(list.first.matchType, '5v5');
    expect(list.first.courtType, 'Indoor Turf');
    expect(list.first.slotDurationMinutes, 60);
    expect(list.first.matchingSlot?.id, 298);
    expect(list.first.matchingSlot?.label, '6Am - 7Ams');
    expect(list.first.isAvailable, isTrue);
  });

  test('a discounted court charges the discounted amount', () {
    final VenueCourtItemModel court = courts().first;

    expect(court.basePrice, 1200);
    expect(court.hasDiscount, isTrue);
    expect(court.priceFor(date, '6:00 AM'), 1100);
    expect(court.originalPriceFor(date, '6:00 AM'), 1200);
    expect(court.savingsPerSession, 100);
    expect(court.actualPrice?.discount?.isPercent, isFalse);
    expect(court.actualPrice?.discount?.amount, 100);
    expect(court.actualPrice?.priceType, 'base');
  });

  test('an undiscounted court charges its own amount', () {
    final VenueCourtItemModel court = courts().last;

    expect(court.hasDiscount, isFalse);
    expect(court.priceFor(date, '6:00 AM'), 250);
    expect(court.originalPriceFor(date, '6:00 AM'), 250);
    expect(court.savingsPerSession, 0);
  });

  test('the weekend surcharge is not added on top of a server price', () {
    final VenueCourtItemModel court = courts().first.copyWith(
      weekendSurcharge: 500,
    );

    // 2026-09-19 is a Saturday; the server already priced the slot.
    expect(court.priceFor(DateTime(2026, 9, 19), '6:00 AM'), 1100);
  });

  test('a percentage discount is read as one', () {
    final String percent = _response.replaceFirst(
      '"type": "flat", "value": 100, "amount": 100, "label": "Rs. 100 off"',
      '"type": "percentage", "value": 10, "amount": 120, "label": "10% off"',
    );
    final VenueCourtItemModel court = AvailableCourtsModel.fromResponse(
      jsonDecode(percent) as Map<String, dynamic>,
    ).courts.first;

    expect(court.actualPrice?.discount?.isPercent, isTrue);
    expect(court.actualPrice?.discount?.value, 10);
    expect(court.actualPrice?.discount?.amount, 120);
  });

  test('a court with no actual_price still falls back to its rules', () {
    const String bare = '''
{"data":{"available_courts":[
  {"id": 7, "name": "Court 7", "capacity": 8, "base_price": 800,
   "court_type": "Outdoor", "match_format": "7v7",
   "availability_status": "available"}
]}}
''';
    final VenueCourtItemModel court = AvailableCourtsModel.fromResponse(
      jsonDecode(bare) as Map<String, dynamic>,
    ).courts.single;

    expect(court.actualPrice, isNull);
    expect(court.priceFor(date, '6:00 AM'), 800);
    expect(court.hasDiscount, isFalse);
  });
}
