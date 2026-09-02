import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_step_request.dart';

void main() {
  group('OpponentMatchStepRequest', () {
    test('serialises exactly the documented payload', () {
      // The schedule is no longer part of step one — it comes from the venue
      // step, so nothing date-shaped may leak into this body.
      final Map<String, dynamic> json = OpponentMatchStepRequest(
        teamId: 7,
        matchFormatId: 1,
        opponentLevelId: 2,
      ).toJson();

      expect(json, <String, dynamic>{
        'team_id': 7,
        'match_format_id': 1,
        'opponent_level_id': 2,
      });
    });
  });

  group('OpponentVenueStepRequest', () {
    test('an existing booking sends only its id', () {
      expect(
        const OpponentVenueStepRequest.existingBooking(31).toJson(),
        <String, dynamic>{'venue_source': 'booking', 'booking_id': 31},
      );
    });

    test('booked elsewhere carries the match day as preferred_date', () {
      final Map<String, dynamic> json = OpponentVenueStepRequest.external(
        venueName: 'Star Futsal',
        courtName: '',
        address: 'Lalitpur',
        date: DateTime(2026, 9, 5),
        preferredDate: DateTime(2026, 9, 5),
        startTime: (hour: 6, minute: 0),
        endTime: (hour: 7, minute: 0),
        feeAmount: 1800,
      ).toJson();

      expect(json, <String, dynamic>{
        'venue_source': 'external',
        'external_venue_name': 'Star Futsal',
        'external_address': 'Lalitpur',
        'external_date': '2026-09-05',
        'preferred_date': '2026-09-05',
        'external_start_time': '06:00',
        'external_end_time': '07:00',
        'external_fee_amount': 1800,
      });
    });

    test('preferred_date falls back to the booked date', () {
      final Map<String, dynamic> json = OpponentVenueStepRequest.external(
        venueName: 'Star Futsal',
        courtName: '',
        address: '',
        date: DateTime(2026, 1, 7, 18, 30),
        startTime: (hour: 18, minute: 30),
        feeAmount: 1200,
      ).toJson();

      // Date only — a clock time on the DateTime must not leak into either key.
      expect(json['external_date'], '2026-01-07');
      expect(json['preferred_date'], '2026-01-07');
      expect(json.containsKey('external_end_time'), isFalse);
    });

    test('a stated match day wins over the booked date', () {
      final Map<String, dynamic> json = OpponentVenueStepRequest.external(
        venueName: 'Star Futsal',
        courtName: '',
        address: '',
        date: DateTime(2026, 3, 2),
        preferredDate: DateTime(2026, 3, 9),
        startTime: (hour: 20, minute: 0),
        feeAmount: 1000,
      ).toJson();

      expect(json['external_date'], '2026-03-02');
      expect(json['preferred_date'], '2026-03-09');
    });
  });

  group('OpponentCostStepRequest', () {
    test('an even split sends nothing but the type', () {
      expect(const OpponentCostStepRequest.even().toJson(), <String, dynamic>{
        'split_type': 'even',
      });
    });

    test('a fixed per-side split names the requesting team', () {
      expect(
        const OpponentCostStepRequest.custom(
          basis: OpponentSplitBasis.team,
          requestingTeamPercent: 60,
        ).toJson(),
        <String, dynamic>{
          'split_type': 'custom',
          'split_basis': 'team',
          'requesting_team_percent': 60,
        },
      );
    });

    test('a result-keyed split sends both sides, not a requester share', () {
      expect(
        const OpponentCostStepRequest.custom(
          basis: OpponentSplitBasis.result,
          requestingTeamPercent: 70,
        ).toJson(),
        <String, dynamic>{
          'split_type': 'custom',
          'split_basis': 'result',
          'loser_pay_percent': 70,
          'winner_pay_percent': 30,
        },
      );
    });

    test('the loser can carry the whole fee', () {
      final Map<String, dynamic> json = const OpponentCostStepRequest.custom(
        basis: OpponentSplitBasis.result,
        requestingTeamPercent: 100,
      ).toJson();

      expect(json['loser_pay_percent'], 100);
      expect(json['winner_pay_percent'], 0);
    });
  });

  group('OpponentRequestRefModel', () {
    test('reads the id at the top level', () {
      final ref = OpponentRequestRefModel.fromResponse(<String, dynamic>{
        'id': 42,
        'status': 'draft',
      });

      expect(ref.id, '42');
      expect(ref.status, 'draft');
      expect(ref.isValid, isTrue);
    });

    test('digs the id out of the wrapped response', () {
      final ref = OpponentRequestRefModel.fromResponse(<String, dynamic>{
        'status': 'success',
        'message': 'Opponent request created.',
        'data': <String, dynamic>{
          'opponent_request': <String, dynamic>{'id': 108, 'status': 'open'},
        },
      });

      expect(ref.id, '108');
      expect(ref.status, 'open');
    });

    test('is invalid when no id is anywhere in the payload', () {
      final ref = OpponentRequestRefModel.fromResponse(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{'message': 'ok'},
      });

      expect(ref.isValid, isFalse);
    });

    test('survives a non-map payload', () {
      expect(OpponentRequestRefModel.fromResponse('boom').isValid, isFalse);
      expect(OpponentRequestRefModel.fromResponse(null).isValid, isFalse);
    });
  });
}
