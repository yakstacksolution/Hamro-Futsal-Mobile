import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/api/api_client/booking_type_payload.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/courts_details/presentation/page/court_details.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/available_courts_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_draft.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_recurrence.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/recurring_availability_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_court_item_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/service/reverb_slot_socket_service.dart';
import 'package:hamro_futsal/features/futsal_details/data/service/slot_socket_service.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/check_recurring_availability_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_available_courts_use_case.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_venue_slots_use_case.dart';

part 'slots_selection_event.dart';
part 'slots_selection_state.dart';

class SlotsSelectionBloc
    extends Bloc<SlotsSelectionEvent, SlotsSelectionState> {
  SlotsSelectionBloc(
    this._getAvailableCourtsUseCase,
    this._getVenueSlotsUseCase,
    this._checkRecurringAvailabilityUseCase, {
    SlotSocketService? socketService,
  }) : _socketService = socketService ?? ReverbSlotSocketService.instance,
       super(const SlotsSelectionState()) {
    on<InitializeSlotsSelectionEvent>(_onInitialize);
    on<SelectSlotsDateEvent>(_onSelectDate);
    on<SelectSlotsTimeEvent>(_onSelectTime);
    on<SelectSlotsCourtEvent>(_onSelectCourt);
    on<ChangeSlotsBookingModeEvent>(_onChangeBookingMode);
    on<ChangeSlotsRecurrenceEvent>(_onChangeRecurrence);
    on<ToggleSlotsRecurringDayEvent>(_onToggleRecurringDay);
    on<RefreshSlotsAvailabilityEvent>(_onRefresh);
    on<SlotsRealtimeRefreshRequested>(_onRealtimeRefresh);
    on<SlotsBookingRealtimeEvent>(_onBookingRealtimeEvent);
    on<SlotsViewersChangedEvent>(_onViewersChanged);
    on<CheckRecurringAvailabilityRequested>(_onCheckRecurringAvailability);
  }

  final GetAvailableCourtsUseCase _getAvailableCourtsUseCase;
  final GetVenueSlotsUseCase _getVenueSlotsUseCase;
  final CheckRecurringAvailabilityUseCase _checkRecurringAvailabilityUseCase;
  final SlotSocketService _socketService;
  CourtDetailModel? _sourceCourt;
  int _slotsRequestSerial = 0;
  int _courtsRequestSerial = 0;
  int _recurringRequestSerial = 0;
  String? _preferredInitialStartTime;

  /// Which flow opened this screen — walk-ins ask the API for manual-booking
  /// availability. Set once on initialize and reused by every refresh.
  String _bookingType = BookingTypePayload.regular;

  /// Live slot-availability wiring for the current venue.
  StreamSubscription<SlotAvailabilityUpdate>? _availabilitySub;
  Timer? _availabilityDebounce;
  int? _subscribedVenueId;

  /// Live hold/booking wiring for the venue + date currently on screen
  /// (the `venue.{venueId}.booking.{bookingDate}` presence channel).
  StreamSubscription<BookingSlotEvent>? _bookingEventsSub;
  StreamSubscription<int>? _viewersSub;
  int? _joinedBookingVenueId;
  String? _joinedBookingDate;

  FutureOr<void> _onInitialize(
    InitializeSlotsSelectionEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    _sourceCourt = event.court;
    _preferredInitialStartTime = event.initialStartTime;
    _bookingType = event.bookingType;
    final DateTime today = _dateOnly(DateTime.now());
    final DateTime? preferredDate = event.initialDate == null
        ? null
        : _dateOnly(event.initialDate!);
    final int preferredOffset = preferredDate?.difference(today).inDays ?? 0;
    final int dateCount = preferredOffset >= 14 ? preferredOffset + 1 : 14;
    final List<DateTime> dates = List<DateTime>.generate(
      dateCount,
      (int i) => _dateOnly(DateTime.now().add(Duration(days: i))),
    );
    final int preferredDateIndex = preferredDate == null
        ? 0
        : dates.indexWhere((DateTime date) => date == preferredDate);
    final SlotsSelectionState next = state.copyWith(
      venueId: event.court.venueId,
      dates: dates,
      selectedDateIndex: preferredDateIndex < 0 ? 0 : preferredDateIndex,
      selectedSlotIndex: -1,
      selectedCourtIndex: -1,
      timeSlots: const <TimeSlotModel>[],
      courts: const <VenueCourtItemModel>[],
      bookingMode: BookingMode.single,
      recurrence: BookingRecurrence.oneMonth,
      fallbackPrice: _priceFromText(event.court.price) ?? 0,
      status: SlotsSelectionStatus.loading,
      clearError: true,
    );
    emit(next);
    _listenToAvailability(event.court.venueId);
    _joinBookingChannel(event.court.venueId, next.selectedDate);
    await _fetchSlotsAndCourts(emit, next);
  }

  /// Subscribes (once per venue) to the `venue.{venueId}.slots` Reverb channel.
  void _listenToAvailability(int? venueId) {
    if (venueId == null || venueId <= 0) return;
    if (_availabilitySub != null && venueId == _subscribedVenueId) return;
    _availabilitySub?.cancel();
    _subscribedVenueId = venueId;
    _availabilitySub = _socketService
        .venueSlots(venueId)
        .listen(_onAvailabilityPush);
  }

  /// Debounces bursts of broadcasts into a single silent refresh, and ignores
  /// updates that target a day other than the one currently on screen.
  void _onAvailabilityPush(SlotAvailabilityUpdate update) {
    if (update.date != null &&
        update.date != _formatApiDate(state.selectedDate)) {
      return;
    }
    // The date-scoped presence event already patches the visible court state.
    // Avoid a second REST request from the companion venue-level broadcast,
    // which replaces the grid and causes visible shaking while selecting.
    if (state.hasSlotSelection) return;
    _scheduleRealtimeRefresh();
  }

  void _scheduleRealtimeRefresh() {
    _availabilityDebounce?.cancel();
    _availabilityDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!isClosed) add(const SlotsRealtimeRefreshRequested());
    });
  }

  /// Joins the `venue.{venueId}.booking.{date}` presence channel for the day
  /// on screen, leaving the previously joined one (per-date channel, so the
  /// user must drop out of the old date's roster). No-op when already joined.
  void _joinBookingChannel(int? venueId, DateTime date) {
    if (venueId == null || venueId <= 0) return;
    final String bookingDate = _formatApiDate(date);
    if (venueId == _joinedBookingVenueId && bookingDate == _joinedBookingDate) {
      return;
    }
    _leaveBookingChannel();
    _joinedBookingVenueId = venueId;
    _joinedBookingDate = bookingDate;
    _bookingEventsSub = _socketService
        .bookingEvents(venueId, bookingDate)
        .listen((BookingSlotEvent push) {
          if (!isClosed) add(SlotsBookingRealtimeEvent(push));
        });
    _viewersSub = _socketService.bookingViewers(venueId, bookingDate).listen((
      int viewers,
    ) {
      if (!isClosed) add(SlotsViewersChangedEvent(viewers));
    });
  }

  void _leaveBookingChannel() {
    _bookingEventsSub?.cancel();
    _viewersSub?.cancel();
    _bookingEventsSub = null;
    _viewersSub = null;
    final int? venueId = _joinedBookingVenueId;
    final String? bookingDate = _joinedBookingDate;
    _joinedBookingVenueId = null;
    _joinedBookingDate = null;
    if (venueId != null && bookingDate != null) {
      _socketService.leaveBookingChannel(venueId, bookingDate);
    }
  }

  /// Applies a live hold/booking broadcast directly to the matching court
  /// cell. Do not re-fetch here: replacing the full grid after every socket
  /// push causes unnecessary rebuilds, selection flicker and scroll shaking.
  FutureOr<void> _onBookingRealtimeEvent(
    SlotsBookingRealtimeEvent event,
    Emitter<SlotsSelectionState> emit,
  ) {
    final BookingSlotEvent push = event.push;
    // booking.step.updated is informational; no availability change.
    if (push.isInformational) return null;
    // Defensive: the channel is per-date, but ignore mismatches anyway.
    if (push.bookingDate != null &&
        push.bookingDate != _formatApiDate(state.selectedDate)) {
      return null;
    }

    _patchCourtFromPush(push, emit);
    return null;
  }

  /// Immediate optimistic patch: flips the affected court's status when the
  /// broadcast targets the currently selected slot. The debounced re-fetch
  /// remains the source of truth for everything else (e.g. slot-level counts).
  void _patchCourtFromPush(
    BookingSlotEvent push,
    Emitter<SlotsSelectionState> emit,
  ) {
    final int? courtId = push.courtId;
    final String? status = push.status ?? _statusForBookingEvent(push.type);
    if (courtId == null || status == null) return;
    if (!state.hasSlotSelection) return;
    if (!_sameApiTime(push.startTime, state.selectedSlotApiTime)) return;

    final int index = state.courts.indexWhere(
      (VenueCourtItemModel court) => court.id == courtId,
    );
    if (index < 0) return;

    final SlotStatus newStatus = SlotStatus.fromApi(status);
    if (state.courts[index].status == newStatus) return;

    final List<VenueCourtItemModel> courts = List<VenueCourtItemModel>.of(
      state.courts,
    );
    courts[index] = courts[index].copyWith(status: newStatus);
    emit(
      state.copyWith(
        courts: courts,
        // Deselect the court if someone else just took it.
        selectedCourtIndex:
            state.selectedCourtIndex == index && !newStatus.canSelect
            ? -1
            : state.selectedCourtIndex,
      ),
    );
  }

  FutureOr<void> _onViewersChanged(
    SlotsViewersChangedEvent event,
    Emitter<SlotsSelectionState> emit,
  ) {
    emit(state.copyWith(liveViewers: event.viewers));
    return null;
  }

  /// Silent refresh triggered by the socket: re-pulls authoritative
  /// availability without flipping to a loading spinner, preserving the user's
  /// current selection.
  Future<void> _onRealtimeRefresh(
    SlotsRealtimeRefreshRequested event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    // Don't interfere with an in-flight user-driven load.
    if (state.status == SlotsSelectionStatus.loading) return;

    final SlotsSelectionState current = state;
    if (current.hasSlotSelection) {
      await _fetchAvailableCourts(emit, current, silent: true);
    } else {
      await _fetchVenueSlots(emit, current, markSuccess: true, silent: true);
      if (emit.isDone) return;
      await _fetchAvailableCourts(emit, state, silent: true);
    }
  }

  FutureOr<void> _onSelectDate(
    SelectSlotsDateEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.dates.length) return;

    final SlotsSelectionState next = state.copyWith(
      selectedDateIndex: event.index,
      selectedSlotIndex: -1,
      selectedCourtIndex: -1,
      timeSlots: const <TimeSlotModel>[],
      courts: const <VenueCourtItemModel>[],
      status: SlotsSelectionStatus.loading,
      clearError: true,
      // Roster resets while the new date's presence subscription completes.
      liveViewers: 0,
    );
    emit(next);
    _joinBookingChannel(
      next.venueId ?? _sourceCourt?.venueId,
      next.selectedDate,
    );
    await _fetchSlotsAndCourts(emit, next);
  }

  FutureOr<void> _onSelectTime(
    SelectSlotsTimeEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    if (event.index >= state.timeSlots.length) return;
    if (event.index >= 0 && !state.timeSlots[event.index].isAvailable) return;

    if (event.index < 0) {
      // Unselecting the slot falls back to the whole day: re-pull the courts
      // without a slot filter instead of leaving the grid empty.
      final SlotsSelectionState cleared = state.copyWith(
        selectedSlotIndex: -1,
        selectedCourtIndex: -1,
        courts: const <VenueCourtItemModel>[],
        status: SlotsSelectionStatus.loading,
        clearError: true,
        clearRecurring: true,
      );
      emit(cleared);
      await _fetchAvailableCourts(emit, cleared);
      return;
    }

    final SlotsSelectionState next = state.copyWith(
      selectedSlotIndex: event.index,
      selectedCourtIndex: -1,
      courts: const <VenueCourtItemModel>[],
      status: SlotsSelectionStatus.loading,
      clearError: true,
    );
    emit(next);
    await _fetchAvailableCourts(emit, next);
  }

  Future<void> _onSelectCourt(
    SelectSlotsCourtEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    if (event.index < 0 || event.index >= state.courts.length) return;
    if (!state.courts[event.index].isAvailable) return;
    emit(state.copyWith(selectedCourtIndex: event.index));
    await _fetchRecurringAvailability(emit, state);
  }

  Future<void> _onChangeBookingMode(
    ChangeSlotsBookingModeEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    emit(state.copyWith(bookingMode: event.mode));
    if (event.mode == BookingMode.recurring) {
      await _fetchRecurringAvailability(emit, state);
    } else {
      // Single booking: drop any recurring-availability result.
      emit(state.copyWith(clearRecurring: true));
    }
  }

  Future<void> _onChangeRecurrence(
    ChangeSlotsRecurrenceEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    emit(state.copyWith(recurrence: event.recurrence));
    await _fetchRecurringAvailability(emit, state);
  }

  Future<void> _onToggleRecurringDay(
    ToggleSlotsRecurringDayEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    // Resolve the implicit "selected date's weekday" into a real set before
    // toggling, so the first tap adds a day rather than replacing the default.
    final Set<int> next = <int>{...state.effectiveWeekdays};
    if (!next.remove(event.weekday)) {
      next.add(event.weekday);
    }
    // A recurring booking with no weekday has no sessions; keep the last one.
    if (next.isEmpty) return;
    if (setEquals(next, state.effectiveWeekdays)) return;

    emit(state.copyWith(recurringWeekdays: next));
    await _fetchRecurringAvailability(emit, state);
  }

  Future<void> _onCheckRecurringAvailability(
    CheckRecurringAvailabilityRequested event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    await _fetchRecurringAvailability(emit, state);
  }

  /// Hits `/bookings/recurring-availability` for the selected court, slot and
  /// recurrence. No-op unless a recurring booking with a slot and court is set.
  Future<void> _fetchRecurringAvailability(
    Emitter<SlotsSelectionState> emit,
    SlotsSelectionState current,
  ) async {
    if (!current.isRecurring ||
        !current.hasSlotSelection ||
        current.selectedCourt == null) {
      return;
    }

    final int? venueId = current.venueId ?? _sourceCourt?.venueId;
    final int? courtId = current.selectedCourt?.id;
    final String? startTime = current.selectedSlotApiTime;
    if (venueId == null || courtId == null || startTime == null) return;

    final int requestId = ++_recurringRequestSerial;
    emit(
      current.copyWith(
        recurringCheckStatus: RecurringCheckStatus.loading,
        clearRecurringError: true,
      ),
    );

    final Either<AppException, RecurringAvailabilityModel> response =
        await _checkRecurringAvailabilityUseCase.checkRecurringAvailability(
          venueId: venueId,
          courtId: courtId,
          bookingDate: _formatApiDate(current.selectedDate),
          slotStartTime: startTime,
          slotEndTime: current.selectedSlotApiEndTime,
          recurringDates: current.sessionDates
              .map(_formatApiDate)
              .toList(growable: false),
        );

    if (requestId != _recurringRequestSerial || emit.isDone) return;

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          recurringCheckStatus: RecurringCheckStatus.failure,
          recurringAvailabilityError: failure.errorMessage,
        ),
      ),
      (RecurringAvailabilityModel result) => emit(
        state.copyWith(
          recurringCheckStatus: RecurringCheckStatus.success,
          recurringAvailability: result,
          clearRecurringError: true,
        ),
      ),
    );
  }

  FutureOr<void> _onRefresh(
    RefreshSlotsAvailabilityEvent event,
    Emitter<SlotsSelectionState> emit,
  ) async {
    final SlotsSelectionState next = state.copyWith(
      status: SlotsSelectionStatus.loading,
      clearError: true,
    );
    emit(next);
    if (next.hasSlotSelection) {
      await _fetchAvailableCourts(emit, next);
    } else {
      await _fetchSlotsAndCourts(emit, next);
    }
  }

  /// Loads the date's time slots and the available courts for that date in one
  /// pass. Used on page open and whenever the date changes — the courts call
  /// runs without a slot filter so the server returns courts for "now".
  Future<void> _fetchSlotsAndCourts(
    Emitter<SlotsSelectionState> emit,
    SlotsSelectionState current,
  ) async {
    await _fetchVenueSlots(emit, current, markSuccess: false);
    if (state.status == SlotsSelectionStatus.failure || emit.isDone) return;
    await _fetchAvailableCourts(emit, state);
  }

  Future<void> _fetchVenueSlots(
    Emitter<SlotsSelectionState> emit,
    SlotsSelectionState current, {
    bool markSuccess = true,
    bool silent = false,
  }) async {
    final int? venueId = current.venueId ?? _sourceCourt?.venueId;
    if (venueId == null || venueId <= 0) {
      if (!silent) {
        emit(
          current.copyWith(
            status: SlotsSelectionStatus.failure,
            errorMessage: StringConstants.venueIdIsMissingForSlotAvailability,
          ),
        );
      }
      return;
    }

    final int requestId = ++_slotsRequestSerial;
    final Either<AppException, List<TimeSlotModel>> response =
        await _getVenueSlotsUseCase(
          venueId: venueId,
          date: _formatApiDate(current.selectedDate),
          // A vendor's walk-in and a player's own booking see different
          // slots, so the lookup is scoped the same way the courts call is.
          bookingType: _bookingType,
        );

    if (requestId != _slotsRequestSerial || emit.isDone) return;

    response.fold(
      (AppException failure) {
        // A background (socket-driven) refresh must not blow away the screen
        // on a transient error; keep the last-known data.
        if (silent) {
          debugPrint('Silent slots refresh failed: ${failure.errorMessage}');
          return;
        }
        emit(
          current.copyWith(
            status: SlotsSelectionStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        );
      },
      (List<TimeSlotModel> timeSlots) {
        final int selectedSlotIndex = _preferredInitialStartTime == null
            ? _safeSlotIndex(current.selectedSlotIndex, timeSlots)
            : timeSlots.indexWhere(
                (TimeSlotModel slot) =>
                    slot.isAvailable &&
                    _sameApiTime(
                      slot.apiTime ?? _apiTimeFromDisplay(slot.time),
                      _preferredInitialStartTime,
                    ),
              );
        _preferredInitialStartTime = null;
        emit(
          current.copyWith(
            status: markSuccess
                ? SlotsSelectionStatus.success
                : SlotsSelectionStatus.loading,
            timeSlots: timeSlots,
            selectedSlotIndex: selectedSlotIndex,
            selectedCourtIndex: -1,
            courts: const <VenueCourtItemModel>[],
            clearError: true,
          ),
        );
      },
    );
  }

  Future<void> _fetchAvailableCourts(
    Emitter<SlotsSelectionState> emit,
    SlotsSelectionState current, {
    bool silent = false,
  }) async {
    final int? venueId = current.venueId ?? _sourceCourt?.venueId;
    final String? slotStartTime = current.selectedSlotApiTime;
    final String? slotEndTime = current.selectedSlotApiEndTime;
    if (venueId == null || venueId <= 0) {
      if (!silent) {
        emit(
          current.copyWith(
            status: SlotsSelectionStatus.failure,
            errorMessage: StringConstants.venueIdIsMissingForCourtAvailability,
          ),
        );
      }
      return;
    }

    final int requestId = ++_courtsRequestSerial;
    final Either<AppException, AvailableCourtsModel> response =
        await _getAvailableCourtsUseCase.getAvailableCourts(
          venueId: venueId,
          selectDate: _formatApiDate(current.selectedDate),
          slotStartTime: slotStartTime,
          slotEndTime: slotEndTime,
          bookingType: _bookingType,
        );

    if (requestId != _courtsRequestSerial || emit.isDone) return;

    response.fold(
      (AppException failure) {
        if (silent) {
          debugPrint('Silent courts refresh failed: ${failure.errorMessage}');
          return;
        }
        emit(
          current.copyWith(
            status: SlotsSelectionStatus.failure,
            errorMessage: failure.errorMessage,
          ),
        );
      },
      (AvailableCourtsModel availability) {
        final List<VenueCourtItemModel> courts = availability.courts
            .map(_withCourtDefaults)
            .toList(growable: false);
        final int selectedCourtIndex = _selectedCourtIndexAfterFetch(
          previous: current.selectedCourt,
          courts: courts,
        );

        emit(
          current.copyWith(
            status: SlotsSelectionStatus.success,
            courts: courts,
            selectedCourtIndex: selectedCourtIndex,
            clearError: true,
          ),
        );
      },
    );
  }

  VenueCourtItemModel _withCourtDefaults(VenueCourtItemModel court) {
    final CourtDetailModel? source = _sourceCourt;
    if (source == null) return court;

    final String fallbackImage = source.images.isEmpty
        ? ''
        : source.images.first;
    final List<CourtPriceRule> fallbackPrices = _fallbackPriceRules(source);
    final bool hasServerPrice = court.priceList.any(
      (CourtPriceRule rule) => rule.price > 0,
    );

    return court.copyWith(
      venueId: court.venueId ?? source.venueId,
      image: court.image.trim().isEmpty ? fallbackImage : court.image,
      maxPlayers: court.maxPlayers > 0 ? court.maxPlayers : source.maxPlayers,
      courtType: court.courtType.trim().isEmpty
          ? source.courtType
          : court.courtType,
      priceList: hasServerPrice ? court.priceList : fallbackPrices,
    );
  }

  List<CourtPriceRule> _fallbackPriceRules(CourtDetailModel source) {
    final double price = _priceFromText(source.price) ?? 0;
    return <CourtPriceRule>[
      CourtPriceRule(
        label: StringConstants.standard,
        timeRange: StringConstants.allDay,
        startHour: 0,
        endHour: 24,
        price: price,
      ),
    ];
  }

  int _selectedCourtIndexAfterFetch({
    required VenueCourtItemModel? previous,
    required List<VenueCourtItemModel> courts,
  }) {
    if (courts.isEmpty) return -1;
    if (previous?.id != null) {
      final int byId = courts.indexWhere(
        (VenueCourtItemModel court) =>
            court.id == previous!.id && court.isAvailable,
      );
      if (byId >= 0) return byId;
    }
    return courts.indexWhere((VenueCourtItemModel court) => court.isAvailable);
  }

  @override
  Future<void> close() {
    _availabilityDebounce?.cancel();
    _availabilitySub?.cancel();
    // Drop out of the per-date presence roster; the shared Reverb connection
    // itself is app-wide, so don't dispose it here.
    _leaveBookingChannel();
    return super.close();
  }
}

