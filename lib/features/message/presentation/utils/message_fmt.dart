import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class MessageFmt {
  static String friendly(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final diff = now.difference(d);

    // Avoid negative values if the client and server clocks differ slightly.
    if (diff.isNegative || diff.inSeconds < 60) return StringConstants.nowLower;
    if (diff.inMinutes < 60) return StringConstants.minutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return StringConstants.hoursAgoShort(diff.inHours);

    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final days = today.difference(day).inDays;
    if (days < 7) return StringConstants.daysAgoShort(days);

    return AppDateFormat.year(d) == AppDateFormat.year(now)
        ? AppDateFormat.format(d, 'd MMM')
        : AppDateFormat.format(d, 'd MMM y');
  }

  static String clock(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? StringConstants.am : StringConstants.pm}';
  }
}
