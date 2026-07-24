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
    on<RequestSettlementEvent>(_onRequestSettlement);
  }

  final AccountUseCase useCase;

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
      useCase.getSettlements(),
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
      (settlements) => next = next.copyWith(
        settlementsStatus: AccountStatus.success,
        settlements: (settlements as List).cast<SettlementModel>(),
      ),
    );
    emit(next);
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
