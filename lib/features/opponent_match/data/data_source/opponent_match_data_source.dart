import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';

/// Compile-time switch that serves opponent requests from contract-shaped
/// canned JSON only (network never attempted) — run with
/// `flutter run --dart-define=OPPONENT_MOCK=true`.
///
/// Without the flag the default is [OpponentRequestFallbackDataSourceImpl]:
/// hit the real API first and serve the canned success response only when the
/// call fails (endpoints not deployed yet).
const bool kUseOpponentRequestMock = bool.fromEnvironment('OPPONENT_MOCK');

/// Team CRUD + member management, backed by the `/api/teams` endpoints.
/// Also serves the `/positions` and `/opponent-levels` lookups.
abstract class TeamRemoteDataSource {
  Future<Result> getTeams();
  Future<Result> getTeam(int teamId);
  Future<Result> createTeam(Map<String, dynamic> data);
  Future<Result> updateTeam(int teamId, Map<String, dynamic> data);
  Future<Result> deleteTeam(int teamId);
  Future<Result> addMember(int teamId, Map<String, dynamic> data);
  Future<Result> updateMember(
    int teamId,
    int memberId,
    Map<String, dynamic> data,
  );
  Future<Result> removeMember(int teamId, int memberId);
  Future<Result> getPositions();
  Future<Result> getOpponentLevels();
}

final class TeamRemoteDataSourceImpl extends TeamRemoteDataSource {
  @override
  Future<Result> getTeams() async =>
      await Client.instance().getAuthManager().getTeams();

  @override
  Future<Result> getPositions() async =>
      await Client.instance().getAuthManager().getPlayerPositions();

  @override
  Future<Result> getOpponentLevels() async =>
      await Client.instance().getAuthManager().getOpponentLevels();

  @override
  Future<Result> getTeam(int teamId) async =>
      await Client.instance().getAuthManager().getTeam(teamId);

