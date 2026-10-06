import 'package:hamro_futsal/core/utils/string_constants.dart';

class Money {
  const Money._();

  static String npr(num v) {
    final double abs = v.abs().toDouble();
    final bool whole = abs == abs.roundToDouble();
    final String digits = abs.truncate().toString();
    final String paisa = whole
        ? ''
        : '.${((abs - abs.truncate()) * 100).round().toString().padLeft(2, '0')}';
    return '${v < 0 ? '-' : ''}${StringConstants.npr} ${group(digits)}$paisa';
  }

  static String amountInput(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

  static String group(String digits) {
    final StringBuffer buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}
