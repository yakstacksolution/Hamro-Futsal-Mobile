import 'package:nepali_utils/nepali_utils.dart';

/// Conversion between Gregorian (AD) and Bikram Sambat (BS) dates.
///
/// nepali_utils covers BS 1970/2/5 – 2250/11/6 and asserts outside it, so
/// every conversion here clamps into that window first.
abstract final class AppDate {
  /// Earliest and latest BS dates the calendar data covers.
  static final NepaliDateTime bsMin = NepaliDateTime(1970, 2, 5);
  static final NepaliDateTime bsMax = NepaliDateTime(2250, 11, 6);

  /// The same window in AD.
  static final DateTime adMin = dateOnly(bsMin.toDateTime());
  static final DateTime adMax = dateOnly(bsMax.toDateTime());

  /// [date] without its time of day.
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Whether [date] can be shown in BS.
  static bool isBsSupported(DateTime date) {
    final DateTime day = dateOnly(date);
    return !day.isBefore(adMin) && !day.isAfter(adMax);
  }

  /// [date] moved into the BS-supported window (time of day kept).
  static DateTime clampToBsRange(DateTime date) {
    if (date.isBefore(adMin)) return adMin;
    if (date.isAfter(adMax)) return adMax;
    return date;
  }

  /// AD → BS. Dates outside the supported window are clamped to its edge.
  static NepaliDateTime toBs(DateTime ad) {
    if (ad is NepaliDateTime) return ad;
    return clampToBsRange(ad).toNepaliDateTime();
  }

  /// BS → AD.
  static DateTime toAd(NepaliDateTime bs) => bs.toDateTime();

  /// A BS calendar day as an AD date, e.g. `fromBs(2083, 6, 17)`.
  static DateTime fromBs(int year, [int month = 1, int day = 1]) =>
      dateOnly(NepaliDateTime(year, month, day).toDateTime());

  /// Today in BS.
  static NepaliDateTime todayBs() => toBs(DateTime.now());
}
