import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Daily/monthly spend column chart with tracks and tap tooltips.
class ExpenseTrendCard extends StatelessWidget {
  const ExpenseTrendCard({super.key, required this.analytics});

  final ExpenseAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final buckets = analytics.series;
    final values = buckets.map((b) => b.value).toList(growable: false);
    final maxV = values.fold<int>(0, (a, b) => a > b ? a : b);
    final avg = buckets.isEmpty
        ? 0
        : (buckets.fold<int>(0, (a, b) => a + b.value) / buckets.length)
              .round();

    return ExpenseSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                switch (analytics.period) {
                  ExpensePeriod.year => 'Monthly spend',
                  ExpensePeriod.today => 'Hourly spend',
                  _ => 'Daily spend',
                },
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
            // period/filter changes the series.
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
                  ColumnSeries<ChartBucket, String>(
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
        final b = data as ChartBucket;
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
    required this.analytics,
    required this.selectedCategory,
    required this.onSelect,
  });

  final ExpenseAnalytics analytics;

  final String? selectedCategory;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final entries = analytics.byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = entries.fold<int>(0, (a, b) => a + b.value);

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
                        entries.map((e) => Object.hash(e.key, e.value)),
                      ),
                    ),
                    margin: EdgeInsets.zero,
                    tooltipBehavior: _donutTooltip(total),
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
                      DoughnutSeries<MapEntry<String, int>, String>(
                        dataSource: entries,
                        xValueMapper: (e, _) => analytics.categoryName(e.key),
                        yValueMapper: (e, _) => e.value,
                        pointColorMapper: (e, _) =>
                            analytics.categoryEnumOf(e.key).color,
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
                          color: analytics.categoryEnumOf(e.key).color,
                          label: analytics.categoryName(e.key),
                          pct: total == 0 ? 0 : e.value / total,
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
              categoryId: e.key,
              category: analytics.categoryEnumOf(e.key),
              label: analytics.categoryName(e.key),
              amount: e.value,
              fraction: total == 0 ? 0 : e.value / total,
              isSelected: selectedCategory == e.key,
              onTap: () => onSelect(selectedCategory == e.key ? null : e.key),
            ),
        ],
      ),
    );
  }

  TooltipBehavior _donutTooltip(int total) {
    return TooltipBehavior(
      enable: true,
      builder: (data, point, series, pointIndex, seriesIndex) {
        final e = data as MapEntry<String, int>;
        final pct = total == 0 ? 0 : (e.value / total * 100).round();
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
            '${analytics.categoryName(e.key)} · ${ExpenseFmt.npr(e.value)} ($pct%)',
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
