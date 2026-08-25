import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';

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

  factory AvailabilitySession.fromJson(Map<String, dynamic> json) {
    final String? rawDate = _asString(
      json['date'] ??
          json['booking_date'] ??
          json['session_date'] ??
          json['day'],
    );
    return AvailabilitySession(
      date: rawDate ?? '',
      dateTime: rawDate == null ? null : DateTime.tryParse(rawDate),
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

  static SlotStatus _statusFrom(Map<String, dynamic> json) {
    final dynamic raw =
        json['status'] ??
        json['availability_status'] ??
        json['availabilityStatus'];
    if (raw != null) return SlotStatus.fromApi(raw);
    final bool? available = _asBool(
      json['is_available'] ?? json['isAvailable'] ?? json['available'],
    );
    if (available == true) return SlotStatus.available;
    if (available == false) return SlotStatus.unavailable;
    return SlotStatus.available;
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
      .map((AvailabilitySession s) => s.date)
      .where((String d) => d.isNotEmpty)
      .toSet();

  Set<String> get unavailableDateKeys => unavailableSessions
      .map((AvailabilitySession s) => s.date)
      .where((String d) => d.isNotEmpty)
      .toSet();

  bool get hasSessions => sessions.isNotEmpty;

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

    if (itemSessions.isNotEmpty) {
      return RecurringAvailabilityModel(
        sessions: itemSessions,
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
          dateTime: DateTime.tryParse(date),
          startTime: startTime,
          endTime: endTime,
          status: unavailable.contains(date)
              ? SlotStatus.booked
              : SlotStatus.available,
        ),
      )
      .toList(growable: false);
}

List<String> _dateList(dynamic value) {
  if (value is! List) return const <String>[];
  return value.map(_asString).whereType<String>().toList(growable: false);
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
