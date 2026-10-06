import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:flutter/material.dart';

class OpponentFmt {
  static String npr(int v) =>
      '${v < 0 ? '-' : ''}NPR ${group(v.abs().toString())}';

  static String group(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  static String shortDate(DateTime d) => AppDateFormat.format(d, 'MMM dd');

  static String time(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  static String slot(TimeOfDay start) {
    final end = TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute);
    return '${time(start)} – ${time(end)}';
  }

  static String countdown(Duration d) {
    if (d.isNegative) return '00:00';
    final int days = d.inDays;
    final String hh = d.inHours.remainder(24).toString().padLeft(2, '0');
    final String mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final String ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (days > 0) return '${days}d $hh:$mm';
    if (d.inHours > 0) return '${d.inHours}:$mm:$ss';
    return '$mm:$ss';
  }

  static String friendlyDate(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.add(const Duration(days: 1))) return 'Tomorrow';
    return shortDate(d);
  }

  static String friendlyDateTime(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    final t = time(TimeOfDay.fromDateTime(d));
    if (day == today) return 'Today, $t';
    if (day == today.add(const Duration(days: 1))) return 'Tomorrow, $t';
    return '${shortDate(d)} · $t';
  }
}
