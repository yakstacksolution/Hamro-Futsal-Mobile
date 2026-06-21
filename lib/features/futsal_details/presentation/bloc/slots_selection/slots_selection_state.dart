part of 'slots_selection_bloc.dart';

enum SlotsSelectionStatus { idle, loading, success, failure }

final class SlotsSelectionState extends Equatable {
  const SlotsSelectionState({
    this.status = SlotsSelectionStatus.idle,
    this.venueId,
    this.dates = const <DateTime>[],
    this.timeSlots = const <TimeSlotModel>[],
    this.courts = const <VenueCourtItemModel>[],
    this.selectedDateIndex = 0,
    this.selectedSlotIndex = -1,
    this.selectedCourtIndex = -1,
    this.bookingMode = BookingMode.single,
    this.recurrence = BookingRecurrence.oneMonth,
    this.fallbackPrice = 0,
    this.errorMessage,
  });

  final SlotsSelectionStatus status;
  final int? venueId;
  final List<DateTime> dates;
  final List<TimeSlotModel> timeSlots;
  final List<VenueCourtItemModel> courts;
  final int selectedDateIndex;
  final int selectedSlotIndex;
  final int selectedCourtIndex;
  final BookingMode bookingMode;
  final BookingRecurrence recurrence;
  final double fallbackPrice;
  final String? errorMessage;

  int get safeSelectedDateIndex {
    if (dates.isEmpty) return 0;
    if (selectedDateIndex < 0) return 0;
    if (selectedDateIndex >= dates.length) return dates.length - 1;
    return selectedDateIndex;
  }

  DateTime get selectedDate {
    if (dates.isEmpty) return _dateOnly(DateTime.now());
    return dates[safeSelectedDateIndex];
  }

  TimeSlotModel? get selectedSlot {
    if (selectedSlotIndex < 0 || selectedSlotIndex >= timeSlots.length) {
      return null;
    }
    final TimeSlotModel slot = timeSlots[selectedSlotIndex];
    return slot.isAvailable ? slot : null;
  }

  VenueCourtItemModel? get selectedCourt {
    if (selectedCourtIndex < 0 || selectedCourtIndex >= courts.length) {
      return null;
    }
    return courts[selectedCourtIndex];
  }

  String? get selectedTime => selectedSlot?.time;

  String? get selectedSlotApiTime {
    final TimeSlotModel? slot = selectedSlot;
    if (slot == null) return null;
    return slot.apiTime ?? _apiTimeFromDisplay(slot.time);
  }

  bool get isLoading => status == SlotsSelectionStatus.loading;

  bool get hasSlotSelection => selectedSlot != null;

  int get availableCourtCount {
    return courts
        .where((VenueCourtItemModel court) => court.isAvailable)
        .length;
  }

  bool get isRecurring => bookingMode == BookingMode.recurring;

  int get sessions => isRecurring ? recurrence.sessions : 1;

  List<DateTime> get sessionDates {
    if (isRecurring) return recurrence.datesFrom(selectedDate);
    return <DateTime>[selectedDate];
  }

  String? get slotLabel {
    final String? time = selectedTime;
    if (time == null) return null;
    return '${_dayName(selectedDate)}, ${selectedDate.day} ${_monthName(selectedDate)} · $time';
  }

  double get selectedPrice {
    final VenueCourtItemModel? court = selectedCourt;
    if (court == null) return fallbackPrice;
    if (!hasSlotSelection) return court.minPrice;
    return sessionDates.fold<double>(
      0,
      (double sum, DateTime date) => sum + court.priceFor(date, selectedTime),
    );
  }

  String get priceText => 'Rs ${selectedPrice.toStringAsFixed(0)}';

  String get priceUnit {
    if (!hasSlotSelection) return '/ hour';
    if (isRecurring) return 'total · $sessions sessions';
    return '/ hour';
  }

  String get selectedLabel {
    final VenueCourtItemModel? court = selectedCourt;
    if (!hasSlotSelection || court == null) {
      return 'Select a time slot to continue';
    }
    if (isRecurring) {
      return '${court.name} · Every ${_dayName(selectedDate)} · $selectedTime';
    }
    return '${court.name} · ${_dayName(selectedDate)}, ${selectedDate.day} ${_monthName(selectedDate)} · $selectedTime';
  }

  String get buttonText {
    if (!hasSlotSelection) return 'Select Slot';
    return selectedCourt == null ? 'Unavailable' : 'Book Now';
  }

  SlotsSelectionState copyWith({
    SlotsSelectionStatus? status,
    int? venueId,
    List<DateTime>? dates,
    List<TimeSlotModel>? timeSlots,
    List<VenueCourtItemModel>? courts,
    int? selectedDateIndex,
    int? selectedSlotIndex,
    int? selectedCourtIndex,
    BookingMode? bookingMode,
    BookingRecurrence? recurrence,
    double? fallbackPrice,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SlotsSelectionState(
      status: status ?? this.status,
      venueId: venueId ?? this.venueId,
      dates: dates ?? this.dates,
      timeSlots: timeSlots ?? this.timeSlots,
      courts: courts ?? this.courts,
      selectedDateIndex: selectedDateIndex ?? this.selectedDateIndex,
      selectedSlotIndex: selectedSlotIndex ?? this.selectedSlotIndex,
      selectedCourtIndex: selectedCourtIndex ?? this.selectedCourtIndex,
      bookingMode: bookingMode ?? this.bookingMode,
      recurrence: recurrence ?? this.recurrence,
      fallbackPrice: fallbackPrice ?? this.fallbackPrice,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    venueId,
    dates,
    timeSlots,
    courts,
    selectedDateIndex,
    selectedSlotIndex,
    selectedCourtIndex,
    bookingMode,
    recurrence,
    fallbackPrice,
    errorMessage,
  ];
}
