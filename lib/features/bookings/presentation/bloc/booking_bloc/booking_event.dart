part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FetchMyBookingsEvent extends BookingEvent {
  const FetchMyBookingsEvent({this.silent = false});

  /// When true, the list isn't replaced by the skeleton loader while fetching
  /// — used for pull-to-refresh, where the [RefreshIndicator] shows progress.
  final bool silent;

  @override
  List<Object?> get props => <Object?>[silent];
}

class FetchFutsalBookingsEvent extends BookingEvent {
  const FetchFutsalBookingsEvent({this.silent = false});

  /// When true, the list isn't replaced by the skeleton loader while fetching
  /// — used for pull-to-refresh, where the [RefreshIndicator] shows progress.
  final bool silent;

  @override
  List<Object?> get props => <Object?>[silent];
}
