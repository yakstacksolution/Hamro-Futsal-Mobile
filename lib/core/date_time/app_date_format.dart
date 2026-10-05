import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/date_time/app_date.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:intl/intl.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// Calendar-aware date and time text — the one place every *displayed* date
/// in the app is written.
///
/// Each method formats a Gregorian [DateTime] in the user's calendar
/// ([AppCalendarController], driven by the profile's `use_nepali_calendar`)
/// unless [calendar] / [script] say otherwise:
///
/// | AD                | BS (English letters) | BS (नेपाली)        |
/// |-------------------|----------------------|--------------------|
/// | `Oct 03, 2026`    | `Ashwin 17, 2083`    | `आश्विन १७, २०८३`  |
///
/// Only for display. Dates sent to the API, used as map keys or compared stay
/// Gregorian — use `isoDate` / `DateFormat('yyyy-MM-dd')` for those.
abstract final class AppDateFormat {
  static AppCalendarPreference get _pref =>
      AppCalendarController.instance.value;

  /// Whether dates are currently shown in Bikram Sambat.
  static bool get isBs => _pref.isBs;

  static AppCalendar _calendar(AppCalendar? calendar) =>
      calendar ?? _pref.calendar;

  static CalendarScript _script(CalendarScript? script) =>
      script ?? _pref.script;

  /// [date] written with an `intl` [pattern] — `'d MMM yyyy'`, `'EEE, d MMM'`,
  /// `'MMMM yyyy'`, `'dd MMM yyyy, hh:mm a'` … — in the user's calendar.
  ///
  /// For BS the pattern is adapted: month abbreviations become full names
  /// (Nepali short months are unreadable — `Ash`, `आ`) and weekday widths are
  /// matched to intl's.
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

  /// intl pattern → nepali_utils pattern.
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

  /// `Oct 03, 2026` / `Ashwin 17, 2083`.
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

  /// `Sat, Oct 03` / `Sat, Ashwin 17` — a day without its year.
  static String weekdayDate(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) => format(date, 'EEE, MMM d', calendar: calendar, script: script);

  /// `October 2026` / `Ashwin 2083`.
  static String monthYear(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) => format(date, 'MMMM yyyy', calendar: calendar, script: script);

  /// Day of the month: `3` / `17` / `१७`.
  static String day(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'd', calendar: calendar);

  /// Month name: `Oct` (AD, short) / `Ashwin` (BS).
  static String monthShort(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'MMM', calendar: calendar);

  /// Month name: `October` / `Ashwin`.
  static String monthName(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'MMMM', calendar: calendar);

  /// `Sat` / `शनि` — the weekday is the same in both calendars; only the
  /// script differs.
  static String weekdayShort(DateTime date) => format(date, 'EEE');

  /// `Saturday` / `शनिबार`.
  static String weekdayName(DateTime date) => format(date, 'EEEE');

  /// Year: `2026` / `2083`.
  static String year(DateTime date, {AppCalendar? calendar}) =>
      format(date, 'y', calendar: calendar);

  /// [value] in the user's digits: `12` / `१२` (Nepali script only).
  static String digits(Object value) {
    final String text = '$value';
    if (!(isBs && _pref.script == CalendarScript.nepali)) return text;
    return NepaliUnicode.convert(text);
  }

  /// `9:31 PM`; with BS in Nepali script, Nepali digits and day-part words.
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

  /// `Oct 03, 2026 · 9:31 PM` in the user's calendar.
  static String dateTime(
    DateTime date, {
    AppCalendar? calendar,
    CalendarScript? script,
  }) =>
      '${AppDateFormat.date(date, calendar: calendar, script: script)}'
      ' · ${time(date, script: script)}';

  /// Both calendars, the user's first: `Ashwin 17, 2083 BS (Oct 03, 2026)`.
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
