import 'dart:async';

class SlotAvailabilityUpdate {
  const SlotAvailabilityUpdate({
    required this.venueId,
    this.date,
    this.raw = const <String, dynamic>{},
  });

  final int venueId;

  final String? date;

  final Map<String, dynamic> raw;
}

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

  final String type;

  final int venueId;
  final int? courtId;

  final String? bookingDate;

  final String? startTime;
  final String? endTime;

  final String? status;

  final String? reason;
  final String? step;

  final DateTime? expiresAt;

  final Map<String, dynamic> raw;

  bool get isInformational => type == stepUpdated;
}

abstract class SlotSocketService {
  Stream<SlotAvailabilityUpdate> venueSlots(int venueId);

  Stream<BookingSlotEvent> bookingEvents(int venueId, String bookingDate);

  Stream<int> bookingViewers(int venueId, String bookingDate);

  void leaveBookingChannel(int venueId, String bookingDate);

  void dispose();
}

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
