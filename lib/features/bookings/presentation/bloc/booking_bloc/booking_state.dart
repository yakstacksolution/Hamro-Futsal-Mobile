part of 'booking_bloc.dart';

enum BookingLoadStatus { idle, loading, success, failure }

/// Every status the two booking endpoints filter on, in the order the chips
/// show them. `null` is not used here — the `all` slice is its own member, so a
/// slice map can be keyed by this enum without a nullable key.
enum BookingStatusFilter {
  all,
  pending,
  confirmed,
  completed,
  cancelled,
  rejected;

  /// The chip's status, or null for [all].
  BookingStatus? get status => switch (this) {
    BookingStatusFilter.all => null,
    BookingStatusFilter.pending => BookingStatus.pending,
    BookingStatusFilter.confirmed => BookingStatus.confirmed,
    BookingStatusFilter.completed => BookingStatus.completed,
    BookingStatusFilter.cancelled => BookingStatus.cancelled,
    BookingStatusFilter.rejected => BookingStatus.rejected,
  };

  /// The `status` query value the endpoints accept.
  String get query => switch (this) {
    BookingStatusFilter.all => 'all',
    BookingStatusFilter.pending => 'pending',
    BookingStatusFilter.confirmed => 'confirmed',
    BookingStatusFilter.completed => 'completed',
    BookingStatusFilter.cancelled => 'cancelled',
    BookingStatusFilter.rejected => 'rejected',
  };

  static BookingStatusFilter of(BookingStatus? status) => switch (status) {
    null => BookingStatusFilter.all,
    BookingStatus.pending => BookingStatusFilter.pending,
    BookingStatus.confirmed => BookingStatusFilter.confirmed,
    BookingStatus.completed => BookingStatusFilter.completed,
    BookingStatus.cancelled => BookingStatusFilter.cancelled,
    BookingStatus.rejected => BookingStatusFilter.rejected,
  };
}

/// One status's list: its rows, its load state and its own pagination cursor.
///
/// Each status is a separate server query (`?status=…`), so each keeps its own
/// slice rather than sharing one list. That is what makes switching status
/// smooth: a status already fetched is on screen the moment it is selected,
/// with the scroll position it had, and its next page picks up where it left
/// off instead of restarting from page 1.
final class BookingListSlice extends Equatable {
  const BookingListSlice({
    this.loadStatus = BookingLoadStatus.idle,
    this.bookings = const <BookingModel>[],
    this.error,
    this.currentPage = 0,
    this.lastPage = 1,
    this.total = 0,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.loadMoreFailed = false,
  });

  final BookingLoadStatus loadStatus;
  final List<BookingModel> bookings;
  final String? error;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMorePages;
  final bool isLoadingMore;

  /// A page-1 refetch running over rows that are already on screen — what a
  /// swipe onto this status starts. Distinct from [loadStatus] `loading`, which
  /// blanks the page for a skeleton: a refresh must not do that, or every swipe
  /// would flash.
  final bool isRefreshing;

  /// Set when a *next* page failed, so the list can offer to retry it. A failed
  /// refresh sets [error] but not this: the rows on screen are still good and
  /// there is nothing to append.
  final bool loadMoreFailed;

  bool get isIdle => loadStatus == BookingLoadStatus.idle;

  /// True while anything is in flight for this status — the guard that keeps a
  /// second swipe onto the same page from firing a duplicate request.
  bool get isBusy =>
      isRefreshing || isLoadingMore || loadStatus == BookingLoadStatus.loading;

  BookingListSlice copyWith({
    BookingLoadStatus? loadStatus,
    List<BookingModel>? bookings,
    String? error,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMorePages,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool? loadMoreFailed,
  }) => BookingListSlice(
    loadStatus: loadStatus ?? this.loadStatus,
    bookings: bookings ?? this.bookings,
    error: clearError ? null : error ?? this.error,
    currentPage: currentPage ?? this.currentPage,
    lastPage: lastPage ?? this.lastPage,
    total: total ?? this.total,
    hasMorePages: hasMorePages ?? this.hasMorePages,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    loadMoreFailed: loadMoreFailed ?? this.loadMoreFailed,
  );

  @override
  List<Object?> get props => <Object?>[
    loadStatus,
    bookings,
    error,
    currentPage,
    lastPage,
    total,
    hasMorePages,
    isLoadingMore,
    isRefreshing,
    loadMoreFailed,
  ];
}

