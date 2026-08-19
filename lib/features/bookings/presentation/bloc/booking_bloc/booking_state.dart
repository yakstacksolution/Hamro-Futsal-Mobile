part of 'booking_bloc.dart';

enum BookingLoadStatus { idle, loading, success, failure }

final class BookingState extends Equatable {
  const BookingState({
    this.myBookingsStatus = BookingLoadStatus.idle,
    this.myBookings = const <BookingModel>[],
    this.myBookingsError,
    this.myCurrentPage = 0,
    this.myLastPage = 1,
    this.myTotal = 0,
    this.myHasMorePages = false,
    this.myIsLoadingMore = false,
    this.futsalBookingsStatus = BookingLoadStatus.idle,
    this.futsalBookings = const <BookingModel>[],
    this.futsalBookingsError,
    this.futsalCurrentPage = 0,
    this.futsalLastPage = 1,
    this.futsalTotal = 0,
    this.futsalHasMorePages = false,
    this.futsalIsLoadingMore = false,
    this.refreshTick = 0,
  });

  final BookingLoadStatus myBookingsStatus;
  final List<BookingModel> myBookings;
  final String? myBookingsError;
  final int myCurrentPage;
  final int myLastPage;
  final int myTotal;
  final bool myHasMorePages;
  final bool myIsLoadingMore;

  final BookingLoadStatus futsalBookingsStatus;
  final List<BookingModel> futsalBookings;
  final String? futsalBookingsError;
  final int futsalCurrentPage;
  final int futsalLastPage;
  final int futsalTotal;
  final bool futsalHasMorePages;
  final bool futsalIsLoadingMore;

  /// Bumped on every completed fetch so a (silent) refresh that returns
  /// identical data still emits a distinct state — otherwise Equatable would
  /// suppress the emission and any `stream.firstWhere` awaiting it would hang.
  final int refreshTick;

  BookingState copyWith({
    BookingLoadStatus? myBookingsStatus,
    List<BookingModel>? myBookings,
    String? myBookingsError,
    bool clearMyError = false,
    int? myCurrentPage,
    int? myLastPage,
    int? myTotal,
    bool? myHasMorePages,
    bool? myIsLoadingMore,
    BookingLoadStatus? futsalBookingsStatus,
    List<BookingModel>? futsalBookings,
    String? futsalBookingsError,
    bool clearFutsalError = false,
    int? futsalCurrentPage,
    int? futsalLastPage,
    int? futsalTotal,
    bool? futsalHasMorePages,
    bool? futsalIsLoadingMore,
    int? refreshTick,
  }) {
    return BookingState(
      myBookingsStatus: myBookingsStatus ?? this.myBookingsStatus,
      myBookings: myBookings ?? this.myBookings,
      myBookingsError: clearMyError
          ? null
          : myBookingsError ?? this.myBookingsError,
      myCurrentPage: myCurrentPage ?? this.myCurrentPage,
      myLastPage: myLastPage ?? this.myLastPage,
      myTotal: myTotal ?? this.myTotal,
      myHasMorePages: myHasMorePages ?? this.myHasMorePages,
      myIsLoadingMore: myIsLoadingMore ?? this.myIsLoadingMore,
      futsalBookingsStatus: futsalBookingsStatus ?? this.futsalBookingsStatus,
      futsalBookings: futsalBookings ?? this.futsalBookings,
      futsalBookingsError: clearFutsalError
          ? null
          : futsalBookingsError ?? this.futsalBookingsError,
      futsalCurrentPage: futsalCurrentPage ?? this.futsalCurrentPage,
      futsalLastPage: futsalLastPage ?? this.futsalLastPage,
      futsalTotal: futsalTotal ?? this.futsalTotal,
      futsalHasMorePages: futsalHasMorePages ?? this.futsalHasMorePages,
      futsalIsLoadingMore: futsalIsLoadingMore ?? this.futsalIsLoadingMore,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    myBookingsStatus,
    myBookings,
    myBookingsError,
    myCurrentPage,
    myLastPage,
    myTotal,
    myHasMorePages,
    myIsLoadingMore,
    futsalBookingsStatus,
    futsalBookings,
    futsalBookingsError,
    futsalCurrentPage,
    futsalLastPage,
    futsalTotal,
    futsalHasMorePages,
    futsalIsLoadingMore,
    refreshTick,
  ];
}
