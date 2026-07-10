import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_footsall/features/opponent_match/domain/usecase/opponent_match_usecase.dart';

part 'opponent_match_event.dart';
part 'opponent_match_state.dart';

class OpponentMatchBloc extends Bloc<OpponentMatchEvent, OpponentMatchState> {
  OpponentMatchBloc(this.useCase) : super(const OpponentMatchState()) {
    on<LoadTeamsEvent>(_onLoadTeams);
    on<LoadTeamEvent>(_onLoadTeam);
    on<LoadVenuesEvent>(_onLoadVenues);
    on<LoadPositionsEvent>(_onLoadPositions);
    on<LoadOpponentLevelsEvent>(_onLoadOpponentLevels);
    on<LoadOpponentRequestsEvent>(_onLoadRequests);
    on<CreateTeamEvent>(_onCreateTeam);
    on<UpdateTeamEvent>(_onUpdateTeam);
    on<DeleteTeamEvent>(_onDeleteTeam);
    on<AddPlayerEvent>(_onAddPlayer);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<RemoveMemberEvent>(_onRemoveMember);
    on<SendOpponentRequestEvent>(_onSendRequest);
    on<DeclineRequestEvent>(_onDeclineRequest);
    on<RequestAcceptedEvent>(_onRequestAccepted);
    on<DeleteOpponentRequestEvent>(_onDeleteRequest);
    on<VerifyOpponentPaymentEvent>(_onVerifyPayment);
    on<RejectOpponentPaymentEvent>(_onRejectPayment);
  }

  final OpponentMatchUseCase useCase;

  Future<void> _onLoadTeams(
    LoadTeamsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    emit(state.copyWith(teamsStatus: OpponentMatchStatus.loading));
    final result = await useCase.getTeams();
    result.fold(
      (failure) => emit(
        state.copyWith(
          teamsStatus: OpponentMatchStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (teams) => emit(
        state.copyWith(teamsStatus: OpponentMatchStatus.success, teams: teams),
      ),
    );
  }

  Future<void> _onLoadVenues(
    LoadVenuesEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    emit(state.copyWith(venuesStatus: OpponentMatchStatus.loading));
    final result = await useCase.getVenues();
    result.fold(
      (failure) =>
          emit(state.copyWith(venuesStatus: OpponentMatchStatus.failure)),
      (venues) => emit(
        state.copyWith(
          venuesStatus: OpponentMatchStatus.success,
          venues: venues,
        ),
      ),
    );
  }

  /// Positions and levels are lookups with static fallbacks in the UI, so a
  /// failed fetch is silent — the chips simply keep the default options.
  Future<void> _onLoadPositions(
    LoadPositionsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final result = await useCase.getPositions();
    result.fold(
      (_) {},
      (positions) => emit(state.copyWith(positions: positions)),
    );
  }

  Future<void> _onLoadOpponentLevels(
    LoadOpponentLevelsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final result = await useCase.getOpponentLevels();
    result.fold((_) {}, (levels) => emit(state.copyWith(levels: levels)));
  }

  Future<void> _onLoadRequests(
    LoadOpponentRequestsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    emit(
      state.copyWith(
        requestsStatus: OpponentMatchStatus.loading,
        clearErrorMessage: true,
      ),
    );
    final result = await useCase.getRequests();
    result.fold(
      (failure) => emit(
        state.copyWith(
          requestsStatus: OpponentMatchStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (requests) => emit(
        state.copyWith(
          requestsStatus: OpponentMatchStatus.success,
          requests: requests,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  Future<void> _onLoadTeam(
    LoadTeamEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final result = await useCase.getTeam(event.teamId);
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (team) {
        final teams = [
          for (final t in state.teams)
            if (t.id == team.id) team else t,
        ];
        emit(state.copyWith(teams: teams, clearErrorMessage: true));
      },
    );
  }

  Future<void> _onCreateTeam(
    CreateTeamEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.createTeam(event.name), emit);
  }

  Future<void> _onUpdateTeam(
    UpdateTeamEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.updateTeam(event.teamId, event.name), emit);
  }

  Future<void> _onDeleteTeam(
    DeleteTeamEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.deleteTeam(event.teamId), emit);
  }

  Future<void> _onAddPlayer(
    AddPlayerEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.addMember(event.teamId, event.player), emit);
  }

  Future<void> _onUpdateMember(
    UpdateMemberEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.updateMember(event.teamId, event.player), emit);
  }

  Future<void> _onRemoveMember(
    RemoveMemberEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.removeMember(event.teamId, event.memberId), emit);
  }

  void _applyTeams(
    Either<AppException, List<TeamModel>> result,
    Emitter<OpponentMatchState> emit,
  ) {
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (teams) => emit(state.copyWith(teams: teams, clearErrorMessage: true)),
    );
  }

  Future<void> _onSendRequest(
    SendOpponentRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(await useCase.sendRequest(event.request), emit);
  }

  Future<void> _onDeclineRequest(
    DeclineRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(await useCase.declineRequest(event.request.id), emit);
  }

  /// Patch the accepted request into the list right away so the card shows
  /// "payment pending" without waiting for the round-trip refresh.
  Future<void> _onRequestAccepted(
    RequestAcceptedEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final requests = [
      for (final r in state.requests)
        if (r.id == event.updated.id) event.updated else r,
    ];
    emit(state.copyWith(requests: requests, clearErrorMessage: true));
    _applyRequests(await useCase.getRequests(), emit);
  }

  Future<void> _onDeleteRequest(
    DeleteOpponentRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(await useCase.deleteRequest(event.request.id), emit);
  }

  Future<void> _onVerifyPayment(
    VerifyOpponentPaymentEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(await useCase.verifyPayment(event.request.id), emit);
  }

  Future<void> _onRejectPayment(
    RejectOpponentPaymentEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(
      await useCase.rejectPayment(event.request.id, event.reason),
      emit,
    );
  }

  void _applyRequests(
    Either<AppException, List<OpponentRequestModel>> result,
    Emitter<OpponentMatchState> emit,
  ) {
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (requests) =>
          emit(state.copyWith(requests: requests, clearErrorMessage: true)),
    );
  }
}
