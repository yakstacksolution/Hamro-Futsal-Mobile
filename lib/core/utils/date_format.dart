/// Date and time formatting shared across features.
///
/// Lives in core for the same reason as `Money`: a booking card reading
/// `14 Sep 2026` beside a ledger card reading `Sep 14, 2026` is what makes two
/// screens look like two products. One spelling, one place to change it.
class DateFmt {
  const DateFmt._();

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// e.g. `Sep 14, 2026`.
  static String date(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

  /// e.g. `9:31 PM`.
  static String time(DateTime d) {
    final int hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final String minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  /// e.g. `Sep 14, 2026 · 6:00 AM`. Used wherever the exact moment matters.
  static String dateTime(DateTime d) => '${date(d)} · ${time(d)}';

  /// A list section heading: `TODAY · 12 SEP 2026`.
  ///
  /// The relative word carries the day for the two that matter, and the full
  /// date follows it so a reader never has to work out which day "Today" was
  /// when the list was fetched.
  static String sectionDay(DateTime d, {DateTime? now}) {
    final DateTime today = now ?? DateTime.now();
    final int days = DateTime(
      today.year,
      today.month,
      today.day,
    ).difference(dayOf(d)).inDays;
    final String full =
        '${d.day.toString().padLeft(2, '0')} '
        '${_months[d.month - 1].toUpperCase()} ${d.year}';
    if (days == 0) return 'TODAY  ·  $full';
    if (days == 1) return 'YESTERDAY  ·  $full';
    return full;
  }

  /// The day a row belongs to, ignoring the time.
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
