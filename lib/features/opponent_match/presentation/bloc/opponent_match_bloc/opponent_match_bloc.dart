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
    on<LoadVenuesEvent>(_onLoadVenues);
    on<LoadOpponentRequestsEvent>(_onLoadRequests);
    on<CreateTeamEvent>(_onCreateTeam);
    on<AddPlayerEvent>(_onAddPlayer);
    on<RemovePlayerEvent>(_onRemovePlayer);
    on<SendOpponentRequestEvent>(_onSendRequest);
    on<UpdateRequestStatusEvent>(_onUpdateStatus);
    on<DeleteOpponentRequestEvent>(_onDeleteRequest);
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

  Future<void> _onCreateTeam(
    CreateTeamEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.createTeam(event.name), emit);
  }

  Future<void> _onAddPlayer(
    AddPlayerEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(await useCase.addPlayer(event.teamId, event.player), emit);
  }

  Future<void> _onRemovePlayer(
    RemovePlayerEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyTeams(
      await useCase.removePlayer(event.teamId, event.playerIndex),
      emit,
    );
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

  Future<void> _onUpdateStatus(
    UpdateRequestStatusEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(
      await useCase.updateRequestStatus(event.request.id, event.status),
      emit,
    );
  }

  Future<void> _onDeleteRequest(
    DeleteOpponentRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(await useCase.deleteRequest(event.request.id), emit);
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
