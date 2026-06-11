import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Hourly/daily/monthly spend column chart with tracks and tap tooltips,
/// driven by the server-computed [ExpenseReport.trend].
class ExpenseTrendCard extends StatelessWidget {
  const ExpenseTrendCard({super.key, required this.report});

  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final buckets = report.trend.buckets;
    final values = buckets.map((b) => b.value).toList(growable: false);
    final maxV = values.fold<int>(0, (a, b) => a > b ? a : b);
    final avg = report.trend.avg;

    if (buckets.isEmpty) {
      return const ExpenseEmptyState(
        title: 'No trend yet',
        message: 'No expenses recorded for this range.',
      );
    }

    return ExpenseSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                report.trend.title,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                'Avg ${ExpenseFmt.npr(avg)}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 170,
            // Key on the data so the grow-in animation restarts whenever the
            // filter changes the series.
            child: RepaintBoundary(
              child: SfCartesianChart(
                key: ValueKey(Object.hashAll(values)),
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  arrangeByIndex: true,
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: const TextStyle(
                    color: LightColor.hintTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                  ),
                  // Thin out labels on dense daily series; show all months.
                  interval: buckets.length > 12
                      ? (buckets.length / 4).ceilToDouble()
                      : 1,
                  labelIntersectAction: AxisLabelIntersectAction.hide,
                ),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  maximum: maxV == 0 ? 1 : null,
                ),
                tooltipBehavior: _tooltip(),
                series: [
                  ColumnSeries<ExpenseTrendBucket, String>(
                    dataSource: buckets,
                    xValueMapper: (b, _) => b.label,
                    yValueMapper: (b, _) => b.value,
                    color: LightColor.secondaryColor,
                    width: 0.7,
                    isTrackVisible: true,
                    trackColor: LightColor.dividerColor.withValues(alpha: 0.4),
                    trackBorderWidth: 0,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    animationDuration: 700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TooltipBehavior _tooltip() {
    return TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final b = data as ExpenseTrendBucket;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          decoration: BoxDecoration(
            color: LightColor.primaryTextColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Text(
            '${b.label} · ${ExpenseFmt.npr(b.value)}',
            style: const TextStyle(
              color: LightColor.whiteColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

class ExpenseCategoryCard extends StatelessWidget {
  const ExpenseCategoryCard({
    super.key,
    required this.report,
    required this.selectedCategory,
    required this.onSelect,
  });

  final ExpenseReport report;

  final String? selectedCategory;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final entries = report.byCategory;

    if (entries.isEmpty) {
      return const ExpenseEmptyState(
        title: 'Nothing to break down',
        message: 'No expenses recorded for this range.',
      );
    }

    return ExpenseSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: RepaintBoundary(
                  child: SfCircularChart(
                    key: ValueKey(
                      Object.hashAll(
                        entries.map((e) => Object.hash(e.id, e.amount)),
                      ),
                    ),
                    margin: EdgeInsets.zero,
                    tooltipBehavior: _donutTooltip(),
                    annotations: [
                      CircularChartAnnotation(
                        widget: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${entries.length}',
                              style: textTheme.bodyTextLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: LightColor.primaryTextColor,
                              ),
                            ),
                            Text(
                              'cats',
                              style: textTheme.bodyTextSmall?.copyWith(
                                fontSize: AppDimens.fontBodySubTitle,
                                color: LightColor.hintTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    series: [
                      DoughnutSeries<ExpenseCategorySpend, String>(
                        dataSource: entries,
                        xValueMapper: (e, _) => e.title,
                        yValueMapper: (e, _) => e.amount,
                        pointColorMapper: (e, _) => e.asEnum.color,
                        innerRadius: '74%',
                        radius: '100%',
                        animationDuration: 700,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final e in entries.take(4))
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppDimens.paddingX6,
                        ),
                        child: _LegendDot(
                          color: e.asEnum.color,
                          label: e.title,
                          pct: e.fraction,
                        ),
                      ),
                    if (entries.length > 4)
                      Text(
                        '+ ${entries.length - 4} more',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.hintTextColor,
                          fontSize: AppDimens.fontBodySubTitle,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          const Divider(
            height: 1,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          const SizedBox(height: AppDimens.paddingX10),
          for (final e in entries)
            _CategoryRow(
              categoryId: e.id,
              category: e.asEnum,
              label: e.title,
              amount: e.amount,
              fraction: e.fraction,
              isSelected: selectedCategory == e.id,
              onTap: () => onSelect(selectedCategory == e.id ? null : e.id),
            ),
        ],
      ),
    );
  }

  TooltipBehavior _donutTooltip() {
    return TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final e = data as ExpenseCategorySpend;
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX6,
          ),
          decoration: BoxDecoration(
            color: LightColor.primaryTextColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
          child: Text(
            '${e.title} · ${ExpenseFmt.npr(e.amount)} '
            '(${e.percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(
              color: LightColor.whiteColor,
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

/// Compact court-spend breakdown — name, amount and a percentage bar per
/// court, from the server-computed [ExpenseReport.byCourt].
class ExpenseCourtCard extends StatelessWidget {
  const ExpenseCourtCard({super.key, required this.report});

  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final courts = report.byCourt;
    if (courts.isEmpty) return const SizedBox.shrink();

    return ExpenseSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, c) in courts.indexed) ...[
            if (i > 0) const SizedBox(height: AppDimens.paddingX12),
            Row(
              children: [
                const Icon(
                  Icons.stadium_outlined,
                  size: 16,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: AppDimens.paddingX8),
                Expanded(
                  child: Text(
                    c.name.isEmpty ? '—' : c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: LightColor.primaryTextColor,
                    ),
                  ),
                ),
                Text(
                  ExpenseFmt.npr(c.amount),
                  style: textTheme.bodyTextSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: Container(
                height: 5,
                color: LightColor.dividerColor.withValues(alpha: 0.5),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: c.fraction.clamp(0.0, 1.0),
                  child: Container(color: LightColor.secondaryColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    required this.pct,
  });

  final Color color;
  final String label;
  final double pct;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppDimens.paddingX6),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          '${(pct * 100).toStringAsFixed(0)}%',
          style: textTheme.bodyTextSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: LightColor.primaryTextColor,
            fontSize: AppDimens.fontBodySubTitle,
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categoryId,
    required this.category,
    required this.label,
    required this.amount,
    required this.fraction,
    required this.isSelected,
    required this.onTap,
  });

  final String categoryId;

  final ExpenseCategory category;

  final String label;
  final int amount;
  final double fraction;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ExpenseCategoryIcon(
                category: category,
                categoryId: categoryId,
                boxSize: 38,
                iconSize: 18,
                radius: AppDimens.radiusX8,
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: textTheme.bodyTextSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ExpenseFmt.npr(amount),
                          style: textTheme.bodyTextSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Container(
                        height: 5,
                        color: LightColor.dividerColor.withValues(alpha: 0.5),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: fraction.clamp(0.0, 1.0),
                          child: Container(color: category.color),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: AppDimens.paddingX8),
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: category.color,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
