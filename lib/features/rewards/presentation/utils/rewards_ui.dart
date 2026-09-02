import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';

/// Formatting for reward figures. Kept local to the feature so the number and
/// date shapes stay consistent between the profile card, the rewards page and
/// the history list.
class RewardFmt {
  RewardFmt._();

  static const List<String> _months = <String>[
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

  /// `12,450`
  static String points(int value) {
    final String digits = value.abs().toString();
    final StringBuffer buffer = StringBuffer(value < 0 ? '-' : '');
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// `NPR 500` — drops the decimals when the value is whole.
  static String money(double value, {String currency = 'NPR'}) {
    final bool isWhole = value == value.roundToDouble();
    final String amount = isWhole
        ? points(value.round())
        : value.toStringAsFixed(2);
    return '$currency $amount';
  }

  /// `Aug 05, 2026`
  static String date(DateTime value) =>
      '${_months[value.month - 1]} ${value.day.toString().padLeft(2, '0')}, ${value.year}';

  /// `Aug 05, 2026 · 04:30 PM`
  static String dateTime(DateTime value) {
    final int hour12 = value.hour % 12 == 0 ? 12 : value.hour % 12;
    final String minute = value.minute.toString().padLeft(2, '0');
    final String meridiem = value.hour < 12 ? 'AM' : 'PM';
    return '${date(value)} · ${hour12.toString().padLeft(2, '0')}:$minute $meridiem';
  }

  /// The discount a generated coupon carries, or an empty string when the
  /// server returned only a code.
  static String couponValue(GeneratedRewardCouponModel coupon) {
    if (coupon.discountPercent != null && coupon.discountPercent! > 0) {
      final double percent = coupon.discountPercent!;
      final String text = percent == percent.roundToDouble()
          ? percent.round().toString()
          : percent.toStringAsFixed(1);
      return '$text% off';
    }
    if (coupon.discountAmount != null && coupon.discountAmount! > 0) {
      return '${money(coupon.discountAmount!, currency: coupon.currency)} off';
    }
    return '';
  }
}

/// Icon and accent colour per history entry type.
extension RewardEntryTypeUi on RewardEntryType {
  IconData get icon => switch (this) {
    RewardEntryType.earned => Icons.add_circle_outline_rounded,
    RewardEntryType.redeemed => Icons.local_activity_outlined,
    RewardEntryType.expired => Icons.hourglass_disabled_rounded,
    RewardEntryType.adjusted => Icons.tune_rounded,
  };

  Color get color => switch (this) {
    RewardEntryType.earned => LightColor.secondaryColor,
    RewardEntryType.redeemed => LightColor.purpleColor,
    RewardEntryType.expired => LightColor.redColor,
    RewardEntryType.adjusted => LightColor.blueColor,
  };

  /// Used when the server does not label the row.
  String get fallbackTitle => switch (this) {
    RewardEntryType.earned => 'Points earned',
    RewardEntryType.redeemed => 'Points redeemed',
    RewardEntryType.expired => 'Points expired',
    RewardEntryType.adjusted => 'Points adjusted',
  };
}
