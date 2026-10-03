/// Wall-clock time in Nepal (Asia/Kathmandu, UTC+05:45, no DST).
///
/// Venue operations run on Kathmandu time regardless of where the device is
/// set, so "today" and the current-time line must not follow the device's own
/// time zone. The app has no time-zone database; a fixed offset is exact here
/// because Nepal does not observe daylight saving.
abstract final class KathmanduClock {
  static const Duration offset = Duration(hours: 5, minutes: 45);

  /// Overridable in tests.
  static DateTime Function() _utcNow = () => DateTime.now().toUtc();

  /// The current Kathmandu wall-clock time. The returned value's fields
  /// (year … minute) read as Kathmandu time; its zone flag is meaningless.
  static DateTime now() {
    final DateTime k = _utcNow().add(offset);
    return DateTime(k.year, k.month, k.day, k.hour, k.minute, k.second);
  }

  /// Today's date in Kathmandu, at midnight.
  static DateTime today() {
    final DateTime k = now();
    return DateTime(k.year, k.month, k.day);
  }

  /// Minutes since Kathmandu midnight.
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

/// `2026-09-26`.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
