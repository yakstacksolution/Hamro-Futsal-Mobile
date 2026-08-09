import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';

class AccountFmt {
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
      '${v < 0 ? '-' : ''}NPR ${_group(v.abs().toString())}';

  static String _group(String digits) {
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  /// e.g. `May 03, 2026`.
  static String date(DateTime d) =>
      '${_months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
}

/// Visual identity (icon + accent) for each ledger entry type.
extension AccountEntryTypeUi on AccountEntryType {
  IconData get icon => switch (this) {
    AccountEntryType.bookingIncome => Icons.event_available_rounded,
    AccountEntryType.opponentMatchIncome => Icons.sports_soccer_rounded,
    AccountEntryType.commission => Icons.percent_rounded,
    AccountEntryType.settlement => Icons.account_balance_rounded,
    AccountEntryType.refund => Icons.replay_rounded,
    AccountEntryType.adjustment => Icons.tune_rounded,
  };

  Color get color => switch (this) {
    AccountEntryType.bookingIncome => LightColor.secondaryColor,
    AccountEntryType.opponentMatchIncome =>
      LightColor.categoryAccent(LightColor.secondaryDark),
    AccountEntryType.commission => LightColor.purpleColor,
    AccountEntryType.settlement => LightColor.blueColor,
    AccountEntryType.refund => LightColor.warningColor,
    AccountEntryType.adjustment => LightColor.secondaryTextColor,
  };

  String get fallbackTitle => switch (this) {
    AccountEntryType.bookingIncome => 'Booking income',
    AccountEntryType.opponentMatchIncome => 'Opponent match income',
    AccountEntryType.commission => 'Platform commission',
    AccountEntryType.settlement => 'Settlement payout',
    AccountEntryType.refund => 'Refund',
    AccountEntryType.adjustment => 'Adjustment',
  };
}

extension SettlementStatusUi on SettlementStatus {
  String get label => switch (this) {
    SettlementStatus.pending => 'Pending',
    SettlementStatus.processing => 'Processing',
    SettlementStatus.approved => 'Approved',
    SettlementStatus.paid => 'Paid',
    SettlementStatus.rejected => 'Rejected',
    SettlementStatus.cancelled => 'Cancelled',
    SettlementStatus.failed => 'Failed',
  };

  IconData get icon => switch (this) {
    SettlementStatus.pending => Icons.hourglass_top_rounded,
    SettlementStatus.processing => Icons.sync_rounded,
    SettlementStatus.approved => Icons.thumb_up_alt_rounded,
    SettlementStatus.paid => Icons.check_circle_rounded,
    SettlementStatus.rejected => Icons.cancel_rounded,
    SettlementStatus.cancelled => Icons.block_rounded,
    SettlementStatus.failed => Icons.error_rounded,
  };

  Color get color => switch (this) {
    SettlementStatus.pending => LightColor.warningColor,
    SettlementStatus.processing => LightColor.blueColor,
    SettlementStatus.approved => LightColor.blueColor,
    SettlementStatus.paid => LightColor.secondaryColor,
    SettlementStatus.rejected => LightColor.redColor,
    SettlementStatus.cancelled => LightColor.secondaryTextColor,
    SettlementStatus.failed => LightColor.redColor,
  };
}
