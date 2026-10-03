import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/weekday_option.dart';

/// Pure model and logic for the vendor operations dashboard: court schedules,
/// the availability board, the daily summary and the manual-booking selection.
///
/// Nothing here touches Flutter or the network, so every rule — slot
/// generation, pricing, overlap, occupancy — is unit-testable.
///
/// Time is minutes since midnight throughout, and every interval is
/// start-inclusive and end-exclusive: 18:00–19:00 and 19:00–20:00 touch but do
/// not overlap.

const int kMinutesPerDay = 24 * 60;
const int kDefaultSlotMinutes = 60;

// ───────────────────────────── Time helpers ─────────────────────────────

/// Minutes since midnight from any time string the API or the app uses:
/// `18:00`, `18:00:00`, `6:00 PM`, `06 : 00 PM`. Null when unreadable.
int? parseMinuteOfDay(String? raw) {
  final String value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  final RegExpMatch? m = RegExp(
    r'^(\d{1,2})\s*:\s*(\d{2})(?:\s*:\s*\d{2})?\s*(AM|PM)?$',
    caseSensitive: false,
  ).firstMatch(value);
  if (m == null) return null;
  int hour = int.parse(m.group(1)!);
  final int minute = int.parse(m.group(2)!);
  final String? meridiem = m.group(3)?.toUpperCase();
  if (minute > 59) return null;
  if (meridiem != null) {
    if (hour < 1 || hour > 12) return null;
    hour = hour % 12 + (meridiem == 'PM' ? 12 : 0);
  } else if (hour > 24 || (hour == 24 && minute > 0)) {
    return null;
  }
  return hour * 60 + minute;
}

/// `6:00 PM` — for display.
String formatMinuteOfDay(int minute) {
  final int m = minute % kMinutesPerDay;
  final int hour24 = m ~/ 60;
  final int hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final String mm = (m % 60).toString().padLeft(2, '0');
  return '$hour12:$mm ${hour24 < 12 ? 'AM' : 'PM'}';
}

/// `18:00` — the 24-hour `H:i` the API expects. 24:00 is sent as `23:59`
/// never; a slot ending at midnight is sent as `24:00`, which the backend
/// reads as end of day.
String apiTimeOf(int minute) {
  final int hour = minute ~/ 60;
  final String mm = (minute % 60).toString().padLeft(2, '0');
  return '${hour.toString().padLeft(2, '0')}:$mm';
}

/// `1 h 30 m`, `45 m`, `2 h`.
String formatDuration(int minutes) {
  final int h = minutes ~/ 60;
  final int m = minutes % 60;
  if (h == 0) return '$m m';
  if (m == 0) return '$h h';
  return '$h h $m m';
}

/// Court-hours with one decimal, e.g. `3.5`.
String formatHours(int minutes) {
  final double hours = minutes / 60;
  return hours == hours.roundToDouble()
      ? hours.toStringAsFixed(0)
      : hours.toStringAsFixed(1);
}

bool overlaps(int aStart, int aEnd, int bStart, int bEnd) =>
    aStart < bEnd && bStart < aEnd;

/// `sun` … `sat` for [date].
String weekdayKeyOf(DateTime date) =>
    WeekdayOption.values[date.weekday % 7].key;

// ───────────────────────────── Court schedule ─────────────────────────────

/// One pricing window of a court's schedule. Slots are generated inside it,
/// so a slot never straddles two windows.
class OpsPriceBand extends Equatable {
  const OpsPriceBand({
    required this.start,
    required this.end,
    this.days = const <String>{},
    this.price,
    this.weekendPrice,
    this.holidayPrice,
    this.customDatePrices = const <String, double>{},
  });

  final int start;

  /// Exclusive. Already widened to midnight (1440) for an overnight window.
  final int end;

  /// Weekday keys (`sun` … `sat`); empty means every day.
  final Set<String> days;
  final double? price;
  final double? weekendPrice;
  final double? holidayPrice;

  /// ISO date → price for that one date.
  final Map<String, double> customDatePrices;

  bool appliesOn(String dayKey) => days.isEmpty || days.contains(dayKey);

  @override
  List<Object?> get props => <Object?>[
    start,
    end,
    days,
    price,
    weekendPrice,
    holidayPrice,
    customDatePrices,
  ];
}

/// A closure on one date: the whole day, or [start]–[end].
class OpsClosure extends Equatable {
  const OpsClosure({
    required this.date,
    this.fullDay = true,
    this.start,
    this.end,
  });

  final String date;
  final bool fullDay;
  final int? start;
  final int? end;

  @override
  List<Object?> get props => <Object?>[date, fullDay, start, end];
}

/// One sellable slot of a court on a date.
class OpsSlot extends Equatable {
  const OpsSlot({
    required this.courtId,
    required this.venueId,
    required this.date,
    required this.start,
    required this.end,
    this.price,
  });

  final int courtId;
  final int venueId;

  /// ISO date.
  final String date;
  final int start;
  final int end;

  /// Estimated price from the court's schedule. The server prices the booking
  /// for real; this is what the board shows and what the review compares the
  /// server's quote against.
  final double? price;

  int get minutes => end - start;

  @override
  List<Object?> get props => <Object?>[
    courtId,
    venueId,
    date,
    start,
    end,
    price,
  ];
}

/// A court's slots for one date, or why it has none.
class OpsDaySchedule extends Equatable {
  const OpsDaySchedule({required this.slots, this.closedReason});

  final List<OpsSlot> slots;

  /// Set when the court is not open at all that day.
  final String? closedReason;

  @override
  List<Object?> get props => <Object?>[slots, closedReason];
}

class OpsCourt extends Equatable {
  const OpsCourt({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.name,
    this.slotMinutes = kDefaultSlotMinutes,
    this.openMinute,
    this.closeMinute,
    this.open24Hours = false,
    this.openDays = const <String>{},
    this.basePrice,
    this.bands = const <OpsPriceBand>[],
    this.closures = const <OpsClosure>[],
    this.holidayDates = const <String>{},
    this.weekendDays = const <String>{},
    this.isActive = true,
  });

  final int id;
  final int venueId;
  final String venueName;
  final String name;

