part of 'slots_selection_bloc.dart';

sealed class SlotsSelectionEvent extends Equatable {
  const SlotsSelectionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class InitializeSlotsSelectionEvent extends SlotsSelectionEvent {
  const InitializeSlotsSelectionEvent({
    required this.court,
    this.initialDate,
    this.initialStartTime,
    this.bookingType = BookingTypePayload.regular,
  });

  final CourtDetailModel court;
  final DateTime? initialDate;
  final String? initialStartTime;

  /// `manual` for a vendor-entered walk-in, `regular` for a player booking.
  /// Availability lookups send it so the server can scope what is bookable.
  final String bookingType;

  @override
  List<Object?> get props => <Object?>[
    court,
    initialDate,
    initialStartTime,
    bookingType,
  ];
}

final class SelectSlotsDateEvent extends SlotsSelectionEvent {
  const SelectSlotsDateEvent(this.index);

  final int index;

  @override
  List<Object?> get props => <Object?>[index];
}

final class SelectSlotsTimeEvent extends SlotsSelectionEvent {
  const SelectSlotsTimeEvent(this.index);

  final int index;

  @override
  List<Object?> get props => <Object?>[index];
}

final class SelectSlotsCourtEvent extends SlotsSelectionEvent {
  const SelectSlotsCourtEvent(this.index);

  final int index;

  @override
  List<Object?> get props => <Object?>[index];
}

final class ChangeSlotsBookingModeEvent extends SlotsSelectionEvent {
  const ChangeSlotsBookingModeEvent(this.mode);

  final BookingMode mode;

  @override
  List<Object?> get props => <Object?>[mode];
}

final class ChangeSlotsRecurrenceEvent extends SlotsSelectionEvent {
  const ChangeSlotsRecurrenceEvent(this.recurrence);

  final BookingRecurrence recurrence;

  @override
  List<Object?> get props => <Object?>[recurrence];
}

final class RefreshSlotsAvailabilityEvent extends SlotsSelectionEvent {
  const RefreshSlotsAvailabilityEvent();
}

/// Internal event fired when the Reverb `private-venue.{venueId}.slots`
/// channel reports an availability change. Triggers a silent re-fetch of the
/// current view (no loading spinner) so live bookings by others are reflected
/// immediately.
final class SlotsRealtimeRefreshRequested extends SlotsSelectionEvent {
  const SlotsRealtimeRefreshRequested();
}

/// Internal event fired for each hold/booking broadcast on the per-date
/// presence channel `venue.{venueId}.booking.{bookingDate}`
/// (slot.held, slot.released, slot.expired, booking.confirmed,
/// booking.cancelled, booking.step.updated).
final class SlotsBookingRealtimeEvent extends SlotsSelectionEvent {
  const SlotsBookingRealtimeEvent(this.push);

  final BookingSlotEvent push;

  @override
  List<Object?> get props => <Object?>[push];
}

/// Internal event fired when the presence roster of the viewed venue + date
/// changes (someone opened or left the same booking screen).
final class SlotsViewersChangedEvent extends SlotsSelectionEvent {
  const SlotsViewersChangedEvent(this.viewers);

  final int viewers;

  @override
  List<Object?> get props => <Object?>[viewers];
}

final class CheckRecurringAvailabilityRequested extends SlotsSelectionEvent {
  const CheckRecurringAvailabilityRequested();
}
