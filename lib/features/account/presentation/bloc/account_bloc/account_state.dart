part of 'account_bloc.dart';

enum AccountStatus { initial, loading, success, failure }

final class AccountState extends Equatable {
  const AccountState({
    this.summaryStatus = AccountStatus.initial,
    this.statementStatus = AccountStatus.initial,
    this.settlementsStatus = AccountStatus.initial,
    this.submitStatus = AccountStatus.initial,
    this.summary = AccountSummaryModel.empty,
    this.entries = const [],
    this.settlements = const [],
    this.refreshing = false,
    this.errorMessage,
  });

  final AccountStatus summaryStatus;
  final AccountStatus statementStatus;
  final AccountStatus settlementsStatus;

  /// Settlement-request submission lifecycle.
  final AccountStatus submitStatus;

  final AccountSummaryModel summary;
  final List<AccountEntryModel> entries;
  final List<SettlementModel> settlements;

  /// True while a silent refetch is in flight — keeps data on screen.
  final bool refreshing;
  final String? errorMessage;

  /// A settlement already awaiting the super admin blocks a second request.
  bool get hasPendingSettlement => settlements.any(
    (s) =>
        s.status == SettlementStatus.pending ||
        s.status == SettlementStatus.processing ||
        s.status == SettlementStatus.approved,
  );

  AccountState copyWith({
    AccountStatus? summaryStatus,
    AccountStatus? statementStatus,
    AccountStatus? settlementsStatus,
    AccountStatus? submitStatus,
    AccountSummaryModel? summary,
    List<AccountEntryModel>? entries,
    List<SettlementModel>? settlements,
    bool? refreshing,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AccountState(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      statementStatus: statementStatus ?? this.statementStatus,
      settlementsStatus: settlementsStatus ?? this.settlementsStatus,
      submitStatus: submitStatus ?? this.submitStatus,
      summary: summary ?? this.summary,
      entries: entries ?? this.entries,
      settlements: settlements ?? this.settlements,
      refreshing: refreshing ?? this.refreshing,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    summaryStatus,
    statementStatus,
    settlementsStatus,
    submitStatus,
    summary,
    entries,
    settlements,
    refreshing,
    errorMessage,
  ];
}
