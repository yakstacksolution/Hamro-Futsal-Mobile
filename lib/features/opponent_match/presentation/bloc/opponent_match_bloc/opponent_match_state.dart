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
    this.errorMessage,
  });
 
  final OpponentMatchStatus teamsStatus;
  final OpponentMatchStatus venuesStatus;
  final OpponentMatchStatus requestsStatus;
  final List<TeamModel> teams;
  final List<String> venues;
  final List<OpponentRequestModel> requests;
  final String? errorMessage;

  int get openRequestCount => requests.where((r) => r.status.isOpen).length;

  OpponentMatchState copyWith({
    OpponentMatchStatus? teamsStatus,
    OpponentMatchStatus? venuesStatus,
    OpponentMatchStatus? requestsStatus,
    List<TeamModel>? teams,
    List<String>? venues,
    List<OpponentRequestModel>? requests,
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
    errorMessage,
  ];
}
