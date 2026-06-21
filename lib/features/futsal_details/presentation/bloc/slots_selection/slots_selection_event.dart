part of 'slots_selection_bloc.dart';

sealed class SlotsSelectionEvent extends Equatable {
  const SlotsSelectionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class InitializeSlotsSelectionEvent extends SlotsSelectionEvent {
  const InitializeSlotsSelectionEvent({required this.court});

  final CourtDetailModel court;

  @override
  List<Object?> get props => <Object?>[court];
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
