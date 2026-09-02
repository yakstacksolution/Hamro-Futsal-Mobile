import 'package:hamro_futsal/features/futsal_details/data/model/booking_quote_model.dart';

/// Result of `POST /booking-holds`. Mirrors the `data.hold` object the server
/// returns and carries the `hold_token` used to release the hold later with
/// `DELETE /booking-holds/{token}`, plus the server `quote` (pricing).
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

  bool get hasToken => (holdToken ?? '').isNotEmpty;

  DateTime? get expiresAtDateTime =>
      expiresAt == null ? null : DateTime.tryParse(expiresAt!);

  factory BookingHoldModel.fromResponse(dynamic payload) {
    // The hold fields live under `data.hold` (newer shape) or directly under
    // `data` (older shape); the quote is a sibling under `data`.
    final Map<String, dynamic> envelope = _envelope(payload);
    final Map<String, dynamic> map = _mapOf(envelope['hold']) ?? envelope;
    final Map<String, dynamic> metadata = _mapOf(map['metadata']) ?? const {};
    final Map<String, dynamic>? quoteJson = _mapOf(envelope['quote']);
    return BookingHoldModel(
      quote: quoteJson == null ? null : BookingQuoteModel.fromJson(quoteJson),
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
