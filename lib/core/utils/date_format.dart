import 'package:hamro_futsal/core/date_time/app_date_format.dart';

/// Date and time formatting shared across features.
///
/// Follows the user's calendar: with `use_nepali_calendar` on the profile,
/// [date], [dateTime] and [sectionDay] write Bikram Sambat dates (see
/// `AppDateFormat`). [adDate] / [adTime] are the Gregorian spellings.
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

  /// e.g. `Sep 14, 2026` — or `Bhadra 29, 2083` in the Nepali calendar.
  static String date(DateTime d) => AppDateFormat.date(d);

  /// e.g. `9:31 PM` (Nepali digits with the Nepali script).
  static String time(DateTime d) => AppDateFormat.time(d);

  /// Gregorian `Sep 14, 2026`, whatever the user's calendar.
  static String adDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

  /// `9:31 PM`, whatever the user's calendar.
  static String adTime(DateTime d) {
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
    final String full = AppDateFormat.isBs
        ? AppDateFormat.format(d, 'd MMMM yyyy').toUpperCase()
        : '${d.day.toString().padLeft(2, '0')} '
              '${_months[d.month - 1].toUpperCase()} ${d.year}';
    if (days == 0) return 'TODAY  ·  $full';
    if (days == 1) return 'YESTERDAY  ·  $full';
    return full;
  }

  /// The day a row belongs to, ignoring the time.
  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
