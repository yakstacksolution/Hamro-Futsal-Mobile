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

abstract class SlotSocketService {
  /// Emits whenever availability changes on the `venue.{venueId}.slots`
  /// channel. The returned stream is a broadcast stream that stays silent
  /// until an event arrives (or forever, if realtime is disabled).
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId);

  void dispose();
}

/// Used when realtime is unavailable (e.g. tests) — every stream stays silent.
final class NoopSlotSocketService implements SlotSocketService {
  const NoopSlotSocketService();

  @override
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId) => const Stream.empty();

  @override
  void dispose() {}
}
