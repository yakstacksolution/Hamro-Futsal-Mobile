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

/// Loads one section of the requests list from
/// `GET /auth/opponent-requests?tab={need_opponent|my_requests|settled}`.
///
/// Lazy by default: opening a section fires it, and a section already fetched
/// is served from state. Pass [force] to re-fetch (pull-to-refresh, after
/// publishing, or after a mutation).
final class LoadOpponentRequestsEvent extends OpponentMatchEvent {
  const LoadOpponentRequestsEvent({
    this.tab = OpponentRequestTab.needOpponent,
    this.force = false,
  });

  final OpponentRequestTab tab;
  final bool force;

  @override
  List<Object?> get props => <Object?>[tab, force];
}

/// Re-fetches every section that has already been loaded — used after a
/// mutation, since deleting or accepting a request can move it between tabs.
final class RefreshOpponentRequestsEvent extends OpponentMatchEvent {
  const RefreshOpponentRequestsEvent();
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

/// Submits the wizard's first step: opens the request when none exists yet,
/// otherwise patches the match section of the one already opened.
final class SaveOpponentMatchStepEvent extends OpponentMatchEvent {
  const SaveOpponentMatchStepEvent(this.request);

  final OpponentMatchStepRequest request;

  @override
  List<Object?> get props => <Object?>[
    request.teamId,
    request.matchFormatId,
    request.opponentLevelId,
    request.preferredDate,
    request.preferredTime,
  ];
}

/// Submits the wizard's second step — the venue behind the match — against
/// the request the first step opened.
final class SaveOpponentVenueStepEvent extends OpponentMatchEvent {
  const SaveOpponentVenueStepEvent(this.request);

  final OpponentVenueStepRequest request;

  @override
  List<Object?> get props => <Object?>[request.toJson()];
}

/// Sends the wizard's third step — the cost split — against the request step
/// one opened.
final class SaveOpponentCostStepEvent extends OpponentMatchEvent {
  const SaveOpponentCostStepEvent(this.request);

  final OpponentCostStepRequest request;

  @override
  List<Object?> get props => <Object?>[request.toJson()];
}

/// Publishes the draft the wizard has been building — the last step. Only the
/// optional [message] travels; the other sections are already saved.
final class PublishOpponentRequestEvent extends OpponentMatchEvent {
  const PublishOpponentRequestEvent({this.message = ''});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Fetches one of my own requests by id (`/auth/opponent-requests/{id}`) so
/// the wizard can autofill from the server's copy of a draft.
final class LoadOpponentDraftEvent extends OpponentMatchEvent {
  const LoadOpponentDraftEvent(this.requestId);

  final String requestId;

  @override
  List<Object?> get props => <Object?>[requestId];
}

/// Resets the wizard's step state. With no [draftRequestId] the next
/// first-step submit opens a fresh request; pass the id of an existing draft
/// to resume it, so that submit patches the draft instead.
final class ResetOpponentMatchStepEvent extends OpponentMatchEvent {
  const ResetOpponentMatchStepEvent({this.draftRequestId = ''});

  final String draftRequestId;

  @override
  List<Object?> get props => <Object?>[draftRequestId];
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

/// Drops the one-shot [OpponentMatchState.successMessage] /
/// [OpponentMatchState.errorMessage] once the UI has shown them, so the same
/// snackbar is not replayed on the next rebuild.
final class ClearOpponentMessagesEvent extends OpponentMatchEvent {
  const ClearOpponentMessagesEvent();

  @override
  List<Object?> get props => const [];
}
