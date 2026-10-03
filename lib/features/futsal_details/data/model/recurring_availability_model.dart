import 'package:hamro_futsal/features/futsal_details/data/model/time_slot_model.dart';

/// Availability of a single session (one date) for the chosen court & slot.
class AvailabilitySession {
  const AvailabilitySession({
    required this.date,
    this.dateTime,
    this.startTime,
    this.endTime,
    this.status = SlotStatus.available,
    this.reason,
  });

  /// Raw / display date string from the server (e.g. `2025-12-01`).
  final String date;
  final DateTime? dateTime;
  final String? startTime;
  final String? endTime;
  final SlotStatus status;

  /// Optional human reason when unavailable (e.g. `booked`).
  final String? reason;

  bool get isAvailable => status.canSelect;

  /// `yyyy-MM-dd` for this session, whatever shape the server sent the date
  /// in (`2025-12-01`, `2025-12-01T00:00:00Z`, …). Empty when unparseable.
  String get dateKey {
    final DateTime? parsed = dateTime ?? _parseDate(date);
    if (parsed != null) return _dateKey(parsed);
    return date.length >= 10 ? date.substring(0, 10) : date;
  }

  AvailabilitySession _withDate(DateTime value) => AvailabilitySession(
    date: _dateKey(value),
    dateTime: value,
    startTime: startTime,
    endTime: endTime,
    status: status,
    reason: reason,
  );

  factory AvailabilitySession.fromJson(Map<String, dynamic> json) {
    final String? rawDate = _dateStringFrom(json);
    return AvailabilitySession(
      date: rawDate ?? '',
      dateTime: rawDate == null ? null : _parseDate(rawDate),
      startTime: _asString(json['start_time'] ?? json['startTime']),
      endTime: _asString(json['end_time'] ?? json['endTime']),
      status: _statusFrom(json),
      reason: _asString(
        json['reason'] ??
            json['availability_reason'] ??
            json['message'] ??
            json['note'],
      ),
    );
  }

  /// Explicit availability flags win over a `status` string, and only a
  /// status that clearly means "taken" marks the date unavailable.
  ///
  /// [SlotStatus.fromApi] treats every unknown word as unavailable, which is
  /// right for the slot grid but here turned values like `free`, `open` or
  /// `true` into "0 available".
  static SlotStatus _statusFrom(Map<String, dynamic> json) {
    final bool? available = _asBool(
      json['is_available'] ??
          json['isAvailable'] ??
          json['available'] ??
          json['is_bookable'] ??
          json['bookable'],
    );
    if (available == true) return SlotStatus.available;
    if (available == false) return SlotStatus.unavailable;

    final bool? conflict = _asBool(
      json['is_booked'] ??
          json['booked'] ??
          json['has_conflict'] ??
          json['conflict'] ??
          json['is_unavailable'],
    );
    if (conflict == true) return SlotStatus.booked;
    if (conflict == false) return SlotStatus.available;

    final dynamic raw =
        json['status'] ??
        json['availability_status'] ??
        json['availabilityStatus'];
    if (raw is bool) return raw ? SlotStatus.available : SlotStatus.unavailable;
    final String text =
        raw?.toString().trim().toLowerCase().replaceAll(
          RegExp(r'[\s-]+'),
          '_',
        ) ??
        '';
    return switch (text) {
      'booked' ||
      'reserved' ||
      'fully_booked' ||
      'taken' ||
      'conflict' => SlotStatus.booked,
      'closed' || 'holiday' => SlotStatus.closed,
      'unavailable' ||
      'not_available' ||
      'blocked' ||
      'held' ||
      'on_hold' ||
      'false' ||
      '0' => SlotStatus.unavailable,
      _ => SlotStatus.available,
    };
  }
}

class RecurringAvailabilityModel {
  const RecurringAvailabilityModel({
    this.sessions = const <AvailabilitySession>[],
    this.allAvailableFlag,
    this.startTime,
    this.endTime,
  });

  final List<AvailabilitySession> sessions;

  /// The server's own `all_available` verdict, when it sends one. Preferred
  /// over counting [sessions], which can be empty on an all-available response.
  final bool? allAvailableFlag;

  /// Slot window echoed back by `booking_summary`, e.g. `06:00:00`.
  final String? startTime;
  final String? endTime;

  int get totalCount => sessions.length;
  int get availableCount =>
      sessions.where((AvailabilitySession s) => s.isAvailable).length;
  int get unavailableCount => totalCount - availableCount;

  List<AvailabilitySession> get availableSessions =>
      sessions.where((AvailabilitySession s) => s.isAvailable).toList();
  List<AvailabilitySession> get unavailableSessions =>
      sessions.where((AvailabilitySession s) => !s.isAvailable).toList();

