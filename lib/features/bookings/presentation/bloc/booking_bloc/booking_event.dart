part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads one status's page of `/bookings`.
///
/// [filter] names the status; null means "whichever is selected", which is what
/// a pull-to-refresh or a scroll-to-end wants. Selecting a status the user has
/// already visited does not refetch it — its rows are still in state — unless
/// [force] says otherwise.
class FetchMyBookingsEvent extends BookingEvent {
  const FetchMyBookingsEvent({
    this.silent = false,
    this.loadMore = false,
    this.filter,
    this.select = false,
    this.force = false,
  });

  /// Selects [filter] and loads it if it has not been loaded yet.
  const FetchMyBookingsEvent.select(
    BookingStatusFilter filter, {
    bool force = false,
  }) : this(filter: filter, select: true, force: force, silent: true);

  /// Selects [filter] and refetches its first page from the endpoint, keeping
  /// whatever rows it already holds on screen until the new ones land. This is
  /// what a swipe onto a status page sends: the status is asked for again so
  /// the list is current, without the page flashing a skeleton.
  const FetchMyBookingsEvent.refresh(BookingStatusFilter filter)
    : this(filter: filter, select: true, force: true, silent: true);

  /// When true, the list isn't replaced by the skeleton loader while fetching
  /// — used for pull-to-refresh, where the [RefreshIndicator] shows progress.
  final bool silent;
  final bool loadMore;
  final BookingStatusFilter? filter;

  /// Makes [filter] the visible status as well as the one being loaded.
  final bool select;

  /// Refetches page 1 even when the slice already holds rows.
  final bool force;

  @override
  List<Object?> get props => <Object?>[silent, loadMore, filter, select, force];
}

/// Same contract as [FetchMyBookingsEvent], for `/futsal-bookings`.
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

  /// See [FetchMyBookingsEvent.refresh].
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
