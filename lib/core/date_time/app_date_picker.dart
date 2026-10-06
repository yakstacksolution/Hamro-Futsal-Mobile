import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/date_time/app_date.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/widgets/custom_date_picker.dart';
import 'package:nepali_date_picker/nepali_date_picker.dart' as np;

Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  AppCalendar? calendar,
  String? title,
  String confirmText = 'Select',
}) {
  final AppCalendar resolved =
      calendar ?? AppCalendarController.instance.calendar;
  if (resolved == AppCalendar.ad) {
    return showCustomDatePicker(
      context,
      calendar: AppCalendar.ad,
      title: title,
      initialDate: initialDate,
      minDate: firstDate,
      maxDate: lastDate,
      confirmText: confirmText,
    );
  }
  final DateTime today = AppDate.dateOnly(DateTime.now());
  return showBsDatePicker(
    context,
    initialDate: initialDate ?? today,
    firstDate: firstDate ?? DateTime(today.year - 100),
    lastDate: lastDate ?? DateTime(today.year + 50, 12, 31),
    title: title,
    confirmText: confirmText,
  );
}

Future<DateTime?> showBsDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  String confirmText = 'Select',
  CalendarScript? script,
}) async {
  final (DateTime first, DateTime last) = _bsBounds(firstDate, lastDate);
  DateTime initial = AppDate.dateOnly(initialDate);
  if (initial.isBefore(first)) initial = first;
  if (initial.isAfter(last)) initial = last;

  final np.NepaliDateTime? picked = await np.showNepaliDatePicker(
    context: context,
    initialDate: AppDate.toBs(initial),
    firstDate: AppDate.toBs(first),
    lastDate: AppDate.toBs(last),
    helpText: title,
    confirmText: confirmText,
    locale: _localeFor(script),
    builder: _themed,
  );
  return picked == null ? null : AppDate.dateOnly(AppDate.toAd(picked));
}

Future<DateTimeRange?> showAppDateRangePicker(
  BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
  AppCalendar? calendar,
  String? title,
  String? saveText,
}) async {
  final AppCalendar resolved =
      calendar ?? AppCalendarController.instance.calendar;
  if (resolved == AppCalendar.ad) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
      helpText: title,
      saveText: saveText,
      builder: _themed,
    );
  }

  final (DateTime first, DateTime last) = _bsBounds(firstDate, lastDate);
  DateTimeRange<np.NepaliDateTime>? initialBs;
  if (initialDateRange != null) {
    DateTime clamp(DateTime d) {
      final DateTime day = AppDate.dateOnly(d);
      if (day.isBefore(first)) return first;
      if (day.isAfter(last)) return last;
      return day;
    }

    initialBs = DateTimeRange<np.NepaliDateTime>(
      start: AppDate.toBs(clamp(initialDateRange.start)),
      end: AppDate.toBs(clamp(initialDateRange.end)),
    );
  }

  final DateTimeRange<np.NepaliDateTime>? picked = await np
      .showNepaliDateRangePicker(
        context: context,
        firstDate: AppDate.toBs(first),
        lastDate: AppDate.toBs(last),
        initialDateRange: initialBs,
        helpText: title,
        saveText: saveText,
        locale: _localeFor(null),
        builder: _themed,
      );
  if (picked == null) return null;
  return DateTimeRange(
    start: AppDate.dateOnly(AppDate.toAd(picked.start)),
    end: AppDate.dateOnly(AppDate.toAd(picked.end)),
  );
}

(DateTime, DateTime) _bsBounds(DateTime first, DateTime last) => (
  AppDate.dateOnly(AppDate.clampToBsRange(first)),
  AppDate.dateOnly(AppDate.clampToBsRange(last)),
);

Locale? _localeFor(CalendarScript? script) =>
    (script ?? AppCalendarController.instance.script) == CalendarScript.nepali
    ? const Locale('ne')
    : null;

Widget _themed(BuildContext context, Widget? child) {
  final ThemeData theme = Theme.of(context);
  return Theme(
    data: theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        primary: LightColor.secondaryColor,
        onPrimary: LightColor.inverseTextColor,
      ),
      datePickerTheme: theme.datePickerTheme.copyWith(
        backgroundColor: LightColor.cardColor,
        headerBackgroundColor: LightColor.secondaryColor,
        headerForegroundColor: LightColor.inverseTextColor,
        rangeSelectionBackgroundColor: LightColor.secondaryColor.withValues(
          alpha: 0.14,
        ),
      ),
    ),
    child: child ?? const SizedBox.shrink(),
  );
}