  /// Never assumed to be an hour — each court has its own.
  final int slotMinutes;
  final int? openMinute;
  final int? closeMinute;
  final bool open24Hours;

  /// Weekday keys the court opens on; empty means every day.
  final Set<String> openDays;
  final double? basePrice;
  final List<OpsPriceBand> bands;
  final List<OpsClosure> closures;
  final Set<String> holidayDates;

  /// Weekday keys that take the weekend price.
  final Set<String> weekendDays;
  final bool isActive;

  /// Whether the schedule has enough to generate slots from. Courts from the
  /// day's server answer have none — their slots are the server's.
  bool get hasSchedule =>
      bands.isNotEmpty ||
      open24Hours ||
      (openMinute != null && closeMinute != null);

  double? _bandPrice(OpsPriceBand band, String dateKey, String dayKey) =>
      band.customDatePrices[dateKey] ??
      (holidayDates.contains(dateKey) ? band.holidayPrice : null) ??
      (weekendDays.contains(dayKey) ? band.weekendPrice : null) ??
      band.price ??
      basePrice;

  /// This court's slots on [date], hourly closures removed. Past time is not
  /// removed here — that depends on the clock, not the schedule.
  OpsDaySchedule scheduleFor(DateTime date) {
    final String dateKey = isoDate(date);
    final String dayKey = weekdayKeyOf(date);

    if (!isActive) {
      return const OpsDaySchedule(
        slots: <OpsSlot>[],
        closedReason: 'Court inactive',
      );
    }
    for (final OpsClosure c in closures) {
      if (c.date == dateKey && c.fullDay) {
        return const OpsDaySchedule(
          slots: <OpsSlot>[],
          closedReason: 'Closed all day',
        );
      }
    }

    final List<OpsSlot> slots = <OpsSlot>[];
    void addRange(int from, int to, double? price) {
      for (int t = from; t + slotMinutes <= to; t += slotMinutes) {
        // Two windows that overlap on the server must not double a slot.
        if (slots.isNotEmpty && t < slots.last.end) continue;
        slots.add(
          OpsSlot(
            courtId: id,
            venueId: venueId,
            date: dateKey,
            start: t,
            end: t + slotMinutes,
            price: price,
          ),
        );
      }
    }

    final List<OpsPriceBand> todays = bands
        .where((OpsPriceBand b) => b.appliesOn(dayKey))
        .toList();
    if (todays.isNotEmpty) {
      for (final OpsPriceBand band in todays) {
        addRange(band.start, band.end, _bandPrice(band, dateKey, dayKey));
      }
    } else if (bands.isNotEmpty) {
      return OpsDaySchedule(
        slots: const <OpsSlot>[],
        closedReason: 'No slots on ${WeekdayOption.fromAny(dayKey)?.name}',
      );
    } else {
      if (openDays.isNotEmpty && !openDays.contains(dayKey)) {
        return OpsDaySchedule(
          slots: const <OpsSlot>[],
          closedReason: 'Closed on ${WeekdayOption.fromAny(dayKey)?.name}',
        );
      }
      final int? from = open24Hours ? 0 : openMinute;
      final int? to = open24Hours ? kMinutesPerDay : closeMinute;
      if (from == null || to == null) {
        return const OpsDaySchedule(
          slots: <OpsSlot>[],
          closedReason: 'No schedule set',
        );
      }
      addRange(from, to, basePrice);
    }

    final List<OpsClosure> hourly = closures
        .where(
          (OpsClosure c) =>
              c.date == dateKey &&
              !c.fullDay &&
              c.start != null &&
              c.end != null,
        )
        .toList();
    if (hourly.isEmpty) return OpsDaySchedule(slots: slots);
    return OpsDaySchedule(
      slots: slots
          .where(
            (OpsSlot s) => !hourly.any(
              (OpsClosure c) => overlaps(s.start, s.end, c.start!, c.end!),
            ),
          )
          .toList(),
    );
  }

  /// Hourly closures on [date], for drawing them on the board.
  List<OpsClosure> hourlyClosuresOn(DateTime date) {
    final String key = isoDate(date);
    return closures
        .where(
          (OpsClosure c) =>
              c.date == key && !c.fullDay && c.start != null && c.end != null,
        )
        .toList();
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    venueId,
    venueName,
    name,
    slotMinutes,
    openMinute,
    closeMinute,
    open24Hours,
    openDays,
    basePrice,
    bands,
    closures,
    holidayDates,
    weekendDays,
    isActive,
  ];
}

// ───────────────────────────── Bookings ─────────────────────────────

/// Where a booking stands operationally — kept apart from [OpsPaymentState]:
/// a confirmed booking can still be unpaid.
enum OpsBookingPhase { pending, confirmed, inProgress, completed }

enum OpsPaymentState { paid, partial, unpaid }

bool isActiveBooking(BookingModel b) =>
    b.status != BookingStatus.cancelled && b.status != BookingStatus.rejected;

/// The [start, end) intervals [booking] occupies on [date]. Uses the booking's
/// slot rows when it has them — a multi-slot booking is not one block.
List<(int, int)> bookingIntervalsOn(BookingModel booking, String date) {
  final List<(int, int)> out = <(int, int)>[];
  for (final BookingSlotModel slot in booking.bookingSlots) {
    if (isoDate(slot.date) != date) continue;
    final int? s = parseMinuteOfDay(slot.startTime);
    final int? e = parseMinuteOfDay(slot.endTime);
    if (s == null || e == null) continue;
    out.add((s, e <= s ? kMinutesPerDay : e));
  }
  if (out.isNotEmpty) return out;
  if (isoDate(booking.date) != date) return out;
  final int? s = parseMinuteOfDay(booking.startTime);
  final int? e = parseMinuteOfDay(booking.endTime);
  if (s == null || e == null) return out;
  return <(int, int)>[(s, e <= s ? kMinutesPerDay : e)];
}

OpsPaymentState paymentStateOf(BookingModel b) {
  final String status = b.paymentStatus?.trim().toLowerCase() ?? '';
  if (status == 'paid') return OpsPaymentState.paid;
  if (status == 'partial' || status == 'partially_paid') {
    return OpsPaymentState.partial;
  }
  if (b.balanceDue <= 0 && b.paidAmount > 0) return OpsPaymentState.paid;
  if (b.paidAmount > 0) return OpsPaymentState.partial;
  return OpsPaymentState.unpaid;
}

