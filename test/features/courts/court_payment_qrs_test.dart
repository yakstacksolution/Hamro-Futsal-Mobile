import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/vendor/data/model/court_onboarding_response_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_api_payload.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

/// `/api/auth/court/{id}` wrapped the way the endpoint wraps it.
Map<String, dynamic> _courtResponse(Map<String, dynamic> qrFields) =>
    <String, dynamic>{
      'status': 'success',
      'data': <String, dynamic>{'id': 14, 'court_name': 'Court A', ...qrFields},
    };

Map<String, dynamic> _media(int id) => <String, dynamic>{
  'id': id,
  'name': 'qr-$id.png',
  'full_url': 'https://example.com/qr-$id.png',
};

/// The live `/api/auth/vendor/onboarding/update-court` body, verbatim.
Map<String, dynamic> _updateCourtResponse() =>
    jsonDecode(
          File('test/fixtures/update_court_response.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

const List<int> _savedQrIds = <int>[678, 679];

/// The live `/api/auth/court/{id}` body: the same court under `data.court`.
Map<String, dynamic> _courtDetailsResponse() =>
    jsonDecode(
          File('test/fixtures/court_details_response.json').readAsStringSync(),
        )
        as Map<String, dynamic>;

void main() {
  group('the live court details response', () {
    test('reads the court from data.court with its QR list', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtDetailsResponse(),
      );
      expect(court.remoteId, 14);
      expect(court.name, 'Court 1');
      // Not 560, the stale library file in the legacy `payment_qr_media`.
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), _savedQrIds);
      expect(
        court.paymentQrs.last.remoteUrl,
        'https://staging.hamrofutsal.com/storage/court/14/payment_qr/679/'
        'camera_1789701151855572.jpg',
      );
    });

    test('the rest of the court parses', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtDetailsResponse(),
      );
      expect(court.isStepCompleted, isTrue);
      expect(court.mainStep, 3);
      expect(court.subStep, 2);
      expect(court.basePrice, 1200);
      expect(court.advancePaymentType, AdvancePaymentType.percentage);
      expect(court.advancePrice, 50);
      expect(court.maxPlayers, 10);
      expect(court.weekendDays, <String>{'sat', 'sun'});
      expect(court.holidayDates, <String>{'2026-07-28'});
      expect(court.closedDates.single.date, '2026-07-29');
      expect(court.amenities, <int>{4, 2, 5, 3, 1});
      expect(court.facilities, <int>{1, 2, 3, 5});
    });

    test('editing it sends the saved QR ids back', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtDetailsResponse(),
      );
      final Map<String, dynamic> body = VendorOnboardingState.initial()
          .toCourtBody(
            court: court,
            mainStep: 1,
            subStep: 1,
            currentSubstepOnly: true,
          );
      expect(body['payment_qr_ids'], _savedQrIds);
      expect(body['court_id'], 14);
    });
  });

  group('the live update-court response', () {
    test('QRs come from payment_qr_media_list, not the legacy single', () {
      final CourtDraft court = CourtOnboardingResponseModel.fromJson(
        _updateCourtResponse(),
      ).mergeInto(const CourtDraft(id: '14'));
      // 560 is the stale library file in `payment_qr_media`.
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), _savedQrIds);
      expect(
        court.paymentQrs.first.remoteUrl,
        'https://staging.hamrofutsal.com/storage/court/14/payment_qr/678/'
        'camera_1789479440399887.jpg',
      );
    });

    test('a completed court stays completed after the save', () {
      final CourtDraft court = CourtOnboardingResponseModel.fromJson(
        _updateCourtResponse(),
      ).mergeInto(const CourtDraft(id: '14'));
      expect(court.isStepCompleted, isTrue);
      expect(court.remoteId, 14);
      expect(court.mainStep, 3);
      expect(court.subStep, 2);
    });

    test('the rest of the court parses', () {
      final CourtDraft court = CourtOnboardingResponseModel.fromJson(
        _updateCourtResponse(),
      ).mergeInto(const CourtDraft(id: '14'));
      expect(court.basePrice, 1200);
      expect(court.advancePaymentType, AdvancePaymentType.percentage);
      expect(court.advancePrice, 50);
      expect(court.maxPlayers, 10);
      expect(court.slotDuration, 60);
      expect(court.weekendDays, <String>{'sat', 'sun'});
      expect(court.holidayDates, <String>{'2026-07-28'});
      expect(court.closedDates.single.date, '2026-07-29');
      expect(court.amenities, <int>{4, 2, 5, 3, 1});
      expect(court.facilities, <int>{1, 2, 3, 5});
    });

    test('the court details parser reads the same QRs', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _updateCourtResponse(),
      );
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), _savedQrIds);
    });

    test('an empty payment_qr_media_list means no QRs', () {
      final Map<String, dynamic> json = _updateCourtResponse();
      (json['data'] as Map<String, dynamic>)['payment_qr_media_list'] =
          <Object>[];
      expect(CourtOnboardingResponseModel.fromJson(json).paymentQrs, isEmpty);
      expect(VenueCourtModel.courtFromResponse(json).paymentQrs, isEmpty);
    });
  });

  group('fetching /auth/court/{id}', () {
    test('reads a list of QRs under payment_qrs', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtResponse(<String, dynamic>{
          'payment_qrs': <Object>[_media(7), _media(9)],
        }),
      );
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), <int>[7, 9]);
      expect(court.paymentQr?.id, 7);
    });

    test('reads payment_qr_media sent as an array', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtResponse(<String, dynamic>{
          'payment_qr_media': <Object>[_media(3), _media(4), _media(5)],
        }),
      );
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), <int>[3, 4, 5]);
    });

    test('takes the media id from rows that wrap the file under media', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtResponse(<String, dynamic>{
          'payment_qrs': <Object>[
            <String, dynamic>{'id': 100, 'court_id': 14, 'media': _media(7)},
            <String, dynamic>{'id': 101, 'court_id': 14, 'media': _media(9)},
          ],
        }),
      );
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), <int>[7, 9]);
      expect(court.paymentQrs.first.remoteUrl, 'https://example.com/qr-7.png');
    });

    test('still reads the single QR of an older backend', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtResponse(<String, dynamic>{'payment_qr_media': _media(7)}),
      );
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), <int>[7]);
    });

    test('a bare payment_qr_id becomes one QR', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtResponse(<String, dynamic>{'payment_qr_id': 7}),
      );
      expect(court.paymentQrs.map((UploadRef qr) => qr.id), <int>[7]);
    });

    test('no QR fields means no QRs', () {
      final CourtDraft court = VenueCourtModel.courtFromResponse(
        _courtResponse(const <String, dynamic>{}),
      );
      expect(court.paymentQrs, isEmpty);
    });
  });

  group('adding and updating a court', () {
    const CourtDraft court = CourtDraft(
      id: '14',
      remoteId: 14,
      paymentQrs: <UploadRef>[
        UploadRef(name: 'esewa.png', id: 7),
        UploadRef(name: 'khalti.png', id: 9),
      ],
    );

    test('the payment QR step sends every QR id', () {
      final Map<String, dynamic> body = VendorOnboardingState.initial()
          .toCourtBody(
            court: court,
            mainStep: 1,
            subStep: 1,
            currentSubstepOnly: true,
          );
      expect(body['payment_qr_ids'], <int>[7, 9]);
      // Kept for a backend that still reads a single QR.
      expect(body['payment_qr_id'], 7);
      expect(body['court_id'], 14);
    });

    test('the full court body carries the QRs too', () {
      final Map<String, dynamic> body = VendorOnboardingState.initial()
          .toCourtBody(court: court);
      expect(body['payment_qr_ids'], <int>[7, 9]);
    });

    test('a saved draft restores its QRs, including an old single QR', () {
      final CourtDraft restored = CourtDraft.fromJson(court.toJson());
      expect(restored.paymentQrs.map((UploadRef qr) => qr.id), <int>[7, 9]);

      final Map<String, dynamic> legacy = court.toJson()
        ..remove('paymentQrs')
        ..['paymentQr'] = const UploadRef(name: 'old.png', id: 3).toJson();
      expect(
        CourtDraft.fromJson(legacy).paymentQrs.map((UploadRef qr) => qr.id),
        <int>[3],
      );
    });
  });
}
