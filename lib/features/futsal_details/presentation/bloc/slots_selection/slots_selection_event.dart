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

final class ToggleSlotsRecurringDayEvent extends SlotsSelectionEvent {
  const ToggleSlotsRecurringDayEvent(this.weekday);

  final int weekday;

  @override
  List<Object?> get props => <Object?>[weekday];
}

final class RefreshSlotsAvailabilityEvent extends SlotsSelectionEvent {
  const RefreshSlotsAvailabilityEvent();
}

final class SlotsRealtimeRefreshRequested extends SlotsSelectionEvent {
  const SlotsRealtimeRefreshRequested();
}

final class SlotsBookingRealtimeEvent extends SlotsSelectionEvent {
  const SlotsBookingRealtimeEvent(this.push);

  final BookingSlotEvent push;

  @override
  List<Object?> get props => <Object?>[push];
}

final class SlotsViewersChangedEvent extends SlotsSelectionEvent {
  const SlotsViewersChangedEvent(this.viewers);

  final int viewers;

  @override
  List<Object?> get props => <Object?>[viewers];
}

final class CheckRecurringAvailabilityRequested extends SlotsSelectionEvent {
  const CheckRecurringAvailabilityRequested();
}
