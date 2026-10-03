part of 'vendor_ops_bloc.dart';

sealed class VendorOpsEvent extends Equatable {
  const VendorOpsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the vendor's courts, then the selected date's bookings.
final class VendorOpsStarted extends VendorOpsEvent {
  const VendorOpsStarted();
}

/// Moves the whole dashboard to [date], keeping filters and the selection.
final class VendorOpsDateChanged extends VendorOpsEvent {
  const VendorOpsDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
}

/// Refetches the date's bookings. [completer] resolves when it is done, for
/// pull-to-refresh.
final class VendorOpsRefreshed extends VendorOpsEvent {
  const VendorOpsRefreshed({
    this.silent = false,
    this.background = false,
    this.completer,
  });

  final bool silent;
  final bool background;
  final Completer<void>? completer;

  @override
  List<Object?> get props => <Object?>[silent, background, completer];
}

/// Empty means every venue.
final class VendorOpsVenuesFiltered extends VendorOpsEvent {
  const VendorOpsVenuesFiltered(this.venueIds);

  final Set<int> venueIds;

  @override
  List<Object?> get props => <Object?>[venueIds];
}

/// Empty means every court of the selected venues.
final class VendorOpsCourtsFiltered extends VendorOpsEvent {
  const VendorOpsCourtsFiltered(this.courtIds);

  final Set<int> courtIds;

  @override
  List<Object?> get props => <Object?>[courtIds];
}

final class VendorOpsFocusChanged extends VendorOpsEvent {
  const VendorOpsFocusChanged(this.focus);

  final OpsFocus focus;

  @override
  List<Object?> get props => <Object?>[focus];
}

final class VendorOpsSearchChanged extends VendorOpsEvent {
  const VendorOpsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

final class VendorOpsVenueCollapsed extends VendorOpsEvent {
  const VendorOpsVenueCollapsed(this.venueId);

  final int venueId;

  @override
  List<Object?> get props => <Object?>[venueId];
}

/// Adds a free slot to the selection, or removes it if already selected.
final class VendorOpsSlotToggled extends VendorOpsEvent {
  const VendorOpsSlotToggled(this.cell);

  final OpsCell cell;

  @override
  List<Object?> get props => <Object?>[cell];
}

final class VendorOpsSelectionRemoved extends VendorOpsEvent {
  const VendorOpsSelectionRemoved(this.keys);

  final Set<String> keys;

  @override
  List<Object?> get props => <Object?>[keys];
}

final class VendorOpsSelectionCleared extends VendorOpsEvent {
  const VendorOpsSelectionCleared();
}

/// Switches the availability section between the day board and the
/// per-court week table.
final class VendorOpsViewChanged extends VendorOpsEvent {
  const VendorOpsViewChanged(this.view);

  final OpsAvailabilityView view;

  @override
  List<Object?> get props => <Object?>[view];
}

/// Picks the court the week table shows.
final class VendorOpsWeekCourtChanged extends VendorOpsEvent {
  const VendorOpsWeekCourtChanged(this.courtId);

  final int courtId;

  @override
  List<Object?> get props => <Object?>[courtId];
}

/// Sets where the Week table's days begin.
final class VendorOpsWeekStartChanged extends VendorOpsEvent {
  const VendorOpsWeekStartChanged(this.mode);

  final OpsWeekStart mode;

  @override
  List<Object?> get props => <Object?>[mode];
}

final class VendorOpsBookingUpdated extends VendorOpsEvent {
  const VendorOpsBookingUpdated(this.booking);

  final BookingModel booking;

  @override
  List<Object?> get props => <Object?>[booking];
}

final class _VendorOpsClockTicked extends VendorOpsEvent {
  const _VendorOpsClockTicked();
}
