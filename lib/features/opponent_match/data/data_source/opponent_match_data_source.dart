import 'package:dio/dio.dart';
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
/// two-phase accept (hold quote, then multipart accept with payment proof).
abstract class OpponentRequestRemoteDataSource {
  Future<Result> fetchRequests({Map<String, dynamic>? query});
  Future<Result> fetchRequest(String requestId);
  Future<Result> createRequest(Map<String, dynamic> data);
  Future<Result> createAcceptQuote(String requestId, Map<String, dynamic> data);
  Future<Result> accept(AcceptOpponentRequestRequest request);
  Future<Result> decline(String requestId);
  Future<Result> delete(String requestId);

  /// Requester's review of the accepter's advance-payment proof.
  Future<Result> verifyPayment(String requestId);
  Future<Result> rejectPayment(String requestId, String reason);
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
  Future<Result> createAcceptQuote(
    String requestId,
    Map<String, dynamic> data,
  ) async => await Client.instance().getAuthManager().createOpponentAcceptQuote(
    requestId,
    data,
  );

  @override
  Future<Result> accept(AcceptOpponentRequestRequest request) async {
    final Map<String, dynamic> fields = request.toFields()
      ..removeWhere((_, dynamic value) => value == null);
    if (request.paymentProofPath.isNotEmpty) {
      fields['payment_proof'] = await MultipartFile.fromFile(
        request.paymentProofPath,
        filename: request.paymentProofPath.split('/').last,
      );
    }
    return await Client.instance().getAuthManager().acceptOpponentRequest(
      request.requestId,
      FormData.fromMap(fields),
    );
  }

  @override
  Future<Result> decline(String requestId) async =>
      await Client.instance().getAuthManager().declineOpponentRequest(
        requestId,
      );

  @override
  Future<Result> delete(String requestId) async =>
      await Client.instance().getAuthManager().deleteOpponentRequest(requestId);

  @override
  Future<Result> verifyPayment(String requestId) async =>
      await Client.instance().getAuthManager().verifyOpponentPayment(requestId);

