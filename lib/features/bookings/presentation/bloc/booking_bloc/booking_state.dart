part of 'booking_bloc.dart';

enum BookingLoadStatus { idle, loading, success, failure }

enum BookingStatusFilter {
  all,
  pending,
  confirmed,
  completed,
  cancelled,
  rejected;

  BookingStatus? get status => switch (this) {
    BookingStatusFilter.all => null,
    BookingStatusFilter.pending => BookingStatus.pending,
    BookingStatusFilter.confirmed => BookingStatus.confirmed,
    BookingStatusFilter.completed => BookingStatus.completed,
    BookingStatusFilter.cancelled => BookingStatus.cancelled,
    BookingStatusFilter.rejected => BookingStatus.rejected,
  };

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

  final bool isRefreshing;

  final bool loadMoreFailed;

  bool get isIdle => loadStatus == BookingLoadStatus.idle;

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
    this.myDateFilter = const BookingDateFilter.all(),
    this.futsalDateFilter = const BookingDateFilter.all(),
    this.myOrder = BookingDateOrder.descending,
    this.futsalOrder = BookingDateOrder.descending,
    this.refreshTick = 0,
  });

  final Map<BookingStatusFilter, BookingListSlice> myLists;
  final BookingStatusFilter mySelectedFilter;
  final Map<BookingStatusFilter, BookingListSlice> futsalLists;
  final BookingStatusFilter futsalSelectedFilter;

  final BookingDateFilter myDateFilter;
  final BookingDateFilter futsalDateFilter;
  final BookingDateOrder myOrder;
  final BookingDateOrder futsalOrder;

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
    BookingDateFilter? myDateFilter,
    BookingDateFilter? futsalDateFilter,
    BookingDateOrder? myOrder,
    BookingDateOrder? futsalOrder,
    int? refreshTick,
  }) {
    return BookingState(
      myLists: myLists ?? this.myLists,
      mySelectedFilter: mySelectedFilter ?? this.mySelectedFilter,
      futsalLists: futsalLists ?? this.futsalLists,
      futsalSelectedFilter: futsalSelectedFilter ?? this.futsalSelectedFilter,
      myDateFilter: myDateFilter ?? this.myDateFilter,
      futsalDateFilter: futsalDateFilter ?? this.futsalDateFilter,
      myOrder: myOrder ?? this.myOrder,
      futsalOrder: futsalOrder ?? this.futsalOrder,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    myLists,
    mySelectedFilter,
    futsalLists,
    futsalSelectedFilter,
    myDateFilter,
    futsalDateFilter,
    myOrder,
    futsalOrder,
    refreshTick,
  ];
}