OpsBookingPhase phaseOf(
  BookingModel b, {
  required int start,
  required int end,
  int? nowMinute,
}) {
  switch (b.status) {
    case BookingStatus.completed:
      return OpsBookingPhase.completed;
    case BookingStatus.pending:
      return OpsBookingPhase.pending;
    default:
      if (nowMinute != null && nowMinute >= start && nowMinute < end) {
        return OpsBookingPhase.inProgress;
      }
      return OpsBookingPhase.confirmed;
  }
}

// ───────────────────────────── Board ─────────────────────────────

enum OpsCellKind { available, booked, closed, past }

/// One block on a court's timeline: a free slot, a booking (merged across the
/// slots it covers), a closure, or elapsed time.
class OpsCell extends Equatable {
  const OpsCell({
    required this.courtId,
    required this.venueId,
    required this.date,
    required this.start,
    required this.end,
    required this.kind,
    this.price,
    this.booking,
    this.phase,
    this.payment,
    this.note,
  });

  final int courtId;
  final int venueId;
  final String date;
  final int start;
  final int end;
  final OpsCellKind kind;
  final double? price;
  final BookingModel? booking;
  final OpsBookingPhase? phase;
  final OpsPaymentState? payment;

  /// Closure reason, for closed cells.
  final String? note;

  int get minutes => end - start;

  /// Stable identity of a selectable slot.
  String get slotKey => '$courtId|$date|$start|$end';

  @override
  List<Object?> get props => <Object?>[
    courtId,
    venueId,
    date,
    start,
    end,
    kind,
    price,
    booking?.id,
    phase,
    payment,
    note,
  ];
}

class OpsCourtRow extends Equatable {
  const OpsCourtRow({
    required this.court,
    required this.cells,
    this.closedReason,
    this.sellableMinutes = 0,
  });

  final OpsCourt court;

  /// Sorted by start, non-overlapping.
  final List<OpsCell> cells;

  /// Set when the court is closed for the whole day.
  final String? closedReason;

  /// Scheduled open time, closures excluded — occupancy's denominator.
  final int sellableMinutes;

  bool get isFullyBooked =>
      closedReason == null &&
      cells.isNotEmpty &&
      !cells.any((OpsCell c) => c.kind == OpsCellKind.available);

  @override
  List<Object?> get props => <Object?>[
    court,
    cells,
    closedReason,
    sellableMinutes,
  ];
}

class OpsVenueRow extends Equatable {
  const OpsVenueRow({
    required this.venueId,
    required this.venueName,
    required this.courts,
  });

  final int venueId;
  final String venueName;
  final List<OpsCourtRow> courts;

  @override
  List<Object?> get props => <Object?>[venueId, venueName, courts];
}

class OpsBoard extends Equatable {
  const OpsBoard({
    required this.date,
    required this.venues,
    required this.axisStart,
    required this.axisEnd,
    this.nowMinute,
  });

  final DateTime date;
  final List<OpsVenueRow> venues;

  /// Earliest and latest minute any visible court uses — the timeline's span.
  final int axisStart;
  final int axisEnd;

  /// Set only when [date] is today (Kathmandu).
  final int? nowMinute;

  bool get isEmpty => venues.every((OpsVenueRow v) => v.courts.isEmpty);

  @override
  List<Object?> get props => <Object?>[
    date,
    venues,
    axisStart,
    axisEnd,
    nowMinute,
  ];
}

