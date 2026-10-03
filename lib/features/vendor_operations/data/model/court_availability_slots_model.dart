import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Maps a `GET /court-availability-slots` response to
/// [OpsCourtWeekAvailability].
///
/// Accepts the day list under `data` directly or under `days`, `dates`,
/// `week`, `availability` or `slots`; days as a list of `{date, slots}` or a
/// `date → slots` map; or one flat slot list where each slot carries its own
/// `date`. A slot without a readable start time is skipped.
///
/// Staging answers with `data.days[].slots[]` (a sample is in
/// `test/vendor_operations/court_week_slots_test.dart`); `data.grid` repeats
/// the same slots keyed by time and is not read.
abstract final class CourtAvailabilitySlotsModel {
  static const List<String> _dayListKeys = <String>[
    'days',
    'dates',
    'week',
    'availability',
    'availabilities',
    'slots',
    'data',
  ];

  static OpsCourtWeekAvailability fromResponse(
    dynamic payload, {
    required int courtId,
    DateTime? start,
    DateTime? weekStart,
    OpsAvailabilityResponseType type = OpsAvailabilityResponseType.week,
    DateTime? fetchedAt,
  }) {
    final DateTime anchor = start ?? weekStart!;
    final Map<String, List<OpsServerSlot>> days =
        <String, List<OpsServerSlot>>{};
    _collect(
      _unwrap(payload),
      days,
      date: type == OpsAvailabilityResponseType.day ? isoDate(anchor) : null,
      depth: 0,
    );
    for (final List<OpsServerSlot> list in days.values) {
      list.sort(
        (OpsServerSlot a, OpsServerSlot b) => a.start.compareTo(b.start),
      );
    }
    return OpsCourtWeekAvailability(
      courtId: courtId,
      weekStart: anchor,
      fetchedAt: fetchedAt,
      days: <String, List<OpsServerSlot>>{
        for (final MapEntry<String, List<OpsServerSlot>> e in days.entries)
          e.key: List<OpsServerSlot>.unmodifiable(e.value),
      },
    );
  }

  /// Maps a `type=day` response — every court of every venue the vendor has,
  /// under `data.venues[].courts[]` — to the whole Day board: the courts,
  /// each court's slots on [date], and the bookings those slots carry. A
  /// court listed with no slots gets an empty day (the server says it has
  /// nothing to sell).
  ///
  /// A court's slots are read from `days[].slots[]` when the server sends
  /// days, else from its flat `slots[]` — never both, since they repeat the
  /// same slots.
  static OpsDayAvailability fromDayResponse(
    dynamic payload, {
    required DateTime date,
    DateTime? fetchedAt,
  }) {
    final String dayKey = isoDate(date);
    final List<OpsCourt> courts = <OpsCourt>[];
    final Map<int, OpsCourtWeekAvailability> out =
        <int, OpsCourtWeekAvailability>{};
    final Map<int, BookingModel> bookings = <int, BookingModel>{};
    for (final Map<String, dynamic> court in _dayCourts(payload)) {
      final int? courtId = _int(court['id'] ?? court['court_id']);
      final int? venueId = _int(court['venue_id']);
      if (courtId == null || venueId == null || out.containsKey(courtId)) {
        continue;
      }
      courts.add(
        OpsCourt(
          id: courtId,
          venueId: venueId,
          venueName: _string(court['venue_name']) ?? 'Venue $venueId',
          name:
              _string(court['name'] ?? court['court_name']) ?? 'Court $courtId',
          slotMinutes:
              _int(court['slot_duration_minutes']) ?? kDefaultSlotMinutes,
          basePrice: _double(court['base_price']),
        ),
      );
      final Map<String, List<OpsServerSlot>> days =
          <String, List<OpsServerSlot>>{dayKey: <OpsServerSlot>[]};
      final dynamic byDay = court['days'];
      _collect(
        byDay is List && byDay.isNotEmpty ? byDay : court['slots'],
        days,
        date: dayKey,
        depth: 0,
      );
      for (final List<OpsServerSlot> list in days.values) {
        for (final OpsServerSlot slot in list) {
          if (slot.booking case final BookingModel b) bookings[b.id] = b;
        }
      }
      out[courtId] = OpsCourtWeekAvailability(
        courtId: courtId,
        weekStart: DateTime(date.year, date.month, date.day),
        fetchedAt: fetchedAt,
        type: OpsAvailabilityResponseType.day,
        days: <String, List<OpsServerSlot>>{
          for (final MapEntry<String, List<OpsServerSlot>> e in days.entries)
            e.key: List<OpsServerSlot>.unmodifiable(
              e.value..sort(
                (OpsServerSlot a, OpsServerSlot b) =>
                    a.start.compareTo(b.start),
              ),
            ),
        },
      );
    }
    return OpsDayAvailability(
      date: DateTime(date.year, date.month, date.day),
      courts: List<OpsCourt>.unmodifiable(courts),
      slots: Map<int, OpsCourtWeekAvailability>.unmodifiable(out),
      bookings: List<BookingModel>.unmodifiable(bookings.values),
    );
  }

