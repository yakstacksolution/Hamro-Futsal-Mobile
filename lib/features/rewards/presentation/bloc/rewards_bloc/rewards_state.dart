part of 'rewards_bloc.dart';

enum RewardsStatus { idle, loading, success, failure }

final class RewardsState extends Equatable {
  const RewardsState({
    this.summaryStatus = RewardsStatus.idle,
    this.summary,
    this.isRefreshing = false,
    this.errorMessage,
    this.historyStatus = RewardsStatus.idle,
    this.history = const <RewardHistoryEntryModel>[],
    this.historyPage = 1,
    this.historyTotal = 0,
    this.hasReachedMax = false,
    this.isLoadingMoreHistory = false,
    this.historyErrorMessage,
    this.generateStatus = RewardsStatus.idle,
    this.isGenerating = false,
    this.generatedCoupon,
    this.generateErrorMessage,
  });

  /// Wallet.
  final RewardsStatus summaryStatus;
  final RewardsSummaryModel? summary;
  final bool isRefreshing;
  final String? errorMessage;

  /// History.
  final RewardsStatus historyStatus;
  final List<RewardHistoryEntryModel> history;
  final int historyPage;
  final int historyTotal;
  final bool hasReachedMax;
  final bool isLoadingMoreHistory;
  final String? historyErrorMessage;

  /// Coupon generation.
  final RewardsStatus generateStatus;
  final bool isGenerating;
  final GeneratedRewardCouponModel? generatedCoupon;
  final String? generateErrorMessage;

  /// True only for the very first wallet load, when there is nothing to show.
  bool get isInitialLoading =>
      summaryStatus == RewardsStatus.loading && summary == null;

  bool get hasSummary => summary != null;

  /// Wallet failed and nothing is cached — the page renders a retry state.
  bool get isSummaryFailure =>
      summaryStatus == RewardsStatus.failure && summary == null;

  bool get isHistoryInitialLoading =>
      historyStatus == RewardsStatus.loading && history.isEmpty;

  RewardsSummaryModel get wallet => summary ?? RewardsSummaryModel.empty;

  RewardsState copyWith({
    RewardsStatus? summaryStatus,
    RewardsSummaryModel? summary,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    RewardsStatus? historyStatus,
    List<RewardHistoryEntryModel>? history,
    int? historyPage,
    int? historyTotal,
    bool? hasReachedMax,
    bool? isLoadingMoreHistory,
    String? historyErrorMessage,
    bool clearHistoryError = false,
    RewardsStatus? generateStatus,
    bool? isGenerating,
    GeneratedRewardCouponModel? generatedCoupon,
    bool clearGeneratedCoupon = false,
    String? generateErrorMessage,
    bool clearGenerateError = false,
  }) {
    return RewardsState(
      summaryStatus: summaryStatus ?? this.summaryStatus,
      summary: summary ?? this.summary,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      historyStatus: historyStatus ?? this.historyStatus,
      history: history ?? this.history,
      historyPage: historyPage ?? this.historyPage,
      historyTotal: historyTotal ?? this.historyTotal,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMoreHistory: isLoadingMoreHistory ?? this.isLoadingMoreHistory,
      historyErrorMessage: clearHistoryError
          ? null
          : (historyErrorMessage ?? this.historyErrorMessage),
      generateStatus: generateStatus ?? this.generateStatus,
      isGenerating: isGenerating ?? this.isGenerating,
      generatedCoupon: clearGeneratedCoupon
          ? null
          : (generatedCoupon ?? this.generatedCoupon),
      generateErrorMessage: clearGenerateError
          ? null
          : (generateErrorMessage ?? this.generateErrorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    summaryStatus,
    summary,
    isRefreshing,
    errorMessage,
    historyStatus,
    history,
    historyPage,
    historyTotal,
    hasReachedMax,
    isLoadingMoreHistory,
    historyErrorMessage,
    generateStatus,
    isGenerating,
    generatedCoupon,
    generateErrorMessage,
  ];
}
