import 'package:hamro_futsal/core/date_time/app_date_format.dart';

/// Time formatting shared by the conversations list and the chat thread.
class MessageFmt {
  /// Compact relative time for the conversation list:
  /// `now` · `5 min ago` · `2 hr ago` · `3 day ago` · `4 Jun`.
  static String friendly(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    final diff = now.difference(d);

    // Avoid negative values if the client and server clocks differ slightly.
    if (diff.isNegative || diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hr ago';

    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final days = today.difference(day).inDays;
    if (days < 7) return '$days day ago';

    return AppDateFormat.year(d) == AppDateFormat.year(now)
        ? AppDateFormat.format(d, 'd MMM')
        : AppDateFormat.format(d, 'd MMM y');
  }

  /// `6:30 PM`.
  static String clock(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}
