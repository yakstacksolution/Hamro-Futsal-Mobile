/// Whether a booking is for a single session or repeats weekly.
enum BookingMode { single, recurring }

/// Recurring booking durations. Each defines a horizon of [weeks] from the
/// selected date; which weekdays inside that horizon are actually booked is
/// decided separately by [RecurringWeekdays].
enum BookingRecurrence {
  twoWeeks('2 Weeks', 2),
  oneMonth('1 Month', 4),
  twoMonths('2 Months', 8),
  threeMonths('3 Months', 12);

  const BookingRecurrence(this.label, this.weeks);

  /// Short label shown on the chip (e.g. '1 Month').
  final String label;

  /// How many weeks the recurrence spans.
  final int weeks;

  /// Occurrences produced when only one weekday is booked — the historical
  /// meaning of this enum, kept for call sites that predate day selection.
  int get sessions => weeks;

  /// Every session date in this horizon.
  ///
  /// [weekdays] holds `DateTime.monday`…`DateTime.sunday` values; an empty set
  /// means "just the weekday [start] itself falls on", which reproduces the
  /// original same-weekday-every-week behaviour.
  ///
  /// For each selected weekday the first occurrence is the first date on or
  /// after [start] with that weekday, then one per week for [weeks] weeks. The
  /// result is chronological and free of duplicates.
  List<DateTime> datesFrom(
    DateTime start, {
    Set<int> weekdays = const <int>{},
  }) {
    final Set<int> days = weekdays.isEmpty ? <int>{start.weekday} : weekdays;
    final List<DateTime> dates = <DateTime>[];

    for (final int weekday in days) {
      // 0 when `start` is already on this weekday, so a single-day recurrence
      // still begins on the date the user picked.
      final int offset = (weekday - start.weekday + 7) % 7;
      final DateTime first = start.add(Duration(days: offset));
      for (int week = 0; week < weeks; week++) {
        dates.add(first.add(Duration(days: 7 * week)));
      }
    }

    dates.sort();
    return dates;
  }

  /// How many sessions [weekdays] produces over this horizon.
  int sessionCount(Set<int> weekdays) =>
      weeks * (weekdays.isEmpty ? 1 : weekdays.length);
}

/// Weekday helpers for the recurring-day picker.
///
/// Values are `DateTime.monday`…`DateTime.sunday` (1–7), but the picker is
/// ordered Sunday-first, which is how the week reads locally.
abstract final class RecurringWeekdays {
  /// Picker order: Sun, Mon, Tue, Wed, Thu, Fri, Sat.
  static const List<int> displayOrder = <int>[
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
  ];

  static const List<String> _short = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _full = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  /// `Sun` for [DateTime.sunday].
  static String shortLabel(int weekday) => _short[weekday - 1];

  /// `Sunday` for [DateTime.sunday].
  static String fullLabel(int weekday) => _full[weekday - 1];

  /// Single letter for the picker's circle (`S`, `M`, `T`, …).
  static String initial(int weekday) => _short[weekday - 1][0];

  /// `Sun & Mon`, `Sun, Mon & Wed` — chronological in picker order.
  static String summary(Set<int> weekdays) {
    final List<String> labels = displayOrder
        .where(weekdays.contains)
        .map(shortLabel)
        .toList(growable: false);
    if (labels.isEmpty) return '';
    if (labels.length == 1) return labels.single;
    return '${labels.sublist(0, labels.length - 1).join(', ')} & ${labels.last}';
  }
}
