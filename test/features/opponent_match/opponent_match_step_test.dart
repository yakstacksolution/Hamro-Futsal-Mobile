import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_step_request.dart';

void main() {
  group('OpponentMatchStepRequest', () {
    test('serialises exactly the documented payload', () {
      final Map<String, dynamic> json = OpponentMatchStepRequest(
        teamId: 7,
        matchFormatId: 1,
        opponentLevelId: 1,
        preferredDate: DateTime(2026, 8, 20),
        preferredTime: (hour: 18, minute: 0),
      ).toJson();

      expect(json, <String, dynamic>{
        'team_id': 7,
        'match_format_id': 1,
        'opponent_level_id': 1,
        'preferred_date': '2026-08-20',
        'preferred_time': '18:00',
      });
    });

    test('zero-pads single-digit dates and times', () {
      final Map<String, dynamic> json = OpponentMatchStepRequest(
        teamId: 1,
        matchFormatId: 2,
        opponentLevelId: 3,
        preferredDate: DateTime(2026, 1, 5),
        preferredTime: (hour: 9, minute: 5),
      ).toJson();

      expect(json['preferred_date'], '2026-01-05');
      expect(json['preferred_time'], '09:05');
    });

    test('drops the time-of-day part of the date', () {
      // A DateTime carrying a clock time must not leak it into preferred_date.
      final Map<String, dynamic> json = OpponentMatchStepRequest(
        teamId: 1,
        matchFormatId: 1,
        opponentLevelId: 1,
        preferredDate: DateTime(2026, 8, 20, 23, 45),
        preferredTime: (hour: 18, minute: 0),
      ).toJson();

      expect(json['preferred_date'], '2026-08-20');
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
