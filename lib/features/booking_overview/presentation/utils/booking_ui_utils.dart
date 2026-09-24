import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';

/// Accent color for each booking status.
extension BookingStatusUi on BookingStatus {
  Color get color => switch (this) {
    BookingStatus.completed => LightColor.secondaryColor,
    BookingStatus.confirmed => LightColor.blueColor,
    BookingStatus.pending => LightColor.warningColor,
    BookingStatus.cancelled => LightColor.redColor,
  };
}

/// Parses `#RRGGBB` / `#AARRGGBB`; null when missing or malformed.
Color? bookingHexColor(String hex) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

extension StatusMixEntryUi on StatusMixEntry {
  /// Server color when provided, theme color otherwise.
  Color get color => bookingHexColor(colorHex) ?? status.color;

  String get displayLabel => label.isEmpty ? status.label : label;
}

class BookingFmt {
  static String npr(int v) =>
      '${v < 0 ? '-' : ''}NPR ${group(v.abs().toString())}';

  /// `2` → `2`, `1.5` → `1.5`, `1.25` → `1.3`.
  static String hours(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  /// `100` → `100`, `22.2` → `22.2`.
  static String percent(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  /// Groups a digit-only string with thousands separators: 1234567 → 1,234,567.
  static String group(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  /// e.g. `Jun 4` (appends the year when it isn't the current one).
  static String shortDate(DateTime d) {
    const m = [
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
    final suffix = d.year != DateTime.now().year ? ', ${d.year}' : '';
    return '${m[d.month - 1]} ${d.day}$suffix';
  }
}
