import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';

class AccountFmt {
  static String npr(num v) => Money.npr(v);

  static String amountInput(double v) => Money.amountInput(v);

  static String date(DateTime d) => DateFmt.date(d);

  static String time(DateTime d) => DateFmt.time(d);

  static String dateTime(DateTime d) => DateFmt.dateTime(d);

  static String sectionDay(DateTime d, {DateTime? now}) =>
      DateFmt.sectionDay(d, now: now);

  static DateTime dayOf(DateTime d) => DateFmt.dayOf(d);
}

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
    AccountEntryType.bookingIncome => LightColor.brandTextColor,
    AccountEntryType.opponentMatchIncome => LightColor.categoryAccent(
      LightColor.secondaryDark,
    ),
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
    SettlementStatus.paid => LightColor.brandTextColor,
    SettlementStatus.rejected => LightColor.redColor,
    SettlementStatus.cancelled => LightColor.secondaryTextColor,
    SettlementStatus.failed => LightColor.redColor,
  };
}
