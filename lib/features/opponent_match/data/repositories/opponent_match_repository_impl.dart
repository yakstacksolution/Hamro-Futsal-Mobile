import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/data_source/opponent_match_data_source.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/domain/repository/opponent_match_repository.dart';

final class OpponentMatchRepositoryImpl extends OpponentMatchRepository {
  OpponentMatchRepositoryImpl({OpponentMatchDataSource? dataSource})
    : _dataSource = dataSource ?? OpponentMatchLocalDataSourceImpl();

  final OpponentMatchDataSource _dataSource;

  /// In-memory working copies; the data source is read once and mutations are
  /// applied here until a backend persists them.
  final List<TeamModel> _teams = [];
  final List<OpponentRequestModel> _requests = [];
  bool _teamsLoaded = false;
  bool _requestsLoaded = false;

  AppException _error(String message) =>
      DefaultException(errorMessage: message, statusCode: 0);

  @override
  Future<Either<AppException, List<TeamModel>>> getTeams() async {
    try {
      if (!_teamsLoaded) {
        _teams
          ..clear()
          ..addAll(await _dataSource.fetchTeams());
        _teamsLoaded = true;
      }
      return right(List.unmodifiable(_teams));
    } catch (_) {
      return left(_error('Could not load your teams.'));
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
  Future<Either<AppException, List<OpponentRequestModel>>> getRequests() async {
    try {
      if (!_requestsLoaded) {
        _requests
          ..clear()
          ..addAll(await _dataSource.fetchRequests());
        _requestsLoaded = true;
      }
      return right(List.unmodifiable(_requests));
    } catch (_) {
      return left(_error('Could not load opponent requests.'));
    }
  }

  @override
  Future<Either<AppException, List<TeamModel>>> createTeam(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return left(_error('Team name cannot be empty.'));
    _teams.add(
      TeamModel(
        id: 't${DateTime.now().microsecondsSinceEpoch}',
        name: trimmed,
      ),
    );
    return right(List.unmodifiable(_teams));
  }

  @override
  Future<Either<AppException, List<TeamModel>>> addPlayer(
    String teamId,
    PlayerModel player,
  ) async {
    final i = _teams.indexWhere((t) => t.id == teamId);
    if (i < 0) return left(_error('Team not found.'));
    _teams[i] = _teams[i].copyWith(players: [..._teams[i].players, player]);
    return right(List.unmodifiable(_teams));
  }

  @override
  Future<Either<AppException, List<TeamModel>>> removePlayer(
    String teamId,
    int playerIndex,
  ) async {
    final i = _teams.indexWhere((t) => t.id == teamId);
    if (i < 0) return left(_error('Team not found.'));
    final players = [..._teams[i].players];
    if (playerIndex < 0 || playerIndex >= players.length) {
      return left(_error('Player not found.'));
    }
    players.removeAt(playerIndex);
    _teams[i] = _teams[i].copyWith(players: players);
    return right(List.unmodifiable(_teams));
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> sendRequest(
    CreateOpponentRequestEntity data,
  ) async {
    try {
      _requests.insert(
        0,
        data.toModel('r${DateTime.now().microsecondsSinceEpoch}'),
      );
      return right(List.unmodifiable(_requests));
    } catch (_) {
      return left(_error('Could not send the request.'));
    }
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> updateRequestStatus(
    String id,
    RequestStatus status,
  ) async {
    final i = _requests.indexWhere((r) => r.id == id);
    if (i < 0) return left(_error('Request not found.'));
    _requests[i] = _requests[i].copyWith(status: status);
    return right(List.unmodifiable(_requests));
  }

  @override
  Future<Either<AppException, List<OpponentRequestModel>>> deleteRequest(
    String id,
  ) async {
    final lengthBefore = _requests.length;
    _requests.removeWhere((r) => r.id == id);
    if (_requests.length == lengthBefore) {
      return left(_error('Request not found.'));
    }
    return right(List.unmodifiable(_requests));
  }
}
