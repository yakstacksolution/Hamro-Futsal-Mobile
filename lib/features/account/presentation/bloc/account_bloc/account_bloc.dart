import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/domain/usecase/account_usecase.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc(this.useCase) : super(const AccountState()) {
    on<LoadAccountEvent>(_onLoad);
    on<LoadSettlementsEvent>(_onLoadSettlements);
    on<LoadSettlementBreakdownEvent>(_onLoadBreakdown);
    on<LoadRecentActivityEvent>(_onLoadRecentActivity);
    on<RequestSettlementEvent>(_onRequestSettlement);
  }

  final AccountUseCase useCase;

  /// Settlement history page size.
  static const int _settlementsPerPage = 20;

  /// Ledger page size.
  static const int _activityPerPage = 10;

  bool _loadingSettlements = false;
  bool _loadingBreakdown = false;
  bool _loadingActivity = false;

  /// Loads the account summary, which is everything the main screen renders:
  /// balances, commission, and the inline ledger.
  ///
  /// The per-futsal breakdown and the settlement history are deliberately not
  /// here. Each backs exactly one detail screen and is fetched when that screen
  /// opens, so the main screen costs one request instead of three.
  Future<void> _onLoad(
    LoadAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          summaryStatus: AccountStatus.loading,
          statementStatus: AccountStatus.loading,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(state.copyWith(refreshing: true));
    }

    final result = await useCase.getSettlementAccount();

    var next = state.copyWith(refreshing: false);
    result.fold(
      (failure) => next = next.copyWith(
        summaryStatus: AccountStatus.failure,
        // The ledger rides along with this response, so it fails with it. The
        // breakdown used to resolve this status as a side effect; it no longer
        // runs here, and without this the activity list spins forever.
        statementStatus: AccountStatus.failure,
        errorMessage: failure.errorMessage,
      ),
      (model) {
        next = next.copyWith(
          summaryStatus: AccountStatus.success,
          summary: model,
          // The ledger ships inline with the settlement account.
          statementStatus: AccountStatus.success,
          entries: model.recentActivity,
        );
      },
    );
    emit(
      next.copyWith(
        // A refresh invalidates any held breakdown: reopening the detail screen
        // should show the reconciled figures, not the pre-refresh ones.
        breakdownStatus: state.hasBreakdown
            ? AccountStatus.initial
            : next.breakdownStatus,
        // Same for the settlement history: page 0 is what the detail screen
        // checks on open, so this makes reopening it refetch. The *status* is
        // deliberately left alone — resetting it to `initial` while that screen
        // is mounted would strand it on a skeleton with nothing left to
        // dispatch, since its fetch only fires from initState.
        settlementsPage: 0,
        // Same for the ledger.
        activityPage: 0,
      ),
    );
  }

  /// Loads the per-futsal breakdown on demand.
  ///
  /// Idempotent: reopening the screen with a breakdown already held is a no-op
  /// unless [LoadSettlementBreakdownEvent.refresh] asks for a refetch.
  Future<void> _onLoadBreakdown(
    LoadSettlementBreakdownEvent event,
    Emitter<AccountState> emit,
  ) async {
    if (_loadingBreakdown) return;
    if (state.hasBreakdown && !event.refresh) return;
    _loadingBreakdown = true;
    emit(state.copyWith(breakdownStatus: AccountStatus.loading));

    final result = await useCase.getSettlementBreakdown();
    result.fold(
      (failure) => emit(
        state.copyWith(
          breakdownStatus: AccountStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (breakdown) => emit(
        state.copyWith(
          breakdownStatus: AccountStatus.success,
          // The per-futsal balances live on this endpoint; the
          // settlement-account payload keeps them only as a fallback.
          summary: breakdown.venues.isNotEmpty
              ? state.summary.copyWith(venues: breakdown.venues)
              : state.summary,
          // The ledger already arrived with the account summary — only replace
          // it when this endpoint actually carries a richer one.
          entries: breakdown.entries.isNotEmpty ? breakdown.entries : null,
          clearErrorMessage: true,
        ),
      ),
    );
    _loadingBreakdown = false;
  }

  /// Ledger paging. `loadMore` appends the next page; otherwise page 1
  /// replaces the list. Rows are deduped by id so a movement that shifted
  /// between pages server-side cannot appear twice.
  Future<void> _onLoadRecentActivity(
    LoadRecentActivityEvent event,
    Emitter<AccountState> emit,
  ) async {
    if (_loadingActivity) return;
    if (event.loadMore && !state.activityHasMore) return;
    if (!event.loadMore && !event.refresh && state.activityPage > 0) return;
    _loadingActivity = true;

    final int page = event.loadMore ? state.activityPage + 1 : 1;
    emit(
      event.loadMore
          ? state.copyWith(
              activityLoadingMore: true,
              clearActivityLoadMoreError: true,
            )
          : state.copyWith(
              activityStatus: state.activityEntries.isEmpty
                  ? AccountStatus.loading
                  : state.activityStatus,
            ),
    );

    final result = await useCase.getRecentActivity(
      page: page,
      perPage: _activityPerPage,
    );
    _loadingActivity = false;
    result.fold(
      (failure) => emit(
        event.loadMore
            // Paging failures keep the loaded rows and report in the footer.
            ? state.copyWith(
                activityLoadingMore: false,
                activityLoadMoreError: failure.errorMessage,
              )
            : state.copyWith(
                activityStatus: AccountStatus.failure,
                errorMessage: failure.errorMessage,
              ),
      ),
      (pageResult) => emit(
        state.copyWith(
          activityStatus: AccountStatus.success,
          activityEntries: event.loadMore
              ? _mergeEntries(state.activityEntries, pageResult.items)
              : pageResult.items,
          activityPage: pageResult.currentPage,
          // An empty page means the end, whatever the flag claims.
          activityHasMore:
              pageResult.hasMorePages &&
              (!event.loadMore || pageResult.items.isNotEmpty),
          activityLoadingMore: false,
          clearActivityLoadMoreError: true,
        ),
      ),
    );
  }

  /// Appends only rows this list does not already hold.
  static List<AccountEntryModel> _mergeEntries(
    List<AccountEntryModel> existing,
    List<AccountEntryModel> incoming,
  ) {
    final Set<String> seen = existing
        .map((AccountEntryModel e) => e.id)
        .toSet();
    return <AccountEntryModel>[
      ...existing,
      ...incoming.where(
        (AccountEntryModel e) => e.id.isEmpty || seen.add(e.id),
      ),
    ];
  }

  /// Settlement history paging. `loadMore` appends the next page; `refresh`
  /// (and the first load) replaces the list with page 1. Rows are deduped by
  /// id so a request that shifted between pages server-side cannot double up.
  Future<void> _onLoadSettlements(
    LoadSettlementsEvent event,
    Emitter<AccountState> emit,
  ) async {
    if (_loadingSettlements) return;
    if (event.loadMore && !state.settlementsHasMore) return;
    _loadingSettlements = true;

    final int page = event.loadMore ? state.settlementsPage + 1 : 1;
    emit(
      event.loadMore
          ? state.copyWith(
              settlementsLoadingMore: true,
              clearSettlementsLoadMoreError: true,
            )
          : state.copyWith(
              settlementsStatus: state.settlements.isEmpty
                  ? AccountStatus.loading
                  : state.settlementsStatus,
            ),
    );
    final result = await useCase.getSettlements(
      page: page,
      perPage: _settlementsPerPage,
    );
    _loadingSettlements = false;
    result.fold(
      (failure) => emit(
        event.loadMore
            ? state.copyWith(
                settlementsLoadingMore: false,
                settlementsLoadMoreError: failure.errorMessage,
              )
            : state.copyWith(
                settlementsStatus: AccountStatus.failure,
                errorMessage: failure.errorMessage,
              ),
      ),
      (pageResult) => emit(
        state.copyWith(
          settlementsStatus: AccountStatus.success,
          settlements: event.loadMore
              ? _mergeSettlements(state.settlements, pageResult.items)
              : pageResult.items,
          settlementCounts: pageResult.summary,
          settlementsPage: pageResult.currentPage,
          // An empty page means the end, whatever the flag claims.
          settlementsHasMore:
              pageResult.hasMorePages &&
              (!event.loadMore || pageResult.items.isNotEmpty),
          settlementsLoadingMore: false,
          clearSettlementsLoadMoreError: true,
        ),
      ),
    );
  }

  List<SettlementModel> _mergeSettlements(
    List<SettlementModel> existing,
    List<SettlementModel> incoming,
  ) {
    final byId = <String, SettlementModel>{
      for (final s in existing) s.id: s,
      for (final s in incoming) s.id: s,
    };
    return byId.values.toList(growable: false)..sort(
      (a, b) => (b.requestedAt ?? DateTime(0)).compareTo(
        a.requestedAt ?? DateTime(0),
      ),
    );
  }

  /// Submits the payout request and then refetches the server-authoritative
  /// balance and canonical settlement record. Financial state is never
  /// mutated optimistically.
  Future<void> _onRequestSettlement(
    RequestSettlementEvent event,
    Emitter<AccountState> emit,
  ) async {
    emit(
      state.copyWith(
        submitStatus: AccountStatus.loading,
        clearErrorMessage: true,
      ),
    );
    final result = await useCase.createSettlement(
      amount: event.amount,
      transactionReference: event.transactionReference,
      paymentProof: event.paymentProof,
      venueId: event.venueId,
      note: event.note,
    );
    final String? failureMessage = result.fold(
      (failure) => failure.errorMessage,
      (_) => null,
    );
    if (failureMessage != null) {
      emit(
        state.copyWith(
          submitStatus: AccountStatus.failure,
          errorMessage: failureMessage,
        ),
      );
      return;
    }

    // The request was accepted, but the settlement is not *done* for the vendor
    // until the figures they are looking at reflect it. Reconcile first and
    // report success afterwards, so `submitStatus.success` — which is what
    // raises the confirmation — cannot fire over a screen still showing the
    // pre-payment commission and a live Pay button.
    //
    // Awaited inline rather than dispatched: an `add()` here would return
    // immediately and put the confirmation back ahead of the refresh.
    final bool hadBreakdown = state.hasBreakdown;
    await _onLoad(const LoadAccountEvent(silent: true), emit);
    if (hadBreakdown) {
      await _onLoadBreakdown(
        const LoadSettlementBreakdownEvent(refresh: true),
        emit,
      );
    }

    emit(state.copyWith(submitStatus: AccountStatus.success));
  }
}
