part of 'opponent_match_bloc.dart';

sealed class OpponentMatchEvent extends Equatable {
  const OpponentMatchEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the user's teams.
final class LoadTeamsEvent extends OpponentMatchEvent {
  const LoadTeamsEvent();
}

/// Loads the available venues.
final class LoadVenuesEvent extends OpponentMatchEvent {
  const LoadVenuesEvent();
}

/// Loads the opponent requests list.
final class LoadOpponentRequestsEvent extends OpponentMatchEvent {
  const LoadOpponentRequestsEvent();
}

final class CreateTeamEvent extends OpponentMatchEvent {
  const CreateTeamEvent(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

/// Adds [player] to the team with [teamId].
final class AddPlayerEvent extends OpponentMatchEvent {
  const AddPlayerEvent(this.teamId, this.player);
  final String teamId;
  final PlayerModel player;

  @override
  List<Object?> get props => [teamId, player];
}

/// Removes the player at [playerIndex] from the team with [teamId].
final class RemovePlayerEvent extends OpponentMatchEvent {
  const RemovePlayerEvent(this.teamId, this.playerIndex);
  final String teamId;
  final int playerIndex;

  @override
  List<Object?> get props => [teamId, playerIndex];
}

final class SendOpponentRequestEvent extends OpponentMatchEvent {
  const SendOpponentRequestEvent(this.request);
  final CreateOpponentRequestEntity request;

  @override
  List<Object?> get props => [request];
}

final class UpdateRequestStatusEvent extends OpponentMatchEvent {
  const UpdateRequestStatusEvent(this.request, this.status);
  final OpponentRequestModel request;
  final RequestStatus status;

  @override
  List<Object?> get props => [request, status];
}

final class DeleteOpponentRequestEvent extends OpponentMatchEvent {
  const DeleteOpponentRequestEvent(this.request);
  final OpponentRequestModel request;

  @override
  List<Object?> get props => [request];
}
