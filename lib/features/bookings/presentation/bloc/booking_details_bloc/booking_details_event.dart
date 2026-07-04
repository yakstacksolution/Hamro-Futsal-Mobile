part of 'booking_details_bloc.dart';

sealed class BookingDetailsEvent extends Equatable {
  const BookingDetailsEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class FetchBookingDetailsEvent extends BookingDetailsEvent {
  const FetchBookingDetailsEvent(this.bookingId);

  final int bookingId;

  @override
  List<Object?> get props => <Object?>[bookingId];
}