/// Builds the board for [date] from the courts' schedules and that day's
/// bookings.
///
/// [today] decides what is past: every free slot on an earlier date, slots
/// that have started on today, nothing on a later date.
///
/// A court whose week is in [server] (court id → its week from
/// `GET /court-availability-slots`) and covers [date] is drawn from the
/// server's slots, the way the Week table draws it; any other court from its
/// own schedule.
OpsBoard buildOpsBoard({
  required List<OpsCourt> courts,
  required List<BookingModel> bookings,
  required DateTime date,
  required DateTime today,
  required int nowMinute,
  Map<int, OpsCourtWeekAvailability> server =
      const <int, OpsCourtWeekAvailability>{},
}) {
  final String dateKey = isoDate(date);
  final bool isToday = isSameDay(date, today);
  final bool isPastDate = date.isBefore(today) && !isToday;

  final Map<int, List<BookingModel>> byCourt = <int, List<BookingModel>>{};
  for (final BookingModel b in bookings) {
    if (!isActiveBooking(b) || b.courtId == null) continue;
    byCourt.putIfAbsent(b.courtId!, () => <BookingModel>[]).add(b);
  }

  int axisStart = kMinutesPerDay;
  int axisEnd = 0;

  final Map<int, List<OpsCourtRow>> rowsByVenue = <int, List<OpsCourtRow>>{};
  final Map<int, String> venueNames = <int, String>{};

  for (final OpsCourt court in courts) {
    venueNames[court.venueId] = court.venueName;

    final List<OpsServerSlot>? live = server[court.id]?.days[dateKey];
    if (live != null) {
      final OpsCourtRow row = _serverDayRow(
        court: court,
        slots: live,
        bookings: byCourt[court.id] ?? const <BookingModel>[],
        date: date,
        today: today,
        nowMinute: nowMinute,
      );
      for (final OpsCell c in row.cells) {
        if (c.start < axisStart) axisStart = c.start;
        if (c.end > axisEnd) axisEnd = c.end;
      }
      rowsByVenue.putIfAbsent(court.venueId, () => <OpsCourtRow>[]).add(row);
      continue;
    }

    final OpsDaySchedule schedule = court.scheduleFor(date);

    // Booked intervals on this court, each tied to its booking.
    final List<(int, int, BookingModel)> booked =
        <(int, int, BookingModel)>[
          for (final BookingModel b
              in byCourt[court.id] ?? const <BookingModel>[])
            for (final (int s, int e) in bookingIntervalsOn(b, dateKey))
              (s, e, b),
        ]..sort(
          ((int, int, BookingModel) a, (int, int, BookingModel) b) =>
              a.$1.compareTo(b.$1),
        );

    final List<OpsCell> cells = <OpsCell>[];
    int sellable = 0;

    for (final OpsSlot slot in schedule.slots) {
      sellable += slot.minutes;
      final (int, int, BookingModel)? hit = booked
          .where(
            ((int, int, BookingModel) iv) =>
                overlaps(slot.start, slot.end, iv.$1, iv.$2),
          )
          .firstOrNull;
      if (hit != null) continue; // Drawn as the booking's own block below.
      final bool past = isPastDate || (isToday && slot.start < nowMinute);
      cells.add(
        OpsCell(
          courtId: court.id,
          venueId: court.venueId,
          date: dateKey,
          start: slot.start,
          end: slot.end,
          kind: past ? OpsCellKind.past : OpsCellKind.available,
          price: slot.price,
        ),
      );
    }

    // Each booking is one block at its real times, even when those do not
    // line up with the court's slot grid (a walk-in at 20:33).
    for (final (int s, int e, BookingModel b) in booked) {
      cells.add(
        OpsCell(
          courtId: court.id,
          venueId: court.venueId,
          date: dateKey,
          start: s,
          end: e,
          kind: OpsCellKind.booked,
          booking: b,
          phase: phaseOf(
            b,
            start: s,
            end: e,
            nowMinute: isToday ? nowMinute : null,
          ),
          payment: paymentStateOf(b),
        ),
      );
    }

    for (final OpsClosure c in court.hourlyClosuresOn(date)) {
      cells.add(
        OpsCell(
          courtId: court.id,
          venueId: court.venueId,
          date: dateKey,
          start: c.start!,
          end: c.end!,
          kind: OpsCellKind.closed,
          note: 'Closed',
        ),
      );
    }

    cells.sort((OpsCell a, OpsCell b) => a.start.compareTo(b.start));
    for (final OpsCell c in cells) {
      if (c.start < axisStart) axisStart = c.start;
      if (c.end > axisEnd) axisEnd = c.end;
    }

    rowsByVenue
        .putIfAbsent(court.venueId, () => <OpsCourtRow>[])
        .add(
          OpsCourtRow(
            court: court,
            cells: cells,
            closedReason: schedule.closedReason,
            sellableMinutes: sellable,
          ),
        );
  }

  if (axisStart >= axisEnd) {
    axisStart = 6 * 60;
    axisEnd = 22 * 60;
  }
  // Whole hours, so the time header reads cleanly.
  axisStart = (axisStart ~/ 60) * 60;
  axisEnd = ((axisEnd + 59) ~/ 60) * 60;

  return OpsBoard(
    date: date,
    venues: <OpsVenueRow>[
      for (final MapEntry<int, List<OpsCourtRow>> e in rowsByVenue.entries)
        OpsVenueRow(
          venueId: e.key,
          venueName: venueNames[e.key] ?? 'Venue',
          courts: e.value,
        ),
    ],
    axisStart: axisStart,
    axisEnd: axisEnd.clamp(axisStart + 60, kMinutesPerDay),
    nowMinute: isToday ? nowMinute : null,
  );
}

// ───────────────────────────── Summary ─────────────────────────────

/// One court's share of its open time that is booked, for the per-court
/// occupancy chart.
class OpsCourtOccupancy extends Equatable {
  const OpsCourtOccupancy({
    required this.courtId,
    required this.courtName,
    required this.venueName,
    required this.bookedMinutes,
    required this.sellableMinutes,
    this.closedReason,
  });

  final int courtId;
  final String courtName;
  final String venueName;
  final int bookedMinutes;
  final int sellableMinutes;

  /// Set when the court is not open at all that day.
  final String? closedReason;

  double get occupancy => sellableMinutes <= 0
      ? 0
      : (bookedMinutes / sellableMinutes).clamp(0, 1).toDouble();

  @override
  List<Object?> get props => <Object?>[
    courtId,
    courtName,
    venueName,
    bookedMinutes,
    sellableMinutes,
    closedReason,
  ];
}

class OpsSummary extends Equatable {
  const OpsSummary({
    this.bookingCount = 0,
    this.bookedMinutes = 0,
    this.sellableMinutes = 0,
    this.availableMinutes = 0,
    this.pastUnbookedMinutes = 0,
    this.bookingValue = 0,
    this.paidValue = 0,
    this.outstanding = 0,
    this.outstandingCount = 0,
    this.phaseCounts = const <OpsBookingPhase, int>{},
    this.courts = const <OpsCourtOccupancy>[],
  });

  /// Distinct bookings — a booking with three slots counts once.
  final int bookingCount;
  final int bookedMinutes;

  /// Open court-time, closures excluded.
  final int sellableMinutes;

  /// Free court-time still bookable (past time excluded on today).
  final int availableMinutes;

  /// Open court-time that went by without a booking.
  final int pastUnbookedMinutes;

  /// Net value of the active bookings scheduled on the date.
  final double bookingValue;

  /// What has been paid towards those bookings.
  final double paidValue;

  /// What is still owed on those bookings.
  final double outstanding;
  final int outstandingCount;

  /// Distinct bookings by where they stand. A booking with a slot running now
  /// counts as in progress.
  final Map<OpsBookingPhase, int> phaseCounts;

  /// Every visible court, in board order.
  final List<OpsCourtOccupancy> courts;

  double get occupancy => sellableMinutes <= 0
      ? 0
      : (bookedMinutes / sellableMinutes).clamp(0, 1).toDouble();

  @override
  List<Object?> get props => <Object?>[
    bookingCount,
    bookedMinutes,
    sellableMinutes,
    availableMinutes,
    pastUnbookedMinutes,
    bookingValue,
    paidValue,
    outstanding,
    outstandingCount,
    phaseCounts,
    courts,
  ];
}