  /// `yyyy-MM-dd` keys of the dates the server says are still bookable.
  Set<String> get availableDateKeys => availableSessions
      .map((AvailabilitySession s) => s.dateKey)
      .where((String d) => d.isNotEmpty)
      .toSet();

  Set<String> get unavailableDateKeys => unavailableSessions
      .map((AvailabilitySession s) => s.dateKey)
      .where((String d) => d.isNotEmpty)
      .toSet();

  /// Lines the server's answer up with the full schedule that was asked about.
  ///
  /// The server often reports only the conflicting dates, so a 4-session
  /// request can come back with a single (taken) entry. Counting that list as
  /// the schedule reads "0 available · 1 unavailable". Here every requested
  /// date gets exactly one session, in schedule order: the server's entry when
  /// it sent one, otherwise available.
  ///
  /// When the server named no dates at all, only an `all_available: true`
  /// verdict can be spread over the schedule. A bare `false` says *something*
  /// is taken but not what, so the sessions stay empty and [isUnconfirmed]
  /// tells the UI to warn without inventing per-date counts.
  RecurringAvailabilityModel reconciledWith(List<DateTime> requested) {
    if (requested.isEmpty) return this;

    final Map<String, AvailabilitySession> reported =
        <String, AvailabilitySession>{
          for (final AvailabilitySession s in sessions)
            if (s.dateKey.isNotEmpty) s.dateKey: s,
        };
    if (reported.isEmpty && allAvailableFlag != true) {
      return RecurringAvailabilityModel(
        allAvailableFlag: allAvailableFlag,
        startTime: startTime,
        endTime: endTime,
      );
    }

    const SlotStatus unreported = SlotStatus.available;

    final List<AvailabilitySession> merged = requested
        .map((DateTime date) {
          final DateTime day = DateTime(date.year, date.month, date.day);
          final AvailabilitySession? match = reported[_dateKey(day)];
          if (match != null) return match._withDate(day);
          return AvailabilitySession(
            date: _dateKey(day),
            dateTime: day,
            startTime: startTime,
            endTime: endTime,
            status: unreported,
          );
        })
        .toList(growable: false);

    return RecurringAvailabilityModel(
      sessions: merged,
      allAvailableFlag: allAvailableFlag,
      startTime: startTime,
      endTime: endTime,
    );
  }

  bool get hasSessions => sessions.isNotEmpty;

  /// The server said not every date is free but did not say which.
  bool get isUnconfirmed => !hasSessions && allAvailableFlag == false;

  bool get allAvailable {
    if (hasSessions) return unavailableSessions.isEmpty;
    return allAvailableFlag ?? false;
  }

  /// True only when the server actually reported taken dates — the trigger for
  /// the "continue without these dates?" prompt.
  bool get hasUnavailableDates => unavailableSessions.isNotEmpty;

  factory RecurringAvailabilityModel.fromResponse(dynamic payload) {
    final Map<String, dynamic>? root = _rootMap(payload);
    final bool? allAvailable = _asBool(root?['all_available']);

    final List<AvailabilitySession> itemSessions = _sessionListFrom(payload)
        .whereType<Map>()
        .map(
          (Map item) =>
              AvailabilitySession.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);

    final dynamic rawSummary = root?['booking_summary'];
    final Map<String, dynamic>? summary = rawSummary is Map
        ? Map<String, dynamic>.from(rawSummary)
        : null;

    final String? startTime = _asString(summary?['start_time']);
    final String? endTime = _asString(summary?['end_time']);

    // The summary's split date lists are the server's own verdict per date, so
    // they win over `items` (which may only carry prices or slot rows).
    final bool summaryHasSplit =
        summary != null &&
        (summary['unavailable_dates'] is List ||
            summary['available_dates'] is List);
    final bool itemsHaveDates = itemSessions.any(
      (AvailabilitySession s) => s.dateKey.isNotEmpty,
    );

    if (itemsHaveDates && !summaryHasSplit) {
      return RecurringAvailabilityModel(
        sessions: itemSessions
            .where((AvailabilitySession s) => s.dateKey.isNotEmpty)
            .toList(growable: false),
        allAvailableFlag: allAvailable,
        startTime: startTime,
        endTime: endTime,
      );
    }

    // No per-session `items`: rebuild the sessions from the date lists the
    // summary always carries, so the UI can list what is taken and what is not.
    return RecurringAvailabilityModel(
      sessions: _sessionsFromSummary(
        summary,
        startTime: startTime,
        endTime: endTime,
      ),
      allAvailableFlag: allAvailable,
      startTime: startTime,
      endTime: endTime,
    );
  }
}

