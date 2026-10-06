import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/data/service/vendor_ops_socket_service.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/usecase/get_court_week_availability_use_case.dart';

part 'vendor_ops_event.dart';
part 'vendor_ops_state.dart';

class VendorOpsBloc extends Bloc<VendorOpsEvent, VendorOpsState> {
  VendorOpsBloc({
    VendorOpsRepository? repository,
    VendorOpsSocketService? socket,
    OpsWeekStart weekStartMode = OpsWeekStart.sunday,
  }) : this._(
         repository ?? VendorOpsRepository(),
         socket ?? ReverbVendorOpsSocketService(),
         weekStartMode,
       );

  VendorOpsBloc._(
    VendorOpsRepository repository,
    VendorOpsSocketService socket,
    OpsWeekStart weekStartMode,
  ) : _repository = repository,
      _socket = socket,
      _getCourtWeek = GetCourtWeekAvailabilityUseCase(repository),
      super(
        VendorOpsState(
          date: KathmanduClock.today(),
          weekStartMode: weekStartMode,
        ),
      ) {
    _live = _socket.events.listen(_onLiveEvent);
    on<VendorOpsStarted>(_onStarted);
    on<VendorOpsDateChanged>(_onDateChanged);
    on<VendorOpsRefreshed>(_onRefreshed);
    on<VendorOpsVenuesFiltered>((e, emit) async {
      emit(_rebuild(state.copyWith(venueIds: e.venueIds)));
      // The filter may have taken the table's court away: load the court
      // that took its place.
      await _loadWeekSlots(emit);
    });
    on<VendorOpsCourtsFiltered>(
      (e, emit) => emit(_rebuild(state.copyWith(courtIds: e.courtIds))),
    );
    on<VendorOpsFocusChanged>(
      (e, emit) => emit(state.copyWith(focus: e.focus)),
    );
    on<VendorOpsSearchChanged>(
      (e, emit) => emit(state.copyWith(search: e.query)),
    );
    on<VendorOpsVenueCollapsed>(_onVenueCollapsed);
    on<VendorOpsSlotToggled>(_onSlotToggled);
    on<VendorOpsSelectionRemoved>(_onSelectionRemoved);
    on<VendorOpsSelectionCleared>(_onSelectionCleared);
    on<_VendorOpsClockTicked>(_onClockTicked);
    on<VendorOpsViewChanged>(_onViewChanged);
    on<VendorOpsWeekCourtChanged>(_onWeekCourtChanged);
    on<VendorOpsWeekStartChanged>(_onWeekStartChanged);
    on<VendorOpsBookingUpdated>(_onBookingUpdated);
  }

  final VendorOpsRepository _repository;
  final VendorOpsSocketService _socket;
  final GetCourtWeekAvailabilityUseCase _getCourtWeek;
  Timer? _clock;
  Timer? _autoRefresh;
  late final StreamSubscription<VendorOpsLiveEvent> _live;

  Timer? _liveDebounce;
  static const Duration _liveDelay = Duration(milliseconds: 600);
  bool _liveRefreshPending = false;

  List<String> _liveChannels = const <String>[];

  static List<String> _channelsFor(VendorOpsState s) {
    if (s.view == OpsAvailabilityView.day) {
      return <String>[VendorOpsChannels.day(s.date)];
    }
    final OpsCourt? court = s.tableCourt;
    if (court == null) return const <String>[];
    final DateTime start = s.weekStart;
    return <String>[
      VendorOpsChannels.week(
        start: start,
        end: DateTime(start.year, start.month, start.day + 6),
        venueId: court.venueId,
        courtId: court.id,
      ),
    ];
  }

  @override
  void onChange(Change<VendorOpsState> change) {
    super.onChange(change);
    final List<String> channels = _channelsFor(change.nextState);
    if (_sameChannels(channels, _liveChannels)) return;
    _liveChannels = channels;
    _socket.watch(channels);
  }

  static bool _sameChannels(List<String> a, List<String> b) =>
      a.length == b.length &&
      Iterable<int>.generate(a.length).every((int i) => a[i] == b[i]);

