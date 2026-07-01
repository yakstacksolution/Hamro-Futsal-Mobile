/// All the data needed by the booking checkout page, captured from the slot
/// selection screen when the user taps "Book Now". Kept independent of the
/// bloc so the checkout page can be navigated to with a single [extra] object.
class BookingDraft {
  const BookingDraft({
    this.venueId,
    this.courtId,
    required this.courtName,
    required this.courtImage,
    required this.matchType,
    required this.courtType,
    required this.maxPlayers,
    required this.selectedDate,
    required this.selectedTime,
    this.apiTime,
    this.apiEndTime,
    this.endTime,
    required this.isRecurring,
    this.recurrenceLabel,
    required this.sessions,
    required this.sessionDates,
    required this.pricePerSession,
    required this.subtotal,
  });

  final int? venueId;
  final int? courtId;
  final String courtName;
  final String courtImage;
  final String matchType;
  final String courtType;
  final int maxPlayers;

  /// First (or only) session date.
  final DateTime selectedDate;

  /// Display slot time, e.g. "7:00 AM".
  final String selectedTime;

  /// Slot start time in API format, e.g. "07:00".
  final String? apiTime;

  /// Slot end time in API format, e.g. "08:00".
  final String? apiEndTime;

  /// Display end time of the slot, when known.
  final String? endTime;

  final bool isRecurring;

  /// Recurrence label, e.g. "1 Month". Null for single bookings.
  final String? recurrenceLabel;

  /// Number of sessions (1 for single bookings).
  final int sessions;

  /// Every session date (length == [sessions]).
  final List<DateTime> sessionDates;

  /// Price for one session.
  final double pricePerSession;

  /// Total price before any coupon discount (sum across sessions).
  final double subtotal;
}
