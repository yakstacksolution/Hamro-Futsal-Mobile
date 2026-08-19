import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Large NPR amount entry card with live thousands-separator formatting.
class ExpenseAmountCard extends StatelessWidget {
  const ExpenseAmountCard({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.showError,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool showError;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return GestureDetector(
      onTap: () => focusNode.requestFocus(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX20,
        ),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX14),
          border: Border.all(
            color: showError
                ? LightColor.redColor.withValues(alpha: 0.5)
                : LightColor.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  StringConstants.npr,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontSize: (textTheme.bodyTextMedium?.fontSize ?? 14) + 2,
                    color: LightColor.secondaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: AppDimens.paddingX8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [ThousandsInputFormatter()],
                    textAlign: TextAlign.start,
                    cursorColor: LightColor.secondaryColor,
                    style: textTheme.bodyTextLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: '0',
                      hintStyle: textTheme.bodyTextLarge?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: LightColor.disabledTextColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.paddingX6),
            Text(
              showError
                  ? 'Enter an amount greater than 0'
                  : 'Tap to enter the expense amount',
              style: textTheme.bodyTextSmall?.copyWith(
                color: showError
                    ? LightColor.redColor
                    : LightColor.hintTextColor,
                fontSize: AppDimens.fontBodySubTitle,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Label + value row that opens a picker (date, etc.).
class ExpensePickerRow extends StatelessWidget {
  const ExpensePickerRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingX14,
          vertical: AppDimens.paddingX14,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: LightColor.secondaryTextColor),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.hintTextColor,
                      fontSize: 11.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimens.paddingX8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: LightColor.hintTextColor,
            ),
          ],
        ),
      ),
    );
  }
}

class ExpenseFormDivider extends StatelessWidget {
  const ExpenseFormDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(height: 1, color: LightColor.dividerColor),
    );
  }
}
