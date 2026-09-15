import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

/// The live `/api/auth/get-venue-courts?page=1&per_page=10` body, verbatim.
const String _response = '''
{
  "status": "success",
  "message": "Venues and courts fetched successfully.",
  "data": {
    "venues": [
      {
        "main_step": 0,
        "sub_step": 0,
        "id": 58,
        "vendor_onboarding_id": null,
        "user_id": 4,
        "futsal_name": "Susan test futsal",
        "slug": "susan-test-futsal",
        "registration_number": "gyfysv",
        "phone": "98663536763",
        "email": "futsal@gmail.com",
        "futsal_address": null,
        "cover_image_media": null,
        "status": "inactive",
        "courts": []
      },
      {
        "main_step": 0,
        "sub_step": 0,
        "id": 57,
        "vendor_onboarding_id": null,
        "user_id": 4,
        "futsal_name": "Test futsal",
        "slug": "test-futsal-3",
        "registration_number": "reg627372",
        "phone": "9854243456",
        "email": "futsal.com@gmail.com",
        "futsal_address": null,
        "cover_image_media": null,
        "status": "inactive",
        "courts": []
      },
      {
        "main_step": 2,
        "sub_step": 2,
        "id": 2,
        "vendor_onboarding_id": null,
        "user_id": 4,
        "futsal_name": "Dhanawantary Sports",
        "slug": "dhanawantary-sports",
        "registration_number": "Regs627272",
        "phone": "9868187579",
        "email": "hamrofutsal@gmail.com",
        "futsal_address": "Kathmandu",
        "cover_image_media": {
          "id": 73,
          "name": "scaled_1000070383",
          "full_url": "https://hamrofutsal.com//storage/venue/2/feature/73/scaled_1000070383.jpg"
        },
        "status": "active",
        "courts": [
          {
            "main_step": 3,
            "sub_step": 2,
            "id": 14,
            "venue_id": 2,
            "court_type_id": 1,
            "match_format_id": 1,
            "court_name": "Court 1",
            "slug": "court-1",
            "base_price": "1200.00",
            "is_payment_required": true,
            "advance_payment_required": true,
            "advance_payment_type": "percentage",
            "advance_price": "50.00",
            "court_photos": {
              "id": 163,
              "name": "camera_1784133380663134",
              "full_url": "https://hamrofutsal.com//storage/users/4/library/163/camera_1784133380663134.jpg",
              "status": "active"
            },
            "status": "active"
          },
          {
            "main_step": 3,
            "sub_step": 2,
            "id": 33,
            "venue_id": 2,
            "court_type_id": 1,
            "match_format_id": 1,
            "court_name": "Court 1",
            "slug": "court-1-5",
            "base_price": "250.00",
            "is_payment_required": true,
            "advance_payment_required": true,
            "advance_payment_type": "percentage",
            "advance_price": "30.00",
            "court_photos": {
              "id": 163,
              "name": "camera_1784133380663134",
              "full_url": "https://hamrofutsal.com//storage/users/4/library/163/camera_1784133380663134.jpg",
              "status": "active"
            },
            "status": "active"
          }
        ]
      },
      {
        "main_step": 2,
        "sub_step": 2,
        "id": 1,
        "vendor_onboarding_id": null,
        "user_id": 4,
        "futsal_name": "Dhananjay sport",
        "slug": "dhananjay-sport",
        "registration_number": "Reg527272",
        "phone": "9865464684",
        "email": "futsal@gmail.com",
        "futsal_address": "Nagarjun Municipality Nepal",
        "cover_image_media": {
          "id": 82,
          "name": "scaled_1000070383",
          "full_url": "https://hamrofutsal.com//storage/venue/1/feature/82/scaled_1000070383.jpg"
        },
        "status": "active",
        "courts": [
          {
            "main_step": 3,
            "sub_step": 2,
            "id": 6,
            "venue_id": 1,
            "court_type_id": 1,
            "match_format_id": 1,
            "court_name": "Shidartha",
            "slug": "shidartha",
            "base_price": "1200.00",
            "is_payment_required": true,
            "advance_payment_required": true,
            "advance_payment_type": "percentage",
            "advance_price": "50.00",
            "court_photos": {
              "id": 72,
              "name": "scaled_1000070383",
              "full_url": "https://hamrofutsal.com//storage/users/4/library/72/scaled_1000070383.jpg",
              "status": "active"
            },
            "status": "active"
          }
        ]
      }
    ],
    "pagination": {
      "current_page": 1,
      "last_page": 1,
      "per_page": 10,
      "total": 4,
      "from": 1,
      "to": 4,
      "has_more_pages": false
    }
  }
}
''';