List<AvailabilitySession> _sessionsFromSummary(
  Map<String, dynamic>? summary, {
  String? startTime,
  String? endTime,
}) {
  if (summary == null) return const <AvailabilitySession>[];

  final List<String> booking = _dateList(summary['booking_dates']);
  final Set<String> unavailable = _dateList(
    summary['unavailable_dates'],
  ).toSet();
  final List<String> available = _dateList(summary['available_dates']);
  // When only `available_dates` is sent, everything else in the schedule is
  // what is taken.
  final bool onlyAvailableListed =
      summary['unavailable_dates'] is! List &&
      summary['available_dates'] is List;
  final Set<String> availableSet = available.toSet();

  // `booking_dates` is the full schedule; fall back to the two split lists if
  // the server ever omits it.
  final List<String> ordered = booking.isNotEmpty
      ? booking
      : <String>[...available, ...unavailable];
  if (ordered.isEmpty) return const <AvailabilitySession>[];

  return ordered
      .map(
        (String date) => AvailabilitySession(
          date: date,
          dateTime: _parseDate(date),
          startTime: startTime,
          endTime: endTime,
          status:
              unavailable.contains(date) ||
                  (onlyAvailableListed && !availableSet.contains(date))
              ? SlotStatus.booked
              : SlotStatus.available,
        ),
      )
      .toList(growable: false);
}

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

/// Normalised `yyyy-MM-dd` strings from a list of dates, which the server may
/// send as plain strings or as objects (`{date: …, reason: …}`).
List<String> _dateList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic item) {
        final String? raw = item is Map
            ? _dateStringFrom(Map<String, dynamic>.from(item))
            : _asString(item);
        if (raw == null) return null;
        final DateTime? parsed = _parseDate(raw);
        return parsed == null ? raw : _dateKey(parsed);
      })
      .whereType<String>()
      .toList(growable: false);
}

/// The session date from whichever field the server used, falling back to
/// the first value that looks like a date.
String? _dateStringFrom(Map<String, dynamic> json) {
  const List<String> keys = <String>[
    'date',
    'booking_date',
    'session_date',
    'recurring_date',
    'recurring_booking_date',
    'slot_date',
    'start_date',
    'day',
  ];
  for (final String key in keys) {
    final String? value = _asString(json[key]);
    if (value != null && _parseDate(value) != null) return value;
  }
  for (final dynamic value in json.values) {
    if (value is! String) continue;
    if (_parseDate(value) != null) return value.trim();
  }
  return null;
}

final RegExp _isoDate = RegExp(r'^(\d{4})[-/](\d{1,2})[-/](\d{1,2})');
final RegExp _dmyDate = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})');

/// Date-only parse of `2025-12-01`, `2025/12/01`, `2025-12-01T00:00:00Z` or
/// `01-12-2025`. Null for anything else (times, names, ids).
DateTime? _parseDate(String raw) {
  final String text = raw.trim();
  final RegExpMatch? iso = _isoDate.firstMatch(text);
  if (iso != null) {
    return _safeDate(iso.group(1)!, iso.group(2)!, iso.group(3)!);
  }
  final RegExpMatch? dmy = _dmyDate.firstMatch(text);
  if (dmy != null) {
    return _safeDate(dmy.group(3)!, dmy.group(2)!, dmy.group(1)!);
  }
  return null;
}

DateTime? _safeDate(String y, String m, String d) {
  final int year = int.parse(y);
  final int month = int.parse(m);
  final int day = int.parse(d);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return DateTime(year, month, day);
}

/// Unwraps the response down to the map that holds `booking_summary`.
Map<String, dynamic>? _rootMap(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 6 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    if (map.containsKey('booking_summary') ||
        map.containsKey('all_available')) {
      return map;
    }
    final dynamic nested = map['data'];
    if (nested == null) return map;
    current = nested;
  }
  return current is Map ? Map<String, dynamic>.from(current) : null;
}

List<dynamic> _sessionListFrom(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 6 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic list =
        map['sessions'] ??
        map['availability'] ??
        map['availabilities'] ??
        map['dates'] ??
        map['schedule'] ??
        map['schedules'] ??
        map['weeks'] ??
        map['slots'] ??
        map['results'] ??
        map['items'];
    if (list is List) return list;
    final dynamic nested = map['data'];
    if (nested == null) break;
    current = nested;
  }
  if (current is List) return current;
  return const <dynamic>[];
}

String? _asString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String text = value.toString().trim().toLowerCase();
  if (text.isEmpty) return null;
  if (const <String>{'true', '1', 'yes', 'available'}.contains(text)) {
    return true;
  }
  if (const <String>{
    'false',
    '0',
    'no',
    'unavailable',
    'booked',
    'closed',
  }.contains(text)) {
    return false;
  }
  return null;
}
