import 'package:hamro_futsal/features/bookings/data/model/manual_booking_details.dart';

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
    this.recurringWeekdays = const <int>[],
    required this.sessions,
    required this.sessionDates,
    required this.pricePerSession,
    required this.subtotal,
    this.bookingTotal,
    this.bookingId,
    this.manualBooking,
    this.droppedSessionDates = const <DateTime>[],
  });

  final int? venueId;
  final int? courtId;
  final String courtName;
  final String courtImage;
  final String matchType;
  final String courtType;
  final int maxPlayers;

  final DateTime selectedDate;

  final String selectedTime;

  final String? apiTime;

  final String? apiEndTime;

  final String? endTime;

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

  final String? recurrenceLabel;

  final List<int> recurringWeekdays;

  final int sessions;

  final List<DateTime> sessionDates;

  final double pricePerSession;

  final double subtotal;

  final double? bookingTotal;

  final int? bookingId;

  final ManualBookingDetails? manualBooking;

  final List<DateTime> droppedSessionDates;

  List<String> get apiSessionDates => isRecurring
      ? sessionDates.map(apiDateOf).toList(growable: false)
      : const <String>[];

  int? get repeatWeeksPayload {
    if (!isRecurring) return null;
    if (recurringWeekdays.length > 1) return null;
    // With dates skipped, the session count no longer equals the week span, so
    // only the explicit `booking_dates` list describes the schedule.
    if (droppedSessionDates.isNotEmpty) return null;
    return sessions;
  }

  static String apiDateOf(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

  BookingDraft withSessionDates({
    required List<DateTime> dates,
    required List<DateTime> dropped,
    required double subtotal,
  }) => BookingDraft(
    venueId: venueId,
    courtId: courtId,
    courtName: courtName,
    courtImage: courtImage,
    matchType: matchType,
    courtType: courtType,
    maxPlayers: maxPlayers,
    selectedDate: dates.isEmpty ? selectedDate : dates.first,
    selectedTime: selectedTime,
    apiTime: apiTime,
    apiEndTime: apiEndTime,
    endTime: endTime,
    isRecurring: isRecurring,
    recurrenceLabel: recurrenceLabel,
    recurringWeekdays: recurringWeekdays,
    sessions: dates.length,
    sessionDates: dates,
    pricePerSession: pricePerSession,
    subtotal: subtotal,
    bookingTotal: bookingTotal,
    bookingId: bookingId,
    manualBooking: manualBooking,
    droppedSessionDates: dropped,
  );

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
    recurringWeekdays: recurringWeekdays,
    sessions: sessions,
    sessionDates: sessionDates,
    pricePerSession: pricePerSession,
    subtotal: subtotal,
    bookingTotal: bookingTotal,
    bookingId: bookingId,
    manualBooking: details,
    droppedSessionDates: droppedSessionDates,
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
        recurringWeekdays: recurringWeekdays,
        sessions: sessions,
        sessionDates: sessionDates,
        pricePerSession: pricePerSession,
        subtotal: subtotal,
        bookingTotal: total,
        bookingId: id,
        manualBooking: manualBooking,
        droppedSessionDates: droppedSessionDates,
      );
}
