import 'package:hamro_futsal/features/futsal_details/data/model/booking_quote_model.dart';

class BookingHoldRequest {
  const BookingHoldRequest({
    required this.venueId,
    required this.courtId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
  });

  final int? venueId;
  final int? courtId;
  final String bookingDate;
  final String startTime;
  final String endTime;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'venue_id': venueId,
    'court_id': courtId,
    'booking_date': bookingDate,
    'start_time': apiHourMinute(startTime),
    'end_time': apiHourMinute(endTime),
  };

  static String apiHourMinute(String time) {
    final RegExpMatch? m = RegExp(
      r'(\d{1,2}):(\d{2})(?::\d{2})?\s*([AaPp][Mm])?',
    ).firstMatch(time.trim());
    if (m == null) return time.trim();
    int hour = int.parse(m.group(1)!);
    final String? meridiem = m.group(3)?.toLowerCase();
    if (meridiem == 'pm' && hour < 12) hour += 12;
    if (meridiem == 'am' && hour == 12) hour = 0;
    // `H:i` has no `24:00`; a range ending at midnight ends at `23:59`.
    if (hour >= 24) return '23:59';
    return '${hour.toString().padLeft(2, '0')}:${m.group(2)}';
  }
}

class BookingHoldModel {
  const BookingHoldModel({
    this.id,
    this.holdToken,
    this.venueId,
    this.courtId,
    this.bookingDate,
    this.bookingDates = const <String>[],
    this.startTime,
    this.endTime,
    this.status,
    this.holdStatus,
    this.reason,
    this.isRecurring,
    this.repeatWeeks,
    this.recurrenceType,
    this.recurrenceInterval,
    this.heldByMe,
    this.expiresAt,
    this.step,
    this.quote,
    this.quoteIsShared = false,
    this.bookingQuote,
  });

  final String? id;

  final String? holdToken;

  final int? venueId;
  final int? courtId;
  final String? bookingDate;

  final List<String> bookingDates;

  final String? startTime;
  final String? endTime;

  final String? status;

  final String? holdStatus;

  final String? reason;

  final bool? isRecurring;

  final int? repeatWeeks;

  final String? recurrenceType;

  final int? recurrenceInterval;

  final bool? heldByMe;

  final String? expiresAt;

  final String? step;

  final BookingQuoteModel? quote;

  final bool quoteIsShared;

  final BookingQuoteModel? bookingQuote;

  bool get hasToken => (holdToken ?? '').isNotEmpty;

  bool get hasId => (id ?? '').isNotEmpty;

  DateTime? get expiresAtDateTime =>
      expiresAt == null ? null : DateTime.tryParse(expiresAt!);

  static List<BookingHoldModel> listFromResponse(dynamic payload) {
    dynamic data = payload;
    Map<dynamic, dynamic>? sharedQuote;
    for (int depth = 0; depth < 5 && data is Map; depth++) {
      final Map<dynamic, dynamic> map = data;
      if (map['quote'] is Map) sharedQuote = map['quote'] as Map;
      // `data.items` pairs each hold with its quote (`{hold, quote}`), while
      // `data.holds` beside it lists the bare holds without prices. Reading
      // `holds` first left every hold without a quote: "Advance to pay" read
      // 0, then "—".
      if (map['items'] is List &&
          (map['items'] as List).any(
            (dynamic e) => e is Map && (e['hold'] is Map || e['quote'] is Map),
          )) {
        data = map['items'];
        break;
      }
      if (map['holds'] is List) {
        data = map['holds'];
        break;
      }
      if (map['hold'] is List) {
        data = map['hold'];
        break;
      }
      if (map['hold'] != null || map['hold_token'] != null) break;
      data = map['data'];
    }
    if (data is List) {
      return <BookingHoldModel>[
        for (final dynamic item in data)
          if (item is Map)
            BookingHoldModel.fromResponse(
              sharedQuote != null && item['quote'] is! Map
                  ? <dynamic, dynamic>{...item, 'quote': sharedQuote}
                  : item,
              quoteIsShared: sharedQuote != null && item['quote'] is! Map,
              bookingQuote: sharedQuote,
            ),
      ];
    }
    return <BookingHoldModel>[BookingHoldModel.fromResponse(payload)];
  }

  factory BookingHoldModel.fromResponse(
    dynamic payload, {
    bool quoteIsShared = false,
    Map<dynamic, dynamic>? bookingQuote,
  }) {
    // The hold fields live under `data.hold` (newer shape) or directly under
    // `data` (older shape); the quote is a sibling under `data`.
    final Map<String, dynamic> envelope = _envelope(payload);
    final Map<String, dynamic> map = _mapOf(envelope['hold']) ?? envelope;
    final Map<String, dynamic> metadata = _mapOf(map['metadata']) ?? const {};
    final Map<String, dynamic>? quoteJson = _mapOf(envelope['quote']);
    return BookingHoldModel(
      quote: quoteJson == null ? null : BookingQuoteModel.fromJson(quoteJson),
      quoteIsShared: quoteIsShared && quoteJson != null,
      bookingQuote: bookingQuote == null
          ? null
          : BookingQuoteModel.fromJson(Map<String, dynamic>.from(bookingQuote)),
      id: _asString(map['id']),
      holdToken: _asString(
        map['hold_token'] ?? map['holdToken'] ?? map['token'],
      ),
      venueId: _asInt(map['venue_id'] ?? map['venueId']),
      courtId: _asInt(map['court_id'] ?? map['courtId']),
      bookingDate: _asString(map['booking_date'] ?? map['bookingDate']),
      bookingDates: _asStringList(
        map['booking_dates'] ??
            map['bookingDates'] ??
            metadata['booking_dates'],
      ),
      startTime: _asString(map['start_time'] ?? map['startTime']),
      endTime: _asString(map['end_time'] ?? map['endTime']),
      status: _asString(map['status']),
      holdStatus: _asString(map['hold_status'] ?? map['holdStatus']),
      reason: _asString(map['reason']),
      isRecurring: _asBool(map['is_recurring'] ?? map['isRecurring']),
      repeatWeeks: _asInt(map['repeat_weeks'] ?? map['repeatWeeks']),
      recurrenceType: _asString(
        map['recurrence_type'] ??
            map['recurrenceType'] ??
            metadata['recurrence_type'],
      ),
      recurrenceInterval: _asInt(
        map['recurrence_interval'] ??
            map['recurrenceInterval'] ??
            metadata['recurrence_interval'],
      ),
      heldByMe: _asBool(map['held_by_me'] ?? map['heldByMe']),
      expiresAt: _asString(map['expires_at'] ?? map['expiresAt']),
      step: _asString(map['step']),
    );
  }
}

Map<String, dynamic> _envelope(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 5 && current is Map; depth++) {
    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final bool stop =
        map.containsKey('hold') ||
        map.containsKey('quote') ||
        map.containsKey('hold_token') ||
        map.containsKey('holdToken') ||
        map.containsKey('token');
    final dynamic nested = map['data'] ?? map['booking_hold'];
    if (stop || nested is! Map) return map;
    current = nested;
  }
  return current is Map
      ? Map<String, dynamic>.from(current)
      : <String, dynamic>{};
}

Map<String, dynamic>? _mapOf(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;

String? _asString(dynamic value) {
  final String text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic e) => e?.toString().trim() ?? '')
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _asBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final String text = value.toString().trim().toLowerCase();
  if (text == 'true' || text == '1' || text == 'yes') return true;
  if (text == 'false' || text == '0' || text == 'no') return false;
  return null;
}
