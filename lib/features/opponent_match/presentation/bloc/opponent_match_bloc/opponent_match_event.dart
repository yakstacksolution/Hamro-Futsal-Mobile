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

/// Loads the player positions from `GET /positions`.
final class LoadPositionsEvent extends OpponentMatchEvent {
  const LoadPositionsEvent();
}

/// Loads the opponent levels from `GET /opponent-levels`.
final class LoadOpponentLevelsEvent extends OpponentMatchEvent {
  const LoadOpponentLevelsEvent();
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

/// Renames the team with [teamId].
final class UpdateTeamEvent extends OpponentMatchEvent {
  const UpdateTeamEvent(this.teamId, this.name);
  final String teamId;
  final String name;

  @override
  List<Object?> get props => [teamId, name];
}

/// Deletes the team with [teamId].
final class DeleteTeamEvent extends OpponentMatchEvent {
  const DeleteTeamEvent(this.teamId);
  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

/// Refreshes a single team (with its members) from the backend.
final class LoadTeamEvent extends OpponentMatchEvent {
  const LoadTeamEvent(this.teamId);
  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

/// Adds [player] to the team with [teamId].
final class AddPlayerEvent extends OpponentMatchEvent {
  const AddPlayerEvent(this.teamId, this.player);
  final String teamId;
  final PlayerModel player;

  @override
  List<Object?> get props => [teamId, player];
}

/// Updates [player]'s name/position on the team with [teamId] —
/// `teams/{team}/members/{member}/update`. [PlayerModel.id] carries the
/// member id.
final class UpdateMemberEvent extends OpponentMatchEvent {
  const UpdateMemberEvent(this.teamId, this.player);
  final String teamId;
  final PlayerModel player;

  @override
  List<Object?> get props => [teamId, player];
}

/// Removes the member [memberId] from the team with [teamId].
final class RemoveMemberEvent extends OpponentMatchEvent {
  const RemoveMemberEvent(this.teamId, this.memberId);
  final String teamId;
  final String memberId;

  @override
  List<Object?> get props => [teamId, memberId];
}

final class SendOpponentRequestEvent extends OpponentMatchEvent {
  const SendOpponentRequestEvent(this.request);
  final CreateOpponentRequestEntity request;

  @override
  List<Object?> get props => [request];
}

/// Declines an incoming open request on the server.
final class DeclineRequestEvent extends OpponentMatchEvent {
  const DeclineRequestEvent(this.request);
  final OpponentRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Fired by the accept flow after a successful submit — patches the request
/// into the list immediately, then a background refresh reconciles with the
/// server copy.
final class RequestAcceptedEvent extends OpponentMatchEvent {
  const RequestAcceptedEvent(this.updated);
  final OpponentRequestModel updated;

  @override
  List<Object?> get props => [updated];
}

final class DeleteOpponentRequestEvent extends OpponentMatchEvent {
  const DeleteOpponentRequestEvent(this.request);
  final OpponentRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Requester picks this request's opponent — the match is confirmed and
/// every other invitation is rejected.
final class SelectOpponentEvent extends OpponentMatchEvent {
  const SelectOpponentEvent(this.request);
  final OpponentRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Requester turns the acceptance down with [reason] — the request re-opens
/// for other teams.
final class RejectInvitationEvent extends OpponentMatchEvent {
  const RejectInvitationEvent(this.request, this.reason);
  final OpponentRequestModel request;
  final String reason;

  @override
  List<Object?> get props => [request, reason];
}
