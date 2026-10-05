import 'package:hamro_futsal/features/futsal_details/data/model/booking_quote_model.dart';

/// One slot to hold — an item of the `POST /booking-holds` `holds` list.
/// Every session is its own item, with its own `booking_date`.
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

  /// [time] as the API's `H:i` — `18:00` — whether it came as `18:00:00`
  /// (slot responses), `18:00`, `6:00 PM` or a range like `6:00 PM - 7:00 PM`
  /// (its start is used). Anything else is sent as is, for the server to name.
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

/// One hold from `POST /booking-holds`. Mirrors a `hold` object the server
/// returns — its [id] releases it later with `DELETE /booking-holds` — plus
/// the server `quote` (pricing).
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

  /// Server hold id (e.g. `f19071bb-...`).
  final String? id;

  /// The token used to release the hold later.
  final String? holdToken;

  final int? venueId;
  final int? courtId;
  final String? bookingDate;

  /// All held session dates (`yyyy-MM-dd`); single-item for non-recurring holds.
  final List<String> bookingDates;

  final String? startTime;
  final String? endTime;

  /// Slot status, e.g. `unavailable`.
  final String? status;

  /// Hold lifecycle status, e.g. `holding`.
  final String? holdStatus;

  /// Why the slot is held, e.g. `booking_hold`.
  final String? reason;

  /// Whether this hold is for a recurring booking.
  final bool? isRecurring;

  /// Weeks between recurring sessions, e.g. `1`.
  final int? repeatWeeks;

  /// Recurrence type, e.g. `custom`.
  final String? recurrenceType;

  /// Recurrence interval (from `metadata.recurrence_interval`), e.g. `1`.
  final int? recurrenceInterval;

  /// Whether this hold belongs to the current user.
  final bool? heldByMe;

  /// ISO expiry timestamp string, e.g. `2026-06-29T12:30:07+00:00`.
  final String? expiresAt;

  /// Booking flow step, e.g. `slot_selected`.
  final String? step;

  /// Server pricing for the held slot(s) (`data.quote`).
  final BookingQuoteModel? quote;

  /// [quote] prices the whole booking — the one sent beside a list of holds
  /// — rather than this hold alone.
  final bool quoteIsShared;

  /// The quote sent beside a list of holds, for the whole booking, kept
  /// apart from this hold's own [quote].
  final BookingQuoteModel? bookingQuote;

  bool get hasToken => (holdToken ?? '').isNotEmpty;

  /// What `DELETE /booking-holds` takes to release this hold.
  bool get hasId => (id ?? '').isNotEmpty;

  DateTime? get expiresAtDateTime =>
      expiresAt == null ? null : DateTime.tryParse(expiresAt!);

  /// Every hold in a `POST /booking-holds` answer, in the order sent:
  /// `data` as a list of `{hold, quote}`, `data.holds` as a list, or a single
  /// `data.hold` (with its `quote`).
  ///
  /// A recurring booking holds one slot per date, and the server prices the
  /// whole booking once: `data.quote` sits beside the `holds` list rather than
  /// inside each hold. It is kept on every hold as [bookingQuote] — next to,
  /// not over, the hold's own quote — and a hold with no quote of its own
  /// takes it as its quote. Without it the checkout never got a price and
  /// showed "Calculating price…" forever.
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

/// Unwraps the outer `{status, message, data: {...}}` envelope and returns the
/// node that holds `hold`/`quote` (newer shape) or the hold fields directly
/// (older shape).
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
