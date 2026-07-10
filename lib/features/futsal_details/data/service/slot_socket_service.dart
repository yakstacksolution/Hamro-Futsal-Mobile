import 'dart:async';

/// A realtime signal that a venue's slot / court availability changed.
///
/// The body is intentionally thin: the socket only tells listeners *that*
/// availability moved (and, when the backend includes it, for which day).
/// Listeners re-fetch the authoritative availability from the REST API rather
/// than trusting the broadcast payload — this keeps the booking screen correct
/// regardless of how the backend shapes the event.
class SlotAvailabilityUpdate {
  const SlotAvailabilityUpdate({
    required this.venueId,
    this.date,
    this.raw = const <String, dynamic>{},
  });

  final int venueId;

  /// `yyyy-MM-dd` of the affected day when the backend includes it; else null.
  final String? date;

  /// The decoded broadcast payload, for callers that want to inspect it.
  final Map<String, dynamic> raw;
}

/// A live hold/booking state change broadcast on the per-date booking channel
/// `venue.{venueId}.booking.{bookingDate}`. The Flutter Pusher subscription
/// uses Echo's `presence-` prefix for this channel.
///
/// All six backend events (`slot.held`, `slot.released`, `slot.expired`,
/// `booking.step.updated`, `booking.confirmed`, `booking.cancelled`) share
/// this payload shape; [type] tells them apart. `reason`, `expiresAt` and
/// `step` are only populated where relevant to the specific event.
class BookingSlotEvent {
  const BookingSlotEvent({
    required this.type,
    required this.venueId,
    this.courtId,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.status,
    this.reason,
    this.step,
    this.expiresAt,
    this.raw = const <String, dynamic>{},
  });

  static const String held = 'slot.held';
  static const String released = 'slot.released';
  static const String expired = 'slot.expired';
  static const String stepUpdated = 'booking.step.updated';
  static const String confirmed = 'booking.confirmed';
  static const String cancelled = 'booking.cancelled';

  /// One of the `slot.*` / `booking.*` constants above.
  final String type;

  final int venueId;
  final int? courtId;

  /// `yyyy-MM-dd` of the affected day.
  final String? bookingDate;

  /// `HH:mm` boundaries of the affected slot.
  final String? startTime;
  final String? endTime;

  /// `available` / `unavailable` / `booked` — apply directly to the matching
  /// court/time cell.
  final String? status;

  final String? reason;
  final String? step;

  /// Server-authoritative hold expiry (only on `slot.held`).
  final DateTime? expiresAt;

  /// The decoded broadcast payload, for callers that want to inspect it.
  final Map<String, dynamic> raw;

  /// Purely informational events that don't change slot availability.
  bool get isInformational => type == stepUpdated;
}

abstract class SlotSocketService {
  /// Emits whenever availability changes on the
  /// `private-venue.{venueId}.slots` channel. The returned stream is a
  /// broadcast stream that stays silent until an event arrives (or forever,
  /// if realtime is disabled).
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId);

  /// Emits every hold/booking state change broadcast on the presence channel
  /// `venue.{venueId}.booking.{bookingDate}` for the given day.
  Stream<BookingSlotEvent> bookingEvents(int venueId, String bookingDate);

  /// Emits the number of users currently on that venue + date's presence
  /// channel (including this client) whenever the roster changes.
  Stream<int> bookingViewers(int venueId, String bookingDate);

  /// Leaves the per-date presence channel so this user drops out of the
  /// roster. Call when the screen is torn down or the viewed date changes.
  void leaveBookingChannel(int venueId, String bookingDate);

  void dispose();
}

/// Used when realtime is unavailable (e.g. tests) — every stream stays silent.
final class NoopSlotSocketService implements SlotSocketService {
  const NoopSlotSocketService();

  @override
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId) =>
      const Stream.empty();

  @override
  Stream<BookingSlotEvent> bookingEvents(int venueId, String bookingDate) =>
      const Stream.empty();

  @override
  Stream<int> bookingViewers(int venueId, String bookingDate) =>
      const Stream.empty();

  @override
  void leaveBookingChannel(int venueId, String bookingDate) {}

  @override
  void dispose() {}
}
