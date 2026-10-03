part of 'vendor_ops_bloc.dart';

enum VendorOpsStatus { initial, loading, success, failure }

/// How the availability section is laid out: every court for one day, or one
/// court for a whole week.
enum OpsAvailabilityView { day, week }

final class VendorOpsState extends Equatable {
  const VendorOpsState({
    required this.date,
    this.status = VendorOpsStatus.initial,
    this.courts = const <OpsCourt>[],
    this.bookings = const <BookingModel>[],
    this.bookingsLoaded = false,
    this.bookingsLoading = false,
    this.bookingsError = false,
    this.venueIds = const <int>{},
    this.courtIds = const <int>{},
    this.focus = OpsFocus.all,
    this.search = '',
    this.collapsedVenues = const <int>{},
    this.selection = const <String, OpsSelectionItem>{},
    this.board,
    this.summary = const OpsSummary(),
    this.lastUpdated,
    this.errorMessage,
    this.view = OpsAvailabilityView.day,
    this.weekCourtId,
    this.weekBookings = const <BookingModel>[],
    this.loadedWeekStart,
    this.weekLoading = false,
    this.weekError,
    this.weekSlots = const <String, OpsCourtWeekAvailability>{},
    this.weekSlotsLoading = false,
    this.weekSlotsError,
    this.weekStartMode = OpsWeekStart.sunday,
  });

  /// Kathmandu calendar date the dashboard shows.
  final DateTime date;
  final VendorOpsStatus status;
  final List<OpsCourt> courts;
  final List<BookingModel> bookings;
  final bool bookingsLoaded;
  final bool bookingsLoading;

  /// The date's bookings failed to load and nothing trustworthy is showing.
  final bool bookingsError;
  final Set<int> venueIds;
  final Set<int> courtIds;
  final OpsFocus focus;
  final String search;
  final Set<int> collapsedVenues;

  /// Slot key → selected slot, across courts, venues and dates.
  final Map<String, OpsSelectionItem> selection;
  final OpsBoard? board;
  final OpsSummary summary;
  final DateTime? lastUpdated;
  final String? errorMessage;

  final OpsAvailabilityView view;

  /// The court the week table shows.
  final int? weekCourtId;

  /// Bookings for the week starting [loadedWeekStart].
  final List<BookingModel> weekBookings;
  final DateTime? loadedWeekStart;
  final bool weekLoading;
  final String? weekError;

  /// Courts' weeks and days from `GET /court-availability-slots`, keyed by
  /// [OpsCourtWeekAvailability.keyOf] — kept so going back to a court or a
  /// date shows it at once. Read through [weekSlotsFor] and [daySlotsFor].
  final Map<String, OpsCourtWeekAvailability> weekSlots;
  final bool weekSlotsLoading;

  /// [courtId]'s week from [weekStart], once the server has answered.
  OpsCourtWeekAvailability? weekSlotsFor(int courtId, DateTime weekStart) =>
      weekSlots[OpsCourtWeekAvailability.keyOf(courtId, weekStart)];

  /// [courtId]'s [date] from the Day board's `type=day` call, once the server
  /// has answered. Its `days` is empty when the server left the court out.
  OpsCourtWeekAvailability? daySlotsFor(int courtId, DateTime date) =>
      weekSlots[OpsCourtWeekAvailability.keyOf(
        courtId,
        date,
        OpsAvailabilityResponseType.day,
      )];

  /// The server's week failed to load; the table shows the court's own
  /// schedule instead.
  final String? weekSlotsError;

  /// Where the Week table's days begin: Sunday, or today.
  final OpsWeekStart weekStartMode;

  /// First day of the selected date's week under [weekStartMode].
  DateTime get weekStart =>
      weekStartFor(date, weekStartMode, today: KathmanduClock.today());

  /// The court the Week table shows: the picked one while the venue filter
  /// still lists it, else the first court it lists — never none while there
  /// is a court to show.
  OpsCourt? get tableCourt {
    final List<OpsCourt> listed = filterableCourts;
    return listed.where((OpsCourt c) => c.id == weekCourtId).firstOrNull ??
        listed.firstOrNull;
  }

