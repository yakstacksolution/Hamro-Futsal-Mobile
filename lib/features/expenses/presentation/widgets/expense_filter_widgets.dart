import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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
                        ? LightColor.inverseTextColor
                        : LightColor.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  label,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: selected
                        ? LightColor.inverseTextColor
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

/// Time-period + payment-method dropdowns side by side in a single row.
///
/// The left dropdown drives the `date_filter` query
/// (today / week / month / year / custom) and the right one the
/// `payment_method` query (`null` = all methods).
class ExpenseFilterDropdownRow extends StatelessWidget {
  const ExpenseFilterDropdownRow({
    super.key,
    required this.period,
    required this.customRange,
    required this.onPeriod,
    required this.onEditCustom,
    required this.paymentMethod,
    required this.onPaymentMethod,
  });

  final ExpensePeriod period;
  final DateTimeRange? customRange;
  final ValueChanged<ExpensePeriod> onPeriod;
  final VoidCallback onEditCustom;
  final PaymentMethod? paymentMethod;
  final ValueChanged<PaymentMethod?> onPaymentMethod;

  @override
  Widget build(BuildContext context) {
    final periodLabel = period == ExpensePeriod.custom && customRange != null
        ? 'Custom · ${customRange!.duration.inDays + 1}d'
        : period.label;
    return Row(
      children: [
        Expanded(
          child: ExpenseFilterDropdown(
            icon: Icons.calendar_today_outlined,
            label: periodLabel,
            options: [
              for (final p in ExpensePeriod.values) (p.label, p == period),
            ],
            onSelect: (i) {
              final p = ExpensePeriod.values[i];
              // Re-picking Custom re-opens the date-range editor.
              if (p == ExpensePeriod.custom && period == ExpensePeriod.custom) {
                onEditCustom();
              } else {
                onPeriod(p);
              }
            },
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        Expanded(
          child: ExpenseFilterDropdown(
            icon: switch (paymentMethod) {
              PaymentMethod.cash => Icons.payments_outlined,
              PaymentMethod.online => Icons.credit_card_outlined,
              null => Icons.account_balance_wallet_outlined,
            },
            label: paymentMethod?.label ?? 'All methods',
            active: paymentMethod != null,
            options: [
              ('All methods', paymentMethod == null),
              for (final m in PaymentMethod.values)
                (m.label, m == paymentMethod),
            ],
            onSelect: (i) =>
                onPaymentMethod(i == 0 ? null : PaymentMethod.values[i - 1]),
          ),
        ),
      ],
    );
  }
}

/// Compact dropdown button matching the [ExpenseChip] look. Options are
/// `(label, selected)` pairs; [onSelect] receives the tapped index.
class ExpenseFilterDropdown extends StatelessWidget {
  const ExpenseFilterDropdown({
    super.key,
    required this.icon,
    required this.label,
    required this.options,
    required this.onSelect,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final List<(String, bool)> options;
  final ValueChanged<int> onSelect;

  /// Tints the button like a selected chip when a narrowing value is chosen.
  final bool active;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final fg = active ? LightColor.inverseTextColor : LightColor.secondaryTextColor;
    return PopupMenuButton<int>(
      onSelected: (i) {
        HapticFeedback.selectionClick();
        onSelect(i);
      },
      position: PopupMenuPosition.under,
      color: LightColor.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      constraints: const BoxConstraints(minWidth: AppDimens.sizeX160),
      itemBuilder: (_) => [
        for (var i = 0; i < options.length; i++)
          PopupMenuItem<int>(
            value: i,
            height: AppDimens.sizeX40,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    options[i].$1,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: options[i].$2
                          ? LightColor.secondaryColor
                          : LightColor.primaryTextColor,
                      fontWeight: options[i].$2
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (options[i].$2)
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: LightColor.secondaryColor,
                  ),
              ],
            ),
          ),
      ],
      // Mirror the [ExpenseChip] look so the row sits flush with the venue
      // and category chip rows below it.
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: AppDimens.sizeX32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: active ? LightColor.secondaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.radiusX20),
          border: Border.all(
            color: active ? LightColor.secondaryColor : LightColor.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: fg,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: fg),
          ],
        ),
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
              label: StringConstants.allVenues,
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
              label: StringConstants.all,
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