  /// Courts under `data.venues[].courts[]`, or `data.courts[]`.
  static Iterable<Map<String, dynamic>> _dayCourts(dynamic payload) sync* {
    dynamic data = payload;
    while (data is Map && data['venues'] == null && data['courts'] == null) {
      data = data['data'];
    }
    if (data is! Map) return;
    Iterable<Map<String, dynamic>> mapsOf(dynamic v) => v is List
        ? v.whereType<Map>().map(Map<String, dynamic>.from)
        : const <Map<String, dynamic>>[];
    for (final Map<String, dynamic> venue in mapsOf(data['venues'])) {
      for (final Map<String, dynamic> court in mapsOf(venue['courts'])) {
        yield <String, dynamic>{
          'venue_id': venue['id'],
          ...court,
          'venue_name': venue['name'] ?? venue['futsal_name'],
        };
      }
    }
    yield* mapsOf(data['courts']);
  }

  /// Strips `{status, message, data: …}` envelopes.
  static dynamic _unwrap(dynamic payload) {
    dynamic current = payload;
    while (current is Map &&
        current['data'] != null &&
        !_hasAnyKey(current, const <String>['days', 'dates', 'week'])) {
      current = current['data'];
    }
    return current;
  }

  static void _collect(
    dynamic node,
    Map<String, List<OpsServerSlot>> out, {
    required String? date,
    required int depth,
  }) {
    if (depth > 6 || node == null) return;
    if (node is List) {
      for (final dynamic item in node) {
        _collect(item, out, date: date, depth: depth + 1);
      }
      return;
    }
    if (node is! Map) return;
    final Map<String, dynamic> map = Map<String, dynamic>.from(node);

    final String? ownDate = _date(
      map['date'] ?? map['booking_date'] ?? map['day_date'],
    );
    final String? day = ownDate ?? date;

    // A slot: has a start time.
    final int? start = _minute(
      map['start_time'] ?? map['startTime'] ?? map['from'] ?? map['time'],
    );
    if (start != null && day != null) {
      out.putIfAbsent(day, () => <OpsServerSlot>[]).add(_slot(map, start));
      return;
    }

    // A day: a date with a nested slot list (possibly empty).
    for (final String key in _dayListKeys) {
      final dynamic nested = map[key];
      if (nested is List || nested is Map) {
        if (day != null && nested is List) {
          out.putIfAbsent(day, () => <OpsServerSlot>[]);
        }
        _collect(nested, out, date: day, depth: depth + 1);
        return;
      }
    }

    // `date → slots`.
    for (final MapEntry<String, dynamic> e in map.entries) {
      final String? keyDate = _date(e.key);
      if (keyDate != null && (e.value is List || e.value is Map)) {
        out.putIfAbsent(keyDate, () => <OpsServerSlot>[]);
        _collect(e.value, out, date: keyDate, depth: depth + 1);
      }
    }
  }

  static OpsServerSlot _slot(Map<String, dynamic> map, int start) {
    int? end = _minute(map['end_time'] ?? map['endTime'] ?? map['to']);
    if (end == null || end <= start) {
      end = (start + 60).clamp(0, kMinutesPerDay);
    }
    final dynamic booking = map['booking'];
    final dynamic detail = map['booking_detail'];
    final dynamic breakdown = map['price_breakdown'];
    final BookingModel? attached = _booking(
      detail is Map ? detail : booking,
      slot: map,
    );
    final OpsServerSlotState state =
        attached != null && isActiveBooking(attached)
        ? OpsServerSlotState.booked
        : _state(map);
    return OpsServerSlot(
      start: start,
      end: end,
      state: state,
      price: _double(
        map['price'] ??
            (breakdown is Map ? breakdown['amount'] : null) ??
            map['amount'] ??
            map['rate'] ??
            map['slot_price'],
      ),
      bookingId: _int(
        map['booking_id'] ??
            map['bookingId'] ??
            (booking is Map ? booking['id'] ?? booking['booking_id'] : null) ??
            (detail is Map ? detail['id'] ?? detail['booking_id'] : null),
      ),
      // The server's own cell title reads best ("Maintenance", a customer's
      // name); its reason is a code (`past_slot_not_bookable`).
      reason: state == OpsServerSlotState.available
          ? null
          : _string(map['cell_title']) ??
                _humanize(
                  map['reason'] ??
                      map['availability_reason'] ??
                      map['closed_reason'] ??
                      map['note'],
                ),
      booking: attached,
    );
  }

