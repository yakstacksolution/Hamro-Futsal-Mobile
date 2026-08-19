import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/domain/usecase/account_usecase.dart';

part 'account_event.dart';
part 'account_state.dart';

class AccountBloc extends Bloc<AccountEvent, AccountState> {
  AccountBloc(this.useCase) : super(const AccountState()) {
    on<LoadAccountEvent>(_onLoad);
    on<LoadSettlementsEvent>(_onLoadSettlements);
    on<RequestSettlementEvent>(_onRequestSettlement);
  }

  final AccountUseCase useCase;

  /// Settlement history page size.
  static const int _settlementsPerPage = 20;

  bool _loadingSettlements = false;

  /// Summary, statement and settlements come from three endpoints — fetched
  /// together so one pull-to-refresh reconciles the whole screen, but each
  /// tracks its own status so one failure never blanks the others.
  Future<void> _onLoad(
    LoadAccountEvent event,
    Emitter<AccountState> emit,
  ) async {
    if (!event.silent) {
      emit(
        state.copyWith(
          summaryStatus: AccountStatus.loading,
          statementStatus: AccountStatus.loading,
          settlementsStatus: AccountStatus.loading,
          clearErrorMessage: true,
        ),
      );
    } else {
      emit(state.copyWith(refreshing: true));
    }

    final results = await Future.wait([
      useCase.getSettlementAccount(),
      useCase.getSettlementBreakdown(),
      useCase.getSettlements(page: 1, perPage: _settlementsPerPage),
    ]);

    var next = state.copyWith(refreshing: false);
    results[0].fold(
      (failure) => next = next.copyWith(
        summaryStatus: AccountStatus.failure,
        errorMessage: failure.errorMessage,
      ),
      (summary) {
        final model = summary as AccountSummaryModel;
        next = next.copyWith(
          summaryStatus: AccountStatus.success,
          summary: model,
          // The ledger ships inline with the settlement account.
          statementStatus: AccountStatus.success,
          entries: model.recentActivity,
        );
      },
    );
    results[1].fold(
      (failure) {
        if (next.statementStatus != AccountStatus.success) {
          next = next.copyWith(statementStatus: AccountStatus.failure);
        }
      },
      (breakdown) {
        final model = breakdown as SettlementBreakdownModel;
        next = next.copyWith(
          statementStatus: AccountStatus.success,
          // The per-futsal balances live on the breakdown endpoint; the
          // settlement-account payload keeps them only as a fallback.
          summary: model.venues.isNotEmpty
              ? next.summary.copyWith(venues: model.venues)
              : next.summary,
          entries: model.entries.isNotEmpty ? model.entries : null,
        );
      },
    );
    results[2].fold(
      (failure) =>
          next = next.copyWith(settlementsStatus: AccountStatus.failure),
      (settlements) {
        final page = settlements as SettlementPageModel;
        next = next.copyWith(
          settlementsStatus: AccountStatus.success,
          settlements: page.items,
          settlementCounts: page.summary,
          settlementsPage: page.currentPage,
          settlementsHasMore: page.hasMorePages,
          settlementsLoadingMore: false,
          clearSettlementsLoadMoreError: true,
        );
      },
    );
    emit(next);
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
      paymentProofPath: event.paymentProofPath,
      venueId: event.venueId,
      note: event.note,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          submitStatus: AccountStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (_) {
        emit(state.copyWith(submitStatus: AccountStatus.success));
        add(const LoadAccountEvent(silent: true));
      },
    );
  }
}