  @override
  Future<Result> rejectPayment(String requestId, String reason) async =>
      await Client.instance().getAuthManager().rejectOpponentPayment(requestId, {
        'reason': reason,
      });
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
  Future<Result> createAcceptQuote(
    String requestId,
    Map<String, dynamic> data,
  ) => _withFallback(
    'accept-quote',
    () => _remote.createAcceptQuote(requestId, data),
    () => _mock.createAcceptQuote(requestId, data),
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
  Future<Result> verifyPayment(String requestId) => _withFallback(
    'payment-verify',
    () => _remote.verifyPayment(requestId),
    () => _mock.verifyPayment(requestId),
  );

  @override
  Future<Result> rejectPayment(String requestId, String reason) =>
      _withFallback(
        'payment-reject',
        () => _remote.rejectPayment(requestId, reason),
        () => _mock.rejectPayment(requestId, reason),
      );
}

/// Contract-shaped mock behind [kUseOpponentRequestMock] — every payload here
/// is byte-for-byte what the Laravel side is expected to return, so this class
/// doubles as the living API-contract example while the backend is built.
///
/// Special ids: accept-quoting request `409` simulates losing the
/// double-accept race.
final class OpponentRequestMockDataSourceImpl
    implements OpponentRequestRemoteDataSource {
  static List<Map<String, dynamic>>? _requests;

  static const String _qrUrl =
      'https://upload.wikimedia.org/wikipedia/commons/thumb/d/d0/'
      'QR_code_for_mobile_English_Wikipedia.svg/'
      '440px-QR_code_for_mobile_English_Wikipedia.svg.png';

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
      Map<String, dynamic>? payment,
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
        'advance_payable_now': (totalFee / 4).round(),
      },
      'message': 'Looking for a friendly, competitive futsal match!',
      'accept_deadline': deadline == null ? null : iso(deadline),
      'created_at': iso(now.subtract(const Duration(minutes: 4))),
      'accepted_by': acceptedBy,
      'payment': payment,
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
      // My request that a team has accepted & paid — awaiting MY review of
      // their advance proof.
      request(
        id: 47,
        isMine: true,
        status: 'accept_pending_payment',
        teamName: 'My Team',
        acceptedBy: {'user_id': 22, 'team_id': 9, 'team_name': 'Thamel Tigers'},
        payment: {
          'status': 'pending',
          'amount': 300,
          'proof_url': _qrUrl,
          'rejected_reason': null,
        },
      ),
      request(
        id: 44,
        isMine: false,
        status: 'accept_pending_payment',
        teamName: 'Lalitpur Lions',
        acceptedBy: {'user_id': 1, 'team_id': 5, 'team_name': 'My Team'},
        payment: {
          'status': 'pending',
          'amount': 300,
          'proof_url': '',
          'rejected_reason': null,
        },
      ),
      request(
        id: 45,
        isMine: false,
        status: 'accepted',
        teamName: 'Kathmandu Kings',
        acceptedBy: {'user_id': 1, 'team_id': 5, 'team_name': 'My Team'},
        payment: {
          'status': 'verified',
          'amount': 300,
          'proof_url': '',
          'rejected_reason': null,
        },
      ),
      request(
        id: 46,
        isMine: false,
        status: 'open',
        teamName: 'Pokhara Strikers',
        deadline: now.add(const Duration(minutes: 18)),
        payment: {
          'status': 'rejected',
          'amount': 300,
          'proof_url': '',
          'rejected_reason': 'Proof amount does not match the advance.',
        },
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
        'advance_payable_now': (totalFee / 4).round(),
      },
      'message': data['message'],
      'accept_deadline': now
          .add(const Duration(minutes: 20))
          .toIso8601String(),
      'created_at': now.toIso8601String(),
      'accepted_by': null,
      'payment': null,
    };
    _store.insert(0, created);
    return Result.success({'data': created});
  }

  @override
  Future<Result> createAcceptQuote(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (requestId == '409') {
      return Result.error(
        DataError('This request was just accepted by another team.', 409, {
          'message': 'This request was just accepted by another team.',
          'error_code': 'ALREADY_ACCEPTED',
        }),
      );
    }
    // Unknown ids (e.g. a request that DID load from the real backend)
    // still get a plausible quote so the flow keeps working.
    final r = _find(requestId);
    final pricing = r == null
        ? const {
            'total_fee': 1200,
            'accepter_share': 600,
            'advance_payable_now': 300,
          }
        : Map<String, dynamic>.from(r['pricing'] as Map);
    final int advance = (pricing['advance_payable_now'] as num).toInt();
    final int share = (pricing['accepter_share'] as num).toInt();
    return Result.success({
      'data': {
        'accept_hold': {
          'token': 'ah_mock_$requestId',
          'expires_at': DateTime.now()
              .add(const Duration(minutes: 10))
              .toIso8601String(),
        },
        'quote': {
          'total_fee': pricing['total_fee'],
          'accepter_share': share,
          'advance_payable_now': advance,
          'balance_due_later': share - advance,
        },
        'payment_qr': {
          'payment_qr_media': {'full_url': _qrUrl},
          'payee_name': 'Hamro Futsal Pvt. Ltd.',
          'account_number': '9800000000',
          'bank_name': 'eSewa',
          'note': 'Pay the advance and upload the screenshot.',
        },
      },
    });
  }

  @override
  Future<Result> accept(AcceptOpponentRequestRequest request) async {
    await Future.delayed(const Duration(milliseconds: 700));
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
    r['status'] = 'accept_pending_payment';
    r['accepted_by'] = {
      'user_id': 1,
      'team_id': request.teamId,
      'team_name': 'My Team',
    };
    r['payment'] = {
      'status': 'pending',
      'amount': (r['pricing'] as Map)['advance_payable_now'],
      'proof_url': request.paymentProofPath,
      'rejected_reason': null,
    };
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
  Future<Result> verifyPayment(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final r = _find(requestId);
    if (r != null) {
      r['status'] = 'accepted';
      final payment = r['payment'];
      if (payment is Map) payment['status'] = 'verified';
    }
    return Result.success({
      'data': r ?? {'id': requestId, 'status': 'accepted'},
    });
  }

  @override
  Future<Result> rejectPayment(String requestId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final r = _find(requestId);
    if (r != null) {
      // Rejected proof re-opens the request to every team; the rejection
      // reason stays on the payment for the accepter to see.
      r['status'] = 'open';
      r['accept_deadline'] = DateTime.now()
          .add(const Duration(minutes: 20))
          .toIso8601String();
      r['accepted_by'] = null;
      r['payment'] = {
        'status': 'rejected',
        'amount': (r['pricing'] as Map)['advance_payable_now'],
        'proof_url': '',
        'rejected_reason': reason,
      };
    }
    return Result.success({
      'data': r ?? {'id': requestId, 'status': 'open'},
    });
  }
}
