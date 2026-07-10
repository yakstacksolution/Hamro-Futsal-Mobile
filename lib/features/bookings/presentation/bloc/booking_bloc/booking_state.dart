part of 'booking_bloc.dart';

enum BookingLoadStatus { idle, loading, success, failure }

final class BookingState extends Equatable {
  const BookingState({
    this.myBookingsStatus = BookingLoadStatus.idle,
    this.myBookings = const <BookingModel>[],
    this.myBookingsError,
    this.futsalBookingsStatus = BookingLoadStatus.idle,
    this.futsalBookings = const <BookingModel>[],
    this.futsalBookingsError,
    this.refreshTick = 0,
  });

  final BookingLoadStatus myBookingsStatus;
  final List<BookingModel> myBookings;
  final String? myBookingsError;

  final BookingLoadStatus futsalBookingsStatus;
  final List<BookingModel> futsalBookings;
  final String? futsalBookingsError;

  /// Bumped on every completed fetch so a (silent) refresh that returns
  /// identical data still emits a distinct state — otherwise Equatable would
  /// suppress the emission and any `stream.firstWhere` awaiting it would hang.
  final int refreshTick;

  BookingState copyWith({
    BookingLoadStatus? myBookingsStatus,
    List<BookingModel>? myBookings,
    String? myBookingsError,
    bool clearMyError = false,
    BookingLoadStatus? futsalBookingsStatus,
    List<BookingModel>? futsalBookings,
    String? futsalBookingsError,
    bool clearFutsalError = false,
    int? refreshTick,
  }) {
    return BookingState(
      myBookingsStatus: myBookingsStatus ?? this.myBookingsStatus,
      myBookings: myBookings ?? this.myBookings,
      myBookingsError: clearMyError
          ? null
          : myBookingsError ?? this.myBookingsError,
      futsalBookingsStatus: futsalBookingsStatus ?? this.futsalBookingsStatus,
      futsalBookings: futsalBookings ?? this.futsalBookings,
      futsalBookingsError: clearFutsalError
          ? null
          : futsalBookingsError ?? this.futsalBookingsError,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    myBookingsStatus,
    myBookings,
    myBookingsError,
    futsalBookingsStatus,
    futsalBookings,
    futsalBookingsError,
    refreshTick,
  ];
}
