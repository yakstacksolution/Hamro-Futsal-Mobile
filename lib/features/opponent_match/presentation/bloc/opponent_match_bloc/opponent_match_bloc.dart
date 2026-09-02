import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_details_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_step_request.dart';
import 'package:hamro_futsal/features/opponent_match/domain/entities/opponent_match_entities.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_tab.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_summary_model.dart';
import 'package:hamro_futsal/features/opponent_match/domain/usecase/opponent_match_usecase.dart';

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
    on<LoadMoreOpponentRequestsEvent>(_onLoadMoreRequests);
    on<RefreshOpponentRequestsEvent>(_onRefreshRequests);
    on<CreateTeamEvent>(_onCreateTeam);
    on<UpdateTeamEvent>(_onUpdateTeam);
    on<DeleteTeamEvent>(_onDeleteTeam);
    on<AddPlayerEvent>(_onAddPlayer);
    on<UpdateMemberEvent>(_onUpdateMember);
    on<RemoveMemberEvent>(_onRemoveMember);
    on<SaveOpponentMatchStepEvent>(_onSaveMatchStep);
    on<SaveOpponentVenueStepEvent>(_onSaveVenueStep);
    on<SaveOpponentCostStepEvent>(_onSaveCostStep);
    on<PublishOpponentRequestEvent>(_onPublishRequest);
    on<ResetOpponentMatchStepEvent>(_onResetMatchStep);
    on<LoadOpponentDraftEvent>(_onLoadDraft);
    on<SendOpponentRequestEvent>(_onSendRequest);
    on<DeclineRequestEvent>(_onDeclineRequest);
    on<RequestAcceptedEvent>(_onRequestAccepted);
    on<LoadInvitationsEvent>(_onLoadInvitations);
    on<DeleteOpponentRequestEvent>(_onDeleteRequest);
    on<LoadMatchDetailsEvent>(_onLoadMatchDetails);
    on<SelectOpponentEvent>(_onSelectOpponent);
    on<RejectInvitationEvent>(_onRejectInvitation);
    on<ClearOpponentMessagesEvent>(
      (_, emit) => emit(
        state.copyWith(clearSuccessMessage: true, clearErrorMessage: true),
      ),
    );
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

  /// One tab, one call. Idempotent unless forced: opening a section
  /// re-dispatches this, so a section already fetched is served from state
  /// instead of re-hitting the API.
  Future<void> _onLoadRequests(
    LoadOpponentRequestsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final tab = event.tab;
    if (state.isLoadingTab(tab)) return;
    if (state.hasLoadedTab(tab) && !event.force) return;

    emit(
      state.withTab(tab, status: OpponentMatchStatus.loading, clearError: true),
    );
    // Always the first page: this event either opens a section or refreshes
    // it, and both start the list over rather than appending.
    final result = await useCase.getRequestsByTab(tab, page: 1);
    result.fold(
      (failure) => emit(
        state.withTab(
          tab,
          status: OpponentMatchStatus.failure,
          error: failure.errorMessage,
        ),
      ),
      (page) => emit(
        state.withTab(
          tab,
          requests: page.items,
          status: OpponentMatchStatus.success,
          clearError: true,
          page: page.currentPage,
          hasMore: page.hasMore,
          total: page.total,
          summary: page.summary,
          loadingMore: false,
        ),
      ),
    );
  }

  /// Appends the next page of a section the user has scrolled to the end of.
  ///
  /// Ignored unless the server said more exist, and while a page is already in
  /// flight — the list dispatches this from a scroll listener, which fires far
  /// more often than pages are needed.
  Future<void> _onLoadMoreRequests(
    LoadMoreOpponentRequestsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final tab = event.tab;
    if (!state.hasLoadedTab(tab)) return;
    if (!state.hasMoreFor(tab)) return;
    if (state.isLoadingMore(tab) || state.isLoadingTab(tab)) return;

    final int next = state.pageFor(tab) + 1;
    emit(state.withTab(tab, loadingMore: true));

    final result = await useCase.getRequestsByTab(tab, page: next);
    result.fold(
      // A failed page leaves the rows already on screen alone — the user keeps
      // what they have and the scroll listener can try the same page again.
      (failure) => emit(
        state.withTab(tab, loadingMore: false, error: failure.errorMessage),
      ),
      (page) {
        // Ids already held win over the incoming copy: a row that moved
        // between pages while the user scrolled would otherwise appear twice.
        final List<OpponentRequestModel> current = state.requestsFor(tab);
        final Set<String> seen = current.map((r) => r.id).toSet();
        emit(
          state.withTab(
            tab,
            requests: <OpponentRequestModel>[
              ...current,
              ...page.items.where((r) => !seen.contains(r.id)),
            ],
            page: page.currentPage,
            hasMore: page.hasMore,
            total: page.total,
            summary: page.summary,
            loadingMore: false,
            clearError: true,
          ),
        );
      },
    );
  }

  /// A mutation can move a request between tabs, so every tab already on
  /// screen is re-fetched. Tabs never opened stay untouched — they will load
  /// lazily when the user gets there.
  Future<void> _onRefreshRequests(
    RefreshOpponentRequestsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    for (final tab in OpponentRequestTab.values) {
      if (state.statusFor(tab) == OpponentMatchStatus.initial) continue;
      add(LoadOpponentRequestsEvent(tab: tab, force: true));
    }
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

  /// First wizard step. The id from the create is kept in state, so coming
  /// back to the step and submitting again patches that request instead of
  /// opening another one.
  Future<void> _onSaveMatchStep(
    SaveOpponentMatchStepEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    emit(
      state.copyWith(
        matchStepStatus: OpponentMatchStatus.loading,
        clearMatchStepError: true,
      ),
    );

    final result = await useCase.saveMatchStep(
      event.request,
      requestId: state.hasDraftRequest ? state.draftRequestId : null,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          matchStepStatus: OpponentMatchStatus.failure,
          matchStepError: failure.errorMessage,
        ),
      ),
      (ref) => emit(
        state.copyWith(
          matchStepStatus: OpponentMatchStatus.success,
          draftRequestId: ref.id,
          clearMatchStepError: true,
        ),
      ),
    );
  }

  /// Step two needs the id step one produced; without it there is nothing to
  /// attach the venue to, so the step fails rather than opening a new request.
  Future<void> _onSaveVenueStep(
    SaveOpponentVenueStepEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    if (!state.hasDraftRequest) {
      emit(
        state.copyWith(
          venueStepStatus: OpponentMatchStatus.failure,
          venueStepError:
              'The match details have not been saved yet. '
              'Go back a step and try again.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        venueStepStatus: OpponentMatchStatus.loading,
        clearVenueStepError: true,
      ),
    );

    final result = await useCase.saveVenueStep(
      state.draftRequestId,
      event.request,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          venueStepStatus: OpponentMatchStatus.failure,
          venueStepError: failure.errorMessage,
        ),
      ),
      (ref) => emit(
        state.copyWith(
          venueStepStatus: OpponentMatchStatus.success,
          draftRequestId: ref.id,
          clearVenueStepError: true,
        ),
      ),
    );
  }

  /// Hydrates the wizard from the server's copy of a draft. Failure is kept in
  /// [OpponentMatchState.draftError] so the wizard can offer a retry while the
  /// row it was opened with still fills the pickers.
  Future<void> _onLoadDraft(
    LoadOpponentDraftEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    emit(
      state.copyWith(
        draftStatus: OpponentMatchStatus.loading,
        clearDraftError: true,
      ),
    );
    final result = await useCase.getMyRequest(event.requestId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          draftStatus: OpponentMatchStatus.failure,
          draftError: failure.errorMessage,
        ),
      ),
      (request) => emit(
        state.copyWith(
          draftStatus: OpponentMatchStatus.success,
          draftDetail: request,
          clearDraftError: true,
        ),
      ),
    );
  }

  /// Step three needs the id step one produced, exactly like the venue step.
  Future<void> _onSaveCostStep(
    SaveOpponentCostStepEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    if (!state.hasDraftRequest) {
      emit(
        state.copyWith(
          costStepStatus: OpponentMatchStatus.failure,
          costStepError:
              'The match details have not been saved yet. '
              'Go back a step and try again.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        costStepStatus: OpponentMatchStatus.loading,
        clearCostStepError: true,
      ),
    );

    final result = await useCase.saveCostStep(
      state.draftRequestId,
      event.request,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          costStepStatus: OpponentMatchStatus.failure,
          costStepError: failure.errorMessage,
        ),
      ),
      (ref) => emit(
        state.copyWith(
          costStepStatus: OpponentMatchStatus.success,
          draftRequestId: ref.id,
          clearCostStepError: true,
        ),
      ),
    );
  }

  /// Publishes the wizard's draft. On success the confirmation message goes to
  /// [OpponentMatchState.successMessage] — the screen shows it — and both lists
  /// are refreshed so the row moves out of "Draft".
  Future<void> _onPublishRequest(
    PublishOpponentRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    if (!state.hasDraftRequest) {
      emit(
        state.copyWith(
          publishStatus: OpponentMatchStatus.failure,
          publishError:
              'This request has not been opened on the server yet. '
              'Go back and save the match details first.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        publishStatus: OpponentMatchStatus.loading,
        clearPublishError: true,
      ),
    );

    final result = await useCase.publishRequest(
      state.draftRequestId,
      message: event.message,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          publishStatus: OpponentMatchStatus.failure,
          publishError: failure.errorMessage,
        ),
      ),
      (message) {
        emit(
          state.copyWith(
            publishStatus: OpponentMatchStatus.success,
            successMessage: message,
            clearPublishError: true,
          ),
        );
        // It is no longer a draft: every loaded section may have changed.
        add(const RefreshOpponentRequestsEvent());
      },
    );
  }

  void _onResetMatchStep(
    ResetOpponentMatchStepEvent event,
    Emitter<OpponentMatchState> emit,
  ) {
    emit(
      state.copyWith(
        matchStepStatus: OpponentMatchStatus.initial,
        venueStepStatus: OpponentMatchStatus.initial,
        costStepStatus: OpponentMatchStatus.initial,
        clearCostStepError: true,
        publishStatus: OpponentMatchStatus.initial,
        clearPublishError: true,
        draftRequestId: event.draftRequestId,
        draftStatus: OpponentMatchStatus.initial,
        clearDraftDetail: true,
        clearDraftError: true,
        clearMatchStepError: true,
        clearVenueStepError: true,
      ),
    );
  }

  Future<void> _onDeclineRequest(
    DeclineRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(await useCase.declineRequest(event.request.id), emit);
  }

  /// Patch the accepted request into the list right away so the card shows
  /// "invitation sent" without waiting for the round-trip refresh.
  Future<void> _onRequestAccepted(
    RequestAcceptedEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    // Patch the row wherever it is rendered, then let the server confirm.
    emit(
      state.copyWith(
        tabRequests: {
          for (final entry in state.tabRequests.entries)
            entry.key: [
              for (final r in entry.value)
                if (r.id == event.updated.id) event.updated else r,
            ],
        },
        clearErrorMessage: true,
      ),
    );
    add(const RefreshOpponentRequestsEvent());
  }

  /// Deletes one of my requests. On success the row is dropped from every
  /// loaded section in place — the server already told us it is gone, so no tab
  /// is fetched again — and the server's message is surfaced as a confirmation.
  /// Loads the teams that accepted one request and patches them onto that row
  /// wherever it is rendered, so the review screen, the card's invitation count
  /// and the confirm flow all read from one list.
  Future<void> _onLoadInvitations(
    LoadInvitationsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final String id = event.requestId;
    if (id.isEmpty) return;
    if (state.isLoadingInvitations(id)) return;
    if (state.hasLoadedInvitations(id) && !event.force) return;

    emit(
      state.withInvitations(
        id,
        status: OpponentMatchStatus.loading,
        clearError: true,
      ),
    );
    final result = await useCase.getInvitations(id);
    result.fold(
      (failure) => emit(
        state.withInvitations(
          id,
          status: OpponentMatchStatus.failure,
          error: failure.errorMessage,
        ),
      ),
      (invitations) => emit(
        state.withInvitations(
          id,
          status: OpponentMatchStatus.success,
          invitations: invitations,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> _onDeleteRequest(
    DeleteOpponentRequestEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final String id = event.request.id;
    final result = await useCase.deleteRequest(id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          errorMessage: failure.errorMessage,
          clearSuccessMessage: true,
        ),
      ),
      (message) => emit(
        state.copyWith(
          tabRequests: {
            for (final entry in state.tabRequests.entries)
              entry.key: entry.value
                  .where((r) => r.id != id)
                  .toList(growable: false),
          },
          successMessage: message,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  /// One settled request, one call. The screen re-dispatches this on open, so
  /// a match already read is served from state unless the caller forces it.
  Future<void> _onLoadMatchDetails(
    LoadMatchDetailsEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    final String id = event.requestId;
    if (id.isEmpty) return;
    if (state.isLoadingMatchDetails(id)) return;
    if (state.matchDetailsFor(id) != null && !event.force) return;

    emit(
      state.copyWith(
        matchDetailStatuses: {
          ...state.matchDetailStatuses,
          id: OpponentMatchStatus.loading,
        },
        matchDetailErrors: {...state.matchDetailErrors, id: null},
      ),
    );

    final result = await useCase.getMatchDetails(id);
    result.fold(
      (failure) => emit(
        state.copyWith(
          matchDetailStatuses: {
            ...state.matchDetailStatuses,
            id: OpponentMatchStatus.failure,
          },
          matchDetailErrors: {
            ...state.matchDetailErrors,
            id: failure.errorMessage,
          },
        ),
      ),
      (match) => emit(
        state.copyWith(
          matchDetails: {...state.matchDetails, id: match},
          matchDetailStatuses: {
            ...state.matchDetailStatuses,
            id: OpponentMatchStatus.success,
          },
          matchDetailErrors: {...state.matchDetailErrors, id: null},
        ),
      ),
    );
  }

  Future<void> _onSelectOpponent(
    SelectOpponentEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    if (event.invitation.id.isEmpty) {
      emit(
        state.copyWith(
          selectOpponentStatus: OpponentMatchStatus.failure,
          selectOpponentError:
              'That invitation is missing its id — refresh and try again.',
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        selectOpponentStatus: OpponentMatchStatus.loading,
        clearSelectOpponentError: true,
      ),
    );

    final result = await useCase.selectOpponent(
      event.request.id,
      event.invitation.id,
    );
    emit(
      state.copyWith(
        selectOpponentStatus: result.isLeft()
            ? OpponentMatchStatus.failure
            : OpponentMatchStatus.success,
        selectOpponentError: result.fold((f) => f.errorMessage, (_) => null),
        clearSelectOpponentError: result.isRight(),
      ),
    );
    // The confirmed match changes every list this request appears on, so the
    // reload runs on success and failure alike — a rejected confirmation may
    // still mean the request moved on without this device knowing.
    _applyRequests(result, emit);
  }

  Future<void> _onRejectInvitation(
    RejectInvitationEvent event,
    Emitter<OpponentMatchState> emit,
  ) async {
    _applyRequests(
      await useCase.rejectInvitation(event.request.id, event.reason),
      emit,
    );
  }

  /// Mutations (decline, select an opponent, reject an invitation…) reload the
  /// `need_opponent` slice they answered with, then refresh whatever other
  /// sections are on screen — a request can move between tabs.
  void _applyRequests(
    Either<AppException, List<OpponentRequestModel>> result,
    Emitter<OpponentMatchState> emit,
  ) {
    result.fold(
      (failure) => emit(state.copyWith(errorMessage: failure.errorMessage)),
      (requests) => emit(
        state.withTab(
          OpponentRequestTab.needOpponent,
          requests: requests,
          status: OpponentMatchStatus.success,
          clearError: true,
        ),
      ),
    );
    add(const RefreshOpponentRequestsEvent());
  }
}
