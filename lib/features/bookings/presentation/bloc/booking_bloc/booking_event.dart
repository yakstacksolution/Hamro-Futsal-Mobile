part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class FetchMyBookingsEvent extends BookingEvent {
  const FetchMyBookingsEvent({
    this.silent = false,
    this.loadMore = false,
    this.filter,
    this.select = false,
    this.force = false,
  });

  const FetchMyBookingsEvent.select(
    BookingStatusFilter filter, {
    bool force = false,
  }) : this(filter: filter, select: true, force: force, silent: true);

  const FetchMyBookingsEvent.refresh(BookingStatusFilter filter)
    : this(filter: filter, select: true, force: true, silent: true);

  final bool silent;
  final bool loadMore;
  final BookingStatusFilter? filter;

  final bool select;

  final bool force;

  @override
  List<Object?> get props => <Object?>[silent, loadMore, filter, select, force];
}

class FetchFutsalBookingsEvent extends BookingEvent {
  const FetchFutsalBookingsEvent({
    this.silent = false,
    this.loadMore = false,
    this.filter,
    this.select = false,
    this.force = false,
  });

  const FetchFutsalBookingsEvent.select(
    BookingStatusFilter filter, {
    bool force = false,
  }) : this(filter: filter, select: true, force: force, silent: true);

  const FetchFutsalBookingsEvent.refresh(BookingStatusFilter filter)
    : this(filter: filter, select: true, force: true, silent: true);

  final bool silent;
  final bool loadMore;
  final BookingStatusFilter? filter;
  final bool select;
  final bool force;

  @override
  List<Object?> get props => <Object?>[silent, loadMore, filter, select, force];
}

class ApplyMyBookingsFiltersEvent extends BookingEvent {
  const ApplyMyBookingsFiltersEvent({
    required this.dateFilter,
    required this.order,
  });

  final BookingDateFilter dateFilter;
  final BookingDateOrder order;

  @override
  List<Object?> get props => <Object?>[dateFilter, order];
}

class ApplyFutsalBookingsFiltersEvent extends BookingEvent {
  const ApplyFutsalBookingsFiltersEvent({
    required this.dateFilter,
    required this.order,
  });

  final BookingDateFilter dateFilter;
  final BookingDateOrder order;

  @override
  List<Object?> get props => <Object?>[dateFilter, order];
}

class FutsalBookingUpdatedEvent extends BookingEvent {
  const FutsalBookingUpdatedEvent(this.booking);

  final BookingModel booking;

  @override
  List<Object?> get props => <Object?>[booking];
}
