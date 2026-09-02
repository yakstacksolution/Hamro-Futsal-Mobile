import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';

/// `GET /auth/opponent-requests/{id}/invitations`, verbatim: two pending
/// invitations, each naming its team and the captain who sent it, with no
/// captain block, roster size or share.
List<Map<String, dynamic>> invitationRows() => <Map<String, dynamic>>[
  <String, dynamic>{
    'id': 6,
    'opponent_request_id': 17,
    'invitation_sender_id': 5,
    'status': 'pending',
    'message': null,
    'team': <String, dynamic>{'id': 14, 'name': 'Team'},
    'responded_at': null,
    'created_at': '2026-08-21 19:48:12',
  },
  <String, dynamic>{
    'id': 5,
    'opponent_request_id': 17,
    'invitation_sender_id': 12,
    'status': 'pending',
    'message': null,
    'team': <String, dynamic>{'id': 18, 'name': 'Rajendra Teams'},
    'responded_at': null,
    'created_at': '2026-08-21 19:46:24',
  },
];

void main() {
  test('reads the team and the sender behind each invitation', () {
    final rows = invitationRows()
        .map(OpponentInvitationModel.fromJson)
        .toList(growable: false);

    expect(rows, hasLength(2));
    expect(rows.first.id, '6');
    expect(rows.first.teamId, '14');
    expect(rows.first.teamName, 'Team');
    expect(rows.first.status, InvitationStatus.pending);
    // The chat target: this endpoint names the captain only by sender id.
    expect(rows.first.captainUserId, 5);
    expect(rows.last.captainUserId, 12);
    expect(rows.last.teamName, 'Rajendra Teams');
  });

  test('a pending invitation has no responded_at', () {
    final invitation = OpponentInvitationModel.fromJson(invitationRows().first);

    expect(invitation.respondedAt, isNull);
    // `created_at` stands in for when the acceptance landed.
    expect(invitation.acceptedAt, DateTime(2026, 8, 21, 19, 48, 12));
  });

  test('an answered invitation keeps when it was answered', () {
    final Map<String, dynamic> row = invitationRows().first;
    row['status'] = 'rejected';
    row['responded_at'] = '2026-08-21 20:10:00';

    final invitation = OpponentInvitationModel.fromJson(row);

    expect(invitation.status, InvitationStatus.rejected);
    expect(invitation.respondedAt, DateTime(2026, 8, 21, 20, 10));
  });

  test('unstated roster size and share stay zero, not guessed', () {
    final invitation = OpponentInvitationModel.fromJson(invitationRows().first);

    expect(invitation.playerCount, 0);
    expect(invitation.share, 0);
    expect(invitation.message, isEmpty);
  });

  test('an explicit captain block still wins over the sender id', () {
    final Map<String, dynamic> row = invitationRows().first;
    row['captain'] = <String, dynamic>{'user_id': 99, 'name': 'Bina Thapa'};

    final invitation = OpponentInvitationModel.fromJson(row);

    expect(invitation.captainUserId, 99);
    expect(invitation.captainName, 'Bina Thapa');
  });
}
