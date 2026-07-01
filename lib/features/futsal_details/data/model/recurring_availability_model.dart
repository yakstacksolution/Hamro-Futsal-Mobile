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
  });

  final List<AvailabilitySession> sessions;

  int get totalCount => sessions.length;
  int get availableCount =>
      sessions.where((AvailabilitySession s) => s.isAvailable).length;
  List<AvailabilitySession> get unavailableSessions =>
      sessions.where((AvailabilitySession s) => !s.isAvailable).toList();

  bool get hasSessions => sessions.isNotEmpty;
  bool get allAvailable => hasSessions && unavailableSessions.isEmpty;

  factory RecurringAvailabilityModel.fromResponse(dynamic payload) {
    final List<dynamic> items = _sessionListFrom(payload);
    final List<AvailabilitySession> sessions = items
        .whereType<Map>()
        .map(
          (Map item) =>
              AvailabilitySession.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    return RecurringAvailabilityModel(sessions: sessions);
  }
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
        map['results'];
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
