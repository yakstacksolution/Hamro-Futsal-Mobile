import 'package:nepali_utils/nepali_utils.dart';

abstract final class AppDate {
  static final NepaliDateTime bsMin = NepaliDateTime(1970, 2, 5);
  static final NepaliDateTime bsMax = NepaliDateTime(2250, 11, 6);

  static final DateTime adMin = dateOnly(bsMin.toDateTime());
  static final DateTime adMax = dateOnly(bsMax.toDateTime());

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static bool isBsSupported(DateTime date) {
    final DateTime day = dateOnly(date);
    return !day.isBefore(adMin) && !day.isAfter(adMax);
  }

  static DateTime clampToBsRange(DateTime date) {
    if (date.isBefore(adMin)) return adMin;
    if (date.isAfter(adMax)) return adMax;
    return date;
  }

  static NepaliDateTime toBs(DateTime ad) {
    if (ad is NepaliDateTime) return ad;
    return clampToBsRange(ad).toNepaliDateTime();
  }

  static DateTime toAd(NepaliDateTime bs) => bs.toDateTime();

  static DateTime fromBs(int year, [int month = 1, int day = 1]) =>
      dateOnly(NepaliDateTime(year, month, day).toDateTime());

  static NepaliDateTime todayBs() => toBs(DateTime.now());
}