  /// The booking a slot carries (`booking_detail`, else `booking`), read the
  /// way the bookings list reads one. Its `slots` are the booking's slot rows
  /// — a booking over several slots is not one block — and the slot fills in
  /// the court and venue when the booking does not name them.
  static BookingModel? _booking(
    dynamic json, {
    required Map<String, dynamic> slot,
  }) {
    if (json is! Map) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(json);
    if (_int(map['id'] ?? map['booking_id']) == null) return null;
    try {
      return BookingModel.fromJson(<String, dynamic>{
        'court_id': slot['court_id'],
        'venue_id': slot['venue_id'],
        if (map['booking_slots'] == null && map['slots'] is List)
          'booking_slots': <Map<String, dynamic>>[
            for (final dynamic row in map['slots'] as List)
              if (row is Map)
                <String, dynamic>{
                  'id': row['id'],
                  'slot_date': row['date'] ?? map['booking_date'],
                  'slot_start': row['start_time'],
                  'slot_end': row['end_time'],
                  'slot_price': row['price'],
                  'status': row['status'],
                },
          ],
        ...map,
      });
    } catch (_) {
      return null;
    }
  }

  /// `cell_type` says how the cell is drawn and is the most specific — a
  /// past slot is `status: unavailable` but `cell_type: past`. Then
  /// `status`, then boolean flags. A slot this vendor holds is still theirs
  /// to book.
  static OpsServerSlotState _state(Map<String, dynamic> map) {
    if (_bool(map['held_by_me']) == true) return OpsServerSlotState.available;
    for (final dynamic raw in <dynamic>[
      map['cell_type'],
      map['status'],
      map['slot_status'],
      map['availability_status'],
      map['state'],
    ]) {
      final OpsServerSlotState? known = _stateOf(raw);
      if (known != null) return known;
    }
    return _stateFromFlags(map);
  }

  static OpsServerSlotState? _stateOf(dynamic value) {
    final String raw = (value ?? '').toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
    switch (raw) {
      case 'available':
      case 'open':
      case 'free':
        return OpsServerSlotState.available;
      case 'booked':
      case 'reserved':
      case 'fully_booked':
      case 'confirmed':
      case 'pending':
        return OpsServerSlotState.booked;
      case 'held':
      case 'hold':
      case 'on_hold':
      case 'locked':
        return OpsServerSlotState.held;
      case 'past':
      case 'expired':
      case 'elapsed':
        return OpsServerSlotState.past;
      case 'closed':
      case 'blocked':
      case 'unavailable':
      case 'maintenance':
      case 'holiday':
        return OpsServerSlotState.closed;
    }
    return null;
  }

  static OpsServerSlotState _stateFromFlags(Map<String, dynamic> map) {
    if (_bool(map['is_booked'] ?? map['booked']) == true) {
      return OpsServerSlotState.booked;
    }
    if (_bool(map['is_held'] ?? map['on_hold']) == true) {
      return OpsServerSlotState.held;
    }
    if (_bool(map['is_past'] ?? map['past']) == true) {
      return OpsServerSlotState.past;
    }
    final bool? available = _bool(
      map['is_available'] ?? map['available'] ?? map['isAvailable'],
    );
    if (available == false) return OpsServerSlotState.closed;
    return OpsServerSlotState.available;
  }

  /// `past_slot_not_bookable` → `Past slot not bookable`.
  static String? _humanize(dynamic v) {
    final String? text = _string(v)?.replaceAll(RegExp(r'[_\s]+'), ' ');
    if (text == null) return null;
    return text[0].toUpperCase() + text.substring(1);
  }

  static bool _hasAnyKey(Map<dynamic, dynamic> map, List<String> keys) =>
      keys.any(map.containsKey);

  static String? _date(dynamic v) {
    final String text = v?.toString().trim() ?? '';
    final RegExpMatch? m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(text);
    return m?.group(0);
  }

  static int? _minute(dynamic v) {
    final String text = v?.toString().trim() ?? '';
    if (text.isEmpty) return null;
    // `2026-09-27 18:00:00` / ISO timestamps: keep the time part.
    final RegExpMatch? stamp = RegExp(
      r'[T\s](\d{1,2}:\d{2}(?::\d{2})?)',
    ).firstMatch(text);
    return parseMinuteOfDay(stamp?.group(1) ?? text);
  }

  static double? _double(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '').trim());
  }

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static String? _string(dynamic v) {
    final String text = v?.toString().trim() ?? '';
    return text.isEmpty ? null : text;
  }

  static bool? _bool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    if (v is num) return v != 0;
    return switch (v.toString().trim().toLowerCase()) {
      'true' || '1' || 'yes' => true,
      'false' || '0' || 'no' => false,
      _ => null,
    };
  }
}
