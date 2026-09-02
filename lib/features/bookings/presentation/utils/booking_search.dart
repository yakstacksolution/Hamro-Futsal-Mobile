import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';

enum BookingDateOrder { ascending, descending }

bool bookingMatchesSearch(BookingModel booking, String query) {
  final String normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) return true;

  final String date =
      '${booking.date.day.toString().padLeft(2, '0')}/'
      '${booking.date.month.toString().padLeft(2, '0')}/'
      '${booking.date.year}';
  final Iterable<String?> values = <String?>[
    booking.bookingRef,
    booking.futsalName,
    booking.futsalAddress,
    booking.courtName,
    booking.playerName,
    booking.playerPhone,
    booking.playerEmail,
    booking.status.value,
    booking.paymentStatus,
    booking.displayTimeRange,
    date,
    booking.date.toIso8601String(),
  ];

  return values.any(
    (String? value) =>
        value?.trim().toLowerCase().contains(normalizedQuery) == true,
  );
}

bool bookingFallsWithinDateRange(
  BookingModel booking, {
  DateTime? fromDate,
  DateTime? toDate,
}) {
  final DateTime bookingDate = DateTime(
    booking.date.year,
    booking.date.month,
    booking.date.day,
  );
  final DateTime? normalizedFrom = fromDate == null
      ? null
      : DateTime(fromDate.year, fromDate.month, fromDate.day);
  final DateTime? normalizedTo = toDate == null
      ? null
      : DateTime(toDate.year, toDate.month, toDate.day);

  if (normalizedFrom != null && bookingDate.isBefore(normalizedFrom)) {
    return false;
  }
  if (normalizedTo != null && bookingDate.isAfter(normalizedTo)) {
    return false;
  }
  return true;
}

List<BookingModel> sortBookingsByDate(
  Iterable<BookingModel> bookings,
  BookingDateOrder order,
) {
  final List<BookingModel> sorted = bookings.toList(growable: false);
  sorted.sort((BookingModel left, BookingModel right) {
    int comparison = left.date.compareTo(right.date);
    if (comparison == 0) {
      comparison = left.startTime.compareTo(right.startTime);
    }
    if (comparison == 0) {
      comparison = left.id.compareTo(right.id);
    }
    return order == BookingDateOrder.ascending ? comparison : -comparison;
  });
  return sorted;
}
