part of 'opponent_match_bloc.dart';

sealed class OpponentMatchEvent extends Equatable {
  const OpponentMatchEvent();

  @override
  List<Object?> get props => [];
}

final class LoadTeamsEvent extends OpponentMatchEvent {
  const LoadTeamsEvent();
}

final class LoadVenuesEvent extends OpponentMatchEvent {
  const LoadVenuesEvent();
}

final class LoadPositionsEvent extends OpponentMatchEvent {
  const LoadPositionsEvent();
}

final class LoadOpponentLevelsEvent extends OpponentMatchEvent {
  const LoadOpponentLevelsEvent();
}

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

final class RefreshOpponentRequestsEvent extends OpponentMatchEvent {
  const RefreshOpponentRequestsEvent();
}

final class CreateTeamEvent extends OpponentMatchEvent {
  const CreateTeamEvent(this.name);
  final String name;

  @override
  List<Object?> get props => [name];
}

final class LoadInvitationsEvent extends OpponentMatchEvent {
  const LoadInvitationsEvent(this.requestId, {this.force = false});

  final String requestId;
  final bool force;

  @override
  List<Object?> get props => [requestId, force];
}

final class UpdateTeamEvent extends OpponentMatchEvent {
  const UpdateTeamEvent(this.teamId, this.name);
  final String teamId;
  final String name;

  @override
  List<Object?> get props => [teamId, name];
}

final class DeleteTeamEvent extends OpponentMatchEvent {
  const DeleteTeamEvent(this.teamId);
  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

final class LoadTeamEvent extends OpponentMatchEvent {
  const LoadTeamEvent(this.teamId);
  final String teamId;

  @override
  List<Object?> get props => [teamId];
}

final class AddPlayerEvent extends OpponentMatchEvent {
  const AddPlayerEvent(this.teamId, this.player);
  final String teamId;
  final PlayerModel player;

  @override
  List<Object?> get props => [teamId, player];
}

final class UpdateMemberEvent extends OpponentMatchEvent {
  const UpdateMemberEvent(this.teamId, this.player);
  final String teamId;
  final PlayerModel player;

  @override
  List<Object?> get props => [teamId, player];
}

final class RemoveMemberEvent extends OpponentMatchEvent {
  const RemoveMemberEvent(this.teamId, this.memberId);
  final String teamId;
  final String memberId;

  @override
  List<Object?> get props => [teamId, memberId];
}

final class SaveOpponentMatchStepEvent extends OpponentMatchEvent {
  const SaveOpponentMatchStepEvent(this.request);

  final OpponentMatchStepRequest request;

  @override
  List<Object?> get props => <Object?>[
    request.teamId,
    request.matchFormatId,
    request.opponentLevelId,
  ];
}

final class SaveOpponentVenueStepEvent extends OpponentMatchEvent {
  const SaveOpponentVenueStepEvent(this.request);

  final OpponentVenueStepRequest request;

  @override
  List<Object?> get props => <Object?>[request.toJson()];
}

final class SaveOpponentCostStepEvent extends OpponentMatchEvent {
  const SaveOpponentCostStepEvent(this.request);

  final OpponentCostStepRequest request;

  @override
  List<Object?> get props => <Object?>[request.toJson()];
}

final class PublishOpponentRequestEvent extends OpponentMatchEvent {
  const PublishOpponentRequestEvent({this.message = ''});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

final class LoadOpponentDraftEvent extends OpponentMatchEvent {
  const LoadOpponentDraftEvent(this.requestId);

  final String requestId;

  @override
  List<Object?> get props => <Object?>[requestId];
}

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

final class DeclineRequestEvent extends OpponentMatchEvent {
  const DeclineRequestEvent(this.request);
  final OpponentRequestModel request;

  @override
  List<Object?> get props => [request];
}

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

final class LoadMoreOpponentRequestsEvent extends OpponentMatchEvent {
  const LoadMoreOpponentRequestsEvent(this.tab);
  final OpponentRequestTab tab;

  @override
  List<Object?> get props => [tab];
}

final class LoadMatchDetailsEvent extends OpponentMatchEvent {
  const LoadMatchDetailsEvent(this.requestId, {this.force = false});
  final String requestId;
  final bool force;

  @override
  List<Object?> get props => [requestId, force];
}

final class SelectOpponentEvent extends OpponentMatchEvent {
  const SelectOpponentEvent(this.request, this.invitation);
  final OpponentRequestModel request;
  final OpponentInvitationModel invitation;

  @override
  List<Object?> get props => [request, invitation];
}

final class RejectInvitationEvent extends OpponentMatchEvent {
  const RejectInvitationEvent(this.request, this.reason);
  final OpponentRequestModel request;
  final String reason;

  @override
  List<Object?> get props => [request, reason];
}

final class ClearOpponentMessagesEvent extends OpponentMatchEvent {
  const ClearOpponentMessagesEvent();

  @override
  List<Object?> get props => const [];
}