String? _statusForBookingEvent(String type) => switch (type) {
  BookingSlotEvent.held => 'unavailable',
  BookingSlotEvent.confirmed => 'booked',
  BookingSlotEvent.released ||
  BookingSlotEvent.expired ||
  BookingSlotEvent.cancelled => 'available',
  _ => null,
};

/// Compares two API times (`18:00`, `18:00:00`, `6:00`) on hours + minutes.
bool _sameApiTime(String? a, String? b) {
  if (a == null || b == null) return false;
  String normalize(String value) {
    final List<String> parts = value.trim().split(':');
    if (parts.length < 2) return value.trim();
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  return normalize(a) == normalize(b);
}

int _safeSlotIndex(int index, List<TimeSlotModel> slots) {
  if (index < 0 || index >= slots.length) return -1;
  return slots[index].isAvailable ? index : -1;
}

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _formatApiDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

String? _apiTimeFromDisplay(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final String text = value.trim();
  final RegExpMatch? meridiemMatch = RegExp(
    r'^(\d{1,2})(?::(\d{1,2}))?\s*([AP]M)$',
    caseSensitive: false,
  ).firstMatch(text);
  if (meridiemMatch != null) {
    int hour = int.tryParse(meridiemMatch.group(1) ?? '') ?? 0;
    final int minute = int.tryParse(meridiemMatch.group(2) ?? '0') ?? 0;
    final String suffix = meridiemMatch.group(3)!.toUpperCase();
    if (suffix == 'PM' && hour != 12) hour += 12;
    if (suffix == 'AM' && hour == 12) hour = 0;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
  final RegExpMatch? match = RegExp(
    r'^(\d{1,2})(?::(\d{1,2}))?',
  ).firstMatch(text);
  if (match == null) return text;
  final int hour = int.tryParse(match.group(1) ?? '') ?? 0;
  final int minute = int.tryParse(match.group(2) ?? '0') ?? 0;
  return '${hour.clamp(0, 23).toString().padLeft(2, '0')}:${minute.clamp(0, 59).toString().padLeft(2, '0')}';
}

double? _priceFromText(String value) {
  final String normalized = value.replaceAll(',', '');
  final RegExpMatch? match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(normalized);
  if (match == null) return null;
  return double.tryParse(match.group(1) ?? '');
}

String _dayName(DateTime date) {
  const List<String> days = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  return days[date.weekday - 1];
}

String _monthName(DateTime date) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[date.month - 1];
}
