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

class BookingFmt {
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
