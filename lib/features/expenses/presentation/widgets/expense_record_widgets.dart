import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';

class ExpenseRecordsSliver extends StatelessWidget {
  const ExpenseRecordsSliver({
    super.key,
    required this.expenses,
    required this.venues,
    this.courts = const [],
    required this.hasFilters,
    required this.onTap,
    required this.onAdd,
    required this.onClearFilters,
  });

  final List<ExpenseModel> expenses;
  final List<VenueModel> venues;
  final List<CourtModel> courts;
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
            const SizedBox(height: AppDimens.paddingX16),
        itemBuilder: (_, i) => _DaySection(
          date: days[i],
          expenses: byDay[days[i]]!,
          venues: venues,
          courts: courts,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.date,
    required this.expenses,
    required this.venues,
    required this.courts,
    required this.onTap,
  });

  final DateTime date;
  final List<ExpenseModel> expenses;
  final List<VenueModel> venues;
  final List<CourtModel> courts;
  final ValueChanged<ExpenseModel> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DayHeader(date: date, expenses: expenses),
        const SizedBox(height: AppDimens.paddingX8),
        for (final (i, e) in expenses.indexed) ...[
          if (i > 0) const SizedBox(height: AppDimens.paddingX8),
          _ExpenseCard(
            expense: e,
            venueName:
                e.venueName ??
                venues
                    .firstWhere(
                      (v) => v.id == e.venueId,
                      orElse: () => const VenueModel(id: '?', name: '—'),
                    )
                    .name,
            courtName:
                e.courtName ??
                (e.courtId == null
                    ? null
                    : courts.where((c) => c.id == e.courtId).firstOrNull?.name),
            onTap: () => onTap(e),
          ),
        ],
      ],
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.date, required this.expenses});

  final DateTime date;
  final List<ExpenseModel> expenses;

  static const _months = [
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
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final sum = expenses.fold<int>(0, (a, e) => a + e.amount);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Day-difference comparison handles month/year boundaries correctly.
    final diff = today.difference(date).inDays;
    final label = diff == 0
        ? 'TODAY'
        : diff == 1
        ? 'YESTERDAY'
        : '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]}'
              .toUpperCase();

    return Padding(
      padding: AppUtils().getPadding(symmetricHorizontal: AppDimens.paddingX2),
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.secondaryTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX8),
          Text(
            '· ${expenses.length} ${expenses.length == 1 ? 'entry' : 'entries'}',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const Spacer(),
          Text(
            ExpenseFmt.npr(sum),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.venueName,
    this.courtName,
    required this.onTap,
  });

  final ExpenseModel expense;
  final String venueName;
  final String? courtName;
  final VoidCallback onTap;

  String get _time {
    final t = expense.date;
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final accent = expense.category.color;

    return Material(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
            boxShadow: [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimens.radiusX12),
                      bottomLeft: Radius.circular(AppDimens.radiusX12),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.paddingX12,
                      AppDimens.paddingX10,
                      AppDimens.paddingX12,
                      AppDimens.paddingX10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ExpenseCategoryIcon(
                          category: expense.category,
                          categoryId: expense.categoryId,
                          boxSize: 40,
                          iconSize: 18,
                          radius: AppDimens.radiusX8,
                        ),
                        const SizedBox(width: AppDimens.paddingX10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      expense.vendor,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyTextMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: LightColor.primaryTextColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: AppDimens.paddingX10),
                                  Text(
                                    '- ${ExpenseFmt.npr(expense.amount)}',
                                    style: textTheme.bodyTextMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: LightColor.redColor,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text:
                                          expense.categoryDetail?.name ??
                                          expense.category.label,
                                      style: textTheme.bodyTextSmall?.copyWith(
                                        color: accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppDimens.fontBodySubTitle,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' · ${expense.method.label} · $_time',
                                      style: textTheme.bodyTextSmall?.copyWith(
                                        color: LightColor.secondaryTextColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: AppDimens.fontBodySubTitle,
                                      ),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: LightColor.hintTextColor,
                                  ),
                                  const SizedBox(width: AppDimens.paddingX4),
                                  Flexible(
                                    child: Text(
                                      courtName == null
                                          ? venueName
                                          : '$venueName · $courtName',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textTheme.bodyTextSmall?.copyWith(
                                        color: LightColor.hintTextColor,
                                        fontSize: AppDimens.fontBodySubTitle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
