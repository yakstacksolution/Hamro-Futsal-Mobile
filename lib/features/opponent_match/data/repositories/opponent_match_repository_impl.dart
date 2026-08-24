import 'dart:math';

import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/opponent_match/data/data_source/opponent_match_data_source.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/accept_opponent_request_request.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_details_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_step_request.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_request_page_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_request_summary_model.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_request_tab.dart';
import 'package:hamro_footsall/features/opponent_match/domain/repository/opponent_match_repository.dart';

final class OpponentMatchRepositoryImpl extends OpponentMatchRepository {
  // Teams/members are backend-only; requests hit the API but fall back to
  // the static expected response while those endpoints aren't live yet.
  OpponentMatchRepositoryImpl({
    OpponentMatchDataSource? dataSource,
    TeamRemoteDataSource? teamDataSource,
    OpponentRequestRemoteDataSource? requestDataSource,
  }) : _dataSource = dataSource ?? OpponentMatchLocalDataSourceImpl(),
       _teamDataSource = teamDataSource ?? TeamRemoteDataSourceImpl(),
       _requestDataSource =
           requestDataSource ??
           (kUseOpponentRequestMock
               ? OpponentRequestMockDataSourceImpl()
               : OpponentRequestFallbackDataSourceImpl());

  final OpponentMatchDataSource _dataSource;
  final TeamRemoteDataSource _teamDataSource;
  final OpponentRequestRemoteDataSource _requestDataSource;

  final List<TeamModel> _teams = [];

  AppException _error(String message) =>
      DefaultException(errorMessage: message, statusCode: 0);

  int? _teamId(String id) => int.tryParse(id.trim());

