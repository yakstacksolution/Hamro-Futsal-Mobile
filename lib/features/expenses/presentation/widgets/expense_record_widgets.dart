import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';

/// Lazily-built, day-grouped records list. Only the day-cards near the
/// viewport are instantiated.
class ExpenseRecordsSliver extends StatelessWidget {
  const ExpenseRecordsSliver({
    super.key,
    required this.expenses,
    required this.venues,
    required this.hasFilters,
    required this.onTap,
    required this.onAdd,
    required this.onClearFilters,
  });

  final List<ExpenseModel> expenses;
  final List<VenueModel> venues;
  final bool hasFilters;
  final ValueChanged<ExpenseModel> onTap;
  final VoidCallback onAdd;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX20),
        sliver: SliverToBoxAdapter(
          child: ExpenseEmptyState(
            title: hasFilters ? 'No matching records' : 'No records yet',
            message: hasFilters
                ? 'Try a different period, venue or category.'
                : 'Expenses you add will show up here.',
            actionLabel: hasFilters ? 'Clear filters' : 'Add expense',
            onAction: hasFilters ? onClearFilters : onAdd,
          ),
        ),
      );
    }

    final byDay = <DateTime, List<ExpenseModel>>{};
    for (final e in expenses) {
      final k = DateTime(e.date.year, e.date.month, e.date.day);
      byDay.putIfAbsent(k, () => []).add(e);
    }
    final days = byDay.keys.toList()..sort((a, b) => b.compareTo(a));

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX20),
      sliver: SliverList.separated(
        itemCount: days.length,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppDimens.paddingX10),
        itemBuilder: (_, i) => _DayGroupCard(
          date: days[i],
          expenses: byDay[days[i]]!,
          venues: venues,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DayGroupCard extends StatelessWidget {
  const _DayGroupCard({
    required this.date,
    required this.expenses,
    required this.venues,
    required this.onTap,
  });

  final DateTime date;
  final List<ExpenseModel> expenses;
  final List<VenueModel> venues;
  final ValueChanged<ExpenseModel> onTap;

  @override
  Widget build(BuildContext context) {
    return ExpenseSurface(
      padding: const EdgeInsets.symmetric(vertical: AppDimens.paddingX4),
      child: Column(
        children: [
          _DateHeader(date: date, expenses: expenses),
          for (final e in expenses)
            _ExpenseTile(
              expense: e,
              venueName: venues
                  .firstWhere(
                    (v) => v.id == e.venueId,
                    orElse: () => const VenueModel(id: '?', name: '—'),
                  )
                  .name,
              onTap: () => onTap(e),
            ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date, required this.expenses});

  final DateTime date;
  final List<ExpenseModel> expenses;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final sum = expenses.fold<int>(0, (a, e) => a + e.amount);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Day-difference comparison handles month/year boundaries correctly.
    final diff = today.difference(date).inDays;
    final isToday = diff == 0;
    final isYesterday = diff == 1;
    final label = isToday
        ? 'Today'
        : isYesterday
        ? 'Yesterday'
        : '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}';

    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX14,
        symmetricVertical: AppDimens.paddingX10,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const Spacer(),
          Text(
            ExpenseFmt.npr(sum),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    required this.expense,
    required this.venueName,
    required this.onTap,
  });

  final ExpenseModel expense;
  final String venueName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX14,
          symmetricVertical: AppDimens.paddingX10,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: expense.category.color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              ),
              child: Icon(
                expense.category.icon,
                color: expense.category.color,
                size: 18,
              ),
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
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        expense.category.label,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: expense.category.color,
                          fontWeight: FontWeight.w600,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                      const _MetaSeparator(),
                      Flexible(
                        child: Text(
                          venueName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.hintTextColor,
                            fontSize: AppDimens.fontBodySubTitle,
                          ),
                        ),
                      ),
                      const _MetaSeparator(),
                      Text(
                        expense.method.label,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                    ],
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
      ),
    );
  }
}

class _MetaSeparator extends StatelessWidget {
  const _MetaSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          color: LightColor.hintTextColor,
          fontSize: AppDimens.fontBodySubTitle,
        ),
      ),
    );
  }
}
