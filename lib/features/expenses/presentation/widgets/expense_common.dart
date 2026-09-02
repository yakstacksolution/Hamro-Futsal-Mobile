import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

/// Standard card surface used across the expenses feature.
class ExpenseSurface extends StatelessWidget {
  const ExpenseSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppDimens.paddingX14),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX14),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ExpenseSectionLabel extends StatelessWidget {
  const ExpenseSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX2,
        bottom: AppDimens.paddingX8,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

/// Rich empty state with an optional contextual call to action.
class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return ExpenseSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX20,
        vertical: AppDimens.paddingX24,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 22,
              color: LightColor.secondaryColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppDimens.paddingX14),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: LightColor.secondaryColor,
                side: const BorderSide(color: LightColor.secondaryColor),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX16,
                  vertical: AppDimens.paddingX8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
              ),
              child: Text(
                actionLabel!,
                style: textTheme.bodyTextSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.secondaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
