part of 'booking_overview_bloc.dart';

sealed class BookingOverviewEvent extends Equatable {
  const BookingOverviewEvent();

  @override
  List<Object?> get props => [];
}

final class LoadBookingOverviewEvent extends BookingOverviewEvent {
  const LoadBookingOverviewEvent();
}
