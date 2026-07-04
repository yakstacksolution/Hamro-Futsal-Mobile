part of 'slots_selection_bloc.dart';

enum SlotsSelectionStatus { idle, loading, success, failure }

enum RecurringCheckStatus { idle, loading, success, failure }

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
    this.recurringCheckStatus = RecurringCheckStatus.idle,
    this.recurringAvailability,
    this.recurringAvailabilityError,
    this.liveViewers = 0,
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
  final RecurringCheckStatus recurringCheckStatus;
  final RecurringAvailabilityModel? recurringAvailability;
  final String? recurringAvailabilityError;

  /// Users currently on this venue + date's booking presence channel,
  /// including this client. 0 until the presence subscription succeeds.
  final int liveViewers;

  /// How many *other* people are looking at this venue + date right now.
  int get otherViewers => liveViewers > 1 ? liveViewers - 1 : 0;

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

  String? get selectedSlotApiEndTime {
    final TimeSlotModel? slot = selectedSlot;
    if (slot == null) return null;
    return slot.apiEndTime ?? _apiTimeFromDisplay(slot.endTime);
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

  /// Snapshot of the current selection for the booking checkout page.
  /// Null until a slot and an available court are both chosen.
  BookingDraft? get bookingDraft {
    final VenueCourtItemModel? court = selectedCourt;
    if (court == null || !hasSlotSelection) return null;
    final String time = selectedTime ?? '';
    return BookingDraft(
      venueId: venueId,
      courtId: court.id,
      courtName: court.name,
      courtImage: court.image,
      matchType: court.matchType,
      courtType: court.courtType,
      maxPlayers: court.maxPlayers,
      selectedDate: selectedDate,
      selectedTime: time,
      apiTime: selectedSlotApiTime,
      apiEndTime: selectedSlotApiEndTime,
      endTime: selectedSlot?.endTime ?? court.endTime,
      isRecurring: isRecurring,
      recurrenceLabel: isRecurring ? recurrence.label : null,
      sessions: sessions,
      sessionDates: sessionDates,
      pricePerSession: court.priceFor(selectedDate, time),
      subtotal: selectedPrice,
    );
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
    RecurringCheckStatus? recurringCheckStatus,
    RecurringAvailabilityModel? recurringAvailability,
    String? recurringAvailabilityError,
    bool clearRecurring = false,
    bool clearRecurringError = false,
    int? liveViewers,
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
      recurringCheckStatus: clearRecurring
          ? RecurringCheckStatus.idle
          : recurringCheckStatus ?? this.recurringCheckStatus,
      recurringAvailability: clearRecurring
          ? null
          : recurringAvailability ?? this.recurringAvailability,
      recurringAvailabilityError: clearRecurring || clearRecurringError
          ? null
          : recurringAvailabilityError ?? this.recurringAvailabilityError,
      liveViewers: liveViewers ?? this.liveViewers,
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
    recurringCheckStatus,
    recurringAvailability,
    recurringAvailabilityError,
    liveViewers,
  ];
}
