import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';

/// Visual identity (icon + accent color) for each expense category.
extension ExpenseCategoryUi on ExpenseCategory {
  IconData get icon => switch (this) {
    ExpenseCategory.rent => Icons.home_work_outlined,
    ExpenseCategory.maintenance => Icons.build_outlined,
    ExpenseCategory.salaries => Icons.badge_outlined,
    ExpenseCategory.supplies => Icons.inventory_2_outlined,
    ExpenseCategory.marketing => Icons.campaign_outlined,
    ExpenseCategory.refreshments => Icons.local_cafe_outlined,
    ExpenseCategory.insurance => Icons.shield_outlined,
    ExpenseCategory.utilities => Icons.bolt_outlined,
    ExpenseCategory.other => Icons.more_horiz_rounded,
  };

  Color get color => switch (this) {
    ExpenseCategory.rent => const Color(0xFF2C7969),
    ExpenseCategory.maintenance => const Color(0xFFE0922A),
    ExpenseCategory.salaries => const Color(0xFF3B82F6),
    ExpenseCategory.supplies => const Color(0xFF8B5CF6),
    ExpenseCategory.marketing => const Color(0xFFE5407A),
    ExpenseCategory.refreshments => const Color(0xFFEAB308),
    ExpenseCategory.insurance => const Color(0xFF14B8A6),
    ExpenseCategory.utilities => const Color(0xFFEF4444),
    ExpenseCategory.other => const Color(0xFF6B7280),
  };
}

class ExpenseFmt {
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
}

/// Live thousands-separator formatting for amount fields (max 9 digits).
class ThousandsInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 9) digits = digits.substring(0, 9);
    if (digits.isEmpty) return TextEditingValue.empty;
    final text = ExpenseFmt.group(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// e.g. `Jun 4`.
String formatShortDate(DateTime d) {
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
  return '${m[d.month - 1]} ${d.day}';
}
