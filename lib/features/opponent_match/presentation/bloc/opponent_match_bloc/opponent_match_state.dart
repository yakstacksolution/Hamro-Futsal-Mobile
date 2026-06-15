part of 'opponent_match_bloc.dart';

enum OpponentMatchStatus { initial, loading, success, failure }

final class OpponentMatchState extends Equatable {
  const OpponentMatchState({
    this.teamsStatus = OpponentMatchStatus.initial,
    this.venuesStatus = OpponentMatchStatus.initial,
    this.requestsStatus = OpponentMatchStatus.initial,
    this.teams = const [],
    this.venues = const [],
    this.requests = const [],
    this.positions = const [],
    this.levels = const [],
    this.errorMessage,
  });

  final OpponentMatchStatus teamsStatus;
  final OpponentMatchStatus venuesStatus;
  final OpponentMatchStatus requestsStatus;
  final List<TeamModel> teams;
  final List<String> venues;
  final List<OpponentRequestModel> requests;

  /// Player positions from `GET /positions`. Empty until loaded — the UI
  /// falls back to [PlayerPositionModel.defaults].
  final List<PlayerPositionModel> positions;

  /// Opponent levels from `GET /opponent-levels`. Empty until loaded — the
  /// UI falls back to [OpponentLevelModel.defaults].
  final List<OpponentLevelModel> levels;
  final String? errorMessage;

  int get openRequestCount => requests.where((r) => r.status.isOpen).length;

  OpponentMatchState copyWith({
    OpponentMatchStatus? teamsStatus,
    OpponentMatchStatus? venuesStatus,
    OpponentMatchStatus? requestsStatus,
    List<TeamModel>? teams,
    List<String>? venues,
    List<OpponentRequestModel>? requests,
    List<PlayerPositionModel>? positions,
    List<OpponentLevelModel>? levels,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return OpponentMatchState(
      teamsStatus: teamsStatus ?? this.teamsStatus,
      venuesStatus: venuesStatus ?? this.venuesStatus,
      requestsStatus: requestsStatus ?? this.requestsStatus,
      teams: teams ?? this.teams,
      venues: venues ?? this.venues,
      requests: requests ?? this.requests,
      positions: positions ?? this.positions,
      levels: levels ?? this.levels,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    teamsStatus,
    venuesStatus,
    requestsStatus,
    teams,
    venues,
    requests,
    positions,
    levels,
    errorMessage,
  ];
}
