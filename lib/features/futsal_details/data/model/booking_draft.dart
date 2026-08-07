import 'package:hamro_footsall/features/bookings/data/model/manual_booking_details.dart';

/// All the data needed by the booking checkout page, captured from the slot
/// selection screen when the user taps its booking action. Kept independent of
/// the bloc so the checkout page can be navigated to with a single [extra].
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
    this.bookingTotal,
    this.bookingId,
    this.manualBooking,
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

  /// Complete time label for display. Some slot responses put the full range
  /// in [selectedTime], while others provide its end separately in [endTime].
  String get displayTimeRange {
    final String start = selectedTime.trim();
    final String? end = endTime?.trim();
    final bool alreadyContainsRange = RegExp(r'\s[-–—]\s').hasMatch(start);
    if (end == null || end.isEmpty || alreadyContainsRange || start == end) {
      return start;
    }
    return '$start – $end';
  }

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

  /// Final server-confirmed total after discounts and other adjustments.
  /// Null until checkout has completed successfully.
  final double? bookingTotal;

  /// Server id of the booking created during checkout, when returned by API.
  final int? bookingId;

  /// Present only when a vendor is creating a walk-in booking.
  final ManualBookingDetails? manualBooking;

  BookingDraft withManualBooking(ManualBookingDetails? details) => BookingDraft(
    venueId: venueId,
    courtId: courtId,
    courtName: courtName,
    courtImage: courtImage,
    matchType: matchType,
    courtType: courtType,
    maxPlayers: maxPlayers,
    selectedDate: selectedDate,
    selectedTime: selectedTime,
    apiTime: apiTime,
    apiEndTime: apiEndTime,
    endTime: endTime,
    isRecurring: isRecurring,
    recurrenceLabel: recurrenceLabel,
    sessions: sessions,
    sessionDates: sessionDates,
    pricePerSession: pricePerSession,
    subtotal: subtotal,
    bookingTotal: bookingTotal,
    bookingId: bookingId,
    manualBooking: details,
  );

  BookingDraft withCompletedBooking({required double total, int? id}) =>
      BookingDraft(
        venueId: venueId,
        courtId: courtId,
        courtName: courtName,
        courtImage: courtImage,
        matchType: matchType,
        courtType: courtType,
        maxPlayers: maxPlayers,
        selectedDate: selectedDate,
        selectedTime: selectedTime,
        apiTime: apiTime,
        apiEndTime: apiEndTime,
        endTime: endTime,
        isRecurring: isRecurring,
        recurrenceLabel: recurrenceLabel,
        sessions: sessions,
        sessionDates: sessionDates,
        pricePerSession: pricePerSession,
        subtotal: subtotal,
        bookingTotal: total,
        bookingId: id,
        manualBooking: manualBooking,
      );
}