  void _onLiveEvent(VendorOpsLiveEvent event) {
    _liveRefreshPending = true;
    _liveDebounce?.cancel();
    _liveDebounce = Timer(_liveDelay, () {
      if (isClosed || state.selection.isNotEmpty) return;
      _liveRefreshPending = false;
      add(const VendorOpsRefreshed(silent: true, background: true));
    });
  }

  int _dayRequest = 0;
  int _weekSlotsRequest = 0;

  Future<void> _onViewChanged(
    VendorOpsViewChanged event,
    Emitter<VendorOpsState> emit,
  ) async {
    emit(_rebuild(state.copyWith(view: event.view)));
    await Future.wait(<Future<void>>[
      _loadDay(emit, showLoading: true),
      _loadWeekSlots(emit),
    ]);
  }

  Future<void> _onWeekCourtChanged(
    VendorOpsWeekCourtChanged event,
    Emitter<VendorOpsState> emit,
  ) async {
    emit(state.copyWith(weekCourtId: event.courtId));
    await _loadWeekSlots(emit);
  }

  Future<void> _onWeekStartChanged(
    VendorOpsWeekStartChanged event,
    Emitter<VendorOpsState> emit,
  ) async {
    if (event.mode == state.weekStartMode) return;
    emit(state.copyWith(weekStartMode: event.mode));
    await _loadWeekSlots(emit);
  }

  static const Duration _weekFresh = Duration(minutes: 1);

  final Map<
    String,
    Future<(Map<String, OpsCourtWeekAvailability>, AppException?)>
  >
  _weekSlotsPending =
      <
        String,
        Future<(Map<String, OpsCourtWeekAvailability>, AppException?)>
      >{};

  static bool _isFresh(OpsCourtWeekAvailability week) {
    final DateTime? at = week.fetchedAt;
    // No fetch time to age it by: kept until a refresh or a live event.
    return at == null || KathmanduClock.now().difference(at) < _weekFresh;
  }

  Future<void> _loadWeekSlots(
    Emitter<VendorOpsState> emit, {
    bool force = false,
    bool silent = false,
    bool prefetch = false,
    bool emitOnlyIfChanged = false,
  }) async {
    if (!prefetch && state.view != OpsAvailabilityView.week) return;
    final DateTime start = state.weekStart;
    final OpsCourt? court = state.tableCourt;
    if (court == null) return;
    final OpsCourtWeekAvailability? kept = state.weekSlotsFor(court.id, start);
    if (!force && kept != null && _isFresh(kept)) return;
    final String key = OpsCourtWeekAvailability.keyOf(court.id, start);

    final int request = ++_weekSlotsRequest;
    final bool quiet = silent || prefetch;
    if (!quiet) {
      emit(state.copyWith(weekSlotsLoading: true, clearWeekSlotsError: true));
    }
    final (
      Map<String, OpsCourtWeekAvailability> loaded,
      AppException? failure,
    ) = await (_weekSlotsPending[key] ??= _getCourtWeek
        .many(
          courts: <OpsCourt>[court],
          start: start,
          includeEndDate: true,
          type: OpsAvailabilityResponseType.week,
        )
        .whenComplete(() {
          _weekSlotsPending.remove(key);
        }));
    if (emit.isDone) return;
    // Weeks are keyed by court and week, so what an older request loaded is
    // still right; only the newest request owns the spinner and the warning.
    final bool latest = request == _weekSlotsRequest;
    // The week's bookings come with its slots — no separate
    // `/futsal-bookings` call, which pages slowly through the whole week.
    final OpsCourtWeekAvailability? week = loaded[key];
    final List<BookingModel>? weekBookings = week == null
        ? null
        : _repository.bookingsInWeek(week);
    if (emitOnlyIfChanged &&
        week != null &&
        kept != null &&
        _sameAvailability(week, kept) &&
        _sameList(weekBookings ?? const <BookingModel>[], state.weekBookings)) {
      return;
    }
    emit(
      _rebuild(
        state.copyWith(
          weekBookings: weekBookings,
          loadedWeekStart: week == null ? null : start,
          weekSlots: <String, OpsCourtWeekAvailability>{
            // A forced refresh makes every other kept week stale: drop them
            // so each is fetched again when shown. A refreshed court that
            // failed keeps the week it had.
            for (final MapEntry<String, OpsCourtWeekAvailability> e
                in state.weekSlots.entries)
              if (!force || e.key == key) e.key: e.value,
            ...loaded,
          },
          weekSlotsLoading: latest && !quiet ? false : null,
          // A failed quiet refresh, or one behind a week already showing,
          // keeps what is showing without a warning.
          weekSlotsError: latest && !quiet && kept == null
              ? failure?.errorMessage
              : null,
          clearWeekSlotsError: latest && failure == null,
        ),
      ),
    );
  }

