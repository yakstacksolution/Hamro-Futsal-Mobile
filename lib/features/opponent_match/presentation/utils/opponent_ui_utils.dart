import 'package:flutter/material.dart';

class OpponentFmt {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String npr(int v) =>
      '${v < 0 ? '-' : ''}NPR ${group(v.abs().toString())}';

  /// Groups a digit-only string with thousands separators: 1234567 → 1,234,567.
  static String group(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  /// e.g. `May 03`.
  static String shortDate(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';

  /// e.g. `6:30 PM`.
  static String time(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  /// One-hour slot starting at [start]: `6:00 PM – 7:00 PM`.
  static String slot(TimeOfDay start) {
    final end = TimeOfDay(hour: (start.hour + 1) % 24, minute: start.minute);
    return '${time(start)} – ${time(end)}';
  }

  /// `Today, 6:30 PM` / `Tomorrow, 5:00 PM` / `May 03 · 6:00 PM`.
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
