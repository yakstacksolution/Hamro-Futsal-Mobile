import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/date_time/app_date.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

abstract final class AppDateFormat {
  static AppCalendarPreference get _pref =>
      AppCalendarController.instance.value;

  static bool get isBs => _pref.isBs;

  static AppCalendar _calendar(AppCalendar? calendar) =>
      calendar ?? _pref.calendar;

  static CalendarScript _script(CalendarScript? script) =>
      script ?? _pref.script;

  static String format(
    DateTime date,
    String pattern, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) {
    if (_calendar(calendar) == AppCalendar.ad) {
      return DateFormat(pattern).format(date);
    }
    final CalendarScript resolved = _script(script);
    final String text = NepaliDateFormat(
      _bsPattern(pattern),
      resolved.language,
    ).format(AppDate.toBs(date));
    // nepali_utils writes `am` / `pm`; the app writes `AM` / `PM`.
    return resolved == CalendarScript.english
        ? text.replaceAllMapped(
            RegExp(r'\b(am|pm)\b'),
            (Match m) => m[1]!.toUpperCase(),
          )
        : text;
  }

  static String _bsPattern(String pattern) {
    final StringBuffer out = StringBuffer();
    int i = 0;
    while (i < pattern.length) {
      final String c = pattern[i];
      if (c == "'") {
        // Quoted literal: copy through to the closing quote.
        final int end = pattern.indexOf("'", i + 1);
        final int stop = end == -1 ? pattern.length : end + 1;
        out.write(pattern.substring(i, stop));
        i = stop;
        continue;
      }
      int run = 1;
      while (i + run < pattern.length && pattern[i + run] == c) {
        run++;
      }
      out.write(switch (c) {
        // MMM (abbreviated) and MMMM → full month name.
        'M' when run >= 3 => 'MMMM',
        // E / EE / EEE (Sat) → EE; EEEE (Saturday) → EEE.
        'E' => run >= 4 ? 'EEE' : 'EE',
        _ => c * run,
      });
      i += run;
    }
    return out.toString();
  }

  static String date(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) => switch (_calendar(calendar)) {
    AppCalendar.ad => DateFmt.adDate(date),
    AppCalendar.bs => format(
      date,
      'MMMM d, y',
      calendar: AppCalendar.bs,
      script: script,
    ),
  };

  static String weekdayDate(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) => format(date, 'EEE, MMM d', calendar: calendar, script: script);

  static String monthYear(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) => format(date, 'MMMM yyyy', calendar: calendar, script: script);

  static String day(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'd', calendar: calendar);

  static String monthShort(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'MMM', calendar: calendar);

  static String monthName(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'MMMM', calendar: calendar);

  static String weekdayShort(DateTime date) => format(date, 'EEE');

  static String weekdayName(DateTime date) => format(date, 'EEEE');

  static String year(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'y', calendar: calendar);

  static String digits(Object value) {
    final String text = '$value';
    if (!(isBs && _pref.script == CalendarScript.nepali)) return text;
    return NepaliUnicode.convert(text);
  }

  static String time(DateTime date, {CalendarScript? script}) {
    final bool nepali = isBs && _script(script) == CalendarScript.nepali;
    if (!nepali) return DateFmt.adTime(date);
    return format(
      date,
      'h:mm a',
      calendar: AppCalendar.bs,
      script: CalendarScript.nepali,
    );
  }

  static String dateTime(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) =>
      '${AppDateFormat.date(date, calendar: calendar, script: script)}'
      ' · ${time(date, script: script)}';

  static String dual(DateTime date, {CalendarScript? script}) {
    final AppCalendar first = _pref.calendar;
    final AppCalendar second = first == AppCalendar.ad
        ? AppCalendar.bs
        : AppCalendar.ad;
    return '${AppDateFormat.date(date, calendar: first, script: script)} '
        '${first.shortLabel} '
        '(${AppDateFormat.date(date, calendar: second, script: script)})';
  }
}