  bool get _dayLoaded =>
      state.bookingsLoaded &&
      state.courts.every(
        (OpsCourt c) => state.daySlotsFor(c.id, state.date) != null,
      );

  Future<void> _loadDay(
    Emitter<VendorOpsState> emit, {
    required bool showLoading,
    bool force = false,
    bool emitOnlyIfChanged = false,
  }) async {
    if (state.view != OpsAvailabilityView.day && state.courts.isNotEmpty) {
      return;
    }
    if (!force && _dayLoaded) return;
    final int request = ++_dayRequest;
    final DateTime date = state.date;
    if (showLoading) {
      emit(state.copyWith(bookingsLoading: true, clearError: true));
    }
    final Either<AppException, OpsDayAvailability> result = await _repository
        .loadDay(date);
    if (request != _dayRequest || emit.isDone) return;
    result.fold(
      (AppException e) => emit(
        state.courts.isEmpty
            // Nothing to show yet: the whole page offers a retry.
            ? state.copyWith(
                status: VendorOpsStatus.failure,
                bookingsLoading: false,
                errorMessage: e.errorMessage,
              )
            : state.copyWith(
                status: VendorOpsStatus.success,
                bookingsLoading: false,
                // A failed silent refresh keeps the board that is showing.
                errorMessage: showLoading ? e.errorMessage : null,
                bookingsError: showLoading || !state.bookingsLoaded,
              ),
      ),
      (OpsDayAvailability day) {
        if (emitOnlyIfChanged && _sameDay(day, state)) return;
        emit(
          _rebuild(
            state.copyWith(
              status: VendorOpsStatus.success,
              courts: day.courts,
              bookings: day.bookings,
              weekSlots: <String, OpsCourtWeekAvailability>{
                // A forced refresh drops the kept days; kept weeks stay, to
                // open the Week table at once — they are fetched again when
                // shown once stale.
                for (final MapEntry<String, OpsCourtWeekAvailability> e
                    in state.weekSlots.entries)
                  if (!force ||
                      e.value.type == OpsAvailabilityResponseType.week)
                    e.key: e.value,
                for (final OpsCourt c in day.courts)
                  OpsCourtWeekAvailability.keyOf(
                    c.id,
                    date,
                    OpsAvailabilityResponseType.day,
                  ): day.slots[c.id] ??
                      OpsCourtWeekAvailability(
                        courtId: c.id,
                        weekStart: date,
                        type: OpsAvailabilityResponseType.day,
                      ),
              },
              bookingsLoaded: true,
              bookingsLoading: false,
              bookingsError: false,
              lastUpdated: KathmanduClock.now(),
              clearError: true,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onStarted(
    VendorOpsStarted event,
    Emitter<VendorOpsState> emit,
  ) async {
    emit(state.copyWith(status: VendorOpsStatus.loading, clearError: true));
    // Courts come with the day: one request draws the whole board.
    await _loadDay(emit, showLoading: true, force: true);
    if (state.status == VendorOpsStatus.failure) return;

    _clock ??= Timer.periodic(
      const Duration(minutes: 1),
      (_) => add(const _VendorOpsClockTicked()),
    );
    // Other staff and online players book too; a quiet refresh keeps the
    // board close to the truth between explicit refreshes.
    _autoRefresh ??= Timer.periodic(
      const Duration(minutes: 2),
      (_) => add(const VendorOpsRefreshed(silent: true, background: true)),
    );

    // The Week table's court's week, loaded now — quietly behind the Day
    // board — so switching to Week opens on it instead of waiting on the
    // slow week request. Its slots carry their bookings, so the week's
    // bookings list is left until the table opens. Opened on the Week table
    // (a retry from it), this is its ordinary load.
    await Future.wait(<Future<void>>[
      _loadWeekSlots(emit, prefetch: state.view != OpsAvailabilityView.week),
    ]);
  }

  void _onBookingUpdated(
    VendorOpsBookingUpdated event,
    Emitter<VendorOpsState> emit,
  ) {
    List<BookingModel> update(List<BookingModel> bookings) {
      final List<BookingModel> rows = bookings
          .where((BookingModel booking) => booking.id != event.booking.id)
          .toList(growable: true);
      final bool sameDay = isSameDay(event.booking.date, state.date);
      final bool existed = rows.length != bookings.length;
      if (sameDay || existed) rows.insert(0, event.booking);
      return rows;
    }

    emit(
      _rebuild(
        state.copyWith(
          bookings: update(state.bookings),
          weekBookings: update(state.weekBookings),
          lastUpdated: DateTime.now(),
          clearError: true,
          clearWeekError: true,
        ),
      ),
    );
  }

  Future<void> _onDateChanged(
    VendorOpsDateChanged event,
    Emitter<VendorOpsState> emit,
  ) async {
    final DateTime date = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    );
    if (isSameDay(date, state.date) && state.bookingsLoaded) return;
    emit(
      _rebuild(
        state.copyWith(
          date: date,
          bookings: const <BookingModel>[],
          bookingsLoaded: false,
        ),
      ),
    );
    await Future.wait(<Future<void>>[
      _loadDay(emit, showLoading: true),
      _loadWeekSlots(emit),
    ]);
  }

  Future<void> _onRefreshed(
    VendorOpsRefreshed event,
    Emitter<VendorOpsState> emit,
  ) async {
    try {
      if (state.status == VendorOpsStatus.failure || state.courts.isEmpty) {
        if (!event.silent && !event.background) add(const VendorOpsStarted());
        return;
      }
      await Future.wait(<Future<void>>[
        _loadDay(
          emit,
          showLoading: !event.silent && !event.background,
          force: true,
          emitOnlyIfChanged: event.background,
        ),
        _loadWeekSlots(
          emit,
          force: true,
          silent: event.silent || event.background,
          emitOnlyIfChanged: event.background,
        ),
      ]);
    } finally {
      // Always, so a pull-to-refresh spinner can never be left running.
      final Completer<void>? completer = event.completer;
      if (completer != null && !completer.isCompleted) completer.complete();
    }
  }

  void _onSelectionCleared(
    VendorOpsSelectionCleared event,
    Emitter<VendorOpsState> emit,
  ) {
    emit(state.copyWith(selection: const <String, OpsSelectionItem>{}));
    _flushPendingLiveRefresh();
  }

  void _flushPendingLiveRefresh() {
    if (!_liveRefreshPending || isClosed || state.selection.isNotEmpty) return;
    _liveRefreshPending = false;
    add(const VendorOpsRefreshed(silent: true, background: true));
  }

  static bool _sameDay(OpsDayAvailability day, VendorOpsState state) {
    if (!isSameDay(day.date, state.date)) return false;
    if (!_sameList(day.courts, state.courts)) return false;
    if (!_sameList(day.bookings, state.bookings)) return false;
    final Map<int, OpsCourtWeekAvailability> current =
        <int, OpsCourtWeekAvailability>{
          for (final OpsCourt court in state.courts)
            if (state.daySlotsFor(court.id, state.date)
                case final OpsCourtWeekAvailability slots)
              court.id: slots,
        };
    if (day.slots.length != current.length) return false;
    for (final MapEntry<int, OpsCourtWeekAvailability> entry
        in day.slots.entries) {
      final OpsCourtWeekAvailability? existing = current[entry.key];
      if (existing == null || !_sameAvailability(entry.value, existing)) {
        return false;
      }
    }
    return true;
  }

  static bool _sameAvailability(
    OpsCourtWeekAvailability a,
    OpsCourtWeekAvailability b,
  ) {
    if (a.courtId != b.courtId ||
        !isSameDay(a.weekStart, b.weekStart) ||
        a.type != b.type ||
        a.days.length != b.days.length) {
      return false;
    }
    for (final MapEntry<String, List<OpsServerSlot>> entry in a.days.entries) {
      final List<OpsServerSlot>? other = b.days[entry.key];
      if (other == null || !_sameList(entry.value, other)) return false;
    }
    return true;
  }

  static bool _sameList<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onVenueCollapsed(
    VendorOpsVenueCollapsed event,
    Emitter<VendorOpsState> emit,
  ) {
    final Set<int> collapsed = Set<int>.of(state.collapsedVenues);
    if (!collapsed.remove(event.venueId)) collapsed.add(event.venueId);
    emit(state.copyWith(collapsedVenues: collapsed));
  }

  void _onSlotToggled(
    VendorOpsSlotToggled event,
    Emitter<VendorOpsState> emit,
  ) {
    final OpsCell cell = event.cell;
    if (cell.kind != OpsCellKind.available) return;
    final OpsCourt? court = state.courts
        .where((OpsCourt c) => c.id == cell.courtId)
        .firstOrNull;
    if (court == null) return;
    final Map<String, OpsSelectionItem> selection =
        Map<String, OpsSelectionItem>.of(state.selection);
    if (selection.remove(cell.slotKey) == null) {
      selection[cell.slotKey] = OpsSelectionItem.fromCell(cell, court);
    }
    emit(state.copyWith(selection: selection));
    _flushPendingLiveRefresh();
  }

  void _onSelectionRemoved(
    VendorOpsSelectionRemoved event,
    Emitter<VendorOpsState> emit,
  ) {
    final Map<String, OpsSelectionItem> selection =
        Map<String, OpsSelectionItem>.of(state.selection)
          ..removeWhere((String key, _) => event.keys.contains(key));
    emit(state.copyWith(selection: selection));
    _flushPendingLiveRefresh();
  }

  void _onClockTicked(
    _VendorOpsClockTicked event,
    Emitter<VendorOpsState> emit,
  ) {
    // Past slots and "in progress" move with the clock, and a selected slot
    // that has started can no longer be booked — whichever date is showing.
    final VendorOpsState next = _rebuild(state);
    final Map<String, OpsSelectionItem> selection = _dropStarted(
      next.selection,
    );
    emit(next.copyWith(selection: selection));
  }

  Map<String, OpsSelectionItem> _dropStarted(
    Map<String, OpsSelectionItem> selection,
  ) {
    final String today = isoDate(KathmanduClock.today());
    final int now = KathmanduClock.minuteOfDay();
    return Map<String, OpsSelectionItem>.of(selection)..removeWhere(
      (_, OpsSelectionItem i) =>
          i.date.compareTo(today) < 0 || (i.date == today && i.start < now),
    );
  }

  VendorOpsState _rebuild(VendorOpsState s) {
    final List<OpsCourt> visible = s.courts
        .where(
          (OpsCourt c) =>
              (s.venueIds.isEmpty || s.venueIds.contains(c.venueId)) &&
              (s.courtIds.isEmpty || s.courtIds.contains(c.id)),
        )
        .toList();
    final OpsBoard board = buildOpsBoard(
      courts: visible,
      bookings: s.bookings,
      date: s.date,
      today: KathmanduClock.today(),
      nowMinute: KathmanduClock.minuteOfDay(),
      // The day's own answer, else a loaded week that covers the date.
      server: <int, OpsCourtWeekAvailability>{
        for (final OpsCourt c in visible)
          if (<OpsCourtWeekAvailability?>[
                s.daySlotsFor(c.id, s.date),
                s.weekSlotsFor(c.id, s.weekStart),
              ].firstWhere(
                (OpsCourtWeekAvailability? w) =>
                    w?.days.containsKey(isoDate(s.date)) ?? false,
                orElse: () => null,
              )
              case final OpsCourtWeekAvailability live)
            c.id: live,
      },
    );
    return s.copyWith(
      board: board,
      summary: summarizeBoard(board),
      // No court picked, or the picked one is gone or filtered out: the
      // first listed court is the one selected.
      weekCourtId: s.tableCourt?.id,
    );
  }

  @override
  Future<void> close() {
    _clock?.cancel();
    _autoRefresh?.cancel();
    _liveDebounce?.cancel();
    _live.cancel();
    _socket.dispose();
    return super.close();
  }
}