OpsSummary summarizeBoard(OpsBoard board) {
  final Map<int, BookingModel> bookings = <int, BookingModel>{};
  final Map<int, OpsBookingPhase> phases = <int, OpsBookingPhase>{};
  final List<OpsCourtOccupancy> courts = <OpsCourtOccupancy>[];
  int booked = 0;
  int sellable = 0;
  int available = 0;
  int pastUnbooked = 0;
  for (final OpsVenueRow venue in board.venues) {
    for (final OpsCourtRow row in venue.courts) {
      sellable += row.sellableMinutes;
      int courtBooked = 0;
      for (final OpsCell cell in row.cells) {
        switch (cell.kind) {
          case OpsCellKind.booked:
            booked += cell.minutes;
            courtBooked += cell.minutes;
            final int id = cell.booking!.id;
            bookings[id] = cell.booking!;
            if (phases[id] != OpsBookingPhase.inProgress) {
              phases[id] = cell.phase ?? OpsBookingPhase.confirmed;
            }
          case OpsCellKind.available:
            available += cell.minutes;
          case OpsCellKind.past:
            pastUnbooked += cell.minutes;
          case OpsCellKind.closed:
            break;
        }
      }
      courts.add(
        OpsCourtOccupancy(
          courtId: row.court.id,
          courtName: row.court.name,
          venueName: venue.venueName,
          bookedMinutes: courtBooked,
          sellableMinutes: row.sellableMinutes,
          closedReason: row.closedReason,
        ),
      );
    }
  }
  double value = 0;
  double paid = 0;
  double outstanding = 0;
  int outstandingCount = 0;
  for (final BookingModel b in bookings.values) {
    value += b.amount;
    paid += b.paidAmount;
    if (b.balanceDue > 0) {
      outstanding += b.balanceDue;
      outstandingCount++;
    }
  }
  final Map<OpsBookingPhase, int> phaseCounts = <OpsBookingPhase, int>{};
  for (final OpsBookingPhase p in phases.values) {
    phaseCounts[p] = (phaseCounts[p] ?? 0) + 1;
  }
  return OpsSummary(
    bookingCount: bookings.length,
    bookedMinutes: booked,
    sellableMinutes: sellable,
    availableMinutes: available,
    pastUnbookedMinutes: pastUnbooked,
    bookingValue: value,
    paidValue: paid,
    outstanding: outstanding,
    outstandingCount: outstandingCount,
    phaseCounts: phaseCounts,
    courts: courts,
  );
}

// ───────────────────────────── Focus & filters ─────────────────────────────

/// What the board emphasises. Set from the status filter or a summary card;
/// cells that do not match are dimmed, never hidden, so the day keeps its
/// shape.
enum OpsFocus {
  all('All'),
  available('Available'),
  upcoming('Upcoming'),
  inProgress('In progress'),
  completed('Completed'),
  pending('Pending'),
  outstanding('Outstanding payment');

  const OpsFocus(this.label);
  final String label;
}

bool cellMatchesFocus(OpsCell cell, OpsFocus focus, String search) {
  final String q = search.trim().toLowerCase();
  if (q.isNotEmpty) {
    final BookingModel? b = cell.booking;
    if (b == null) return false;
    final bool hit =
        (b.playerName?.toLowerCase().contains(q) ?? false) ||
        (b.playerPhone?.contains(q) ?? false) ||
        b.bookingRef.toLowerCase().contains(q);
    if (!hit) return false;
  }
  switch (focus) {
    case OpsFocus.all:
      return true;
    case OpsFocus.available:
      return cell.kind == OpsCellKind.available;
    case OpsFocus.upcoming:
      return cell.phase == OpsBookingPhase.confirmed;
    case OpsFocus.inProgress:
      return cell.phase == OpsBookingPhase.inProgress;
    case OpsFocus.completed:
      return cell.phase == OpsBookingPhase.completed;
    case OpsFocus.pending:
      return cell.phase == OpsBookingPhase.pending;
    case OpsFocus.outstanding:
      return (cell.booking?.balanceDue ?? 0) > 0;
  }
}

// ───────────────────────────── Selection ─────────────────────────────

/// One slot the vendor has picked for the manual booking.
class OpsSelectionItem extends Equatable {
  const OpsSelectionItem({
    required this.venueId,
    required this.venueName,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.start,
    required this.end,
    this.price,
  });

  factory OpsSelectionItem.fromCell(OpsCell cell, OpsCourt court) =>
      OpsSelectionItem(
        venueId: court.venueId,
        venueName: court.venueName,
        courtId: court.id,
        courtName: court.name,
        date: cell.date,
        start: cell.start,
        end: cell.end,
        price: cell.price,
      );

  final int venueId;
  final String venueName;
  final int courtId;
  final String courtName;
  final String date;
  final int start;
  final int end;
  final double? price;

  String get key => '$courtId|$date|$start|$end';
  int get minutes => end - start;

  @override
  List<Object?> get props => <Object?>[
    venueId,
    venueName,
    courtId,
    courtName,
    date,
    start,
    end,
    price,
  ];
}

/// Selected slots on one court and date that touch end to start — booked as
/// one request, since the booking API takes one court and one time range.
/// Slots with a gap between them stay separate ranges: the gap is never
/// filled in.
class OpsBookingRange extends Equatable {
  const OpsBookingRange({required this.items});

  final List<OpsSelectionItem> items;

  OpsSelectionItem get first => items.first;
  int get venueId => first.venueId;
  String get venueName => first.venueName;
  int get courtId => first.courtId;
  String get courtName => first.courtName;
  String get date => first.date;
  int get start => first.start;
  int get end => items.last.end;
  int get minutes => end - start;

  /// Null when any slot has no known price.
  double? get estimate {
    double total = 0;
    for (final OpsSelectionItem i in items) {
      if (i.price == null) return null;
      total += i.price!;
    }
    return total;
  }

  String get key => '$courtId|$date|$start|$end';

  @override
  List<Object?> get props => <Object?>[items];
}

