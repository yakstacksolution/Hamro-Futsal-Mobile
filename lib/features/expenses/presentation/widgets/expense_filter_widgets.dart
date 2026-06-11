import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';

/// Compact selectable chip with haptic feedback, shared by all filter rows.
class ExpenseChip extends StatelessWidget {
  const ExpenseChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          // Scale content down instead of overflowing when the chip is
          // squeezed into a tight slot (e.g. equal-width period rows).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 12,
                    color: selected
                        ? LightColor.whiteColor
                        : LightColor.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: selected
                        ? LightColor.whiteColor
                        : LightColor.secondaryTextColor,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `Jun 1 – Jun 30 · 84 entries · NPR 145,200` context line.
class ExpenseContextLine extends StatelessWidget {
  const ExpenseContextLine({
    super.key,
    required this.range,
    required this.count,
    required this.total,
  });

  final ExpenseRange range;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final last = range.end.subtract(const Duration(days: 1));
    final sameDay = range.days == 1;
    final label = sameDay
        ? formatShortDate(range.start)
        : '${formatShortDate(range.start)} – ${formatShortDate(last)}';
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingX4),
      child: Text(
        '$label · $count entries · ${ExpenseFmt.npr(total)}',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

class ExpensePeriodChips extends StatelessWidget {
  const ExpensePeriodChips({
    super.key,
    required this.period,
    required this.customRange,
    required this.onPeriod,
    required this.onEditCustom,
  });

  final ExpensePeriod period;
  final DateTimeRange? customRange;
  final ValueChanged<ExpensePeriod> onPeriod;
  final VoidCallback onEditCustom;

  @override
  Widget build(BuildContext context) {
    // Single horizontally scrollable row, same pattern as the venue filter.
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: ExpensePeriod.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          final p = ExpensePeriod.values[i];
          return ExpenseChip(
            label: p == ExpensePeriod.custom && customRange != null
                ? '${customRange!.duration.inDays + 1}d'
                : p.label,
            selected: period == p,
            icon: p == ExpensePeriod.custom ? Icons.date_range_outlined : null,
            onTap: () {
              if (p == ExpensePeriod.custom && period == ExpensePeriod.custom) {
                onEditCustom();
              } else {
                onPeriod(p);
              }
            },
          );
        },
      ),
    );
  }
}

class ExpenseVenueFilter extends StatelessWidget {
  const ExpenseVenueFilter({
    super.key,
    required this.venues,
    required this.selectedId,
    required this.onChange,
  });

  final List<VenueModel> venues;
  final String? selectedId;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: venues.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return ExpenseChip(
              label: 'All venues',
              selected: selectedId == null,
              onTap: () => onChange(null),
            );
          }
          final v = venues[i - 1];
          return ExpenseChip(
            label: v.name,
            selected: selectedId == v.id,
            onTap: () => onChange(v.id),
          );
        },
      ),
    );
  }
}

/// Cash / Online payment-method filter — maps to the `payment_method` query
/// param. `null` = all methods.
class ExpensePaymentFilter extends StatelessWidget {
  const ExpensePaymentFilter({
    super.key,
    required this.selected,
    required this.onChange,
  });

  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod?> onChange;

  @override
  Widget build(BuildContext context) {
    const options = <(String, PaymentMethod?)>[
      ('All methods', null),
      ('Cash', PaymentMethod.cash),
      ('Online', PaymentMethod.online),
    ];
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          final (label, value) = options[i];
          return ExpenseChip(
            label: label,
            selected: selected == value,
            icon: value == null
                ? null
                : value == PaymentMethod.cash
                ? Icons.payments_outlined
                : Icons.credit_card_outlined,
            onTap: () => onChange(value),
          );
        },
      ),
    );
  }
}

class ExpenseCategoryFilterRow extends StatelessWidget {
  const ExpenseCategoryFilterRow({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChange,
  });

  /// Categories fetched from the `/expense-categories` API — the row renders
  /// only what the server returns (no static fallback) and hides itself
  /// while the list is empty.
  final List<ExpenseCategoryModel> categories;

  /// Selected server category id.
  final String? selected;
  final ValueChanged<String?> onChange;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppDimens.paddingX8),
        itemBuilder: (_, i) {
          if (i == 0) {
            return ExpenseChip(
              label: 'All',
              selected: selected == null,
              onTap: () => onChange(null),
            );
          }
          final c = categories[i - 1];
          // Records are keyed by the server category id, so the chip
          // filters by id directly.
          return ExpenseChip(
            label: c.name,
            selected: selected == c.id,
            onTap: () => onChange(selected == c.id ? null : c.id),
          );
        },
      ),
    );
  }
}