  bool get isToday => KathmanduClock.isToday(date);

  /// Every venue the vendor has, for the venue filter.
  List<(int, String)> get venues {
    final Map<int, String> map = <int, String>{};
    for (final OpsCourt c in courts) {
      map[c.venueId] = c.venueName;
    }
    return map.entries
        .map((MapEntry<int, String> e) => (e.key, e.value))
        .toList()
      ..sort(((int, String) a, (int, String) b) => a.$2.compareTo(b.$2));
  }

  /// Courts of the selected venues, for the court filter.
  List<OpsCourt> get filterableCourts => courts
      .where((OpsCourt c) => venueIds.isEmpty || venueIds.contains(c.venueId))
      .toList();

  List<OpsBookingRange> get ranges => mergeSelection(selection.values);

  int get selectedMinutes => selection.values.fold<int>(
    0,
    (int sum, OpsSelectionItem i) => sum + i.minutes,
  );

  bool get hasActiveFilters =>
      venueIds.isNotEmpty ||
      courtIds.isNotEmpty ||
      focus != OpsFocus.all ||
      search.trim().isNotEmpty;

  VendorOpsState copyWith({
    DateTime? date,
    VendorOpsStatus? status,
    List<OpsCourt>? courts,
    List<BookingModel>? bookings,
    bool? bookingsLoaded,
    bool? bookingsLoading,
    bool? bookingsError,
    Set<int>? venueIds,
    Set<int>? courtIds,
    OpsFocus? focus,
    String? search,
    Set<int>? collapsedVenues,
    Map<String, OpsSelectionItem>? selection,
    OpsBoard? board,
    OpsSummary? summary,
    DateTime? lastUpdated,
    String? errorMessage,
    bool clearError = false,
    OpsAvailabilityView? view,
    int? weekCourtId,
    List<BookingModel>? weekBookings,
    DateTime? loadedWeekStart,
    bool? weekLoading,
    String? weekError,
    bool clearWeekError = false,
    Map<String, OpsCourtWeekAvailability>? weekSlots,
    bool? weekSlotsLoading,
    String? weekSlotsError,
    bool clearWeekSlotsError = false,
    OpsWeekStart? weekStartMode,
  }) {
    return VendorOpsState(
      date: date ?? this.date,
      status: status ?? this.status,
      courts: courts ?? this.courts,
      bookings: bookings ?? this.bookings,
      bookingsLoaded: bookingsLoaded ?? this.bookingsLoaded,
      bookingsLoading: bookingsLoading ?? this.bookingsLoading,
      bookingsError: bookingsError ?? this.bookingsError,
      venueIds: venueIds ?? this.venueIds,
      courtIds: courtIds ?? this.courtIds,
      focus: focus ?? this.focus,
      search: search ?? this.search,
      collapsedVenues: collapsedVenues ?? this.collapsedVenues,
      selection: selection ?? this.selection,
      board: board ?? this.board,
      summary: summary ?? this.summary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      view: view ?? this.view,
      weekCourtId: weekCourtId ?? this.weekCourtId,
      weekBookings: weekBookings ?? this.weekBookings,
      loadedWeekStart: loadedWeekStart ?? this.loadedWeekStart,
      weekLoading: weekLoading ?? this.weekLoading,
      weekError: clearWeekError ? null : (weekError ?? this.weekError),
      weekSlots: weekSlots ?? this.weekSlots,
      weekSlotsLoading: weekSlotsLoading ?? this.weekSlotsLoading,
      weekSlotsError: clearWeekSlotsError
          ? null
          : (weekSlotsError ?? this.weekSlotsError),
      weekStartMode: weekStartMode ?? this.weekStartMode,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    date,
    status,
    courts,
    bookings,
    bookingsLoaded,
    bookingsLoading,
    bookingsError,
    venueIds,
    courtIds,
    focus,
    search,
    collapsedVenues,
    selection,
    board,
    summary,
    lastUpdated,
    errorMessage,
    view,
    weekCourtId,
    weekBookings,
    loadedWeekStart,
    weekLoading,
    weekError,
    weekSlots,
    weekSlotsLoading,
    weekSlotsError,
    weekStartMode,
  ];
}