final class BookingState extends Equatable {
  const BookingState({
    this.myLists = const <BookingStatusFilter, BookingListSlice>{},
    this.mySelectedFilter = BookingStatusFilter.all,
    this.futsalLists = const <BookingStatusFilter, BookingListSlice>{},
    this.futsalSelectedFilter = BookingStatusFilter.all,
    this.refreshTick = 0,
  });

  /// `/bookings` and `/futsal-bookings`, each sliced per status. A status not
  /// yet visited has no entry and reads as [BookingListSlice] defaults — idle,
  /// which is what makes the first look at it show the skeleton.
  final Map<BookingStatusFilter, BookingListSlice> myLists;
  final BookingStatusFilter mySelectedFilter;
  final Map<BookingStatusFilter, BookingListSlice> futsalLists;
  final BookingStatusFilter futsalSelectedFilter;

  /// Bumped on every completed fetch so a (silent) refresh that returns
  /// identical data still emits a distinct state — otherwise Equatable would
  /// suppress the emission and any `stream.firstWhere` awaiting it would hang.
  final int refreshTick;

  BookingListSlice mySlice(BookingStatusFilter filter) =>
      myLists[filter] ?? const BookingListSlice();

  BookingListSlice futsalSlice(BookingStatusFilter filter) =>
      futsalLists[filter] ?? const BookingListSlice();

  BookingListSlice get mySelected => mySlice(mySelectedFilter);
  BookingListSlice get futsalSelected => futsalSlice(futsalSelectedFilter);

  // The selected slice under the names the rest of the app already reads, so
  // callers that only care about "the bookings on screen" stay unchanged.
  BookingLoadStatus get myBookingsStatus => mySelected.loadStatus;
  List<BookingModel> get myBookings => mySelected.bookings;
  String? get myBookingsError => mySelected.error;
  int get myCurrentPage => mySelected.currentPage;
  int get myLastPage => mySelected.lastPage;
  int get myTotal => mySelected.total;
  bool get myHasMorePages => mySelected.hasMorePages;
  bool get myIsLoadingMore => mySelected.isLoadingMore;
  bool get myIsRefreshing => mySelected.isRefreshing;
  BookingStatus? get myStatusFilter => mySelectedFilter.status;

  BookingLoadStatus get futsalBookingsStatus => futsalSelected.loadStatus;
  List<BookingModel> get futsalBookings => futsalSelected.bookings;
  String? get futsalBookingsError => futsalSelected.error;
  int get futsalCurrentPage => futsalSelected.currentPage;
  int get futsalLastPage => futsalSelected.lastPage;
  int get futsalTotal => futsalSelected.total;
  bool get futsalHasMorePages => futsalSelected.hasMorePages;
  bool get futsalIsLoadingMore => futsalSelected.isLoadingMore;
  bool get futsalIsRefreshing => futsalSelected.isRefreshing;
  BookingStatus? get futsalStatusFilter => futsalSelectedFilter.status;

  /// Returns a copy with one status's slice of one list replaced.
  BookingState withMySlice(
    BookingStatusFilter filter,
    BookingListSlice slice,
  ) => copyWith(
    myLists: <BookingStatusFilter, BookingListSlice>{...myLists, filter: slice},
  );

  BookingState withFutsalSlice(
    BookingStatusFilter filter,
    BookingListSlice slice,
  ) => copyWith(
    futsalLists: <BookingStatusFilter, BookingListSlice>{
      ...futsalLists,
      filter: slice,
    },
  );

  BookingState copyWith({
    Map<BookingStatusFilter, BookingListSlice>? myLists,
    BookingStatusFilter? mySelectedFilter,
    Map<BookingStatusFilter, BookingListSlice>? futsalLists,
    BookingStatusFilter? futsalSelectedFilter,
    int? refreshTick,
  }) {
    return BookingState(
      myLists: myLists ?? this.myLists,
      mySelectedFilter: mySelectedFilter ?? this.mySelectedFilter,
      futsalLists: futsalLists ?? this.futsalLists,
      futsalSelectedFilter: futsalSelectedFilter ?? this.futsalSelectedFilter,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    myLists,
    mySelectedFilter,
    futsalLists,
    futsalSelectedFilter,
    refreshTick,
  ];
}
