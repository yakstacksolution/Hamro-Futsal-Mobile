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
  });

  final BookingLoadStatus myBookingsStatus;
  final List<BookingModel> myBookings;
  final String? myBookingsError;

  final BookingLoadStatus futsalBookingsStatus;
  final List<BookingModel> futsalBookings;
  final String? futsalBookingsError;

  BookingState copyWith({
    BookingLoadStatus? myBookingsStatus,
    List<BookingModel>? myBookings,
    String? myBookingsError,
    bool clearMyError = false,
    BookingLoadStatus? futsalBookingsStatus,
    List<BookingModel>? futsalBookings,
    String? futsalBookingsError,
    bool clearFutsalError = false,
  }) {
    return BookingState(
      myBookingsStatus: myBookingsStatus ?? this.myBookingsStatus,
      myBookings: myBookings ?? this.myBookings,
      myBookingsError: clearMyError ? null : myBookingsError ?? this.myBookingsError,
      futsalBookingsStatus: futsalBookingsStatus ?? this.futsalBookingsStatus,
      futsalBookings: futsalBookings ?? this.futsalBookings,
      futsalBookingsError:
          clearFutsalError ? null : futsalBookingsError ?? this.futsalBookingsError,
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
      ];
}
