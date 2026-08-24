part of 'transaction_history_bloc.dart';

enum TransactionHistoryStatus { initial, loading, success, failure }

class TransactionHistoryState extends Equatable {
  const TransactionHistoryState({
    this.status = TransactionHistoryStatus.initial,
    this.items = const <TransactionHistoryItemModel>[],
    this.summary,
    this.availableTypes = const <String>[],
    this.direction = TransactionDirectionFilter.all,
    this.type = 'all',
    this.search = '',
    this.range = TransactionDateRange.allTime,
    this.page = 1,
    this.total = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.errorMessage,
  });

  final TransactionHistoryStatus status;

  /// Every page loaded so far, oldest page first.
  final List<TransactionHistoryItemModel> items;
  final TransactionHistorySummaryModel? summary;

  /// `type` chip values: the known sources plus anything else the loaded rows
  /// turn out to carry.
  final List<String> availableTypes;

  final TransactionDirectionFilter direction;
  final String type;

  /// Current server-side `search` term ('' when not searching).
  final String search;

  /// Current `date_from` / `date_to` window.
  final TransactionDateRange range;

  /// Highest page number currently loaded.
  final int page;
  final int total;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? errorMessage;

  /// First load with nothing to show yet — the only time a skeleton appears.
  bool get isInitialLoading =>
      status == TransactionHistoryStatus.loading && items.isEmpty;

  /// A filter or search change is in flight while rows from the previous query
  /// are still on screen. Pull-to-refresh has its own indicator, so it is
  /// excluded here.
  bool get isReloading =>
      status == TransactionHistoryStatus.loading &&
      items.isNotEmpty &&
      !isRefreshing;

  bool get hasFilters =>
      direction != TransactionDirectionFilter.all ||
      type != 'all' ||
      search.isNotEmpty ||
      range.isActive;

  /// Count shown on the filter button's badge; [search] has its own field on
  /// screen, so it is deliberately not counted here.
  int get activeFilterCount =>
      (direction != TransactionDirectionFilter.all ? 1 : 0) +
      (type != 'all' ? 1 : 0) +
      (range.isActive ? 1 : 0);

  TransactionHistoryState copyWith({
    TransactionHistoryStatus? status,
    List<TransactionHistoryItemModel>? items,
    TransactionHistorySummaryModel? summary,
    List<String>? availableTypes,
    TransactionDirectionFilter? direction,
    String? type,
    String? search,
    TransactionDateRange? range,
    int? page,
    int? total,
    bool? hasReachedMax,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? errorMessage,
    bool clearError = false,
    bool clearSummary = false,
  }) {
    return TransactionHistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      summary: clearSummary ? null : (summary ?? this.summary),
      availableTypes: availableTypes ?? this.availableTypes,
      direction: direction ?? this.direction,
      type: type ?? this.type,
      search: search ?? this.search,
      range: range ?? this.range,
      page: page ?? this.page,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    items,
    summary,
    availableTypes,
    direction,
    type,
    search,
    range,
    page,
    total,
    hasReachedMax,
    isLoadingMore,
    isRefreshing,
    errorMessage,
  ];
}
