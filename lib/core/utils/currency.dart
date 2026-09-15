import 'package:hamro_futsal/core/utils/string_constants.dart';

/// Money formatting shared across features.
///
/// Lives in core because the ledger and the booking lists show the same
/// figures and must spell them identically — a card reading `NPR 1,200` next
/// to one reading `Rs. 1200` is what makes two screens look like two products.
class Money {
  const Money._();

  /// `NPR 11,711.99` — paisa are shown only when there are any, so a
  /// whole-rupee figure stays clean.
  static String npr(num v) {
    final double abs = v.abs().toDouble();
    final bool whole = abs == abs.roundToDouble();
    final String digits = abs.truncate().toString();
    final String paisa = whole
        ? ''
        : '.${((abs - abs.truncate()) * 100).round().toString().padLeft(2, '0')}';
    return '${v < 0 ? '-' : ''}${StringConstants.npr} ${group(digits)}$paisa';
  }

  /// Plain, ungrouped value for a text field: `11711.99` / `1200`.
  static String amountInput(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  /// Thousands separators.
  static String group(String digits) {
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