  @override
  Future<Either<AppException, List<TeamModel>>> getTeams() async {
    final response = await _teamDataSource.getTeams();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final items = _findList(
        response.getValue(),
        keys: const ['data', 'teams', 'items', 'results'],
        depth: 0,
      );
      _teams
        ..clear()
        ..addAll(
          items.whereType<Map>().map(
            (e) => TeamModel.fromJson(Map<String, dynamic>.from(e)),
          ),
        );
      return right(List.unmodifiable(_teams));
    } catch (_) {
      return left(_error('Could not parse your teams from server.'));
    }
  }

  @override
  Future<Either<AppException, TeamModel>> getTeam(String teamId) async {
    final id = _teamId(teamId);
    if (id == null) return left(_error('Invalid team.'));
    final response = await _teamDataSource.getTeam(id);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final team = TeamModel.fromJson(_unwrapTeam(response.getValue()));
      final i = _teams.indexWhere((t) => t.id == team.id);
      if (i >= 0) _teams[i] = team;
      return right(team);
    } catch (_) {
      return left(_error('Could not parse the team from server.'));
    }
  }

  @override
  Future<Either<AppException, List<PlayerPositionModel>>> getPositions() async {
    final response = await _teamDataSource.getPositions();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final items = _findList(
        response.getValue(),
        keys: const ['data', 'positions', 'items', 'results'],
        depth: 0,
      );
      final positions = items
          .whereType<Map>()
          .map(
            (e) => PlayerPositionModel.fromJson(Map<String, dynamic>.from(e)),
          )
          .where((p) => p.name.isNotEmpty)
          .toList(growable: false);
      return right(positions);
    } catch (_) {
      return left(_error('Could not parse player positions from server.'));
    }
  }

  @override
  Future<Either<AppException, List<OpponentLevelModel>>>
  getOpponentLevels() async {
    final response = await _teamDataSource.getOpponentLevels();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final items = _findList(
        response.getValue(),
        keys: const ['data', 'levels', 'opponent_levels', 'items', 'results'],
        depth: 0,
      );
      final levels = items
          .whereType<Map>()
          .map((e) => OpponentLevelModel.fromJson(Map<String, dynamic>.from(e)))
          .where((l) => l.name.isNotEmpty)
          .toList(growable: false);
      return right(levels);
    } catch (_) {
      return left(_error('Could not parse opponent levels from server.'));
    }
  }

  @override
  Future<Either<AppException, List<String>>> getVenues() async {
    try {
      return right(await _dataSource.fetchVenues());
    } catch (_) {
      return left(_error('Could not load venues.'));
    }
  }

  @override
  Future<Either<AppException, OpponentMatchDetailsModel>> getMatchDetails(
    String id,
  ) async {
    final response = await _requestDataSource.fetchMatchDetails(id);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    // The endpoint answers with the match under the usual `data` envelope, in
    // its own screen-shaped sections — not the request row the lists send.
    final Map<String, dynamic> row = _asMap(response.getValue())['data'] is Map
        ? _asMap(_asMap(response.getValue())['data'])
        : _asMap(response.getValue());
    if (row.isEmpty) {
      return left(_error('Could not read the match details.'));
    }
    try {
      return right(OpponentMatchDetailsModel.fromJson(row));
    } catch (_) {
      return left(_error('Could not parse the match details from server.'));
    }
  }

  @override
  Future<Either<AppException, OpponentRequestPageModel>> getRequestsByTab(
    OpponentRequestTab tab, {
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _requestDataSource.fetchRequests(
      tab: tab,
      page: page,
      perPage: perPage,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final items = _findList(
        response.getValue(),
        keys: const [
          'data',
          'requests',
          'opponent_requests',
          'invitations',
          'items',
          'results',
        ],
        depth: 0,
      );
      final requests = items
          .whereType<Map>()
          .map((e) => _requestRow(e, tab: tab))
          .where((row) => row.isNotEmpty)
          .map(OpponentRequestModel.fromJson)
          .toList(growable: false);
      // `pagination` sits beside `items` inside `data`.
      final Map<String, dynamic> envelope = _asMap(
        _asMap(response.getValue())['data'],
      );
      final Map<String, dynamic> pagination = _asMap(envelope['pagination']);
      // `summary` counts every tab, not just the one requested — one call is
      // enough to fill in all four chips.
      final Map<String, dynamic> summaryJson = _asMap(envelope['summary']);
      final OpponentRequestSummaryModel? summary = summaryJson.isEmpty
          ? null
          : OpponentRequestSummaryModel.fromJson(summaryJson);
      return right(
        pagination.isEmpty
            ? OpponentRequestPageModel.single(requests, summary: summary)
            : OpponentRequestPageModel.fromJson(
                pagination,
                requests,
                summary: summary,
              ),
      );
    } catch (_) {
      return left(_error('Could not parse opponent requests from server.'));
    }
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>>
  getMyRequests() async => (await getRequestsByTab(
    OpponentRequestTab.myRequests,
  )).map((OpponentRequestPageModel page) => page.items);

  @override
  Future<Either<AppException, OpponentRequestModel>> getMyRequest(
    String id,
  ) async {
    final response = await _requestDataSource.fetchMyRequest(id);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      // The endpoint answers with `data` as a single-element LIST, but tolerate
      // a bare object (and the usual nesting) so either shape hydrates.
      final dynamic payload = response.getValue();
      final List<dynamic> items = _findList(
        payload,
        keys: const ['data', 'requests', 'opponent_requests', 'items'],
        depth: 0,
      );
      final Map<String, dynamic> row = items.isNotEmpty
          ? _requestRow(
              Map<dynamic, dynamic>.from(items.first as Map),
              tab: OpponentRequestTab.myRequests,
            )
          : _requestRow(
              _asMap(_asMap(payload)['data']),
              tab: OpponentRequestTab.myRequests,
            );
      if (row.isEmpty) {
        return left(_error('That request could not be found.'));
      }
      return right(OpponentRequestModel.fromJson(row));
    } catch (_) {
      return left(_error('Could not parse that opponent request.'));
    }
  }

  /// One row of `/auth/opponent-requests?tab=…`.
  ///
  /// A row may either be the request itself or a wrapper carrying it under
  /// `opponent_request`/`request`; [_unwrapRequest] handles both. On the
  /// `my_requests` tab every row belongs to the caller by definition, so
  /// `is_mine` is stamped on rather than trusted from the payload — the UI keys
  /// its actions off it. The other tabs carry other teams' requests, so their
  /// ownership is left to whatever the payload says.
  Map<String, dynamic> _requestRow(
    Map<dynamic, dynamic> raw, {
    required OpponentRequestTab tab,
  }) {
    final Map<String, dynamic> row = _unwrapRequest(
      Map<String, dynamic>.from(raw),
    );
    if (row.isEmpty || !tab.isOwnedByCaller) return row;
    return row..['is_mine'] = true;
  }

  @override
  Future<Either<AppException, List<TeamModel>>> createTeam(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return left(_error('Team name cannot be empty.'));
    return _mutateThenReload(
      () => _teamDataSource.createTeam({'name': trimmed}),
    );
  }

  @override
  Future<Either<AppException, List<TeamModel>>> updateTeam(
    String teamId,
    String name,
  ) async {
    final id = _teamId(teamId);
    if (id == null) return left(_error('Invalid team.'));
    final trimmed = name.trim();
    if (trimmed.isEmpty) return left(_error('Team name cannot be empty.'));
    return _mutateThenReload(
      () => _teamDataSource.updateTeam(id, {'name': trimmed}),
    );
  }

  @override
  Future<Either<AppException, List<TeamModel>>> deleteTeam(
    String teamId,
  ) async {
    final id = _teamId(teamId);
    if (id == null) return left(_error('Invalid team.'));
    return _mutateThenReload(() => _teamDataSource.deleteTeam(id));
  }

  @override
  Future<Either<AppException, List<TeamModel>>> addMember(
    String teamId,
    PlayerModel player,
  ) async {
    final id = _teamId(teamId);
    if (id == null) return left(_error('Invalid team.'));
    final name = player.name.trim();
    if (name.isEmpty) return left(_error('Player name cannot be empty.'));
    // The backend stores the position by its `/positions` row id; when the
    // selection came from the static fallback list (no id yet) derive the
    // 1-based id from the enum (1=GK … 4=FW).
    final int positionId =
        int.tryParse(player.positionId.trim()) ?? player.position.index + 1;
    final String email = player.email.trim();
    return _mutateThenReload(
      () => _teamDataSource.addMember(id, {
        'name': name,
        'position_id': positionId,
        // Optional: omitted rather than sent blank when the roster entry has no
        // address, so the backend does not store an empty string.
        if (email.isNotEmpty) 'email': email,
      }),
    );
  }

  @override
  Future<Either<AppException, List<TeamModel>>> updateMember(
    String teamId,
    PlayerModel player,
  ) async {
    final id = _teamId(teamId);
    final member = _teamId(player.id);
    if (id == null || member == null) return left(_error('Invalid member.'));
    final name = player.name.trim();
    if (name.isEmpty) return left(_error('Player name cannot be empty.'));
    // Same payload shape as addMember: the position travels as its
    // `/positions` row id (enum-derived 1-based id as fallback).
    final int positionId =
        int.tryParse(player.positionId.trim()) ?? player.position.index + 1;
    final String email = player.email.trim();
    return _mutateThenReload(
      () => _teamDataSource.updateMember(id, member, {
        'name': name,
        'position_id': positionId,
        if (email.isNotEmpty) 'email': email,
      }),
    );
  }

  @override
  Future<Either<AppException, List<TeamModel>>> removeMember(
    String teamId,
    String memberId,
  ) async {
    final id = _teamId(teamId);
    final member = _teamId(memberId);
    if (id == null || member == null) return left(_error('Invalid member.'));
    return _mutateThenReload(() => _teamDataSource.removeMember(id, member));
  }

  Future<Either<AppException, List<TeamModel>>> _mutateThenReload(
    Future<dynamic> Function() action,
  ) async {
    final response = await action();
    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      // DELETE endpoints (`teams/{team}`, `teams/{team}/members/{member}`)
      // reply 204 No Content on success, which the logging interceptor
      // surfaces as an error — treat it as a successful mutation.
      if (error.statusCode != 204) return left(error);
    }
    return getTeams();
  }

  Map<String, dynamic> _unwrapTeam(dynamic payload) {
    if (payload is Map) {
      for (final key in const ['data', 'team']) {
        final child = payload[key];
        if (child is Map) return _unwrapTeam(child);
      }
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }

  List<dynamic> _findList(
    dynamic node, {
    required List<String> keys,
    required int depth,
  }) {
    if (node is List) return node;
    if (node is Map && depth < 3) {
      for (final key in keys) {
        final dynamic child = node[key];
        if (child == null) continue;
        final found = _findList(child, keys: keys, depth: depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return const [];
  }

  @override
  Future<Either<AppException, OpponentRequestRefModel>> saveMatchStep(
    OpponentMatchStepRequest data, {
    String? requestId,
  }) async {
    final Map<String, dynamic> body = data.toJson();
    final response = requestId == null || requestId.isEmpty
        ? await _requestDataSource.createMatchStep(body)
        : await _requestDataSource.updateMatchStep(requestId, body);

    if (response.isError()) return left(ResponseHelper.error(response));

    final OpponentRequestRefModel ref = OpponentRequestRefModel.fromResponse(
      response.getValue(),
    );
    if (!ref.isValid && requestId != null && requestId.isNotEmpty) {
      return right(OpponentRequestRefModel(id: requestId));
    }
    if (!ref.isValid) {
      return left(
        DefaultException(
          errorMessage: StringConstants.somethingWentWrong,
          statusCode: 0,
        ),
      );
    }
    return right(ref);
  }

  @override
  Future<Either<AppException, OpponentRequestRefModel>> saveVenueStep(
    String requestId,
    OpponentVenueStepRequest data,
  ) async {
    final response = await _requestDataSource.saveVenueStep(
      requestId,
      data.toJson(),
    );
    if (response.isError()) return left(ResponseHelper.error(response));

    // The venue step patches a request that already exists, so a response that
    // echoes nothing still applied — keep the id the wizard is working against.
    final OpponentRequestRefModel ref = OpponentRequestRefModel.fromResponse(
      response.getValue(),
    );
    return right(ref.isValid ? ref : OpponentRequestRefModel(id: requestId));
  }

  @override
  Future<Either<AppException, OpponentRequestRefModel>> saveCostStep(
    String requestId,
    OpponentCostStepRequest data,
  ) async {
    final response = await _requestDataSource.saveCostStep(
      requestId,
      data.toJson(),
    );
    if (response.isError()) return left(ResponseHelper.error(response));

    // Like the venue step: this replaces a section of an existing request, so an
    // empty echo still applied — keep the id the wizard is working against.
    final OpponentRequestRefModel ref = OpponentRequestRefModel.fromResponse(
      response.getValue(),
    );
    return right(ref.isValid ? ref : OpponentRequestRefModel(id: requestId));
  }

  @override
  Future<Either<AppException, String>> publishRequest(
    String requestId, {
    String message = '',
  }) async {
    final response = await _requestDataSource.publishRequest(requestId, {
      if (message.trim().isNotEmpty) 'message': message.trim(),
    });
    if (response.isError()) return left(ResponseHelper.error(response));

    final String serverMessage = (_asMap(response.getValue())['message'] ?? '')
        .toString()
        .trim();
    return right(
      serverMessage.isEmpty ? StringConstants.requestPublished : serverMessage,
    );
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  ) async {
    // The key lets the server dedupe network-level retries of the same tap.
    final body = data.toJson()..['idempotency_key'] = _idempotencyKey();
    return _mutateRequestsThenReload(
      () => _requestDataSource.createRequest(body),
    );
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> declineRequest(
    String id,
  ) async {
    return _mutateRequestsThenReload(() => _requestDataSource.decline(id));
  }

  @override
  Future<Either<AppException, String>> deleteRequest(String id) async {
    final response = await _requestDataSource.delete(id);
    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      // A 204 carries no body — still a successful delete.
      if (error.statusCode != 204) return left(error);
      return right(StringConstants.requestDeleted);
    }
    final String message = (_asMap(response.getValue())['message'] ?? '')
        .toString()
        .trim();
    return right(message.isEmpty ? StringConstants.requestDeleted : message);
  }

  Map<String, dynamic> _asMap(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : const {};

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> selectOpponent(
    String id,
    String invitationId,
  ) async {
    return _mutateRequestsThenReload(
      () => _requestDataSource.selectOpponent(id, invitationId),
    );
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> rejectInvitation(
    String id,
    String reason,
  ) async {
    return _mutateRequestsThenReload(
      () => _requestDataSource.rejectInvitation(id, reason),
    );
  }

  @override
  Future<Either<AppException, List<OpponentInvitationModel>>> getInvitations(
    String requestId,
  ) async {
    final response = await _requestDataSource.fetchInvitations(requestId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final List<dynamic> rows = _findList(
        response.getValue(),
        keys: const ['data', 'items', 'invitations', 'acceptances', 'results'],
        depth: 0,
      );
      final invitations = rows
          .whereType<Map>()
          .map(
            (raw) => OpponentInvitationModel.fromJson(
              _unwrapInvitation(Map<String, dynamic>.from(raw)),
            ),
          )
          // A row with neither an id nor a team cannot be reviewed or picked.
          .where((i) => i.id.isNotEmpty || i.teamId.isNotEmpty)
          .toList(growable: false);
      return right(invitations);
    } catch (_) {
      return left(_error('Could not parse the invitations from server.'));
    }
  }

  /// An invitation row may be the object itself or a wrapper carrying it under
  /// `invitation`; both shapes have been served by this endpoint.
  Map<String, dynamic> _unwrapInvitation(Map<String, dynamic> raw) {
    for (final key in const ['invitation', 'opponent_invitation']) {
      final dynamic child = raw[key];
      if (child is Map) {
        // Wrapper fields (team, status, timestamps) stay; the nested
        // invitation wins where both name the same key.
        return <String, dynamic>{...raw}
          ..remove(key)
          ..addAll(Map<String, dynamic>.from(child));
      }
    }
    return raw;
  }

  @override
  Future<Either<AppException, OpponentRequestModel>> acceptRequest(
    AcceptOpponentRequestRequest request,
  ) async {
    final response = await _requestDataSource.accept(request);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      final Map<String, dynamic> row = _unwrapRequest(response.getValue());
      // The endpoint creates an invitation, so its 201 may echo the invitation
      // rather than the whole request. An invitation row cannot build a card,
      // so read the request back instead of showing a half-empty one.
      if (_isRequestRow(row)) {
        return right(
          OpponentRequestModel.fromJson(<String, dynamic>{
            ...row,
            'id': row['id'] ?? request.requestId,
          }),
        );
      }
      return _refetchAfterAccept(request.requestId);
    } catch (_) {
      return left(_error('Could not parse the accepted request from server.'));
    }
  }

  /// True when [row] is the request itself rather than the created invitation.
  /// An invitation row carries no schedule or venue of its own, which is what
  /// the cards and the details screen are built from.
  bool _isRequestRow(Map<String, dynamic> row) {
    if (row.isEmpty) return false;
    const List<String> requestOnlyKeys = <String>[
      'venue',
      'match',
      'cost',
      'pricing',
      'preferred_date',
      'match_format',
      'main_step',
    ];
    return requestOnlyKeys.any((String key) => row[key] != null);
  }

  /// Reads the request back after an accept whose response only echoed the
  /// invitation. A failure here is not an accept failure: the acceptance did
  /// land, so surface the server's own message and let the list refresh.
  Future<Either<AppException, OpponentRequestModel>> _refetchAfterAccept(
    String requestId,
  ) async {
    final response = await _requestDataSource.fetchRequest(requestId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    final Map<String, dynamic> row = _unwrapRequest(response.getValue());
    if (row.isEmpty) {
      return left(_error('Could not read the request after accepting.'));
    }
    return right(OpponentRequestModel.fromJson(row));
  }

  /// POST/DELETE then refresh the list — the server copy is the truth after
  /// any request mutation (mirrors the teams `_mutateThenReload` pattern,
  /// including the 204-as-success carve-out for DELETE).
  Future<Either<AppException, List<OpponentRequestModel>>>
  _mutateRequestsThenReload(Future<dynamic> Function() action) async {
    final response = await action();
    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      if (error.statusCode != 204) return left(error);
    }
    // Every list in the app is a tab of `/auth/opponent-requests`; the
    // `need_opponent` slice is the one a mutation lands back on, and the bloc
    // re-fetches whichever other tabs are already on screen.
    return (await getRequestsByTab(
      OpponentRequestTab.needOpponent,
    )).map((OpponentRequestPageModel page) => page.items);
  }

  Map<String, dynamic> _unwrapRequest(dynamic payload) {
    if (payload is Map) {
      for (final key in const ['data', 'request', 'opponent_request']) {
        final child = payload[key];
        if (child is Map) return _unwrapRequest(child);
      }
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }

  /// Unique-enough key for request deduplication; no uuid dependency needed.
  String _idempotencyKey() {
    final random = Random();
    final suffix = List.generate(
      4,
      (_) => random.nextInt(0x10000).toRadixString(16).padLeft(4, '0'),
    ).join();
    return 'req-${DateTime.now().microsecondsSinceEpoch}-$suffix';
  }
}