void main() {
  late VenueCourtPageModel page;

  setUpAll(() {
    page = VenueCourtPageModel.fromResponse(
      jsonDecode(_response) as Map<String, dynamic>,
    );
  });

  test('reads the pagination block', () {
    expect(page.currentPage, 1);
    expect(page.lastPage, 1);
    expect(page.perPage, 10);
    expect(page.total, 4);
    expect(page.from, 1);
    expect(page.to, 4);
    expect(page.hasMorePages, isFalse);
    expect(page.items, hasLength(4));
  });

  test('keeps every half-finished venue, in the order sent', () {
    // Two step-0 drafts arrive before the finished venues.
    final VenueCourtModel first = page.items.first;

    expect(first.id, 58);
    expect(first.title, 'Susan test futsal');
    expect(first.slug, 'susan-test-futsal');
    expect(first.registrationNumber, 'gyfysv');
    expect(first.phone, '98663536763');
    expect(first.email, 'futsal@gmail.com');
    expect(first.isSetupIncomplete, isTrue);
    expect(first.courts, isEmpty);

    expect(
      page.items.map((VenueCourtModel v) => v.id),
      <int>[58, 57, 2, 1],
      reason: 'venues must keep the order the endpoint sent them in',
    );
    expect(
      page.items.where((VenueCourtModel v) => v.isSetupIncomplete).length,
      2,
    );
  });

  test('parses a half-finished venue without dropping it', () {
    final VenueCourtModel venue = page.items[1];

    expect(venue.id, 57);
    expect(venue.title, 'Test futsal');
    expect(venue.slug, 'test-futsal-3');
    expect(venue.registrationNumber, 'reg627372');
    expect(venue.phone, '9854243456');
    expect(venue.email, 'futsal.com@gmail.com');
    expect(venue.userId, 4);
    expect(venue.vendorOnboardingId, isNull);
    expect(venue.mainStep, 0);
    expect(venue.subStep, 0);
    expect(venue.isSetupIncomplete, isTrue);
    expect(venue.isActive, isFalse);
    // Nulls in the payload, not empty strings in the model.
    expect(venue.address, isEmpty);
    expect(venue.imageUrl, isNull);
    expect(venue.courts, isEmpty);
  });

  test('parses a completed venue and its cover image', () {
    final VenueCourtModel venue = page.items[2];

    expect(venue.id, 2);
    expect(venue.title, 'Dhanawantary Sports');
    expect(venue.slug, 'dhanawantary-sports');
    expect(venue.registrationNumber, 'Regs627272');
    expect(venue.address, 'Kathmandu');
    expect(venue.email, 'hamrofutsal@gmail.com');
    expect(venue.mainStep, 2);
    expect(venue.subStep, 2);
    expect(venue.isSetupIncomplete, isFalse);
    expect(venue.isActive, isTrue);
    // The API pastes its app url onto a leading-slash path, so the raw value
    // carries a doubled slash; the model collapses it.
    expect(
      venue.imageUrl,
      'https://hamrofutsal.com/storage/venue/2/feature/73/scaled_1000070383.jpg',
    );
    expect(venue.courts, hasLength(2));
  });

  test('parses each court, including its single photo object', () {
    final CourtDraft court = page.items[2].courts.first;

    expect(court.remoteId, 14);
    expect(court.id, '14');
    expect(court.venueId, 2);
    expect(court.name, 'Court 1');
    expect(court.slug, 'court-1');
    // Sent as the string "1200.00".
    expect(court.basePrice, 1200);
    expect(court.isPaymentRequired, isTrue);
    expect(court.advancePaymentRequired, isTrue);
    expect(court.advancePaymentType, AdvancePaymentType.percentage);
    expect(court.advancePrice, 50);
    expect(court.mainStep, 3);
    expect(court.subStep, 2);
    expect(court.isActive, isTrue);
    // Ids only in this response: the labels come from the id map.
    expect(court.courtTypeId, 1);
    expect(court.courtType, 'Indoor');
    expect(court.matchFormatId, 1);
    expect(court.matchFormat, '5v5');
    // `court_photos` is one media object here, not a list.
    expect(court.photos, hasLength(1));
    expect(court.photos.single.id, 163);
    expect(
      court.photos.single.remoteUrl,
      'https://hamrofutsal.com/storage/users/4/library/163/camera_1784133380663134.jpg',
    );
  });

  test('keeps the second court of the same venue distinct', () {
    final CourtDraft court = page.items[2].courts[1];

    expect(court.remoteId, 33);
    expect(court.slug, 'court-1-5');
    expect(court.basePrice, 250);
    expect(court.advancePrice, 30);
  });

  test('parses the third venue and its only court', () {
    final VenueCourtModel venue = page.items[3];

    expect(venue.id, 1);
    expect(venue.title, 'Dhananjay sport');
    expect(venue.address, 'Nagarjun Municipality Nepal');
    expect(venue.courts.single.remoteId, 6);
    expect(venue.courts.single.name, 'Shidartha');
    expect(venue.courts.single.basePrice, 1200);
  });
}
