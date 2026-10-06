part of 'vendor_ops_bloc.dart';

sealed class VendorOpsEvent extends Equatable {
  const VendorOpsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class VendorOpsStarted extends VendorOpsEvent {
  const VendorOpsStarted();
}

final class VendorOpsDateChanged extends VendorOpsEvent {
  const VendorOpsDateChanged(this.date);

  final DateTime date;

  @override
  List<Object?> get props => <Object?>[date];
}

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

final class VendorOpsVenuesFiltered extends VendorOpsEvent {
  const VendorOpsVenuesFiltered(this.venueIds);

  final Set<int> venueIds;

  @override
  List<Object?> get props => <Object?>[venueIds];
}

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

final class VendorOpsViewChanged extends VendorOpsEvent {
  const VendorOpsViewChanged(this.view);

  final OpsAvailabilityView view;

  @override
  List<Object?> get props => <Object?>[view];
}

final class VendorOpsWeekCourtChanged extends VendorOpsEvent {
  const VendorOpsWeekCourtChanged(this.courtId);

  final int courtId;

  @override
  List<Object?> get props => <Object?>[courtId];
}

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
