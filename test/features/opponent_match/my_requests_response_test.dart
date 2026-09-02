import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';

/// Rows exactly as `/auth/opponent-requests?tab=my_requests` returns them:
/// a published request with an invitation waiting, two untouched drafts
/// (`venue` and `cost` both null), and a request the server has closed.
const List<Map<String, dynamic>> _items = <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 14,
    'status': 'published',
    'main_step': 4,
    'sub_step': 1,
    'team': <String, dynamic>{
      'id': 18,
      'name': 'Rajendra Teams',
      'roster_size': 2,
    },
    'match_format': <String, dynamic>{
      'id': 3,
      'name': '7v7',
      'players_per_team': 7,
    },
    'opponent_level': <String, dynamic>{'id': 3, 'title': 'Advanced'},
    'preferred_date': '2026-08-21',
    'preferred_time': '11:00:00',
    'venue': <String, dynamic>{
      'source': 'external',
      'venue_name': 'Devdatta Sports',
      'court_name': null,
      'address': 'Surkhet',
      'date': '2026-08-21',
      'start_time': '06:00:00',
      'end_time': '07:00:00',
      'fee_amount': 2500,
    },
    'cost': <String, dynamic>{
      'court_fee_amount': 2500,
      'split_type': 'even',
      'split_basis': null,
      'requesting_team_percent': 50,
      'opponent_team_percent': 50,
      'requesting_team_amount': 1250,
      'opponent_team_amount': 1250,
      'roster_size_snapshot': 2,
      'per_player_amount': 625,
    },
    'accepted_team': null,
    'message': 'Looking for a friendly competitive futsal match.',
    'published_at': '2026-08-20 22:29:34',
    'expires_at': '2099-08-21 06:00:00',
    'invitations_summary': <String, dynamic>{
      'pending_count': 1,
      'total_count': 1,
    },
    'created_at': '2026-08-20 22:28:54',
  },
  <String, dynamic>{
    'id': 13,
    'status': 'draft',
    'main_step': 1,
    'sub_step': 1,
    'team': <String, dynamic>{
      'id': 18,
      'name': 'Rajendra Teams',
      'roster_size': 2,
    },
    'match_format': <String, dynamic>{
      'id': 1,
      'name': '5v5',
      'players_per_team': 5,
    },
    'opponent_level': <String, dynamic>{'id': 3, 'title': 'Advanced'},
    'preferred_date': '2026-08-20',
    'preferred_time': '18:00:00',
    'venue': null,
    'cost': null,
    'accepted_team': null,
    'message': null,
    'expires_at': null,
    'invitations_summary': <String, dynamic>{
      'pending_count': 0,
      'total_count': 0,
    },
    'created_at': '2026-08-20 22:24:20',
  },
  <String, dynamic>{
    'id': 11,
    'status': 'closed',
    'main_step': 4,
    'sub_step': 1,
    'team': <String, dynamic>{
      'id': 18,
      'name': 'Rajendra Teams',
      'roster_size': 2,
    },
    'match_format': <String, dynamic>{
      'id': 2,
      'name': '6v6',
      'players_per_team': 6,
    },
    'opponent_level': <String, dynamic>{'id': 1, 'title': 'Beginner'},
    'preferred_date': '2026-08-20',
    'preferred_time': '18:00:00',
    'venue': <String, dynamic>{
      'source': 'external',
      'venue_name': 'Sports Academy',
      'court_name': null,
      'address': 'Kathmandu 23 Nepal',
      'date': '2026-08-20',
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'fee_amount': 2000,
    },
    'cost': <String, dynamic>{
      'court_fee_amount': 2000,
      'split_type': 'even',
      'split_basis': null,
      'requesting_team_percent': 50,
      'opponent_team_percent': 50,
      'requesting_team_amount': 1000,
      'opponent_team_amount': 1000,
      'roster_size_snapshot': 2,
      'per_player_amount': 500,
    },
    'accepted_team': null,
    'message': 'Looking for a friendly competitive futsal match.',
    'published_at': '2026-08-20 22:13:40',
    'expires_at': '2026-08-20 18:00:00',
    'invitations_summary': <String, dynamic>{
      'pending_count': 0,
      'total_count': 0,
    },
    'created_at': '2026-08-20 22:12:43',
  },
];

/// The repository stamps `is_mine` on every `my_requests` row.
OpponentRequestModel _parse(int index) => OpponentRequestModel.fromJson(
  <String, dynamic>{..._items[index], 'is_mine': true},
);

void main() {
  group('my_requests rows', () {
    test('a published request is mine, live, and shows its split', () {
      final OpponentRequestModel r = _parse(0);

      expect(r.id, '14');
      expect(r.isMine, isTrue);
      // Mine + published reads as "sent", not as something to accept.
      expect(r.status, RequestStatus.sent);
      expect(r.team, 'Rajendra Teams');
      expect(r.summary, 'Advanced · 7v7');
      // The booked court wins over the preferred slot.
      expect(r.dateTime, DateTime.parse('2026-08-21 06:00:00'));
      expect(r.slot, '6:00 AM – 7:00 AM');
      expect(r.venue, 'Devdatta Sports');
      expect(r.venueSource, 'external');
      expect(r.totalFee, 2500);
      expect(r.yourShare, 1250);
      expect(r.myPct, 50);
      expect(r.splitType, 'even');
      expect(r.perPlayerAmount, 625);
      expect(r.matchFormatId, '3');
      expect(r.opponentLevelId, '3');
      expect(r.mainStep, 4);
      expect(r.pendingInvitationCount, 1);
      expect(r.invitationCount, 1);
      // `expires_at` is the accept window.
      expect(r.acceptDeadline, DateTime.parse('2099-08-21 06:00:00'));
    });

    test('a draft with null venue and cost still parses', () {
      final OpponentRequestModel r = _parse(1);

      expect(r.status, RequestStatus.draft);
      expect(r.mainStep, 1);
      // Falls back to the preferred slot, since no court is attached yet.
      expect(r.dateTime, DateTime.parse('2026-08-20 18:00:00'));
      expect(r.preferredDateTime, DateTime.parse('2026-08-20 18:00:00'));
      expect(r.venue, isEmpty);
      expect(r.totalFee, 0);
      expect(r.acceptDeadline, isNull);
      expect(r.invitationCount, 0);
    });

    test('a closed request reads as terminal', () {
      final OpponentRequestModel r = _parse(2);

      expect(r.status, RequestStatus.expired);
      expect(r.status.isOpen, isFalse);
      expect(r.status.isSettled, isTrue);
      expect(r.totalFee, 2000);
      expect(r.yourShare, 1000);
    });

    test('an incoming request derives the opponent share from the percent', () {
      // Same row seen from the other side: not mine, and the server sent no
      // `opponent_team_amount`.
      final Map<String, dynamic> row = <String, dynamic>{
        ..._items[0],
        'cost': <String, dynamic>{
          ...(_items[0]['cost'] as Map<String, dynamic>),
          'opponent_team_amount': null,
          'opponent_team_percent': 30,
        },
      };
      final OpponentRequestModel r = OpponentRequestModel.fromJson(row);

      expect(r.isMine, isFalse);
      expect(r.myPct, 30);
      expect(r.yourShare, 750);
    });
  });
}
