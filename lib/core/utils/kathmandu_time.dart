abstract final class KathmanduClock {
  static const Duration offset = Duration(hours: 5, minutes: 45);

  static DateTime Function() _utcNow = () => DateTime.now().toUtc();

  static DateTime now() {
    final DateTime k = _utcNow().add(offset);
    return DateTime(k.year, k.month, k.day, k.hour, k.minute, k.second);
  }

  static DateTime today() {
    final DateTime k = now();
    return DateTime(k.year, k.month, k.day);
  }

  static int minuteOfDay() {
    final DateTime k = now();
    return k.hour * 60 + k.minute;
  }

  static bool isToday(DateTime date) => isSameDay(date, today());

  static void debugSetUtcNow(DateTime Function()? utcNow) {
    _utcNow = utcNow ?? () => DateTime.now().toUtc();
  }
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
