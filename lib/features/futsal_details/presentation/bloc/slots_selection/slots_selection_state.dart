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
    this.recurringWeekdays = const <int>{},
    this.fallbackPrice = 0,
    this.errorMessage,
    this.recurringCheckStatus = RecurringCheckStatus.idle,
    this.recurringAvailability,
    this.recurringAvailabilityError,
    this.liveViewers = 0,
    this.serverAvailableCount,
    this.serverTotalCourts,
    this.availabilityFallbackType,
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

  /// Weekdays a recurring booking repeats on (`DateTime.monday`…`sunday`).
  ///
  /// Empty means "whichever weekday the selected date falls on", so a user who
  /// never opens the day picker gets the original same-day-every-week booking.
  /// Read [effectiveWeekdays] rather than this set when rendering.
  final Set<int> recurringWeekdays;

  final double fallbackPrice;
  final String? errorMessage;

  /// The availability counts the server reported for the requested window
  /// (`available_count` / `total_courts`). Preferred over counting the list,
  /// which only holds the courts the response carried.
  final int? serverAvailableCount;
  final int? serverTotalCourts;

  /// Set when the server answered with a different window than the one asked
  /// for (`fallback_type`), so the page can say so.
  final String? availabilityFallbackType;
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
    return serverAvailableCount ??
        courts.where((VenueCourtItemModel court) => court.isAvailable).length;
  }

  /// How many courts exist for this window, the server's count first.
  int get totalCourtCount => serverTotalCourts ?? courts.length;

  bool get isFallbackAvailability =>
      (availabilityFallbackType ?? '').trim().isNotEmpty;

  /// The cheapest bookable price on offer, for the section header.
  double? get cheapestAvailablePrice {
    final Iterable<double> prices = courts
        .where((VenueCourtItemModel court) => court.isAvailable)
        .map(
          (VenueCourtItemModel court) =>
              court.priceFor(selectedDate, selectedTime),
        )
        .where((double price) => price > 0);
    if (prices.isEmpty) return null;
    return prices.reduce((double a, double b) => a < b ? a : b);
  }

  /// True when at least one bookable court is discounted for this slot.
  bool get hasDiscountedCourt => courts.any(
    (VenueCourtItemModel court) => court.isAvailable && court.hasDiscount,
  );

  /// Whether any loaded slot can still be picked. False when every slot for
  /// the selected date came back booked, closed or otherwise unavailable.
  bool get hasSelectableSlot =>
      timeSlots.any((TimeSlotModel slot) => slot.isAvailable);

  /// True when the selected date is a dead end: slots (or courts) loaded, but
  /// nothing on it can be booked. The page then replaces the booking sections
  /// with a single notice pointing back at the date row.
  bool get isDateFullyUnavailable {
    if (isLoading) return false;
    if (timeSlots.isNotEmpty && !hasSelectableSlot) return true;
    return courts.isNotEmpty && availableCourtCount == 0;
  }

  bool get isRecurring => bookingMode == BookingMode.recurring;

  /// The weekdays actually booked, resolving the empty set to the selected
  /// date's own weekday.
  Set<int> get effectiveWeekdays => recurringWeekdays.isEmpty
      ? <int>{selectedDate.weekday}
      : recurringWeekdays;

  /// True once the booking repeats on more than one weekday, which the
  /// `repeat_weeks` payload cannot express.
  bool get hasMultipleWeekdays => isRecurring && effectiveWeekdays.length > 1;

  int get sessions => sessionDates.length;

  List<DateTime> get sessionDates {
    if (isRecurring) {
      return recurrence.datesFrom(selectedDate, weekdays: effectiveWeekdays);
    }
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

  /// What the same booking would cost without the slot's discount.
  double get selectedOriginalPrice {
    final VenueCourtItemModel? court = selectedCourt;
    if (court == null) return fallbackPrice;
    if (!hasSlotSelection) return court.minPrice;
    return sessionDates.fold<double>(
      0,
      (double sum, DateTime date) =>
          sum + court.originalPriceFor(date, selectedTime),
    );
  }

  /// Rupees taken off the whole selection by the slot's discount.
  double get selectedSavings {
    final double diff = selectedOriginalPrice - selectedPrice;
    return diff > 0 ? diff : 0;
  }

  bool get hasDiscount =>
      hasSlotSelection &&
      (selectedCourt?.hasDiscount ?? false) &&
      selectedSavings > 0;

  String get priceText => _money(selectedPrice);

  /// The struck-through figure beside [priceText]; null when nothing is off.
  String? get originalPriceText =>
      hasDiscount ? _money(selectedOriginalPrice) : null;

  /// `You save Rs 100` — null when there is no discount.
  String? get savingsText =>
      hasDiscount ? 'save ${_money(selectedSavings)}' : null;

  /// `Rs 1,200` — grouped, matching the court cards.
  static String _money(double value) =>
      'Rs ${Money.group(value.round().abs().toString())}';

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
      return '${court.name} · Every ${RecurringWeekdays.summary(effectiveWeekdays)} · $selectedTime';
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
      recurrenceLabel: isRecurring
          ? '${recurrence.label} · ${RecurringWeekdays.summary(effectiveWeekdays)}'
          : null,
      recurringWeekdays: isRecurring
          ? effectiveWeekdays.toList(growable: false)
          : const <int>[],
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
    Set<int>? recurringWeekdays,
    double? fallbackPrice,
    String? errorMessage,
    bool clearError = false,
    RecurringCheckStatus? recurringCheckStatus,
    RecurringAvailabilityModel? recurringAvailability,
    String? recurringAvailabilityError,
    bool clearRecurring = false,
    bool clearRecurringError = false,
    int? liveViewers,
    int? serverAvailableCount,
    int? serverTotalCourts,
    String? availabilityFallbackType,
    bool clearAvailabilitySummary = false,
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
      recurringWeekdays: recurringWeekdays ?? this.recurringWeekdays,
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
      serverAvailableCount: clearAvailabilitySummary
          ? null
          : serverAvailableCount ?? this.serverAvailableCount,
      serverTotalCourts: clearAvailabilitySummary
          ? null
          : serverTotalCourts ?? this.serverTotalCourts,
      availabilityFallbackType: clearAvailabilitySummary
          ? null
          : availabilityFallbackType ?? this.availabilityFallbackType,
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
    recurringWeekdays,
    fallbackPrice,
    errorMessage,
    recurringCheckStatus,
    recurringAvailability,
    recurringAvailabilityError,
    liveViewers,
    serverAvailableCount,
    serverTotalCourts,
    availabilityFallbackType,
  ];
}
