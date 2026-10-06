import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';

extension BookingStatusUi on BookingStatus {
  Color get color => switch (this) {
    BookingStatus.completed => LightColor.secondaryColor,
    BookingStatus.confirmed => LightColor.blueColor,
    BookingStatus.pending => LightColor.warningColor,
    BookingStatus.cancelled => LightColor.redColor,
  };
}

Color? bookingHexColor(String hex) {
  var h = hex.trim().replaceFirst('#', '');
  if (h.length == 6) h = 'FF$h';
  if (h.length != 8) return null;
  final v = int.tryParse(h, radix: 16);
  return v == null ? null : Color(v);
}

extension StatusMixEntryUi on StatusMixEntry {
  Color get color => bookingHexColor(colorHex) ?? status.color;

  String get displayLabel => label.isEmpty ? status.label : label;
}

class BookingFmt {
  static String npr(int v) =>
      '${v < 0 ? '-' : ''}NPR ${group(v.abs().toString())}';

  static String hours(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static String percent(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static String group(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  static String shortDate(DateTime d) {
    final year = AppDateFormat.year(d);
    final suffix = year != AppDateFormat.year(DateTime.now()) ? ', $year' : '';
    return '${AppDateFormat.format(d, 'MMM d')}$suffix';
  }
}
