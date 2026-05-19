part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FetchMyBookingsEvent extends BookingEvent {
  const FetchMyBookingsEvent();
}

class FetchFutsalBookingsEvent extends BookingEvent {
  const FetchFutsalBookingsEvent();
}
