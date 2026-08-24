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

  /// Time left on a countdown, scaled to how much there is.
  ///
  /// `mm:ss` under an hour, `h:mm:ss` past it, and `Nd hh:mm` past a day. A
  /// plain `mm:ss` was showing 16 hours and 55 minutes as `55:43`, which reads
  /// as under an hour — the opposite of the truth.
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

  /// `Today` / `Tomorrow` / `May 03` — the date on its own, for lines that
  /// already state the time (a slot range, say).
  static String friendlyDate(DateTime d) {
    final now = DateTime.now();
    final day = DateTime(d.year, d.month, d.day);
    final today = DateTime(now.year, now.month, now.day);
    if (day == today) return 'Today';
    if (day == today.add(const Duration(days: 1))) return 'Tomorrow';
    return shortDate(d);
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
