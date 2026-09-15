import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';

/// Account-screen formatting. The money and date spellings come from the
/// shared [Money] and [DateFmt] so this screen and the booking lists cannot
/// drift apart; the names are kept for the call sites that already use them.
class AccountFmt {
  /// `NPR 11,711.99` — paisa only when there are any.
  static String npr(num v) => Money.npr(v);

  /// Plain, ungrouped value for a text field: `11711.99` / `1200`.
  static String amountInput(double v) => Money.amountInput(v);

  /// e.g. `Sep 03, 2026`.
  static String date(DateTime d) => DateFmt.date(d);

  /// e.g. `9:31 PM`.
  static String time(DateTime d) => DateFmt.time(d);

  /// e.g. `Aug 20, 2026 · 9:31 PM`.
  static String dateTime(DateTime d) => DateFmt.dateTime(d);

  /// A statement section heading: `TODAY · 12 SEP 2026`.
  static String sectionDay(DateTime d, {DateTime? now}) =>
      DateFmt.sectionDay(d, now: now);

  /// The day a row belongs to, ignoring the time.
  static DateTime dayOf(DateTime d) => DateFmt.dayOf(d);
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
