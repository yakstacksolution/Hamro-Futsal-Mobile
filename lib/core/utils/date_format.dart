import 'package:hamro_futsal/core/date_time/app_date_format.dart';

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

  static String date(DateTime d) => AppDateFormat.date(d);

  static String time(DateTime d) => AppDateFormat.time(d);

  static String adDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';

  static String adTime(DateTime d) {
    final int hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final String minute = d.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  static String dateTime(DateTime d) => '${date(d)} · ${time(d)}';

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

  static DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);
}
