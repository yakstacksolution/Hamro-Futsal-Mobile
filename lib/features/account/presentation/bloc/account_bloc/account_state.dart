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
    this.settlementCounts = const SettlementStatusCounts(),
    this.settlementsPage = 0,
    this.settlementsHasMore = false,
    this.settlementsLoadingMore = false,
    this.settlementsLoadMoreError,
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

  /// Server-reported counts per status — authoritative, and independent of how
  /// many pages have been loaded.
  final SettlementStatusCounts settlementCounts;

  /// Highest settlements page loaded so far; 0 before the first fetch.
  final int settlementsPage;
  final bool settlementsHasMore;
  final bool settlementsLoadingMore;
  final String? settlementsLoadMoreError;

  /// True while a silent refetch is in flight — keeps data on screen.
  final bool refreshing;
  final String? errorMessage;

  /// A settlement already awaiting the super admin blocks a second request.
  /// The server's summary counts every page, so it is trusted over the rows
  /// currently loaded; the local scan is the fallback before the summary lands.
  bool get hasPendingSettlement =>
      settlementCounts.inProgress > 0 ||
      settlements.any(
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
    SettlementStatusCounts? settlementCounts,
    int? settlementsPage,
    bool? settlementsHasMore,
    bool? settlementsLoadingMore,
    String? settlementsLoadMoreError,
    bool clearSettlementsLoadMoreError = false,
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
      settlementCounts: settlementCounts ?? this.settlementCounts,
      settlementsPage: settlementsPage ?? this.settlementsPage,
      settlementsHasMore: settlementsHasMore ?? this.settlementsHasMore,
      settlementsLoadingMore:
          settlementsLoadingMore ?? this.settlementsLoadingMore,
      settlementsLoadMoreError: clearSettlementsLoadMoreError
          ? null
          : settlementsLoadMoreError ?? this.settlementsLoadMoreError,
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
    settlementCounts,
    settlementsPage,
    settlementsHasMore,
    settlementsLoadingMore,
    settlementsLoadMoreError,
    refreshing,
    errorMessage,
  ];
}