List<OpsBookingRange> mergeSelection(Iterable<OpsSelectionItem> selection) {
  final List<OpsSelectionItem> sorted = selection.toList()
    ..sort((OpsSelectionItem a, OpsSelectionItem b) {
      final int byVenue = a.venueName.compareTo(b.venueName);
      if (byVenue != 0) return byVenue;
      final int byCourt = a.courtName.compareTo(b.courtName);
      if (byCourt != 0) return byCourt;
      final int byCourtId = a.courtId.compareTo(b.courtId);
      if (byCourtId != 0) return byCourtId;
      final int byDate = a.date.compareTo(b.date);
      if (byDate != 0) return byDate;
      return a.start.compareTo(b.start);
    });
  final List<OpsBookingRange> ranges = <OpsBookingRange>[];
  List<OpsSelectionItem> current = <OpsSelectionItem>[];
  for (final OpsSelectionItem item in sorted) {
    final OpsSelectionItem? last = current.isEmpty ? null : current.last;
    final bool continues =
        last != null &&
        last.courtId == item.courtId &&
        last.date == item.date &&
        last.end == item.start;
    if (!continues && current.isNotEmpty) {
      ranges.add(OpsBookingRange(items: current));
      current = <OpsSelectionItem>[];
    }
    current.add(item);
  }
  if (current.isNotEmpty) ranges.add(OpsBookingRange(items: current));
  return ranges;
}

// ───────────────────────────── Week table ─────────────────────────────

/// Sunday of the week containing [date] — Nepal's week runs Sunday to
/// Saturday.
DateTime weekStartOf(DateTime date) {
  final DateTime day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday % 7));
}

/// Where the Week table's seven days begin.
enum OpsWeekStart {
  /// The calendar week, Sunday to Saturday.
  sunday('sunday', 'Sun – Sat'),

  /// A rolling week: today and the six days after it, then the seven after
  /// those, and so on.
  today('today', 'From today');

  const OpsWeekStart(this.key, this.label);

  /// Stored in preferences.
  final String key;
  final String label;

  static OpsWeekStart fromKey(String? key) => values.firstWhere(
    (OpsWeekStart m) => m.key == key,
    orElse: () => OpsWeekStart.sunday,
  );
}