  @override
  Future<Result> createTeam(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().createTeam(data);

  @override
  Future<Result> updateTeam(int teamId, Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().updateTeam(teamId, data);

  @override
  Future<Result> deleteTeam(int teamId) async =>
      await Client.instance().getAuthManager().deleteTeam(teamId);

  @override
  Future<Result> addMember(int teamId, Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().addTeamMember(teamId, data);

  @override
  Future<Result> updateMember(
    int teamId,
    int memberId,
    Map<String, dynamic> data,
  ) async => await Client.instance().getAuthManager().updateTeamMember(
    teamId,
    memberId,
    data,
  );

  @override
  Future<Result> removeMember(int teamId, int memberId) async =>
      await Client.instance().getAuthManager().removeTeamMember(
        teamId,
        memberId,
      );
}

/// Local demo source for the one part of the feature without a backend yet —
/// venue name suggestions.
abstract class OpponentMatchDataSource {
  Future<List<String>> fetchVenues();
}

final class OpponentMatchLocalDataSourceImpl
    implements OpponentMatchDataSource {
  @override
  Future<List<String>> fetchVenues() async => const [
    'Green Turf Arena, Kathmandu',
    'Capital Futsal, Lalitpur',
    'Champions Court, Bhaktapur',
    'Soccer Pro Arena, Pulchowk',
  ];
}

/// Opponent requests over `/opponent-requests` — list/create plus the
/// single-call accept (the accepting team, no payment).
abstract class OpponentRequestRemoteDataSource {
  Future<Result> fetchRequests({Map<String, dynamic>? query});
  Future<Result> fetchRequest(String requestId);
  Future<Result> createRequest(Map<String, dynamic> data);
  Future<Result> accept(AcceptOpponentRequestRequest request);
  Future<Result> decline(String requestId);
  Future<Result> delete(String requestId);

  /// Requester confirms the chosen opponent (closing the request for the
  /// other invitations) or releases it back to the pool.
  Future<Result> selectOpponent(String requestId);
  Future<Result> rejectInvitation(String requestId, String reason);
}

final class OpponentRequestRemoteDataSourceImpl
    implements OpponentRequestRemoteDataSource {
  @override
  Future<Result> fetchRequests({Map<String, dynamic>? query}) async =>
      await Client.instance().getAuthManager().getOpponentRequests(
        query: query,
      );

  @override
  Future<Result> fetchRequest(String requestId) async =>
      await Client.instance().getAuthManager().getOpponentRequest(requestId);

  @override
  Future<Result> createRequest(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().createOpponentRequest(data);

  @override
  Future<Result> accept(AcceptOpponentRequestRequest request) async {
    final Map<String, dynamic> fields = request.toFields()
      ..removeWhere((_, dynamic value) => value == null);
    return await Client.instance().getAuthManager().acceptOpponentRequest(
      request.requestId,
      fields,
    );
  }

  @override
  Future<Result> decline(String requestId) async => await Client.instance()
      .getAuthManager()
      .declineOpponentRequest(requestId);

  @override
  Future<Result> delete(String requestId) async =>
      await Client.instance().getAuthManager().deleteOpponentRequest(requestId);

  @override
  Future<Result> selectOpponent(String requestId) async =>
      await Client.instance().getAuthManager().verifyOpponentPayment(requestId);

  @override
  Future<Result> rejectInvitation(String requestId, String reason) async =>
      await Client.instance().getAuthManager().rejectOpponentPayment(
        requestId,
        {'reason': reason},
      );
}

/// Live API with a static fallback: every call hits `/opponent-requests`
/// first; when it fails (the backend hasn't shipped these endpoints yet) the
/// contract-shaped canned success response is served instead, so the accept
/// flow works end-to-end today and switches to real data the moment the
/// backend lands. Teams/members are NOT routed through this — they stay
/// backend-only.
final class OpponentRequestFallbackDataSourceImpl
    implements OpponentRequestRemoteDataSource {
  final OpponentRequestRemoteDataSourceImpl _remote =
      OpponentRequestRemoteDataSourceImpl();
  final OpponentRequestMockDataSourceImpl _mock =
      OpponentRequestMockDataSourceImpl();

  Future<Result> _withFallback(
    String label,
    Future<Result> Function() remote,
    Future<Result> Function() mock,
  ) async {
    try {
      final Result response = await remote();
      if (!response.isError()) return response;
      debugPrint(
        'opponent-requests $label failed on the API — serving the static '
        'expected response.',
      );
    } catch (error) {
      debugPrint(
        'opponent-requests $label threw ($error) — serving the static '
        'expected response.',
      );
    }
    return mock();
  }

  @override
  Future<Result> fetchRequests({Map<String, dynamic>? query}) => _withFallback(
    'list',
    () => _remote.fetchRequests(query: query),
    () => _mock.fetchRequests(query: query),
  );

  @override
  Future<Result> fetchRequest(String requestId) => _withFallback(
    'detail',
    () => _remote.fetchRequest(requestId),
    () => _mock.fetchRequest(requestId),
  );

  @override
  Future<Result> createRequest(Map<String, dynamic> data) => _withFallback(
    'create',
    () => _remote.createRequest(data),
    () => _mock.createRequest(data),
  );

  @override
  Future<Result> accept(AcceptOpponentRequestRequest request) => _withFallback(
    'accept',
    () => _remote.accept(request),
    () => _mock.accept(request),
  );

  @override
  Future<Result> decline(String requestId) => _withFallback(
    'decline',
    () => _remote.decline(requestId),
    () => _mock.decline(requestId),
  );

  @override
  Future<Result> delete(String requestId) => _withFallback(
    'delete',
    () => _remote.delete(requestId),
    () => _mock.delete(requestId),
  );

  @override
  Future<Result> selectOpponent(String requestId) => _withFallback(
    'select-opponent',
    () => _remote.selectOpponent(requestId),
    () => _mock.selectOpponent(requestId),
  );

  @override
  Future<Result> rejectInvitation(String requestId, String reason) =>
      _withFallback(
        'reject-invitation',
        () => _remote.rejectInvitation(requestId, reason),
        () => _mock.rejectInvitation(requestId, reason),
      );
}

/// Contract-shaped mock behind [kUseOpponentRequestMock] — every payload here
/// is byte-for-byte what the Laravel side is expected to return, so this class
/// doubles as the living API-contract example while the backend is built.
///
/// Special id: accepting request `409` simulates losing the double-accept
/// race.
final class OpponentRequestMockDataSourceImpl
    implements OpponentRequestRemoteDataSource {
  static List<Map<String, dynamic>>? _requests;

  List<Map<String, dynamic>> get _store => _requests ??= _seed();

  static List<Map<String, dynamic>> _seed() {
    final now = DateTime.now();
    String iso(DateTime d) => d.toIso8601String();
    String day(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

    Map<String, dynamic> request({
      required int id,
      required bool isMine,
      required String status,
      required String teamName,
      String requesterName = 'Ram Thapa',
      DateTime? deadline,
      int totalFee = 1200,
      String format = '5v5',
      String level = 'Intermediate',
      Map<String, dynamic>? acceptedBy,
      List<Map<String, dynamic>>? invitations,
    }) => {
      'id': id,
      'status': status,
      'is_mine': isMine,
      'requester': {
        'user_id': isMine ? 1 : 12,
        'name': isMine ? 'You' : requesterName,
        'team_id': 7,
        'team_name': teamName,
      },
      'match': {
        'date': day(now.add(const Duration(days: 3))),
        'start_time': '18:00',
        'end_time': '19:00',
        'venue_id': null,
        'venue_name': 'Green Turf Arena, Kathmandu',
        'format': format,
        'level': level,
      },
      'pricing': {
        'total_fee': totalFee,
        'split_mode': 'even',
        'requester_pct': 50,
        'accepter_pct': 50,
        'loser_pct': null,
        'accepter_share': (totalFee / 2).round(),
      },
      'message': 'Looking for a friendly, competitive futsal match!',
      'accept_deadline': deadline == null ? null : iso(deadline),
      'created_at': iso(now.subtract(const Duration(minutes: 4))),
      'accepted_by': acceptedBy,
      'invitations': invitations,
    };

    Map<String, dynamic> invitation({
      required String id,
      required String teamName,
      required int captainUserId,
      required String captainName,
      int playerCount = 7,
      int share = 600,
      String status = 'pending',
      String message = '',
      int minutesAgo = 3,
    }) => {
      'id': id,
      'team_id': id,
      'team_name': teamName,
      'status': status,
      'captain_name': captainName,
      'user_id': captainUserId,
      'player_count': playerCount,
      'accepter_share': share,
      'message': message,
      'accepted_at': iso(now.subtract(Duration(minutes: minutesAgo))),
    };

    return [
      request(
        id: 41,
        isMine: false,
        status: 'open',
        teamName: 'Royal Futsal Club',
        deadline: now.add(const Duration(minutes: 16)),
      ),
      request(
        id: 409,
        isMine: false,
        status: 'open',
        teamName: 'Race Condition FC',
        requesterName: 'Hari KC',
        deadline: now.add(const Duration(minutes: 12)),
        totalFee: 1500,
        format: '6v6',
        level: 'Advanced',
      ),
      request(
        id: 42,
        isMine: false,
        status: 'open',
        teamName: 'Bhaktapur Warriors',
        requesterName: 'Sita Rai',
        totalFee: 1500,
        format: '6v6',
        level: 'Advanced',
      ),
      request(id: 43, isMine: true, status: 'open', teamName: 'My Team'),
      // My published request with competing invitations — the requester picks.
      request(
        id: 47,
        isMine: true,
        status: 'invitation_sent',
        teamName: 'My Team',
        acceptedBy: {'user_id': 22, 'team_id': 9, 'team_name': 'Thamel Tigers'},
        invitations: [
          invitation(
            id: '9',
            teamName: 'Thamel Tigers',
            captainUserId: 22,
            captainName: 'Bikash Shrestha',
            message: 'We can arrive 15 minutes early to warm up.',
          ),
          invitation(
            id: '11',
            teamName: 'Patan Panthers',
            captainUserId: 31,
            captainName: 'Nabin Karki',
            playerCount: 8,
            minutesAgo: 1,
          ),
        ],
      ),
      // A request I accepted — waiting for the requester to pick.
      request(
        id: 44,
        isMine: false,
        status: 'invitation_sent',
        teamName: 'Lalitpur Lions',
        acceptedBy: {'user_id': 1, 'team_id': 5, 'team_name': 'My Team'},
        invitations: [
          invitation(
            id: '5',
            teamName: 'My Team',
            captainUserId: 1,
            captainName: 'You',
          ),
        ],
      ),
      // Confirmed match: my team was selected.
      request(
        id: 45,
        isMine: false,
        status: 'accepted',
        teamName: 'Kathmandu Kings',
        acceptedBy: {'user_id': 1, 'team_id': 5, 'team_name': 'My Team'},
        invitations: [
          invitation(
            id: '5',
            teamName: 'My Team',
            captainUserId: 1,
            captainName: 'You',
            status: 'selected',
          ),
        ],
      ),
      request(
        id: 46,
        isMine: false,
        status: 'open',
        teamName: 'Pokhara Strikers',
        deadline: now.add(const Duration(minutes: 18)),
      ),
    ];
  }

  Map<String, dynamic>? _find(String requestId) {
    for (final r in _store) {
      if (r['id'].toString() == requestId) return r;
    }
    return null;
  }

  @override
  Future<Result> fetchRequests({Map<String, dynamic>? query}) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return Result.success({
      'data': {'requests': _store},
    });
  }

  @override
  Future<Result> fetchRequest(String requestId) async {
    final r = _find(requestId);
    if (r == null) {
      return Result.error(DataError('Request not found.', 404, null));
    }
    return Result.success({'data': r});
  }

  @override
  Future<Result> createRequest(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final now = DateTime.now();
    // Server-authoritative pricing per format — except externally-booked
    // courts, where the requester's claimed fee is the only source of truth.
    final int? claimedFee = int.tryParse(
      data['claimed_total_fee']?.toString() ?? '',
    );
    final int totalFee =
        claimedFee ??
        switch (data['format']?.toString()) {
          '6v6' => 1500,
          '7v7' => 1800,
          _ => 1200,
        };
    final int pct = int.tryParse(data['requester_pct']?.toString() ?? '') ?? 50;
    final created = {
      'id': now.millisecondsSinceEpoch % 100000,
      'status': 'open',
      'is_mine': true,
      'requester': {
        'user_id': 1,
        'name': 'You',
        'team_id': data['team_id'],
        'team_name': 'My Team',
      },
      'match': {
        'date': data['date'],
        'start_time': data['start_time'],
        'end_time': data['end_time'],
        'venue_id': data['venue_id'],
        'venue_name': data['venue_name'],
        'format': data['format'],
        'level': data['level_slug'],
      },
      'pricing': {
        'total_fee': totalFee,
        'split_mode': data['split_mode'],
        'requester_pct': pct,
        'accepter_pct': 100 - pct,
        'loser_pct': data['loser_pct'],
        'accepter_share': (totalFee * (100 - pct) / 100).round(),
      },
      'message': data['message'],
      'accept_deadline': now.add(const Duration(minutes: 20)).toIso8601String(),
      'created_at': now.toIso8601String(),
      'accepted_by': null,
      'invitations': null,
    };
    _store.insert(0, created);
    return Result.success({'data': created});
  }

  @override
  Future<Result> accept(AcceptOpponentRequestRequest request) async {
    await Future.delayed(const Duration(milliseconds: 700));
    if (request.requestId == '409') {
      return Result.error(
        DataError('This request was just settled with another team.', 409, {
          'message': 'This request was just settled with another team.',
          'error_code': 'ALREADY_ACCEPTED',
        }),
      );
    }
    // Unknown ids get a synthesized row so an accept still succeeds even
    // when the request itself came from the real backend.
    final r =
        _find(request.requestId) ??
        (() {
          final synthesized = _seed().first;
          synthesized['id'] = request.requestId;
          _store.insert(0, synthesized);
          return synthesized;
        })();
    // The acceptance becomes an invitation waiting on the requester's pick.
    r['status'] = 'invitation_sent';
    r['accepted_by'] = {
      'user_id': 1,
      'team_id': request.teamId,
      'team_name': 'My Team',
    };
    final List<dynamic> invitations =
        List<dynamic>.from(
          (r['invitations'] as List<dynamic>?) ?? const <dynamic>[],
        )..add({
          'id': 'inv_${request.teamId}',
          'team_id': request.teamId,
          'team_name': 'My Team',
          'status': 'pending',
          'message': request.message,
          'accepter_share': (r['pricing'] as Map)['accepter_share'],
          'accepted_at': DateTime.now().toIso8601String(),
        });
    r['invitations'] = invitations;
    return Result.success({'data': r});
  }

  @override
  Future<Result> decline(String requestId) async {
    final r = _find(requestId);
    if (r != null) r['status'] = 'declined';
    return Result.success({
      'data': r ?? {'id': requestId, 'status': 'declined'},
    });
  }

  @override
  Future<Result> delete(String requestId) async {
    _store.removeWhere((r) => r['id'].toString() == requestId);
    return Result.success({'data': true});
  }

  @override
  Future<Result> selectOpponent(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final r = _find(requestId);
    if (r != null) {
      r['status'] = 'accepted';
      // The chosen team is selected; every other invitation is rejected.
      final invitations = r['invitations'];
      if (invitations is List) {
        for (final dynamic i in invitations) {
          if (i is! Map) continue;
          i['status'] = i['status'] == 'pending' ? 'rejected' : i['status'];
        }
        if (invitations.isNotEmpty && invitations.first is Map) {
          (invitations.first as Map)['status'] = 'selected';
        }
      }
    }
    return Result.success({
      'data': r ?? {'id': requestId, 'status': 'accepted'},
    });
  }

  @override
  Future<Result> rejectInvitation(String requestId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final r = _find(requestId);
    if (r != null) {
      // Turning the invitation down re-opens the request to every team.
      r['status'] = 'open';
      r['accept_deadline'] = DateTime.now()
          .add(const Duration(minutes: 20))
          .toIso8601String();
      r['accepted_by'] = null;
      final invitations = r['invitations'];
      if (invitations is List) {
        for (final dynamic i in invitations) {
          if (i is Map) {
            i['status'] = 'rejected';
            i['message'] = reason;
          }
        }
      }
    }
    return Result.success({
      'data': r ?? {'id': requestId, 'status': 'open'},
    });
  }
}
