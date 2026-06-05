import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';

/// Bottom sheet showing an expense's full details with a delete action.
/// Pops with [ExpenseDetailsSheet.deleteAction] when delete is tapped.
class ExpenseDetailsSheet extends StatelessWidget {
  const ExpenseDetailsSheet({
    super.key,
    required this.expense,
    required this.venueName,
  });

  static const deleteAction = 'delete';

  final ExpenseModel expense;
  final String venueName;

  String get _dateLabel {
    final d = expense.date;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${formatShortDate(d)}, ${d.year} · ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final category = expense.category;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.paddingX20,
          AppDimens.paddingX12,
          AppDimens.paddingX20,
          AppDimens.paddingX20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: LightColor.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  ),
                  child: Icon(category.icon, color: category.color, size: 20),
                ),
                const SizedBox(width: AppDimens.paddingX12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.vendor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: LightColor.primaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        category.label,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: category.color,
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX10),
                Text(
                  '- ${ExpenseFmt.npr(expense.amount)}',
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.redColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX14),
            const Divider(height: 1, color: LightColor.dividerColor),
            const SizedBox(height: AppDimens.paddingX6),
            _DetailRow(label: 'Date', value: _dateLabel),
            _DetailRow(label: 'Venue', value: venueName),
            _DetailRow(label: 'Paid via', value: expense.method.label),
            if (expense.note != null)
              _DetailRow(label: 'Note', value: expense.note!),
            const SizedBox(height: AppDimens.paddingX16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(deleteAction),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LightColor.redColor,
                  side: BorderSide(
                    color: LightColor.redColor.withValues(alpha: 0.4),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimens.paddingX12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  ),
                ),
                label: Text(
                  'Delete expense',
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.redColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.hintTextColor,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyTextSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: LightColor.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