/// First day of the week containing [date] under [mode]. A rolling week
/// counts in sevens from [today], so paging moves a whole week and today is
/// always its first day.
DateTime weekStartFor(
  DateTime date,
  OpsWeekStart mode, {
  required DateTime today,
}) {
  if (mode == OpsWeekStart.sunday) return weekStartOf(date);
  final DateTime day = DateTime(date.year, date.month, date.day);
  final DateTime from = DateTime(today.year, today.month, today.day);
  // Calendar days, not hours: a DST shift must not move the window.
  final int offset = DateTime.utc(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
  final int weeks = (offset / 7).floor();
  return DateTime(from.year, from.month, from.day + weeks * 7);
}

/// What the server says one of a court's slots is
/// (`GET /court-availability-slots`).
enum OpsServerSlotState { available, booked, held, closed, past }

enum OpsAvailabilityResponseType { day, week }

/// One court slot on one day, as the server reports it.
class OpsServerSlot extends Equatable {
  const OpsServerSlot({
    required this.start,
    required this.end,
    required this.state,
    this.price,
    this.bookingId,
    this.reason,
    this.booking,
  });

  final int start;
  final int end;
  final OpsServerSlotState state;
  final double? price;

  /// The booking on this slot, when the server names it.
  final int? bookingId;

  /// The booking itself, when the server sends it with the slot — lets a
  /// booked slot open its booking even when the device has not loaded it.
  final BookingModel? booking;

  /// Why a closed slot is closed, when the server says.
  final String? reason;

  @override
  List<Object?> get props => <Object?>[
    start,
    end,
    state,
    price,
    bookingId,
    reason,
    booking,
  ];
}

/// One court's slots from the server: a week for the Week table, or one day
/// ([type] `day`) for the Day board.
class OpsCourtWeekAvailability extends Equatable {
  const OpsCourtWeekAvailability({
    required this.courtId,
    required this.weekStart,
    this.days = const <String, List<OpsServerSlot>>{},
    this.fetchedAt,
    this.type = OpsAvailabilityResponseType.week,
  });

  final int courtId;

  /// The first day covered — the week's Sunday, or the day itself.
  final DateTime weekStart;

  /// When the server answered (Kathmandu time).
  final DateTime? fetchedAt;

  /// What was asked for. A day answer covers one date only, so it is kept
  /// apart from a week that starts on the same date.
  final OpsAvailabilityResponseType type;

  static String keyOf(
    int courtId,
    DateTime weekStart, [
    OpsAvailabilityResponseType type = OpsAvailabilityResponseType.week,
  ]) => type == OpsAvailabilityResponseType.day
      ? '$courtId|${isoDate(weekStart)}|day'
      : '$courtId|${isoDate(weekStart)}';

  String get key => keyOf(courtId, weekStart, type);

  /// `yyyy-MM-dd` → that day's slots, sorted by start. A day the server did
  /// not report is missing; the table works it out on the device instead.
  final Map<String, List<OpsServerSlot>> days;

  bool isFor(int courtId, DateTime weekStart) =>
      this.courtId == courtId && isSameDay(this.weekStart, weekStart);

  @override
  List<Object?> get props => <Object?>[
    courtId,
    weekStart,
    days,
    fetchedAt,
    type,
  ];
}

/// Everything the Day board shows for one date, from a single
/// `GET /court-availability-slots?start_date=&type=day`: every court of every
/// venue the vendor has, each court's slots, and the bookings on them.
class OpsDayAvailability extends Equatable {
  const OpsDayAvailability({
    required this.date,
    this.courts = const <OpsCourt>[],
    this.slots = const <int, OpsCourtWeekAvailability>{},
    this.bookings = const <BookingModel>[],
  });

  final DateTime date;

  /// In the server's order. They carry no schedule of their own — the
  /// server's slots are the schedule.
  final List<OpsCourt> courts;

  /// Court id → its day (`type` day).
  final Map<int, OpsCourtWeekAvailability> slots;

  /// Every booking the slots carry, once each.
  final List<BookingModel> bookings;

  @override
  List<Object?> get props => <Object?>[date, courts, slots, bookings];
}

/// One cell of the week table: what one court's slot at one time looks like
/// on one day.
class OpsWeekCell extends Equatable {
  const OpsWeekCell({
    required this.kind,
    this.cell,
    this.continuation = false,
    this.note,
  });

  /// No slot at this time on this day (outside hours, or the day has fewer
  /// slots).
  static const OpsWeekCell none = OpsWeekCell(kind: null);

  /// Null when there is no slot here.
  final OpsCellKind? kind;

  /// The board cell behind it: the free slot, or the booking covering it.
  final OpsCell? cell;

  /// The booking started in an earlier row — shown quieter so one booking
  /// reads as one.
  final bool continuation;

  /// Why a closed day or slot is closed.
  final String? note;

  @override
  List<Object?> get props => <Object?>[kind, cell, continuation, note];
}

/// A court's week: one row per slot start time, one column per day.
class OpsWeekTable extends Equatable {
  const OpsWeekTable({
    required this.court,
    required this.days,
    required this.rows,
    required this.cells,
    required this.closedDays,
    this.todayIndex,
    this.nowMinute,
    this.rowEnds = const <int, int>{},
    this.live = false,
  });

  final OpsCourt court;

  /// Seven days, Sunday first.
  final List<DateTime> days;

  /// Slot start minutes, in order — the union across the week, since pricing
  /// windows can differ by weekday.
  final List<int> rows;

  /// `cells[row][day]`.
  final List<List<OpsWeekCell>> cells;

  /// Day index → why the court is closed that whole day.
  final Map<int, String> closedDays;

  /// Index of today in [days], when this week contains it.
  final int? todayIndex;
  final int? nowMinute;

  /// Row start → end, where the server's slots set it.
  final Map<int, int> rowEnds;

  /// Built from the server's slots rather than the court's schedule alone.
  final bool live;

  /// Where the row starting at [start] ends.
  int endOf(int start) => rowEnds[start] ?? start + court.slotMinutes;

  int get freeCount => cells.fold<int>(
    0,
    (int sum, List<OpsWeekCell> row) =>
        sum +
        row.where((OpsWeekCell c) => c.kind == OpsCellKind.available).length,
  );

  @override
  List<Object?> get props => <Object?>[
    court,
    days,
    rows,
    cells,
    closedDays,
    todayIndex,
    nowMinute,
    rowEnds,
    live,
  ];
}

/// Builds [court]'s week from [weekStart] using the same rules as the day
/// board, so a slot reads the same in both views.
///
/// Days [server] reports are built from the server's slots instead; the
/// device's bookings still supply who is booked, so a booked slot opens its
/// booking. Days it does not report fall back to the court's schedule.
OpsWeekTable buildWeekTable({
  required OpsCourt court,
  required List<BookingModel> bookings,
  required DateTime weekStart,
  required DateTime today,
  required int nowMinute,
  OpsCourtWeekAvailability? server,
}) {
  final Map<String, List<OpsServerSlot>> serverDays =
      server != null && server.isFor(court.id, weekStart)
      ? server.days
      : const <String, List<OpsServerSlot>>{};
  final List<DateTime> days = <DateTime>[
    for (int i = 0; i < 7; i++)
      DateTime(weekStart.year, weekStart.month, weekStart.day + i),
  ];
  final List<OpsCourtRow> dayRows = <OpsCourtRow>[
    for (final DateTime day in days)
      if (serverDays[isoDate(day)] case final List<OpsServerSlot> slots)
        _serverDayRow(
          court: court,
          slots: slots,
          bookings: bookings,
          date: day,
          today: today,
          nowMinute: nowMinute,
        )
      else
        buildOpsBoard(
              courts: <OpsCourt>[court],
              bookings: bookings
                  .where((BookingModel b) => b.courtId == court.id)
                  .toList(),
              date: day,
              today: today,
              nowMinute: nowMinute,
            ).venues.firstOrNull?.courts.firstOrNull ??
            OpsCourtRow(court: court, cells: const <OpsCell>[]),
  ];

  final Set<int> starts = <int>{};
  final Map<int, int> rowEnds = <int, int>{};
  final Map<int, String> closedDays = <int, String>{};
  for (int d = 0; d < 7; d++) {
    final OpsCourtRow row = dayRows[d];
    if (row.closedReason != null) closedDays[d] = row.closedReason!;
    final List<OpsServerSlot>? live = serverDays[isoDate(days[d])];
    if (live != null) {
      for (final OpsServerSlot s in live) {
        starts.add(s.start);
        rowEnds.putIfAbsent(s.start, () => s.end);
      }
      continue;
    }
    for (final OpsSlot s in court.scheduleFor(days[d]).slots) {
      starts.add(s.start);
    }
    for (final OpsClosure c in court.hourlyClosuresOn(days[d])) {
      // Closed windows still get rows, so the closure shows in place.
      for (int t = c.start!; t < c.end!; t += court.slotMinutes) {
        starts.add(t);
      }
    }
  }
  final List<int> rows = starts.toList()..sort();

  final List<List<OpsWeekCell>> cells = <List<OpsWeekCell>>[
    for (final int t in rows)
      <OpsWeekCell>[
        for (int d = 0; d < 7; d++)
          _weekCell(
            dayRows[d],
            t,
            rowEnds[t] ?? t + court.slotMinutes,
            closedDays[d],
          ),
      ],
  ];

  final int todayIndex = days.indexWhere((DateTime d) => isSameDay(d, today));
  return OpsWeekTable(
    court: court,
    days: days,
    rows: rows,
    cells: cells,
    closedDays: closedDays,
    todayIndex: todayIndex < 0 ? null : todayIndex,
    nowMinute: todayIndex < 0 ? null : nowMinute,
    rowEnds: rowEnds,
    live: serverDays.isNotEmpty,
  );
}

/// [court]'s [date] from the server's [slots]. The device's bookings, and the
/// ones the server sends with its slots, are laid in at their real times, so
/// a booked slot opens its booking; a slot the server calls booked or held
/// with no booking to show is drawn closed with that reason.
OpsCourtRow _serverDayRow({
  required OpsCourt court,
  required List<OpsServerSlot> slots,
  required List<BookingModel> bookings,
  required DateTime date,
  required DateTime today,
  required int nowMinute,
}) {
  final String dateKey = isoDate(date);
  if (slots.isEmpty) {
    return OpsCourtRow(
      court: court,
      cells: const <OpsCell>[],
      closedReason: 'No slots',
    );
  }
  final bool isToday = isSameDay(date, today);
  final bool isPastDate = date.isBefore(today) && !isToday;

  // The device's bookings, then any the server sent with its slots that the
  // device has not loaded (another staff member's, or outside the page).
  final Set<int> known = <int>{for (final BookingModel b in bookings) b.id};
  final List<BookingModel> all = <BookingModel>[
    ...bookings,
    for (final OpsServerSlot slot in slots)
      if (slot.booking case final BookingModel b when known.add(b.id)) b,
  ];
  final List<(int, int, BookingModel)> booked = <(int, int, BookingModel)>[
    for (final BookingModel b in all)
      if (isActiveBooking(b) && b.courtId == court.id)
        for (final (int s, int e) in bookingIntervalsOn(b, dateKey)) (s, e, b),
  ];

  final List<OpsCell> cells = <OpsCell>[];
  int sellable = 0;
  for (final OpsServerSlot slot in slots) {
    if (slot.state != OpsServerSlotState.closed) {
      sellable += slot.end - slot.start;
    }
    // A booking the device has is drawn as its own block below.
    if (booked.any(
      ((int, int, BookingModel) b) =>
          overlaps(slot.start, slot.end, b.$1, b.$2),
    )) {
      continue;
    }
    final bool elapsed = isPastDate || (isToday && slot.start < nowMinute);
    final (OpsCellKind kind, String? note) = switch (slot.state) {
      OpsServerSlotState.available when elapsed => (OpsCellKind.past, null),
      OpsServerSlotState.available => (OpsCellKind.available, null),
      OpsServerSlotState.past => (OpsCellKind.past, null),
      OpsServerSlotState.booked => (
        OpsCellKind.closed,
        slot.reason ?? 'Booked',
      ),
      OpsServerSlotState.held => (OpsCellKind.closed, slot.reason ?? 'On hold'),
      OpsServerSlotState.closed => (
        OpsCellKind.closed,
        slot.reason ?? 'Closed',
      ),
    };
    cells.add(
      OpsCell(
        courtId: court.id,
        venueId: court.venueId,
        date: dateKey,
        start: slot.start,
        end: slot.end,
        kind: kind,
        price: slot.price ?? court.basePrice,
        note: note,
      ),
    );
  }
  for (final (int s, int e, BookingModel b) in booked) {
    cells.add(
      OpsCell(
        courtId: court.id,
        venueId: court.venueId,
        date: dateKey,
        start: s,
        end: e,
        kind: OpsCellKind.booked,
        booking: b,
        phase: phaseOf(
          b,
          start: s,
          end: e,
          nowMinute: isToday ? nowMinute : null,
        ),
        payment: paymentStateOf(b),
      ),
    );
  }
  cells.sort((OpsCell a, OpsCell b) => a.start.compareTo(b.start));
  return OpsCourtRow(court: court, cells: cells, sellableMinutes: sellable);
}

OpsWeekCell _weekCell(OpsCourtRow row, int start, int end, String? dayClosed) {
  if (dayClosed != null) {
    return OpsWeekCell(kind: OpsCellKind.closed, note: dayClosed);
  }
  // A booking wins over anything else it overlaps: it is what is really
  // happening on the court at that time.
  OpsCell? hit;
  for (final OpsCell c in row.cells) {
    if (!overlaps(c.start, c.end, start, end)) continue;
    if (c.kind == OpsCellKind.booked) {
      hit = c;
      break;
    }
    if (c.start == start || hit == null) hit = c;
  }
  if (hit == null) return OpsWeekCell.none;
  return OpsWeekCell(
    kind: hit.kind,
    cell: hit,
    continuation: hit.kind == OpsCellKind.booked && hit.start < start,
    note: hit.note,
  );
}

// ───────────────────────────── Court summary ─────────────────────────────

/// What a court's day looks like at a glance, for the Day view's court
/// cards: how full it is, the next slot that can be sold, and the booking on
/// court now or next.
class OpsCourtDaySummary extends Equatable {
  const OpsCourtDaySummary({
    required this.court,
    required this.freeSlots,
    required this.bookedMinutes,
    required this.sellableMinutes,
    this.nextFree,
    this.current,
    this.next,
    this.closedReason,
  });

  final OpsCourt court;
  final int freeSlots;
  final int bookedMinutes;
  final int sellableMinutes;

  /// The earliest slot still bookable.
  final OpsCell? nextFree;

  /// The booking on court right now (today only).
  final OpsCell? current;

  /// The next booking to start after now (or the day's first, on a future
  /// date).
  final OpsCell? next;

  /// Set when the court is closed all day.
  final String? closedReason;

  double get occupancy => sellableMinutes <= 0
      ? 0
      : (bookedMinutes / sellableMinutes).clamp(0, 1).toDouble();

  bool get isClosed => closedReason != null;
  bool get isFull => !isClosed && freeSlots == 0 && sellableMinutes > 0;

  @override
  List<Object?> get props => <Object?>[
    court,
    freeSlots,
    bookedMinutes,
    sellableMinutes,
    nextFree,
    current,
    next,
    closedReason,
  ];
}

/// Summarises one court's row of the day board. [nowMinute] is null when the
/// board is not today; on a past date nothing is "now" or "next".
OpsCourtDaySummary summarizeCourtDay(
  OpsCourtRow row, {
  int? nowMinute,
  bool isPastDate = false,
}) {
  int free = 0;
  int booked = 0;
  OpsCell? nextFree;
  OpsCell? current;
  OpsCell? next;
  for (final OpsCell c in row.cells) {
    switch (c.kind) {
      case OpsCellKind.available:
        free++;
        nextFree ??= c;
      case OpsCellKind.booked:
        booked += c.minutes;
        if (isPastDate) break;
        final int now = nowMinute ?? -1;
        if (now >= c.start && now < c.end) {
          current ??= c;
        } else if (c.start >= now) {
          next ??= c;
        }
      case OpsCellKind.closed:
      case OpsCellKind.past:
        break;
    }
  }
  return OpsCourtDaySummary(
    court: row.court,
    freeSlots: free,
    bookedMinutes: booked,
    sellableMinutes: row.sellableMinutes,
    nextFree: nextFree,
    current: current,
    next: next,
    closedReason: row.closedReason,
  );
}
