/// Whether a booking is for a single session or repeats weekly.
enum BookingMode { single, recurring }

/// Recurring booking durations. Each repeats weekly on the same weekday and
/// time as the selected slot, for [sessions] total occurrences.
enum BookingRecurrence {
  twoWeeks('2 Weeks', 2),
  oneMonth('1 Month', 4),
  twoMonths('2 Months', 8),
  threeMonths('3 Months', 12);

  const BookingRecurrence(this.label, this.sessions);

  /// Short label shown on the chip (e.g. '1 Month').
  final String label;

  /// Number of weekly occurrences this duration produces.
  final int sessions;

  /// All session dates starting from [start], stepping one week each time.
  List<DateTime> datesFrom(DateTime start) {
    return List<DateTime>.generate(
      sessions,
      (int i) => start.add(Duration(days: 7 * i)),
    );
  }
}
