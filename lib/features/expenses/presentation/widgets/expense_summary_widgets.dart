import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/models/expense_analytics.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

/// Total-spend hero card: animated count-up total, period-over-period trend
/// pill and a sparkline of the current series.
class ExpenseHeroCard extends StatelessWidget {
  const ExpenseHeroCard({super.key, required this.analytics});

  final ExpenseAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final delta = analytics.total - analytics.prevTotal;
    final pct = analytics.prevTotal == 0
        ? null
        : (delta / analytics.prevTotal) * 100;
    // For expenses, up = bad, down = good.
    final up = delta > 0;

    return ExpenseSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.redColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: LightColor.redColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                'Total expenses',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (pct != null) ExpenseTrendPill(value: pct, up: up),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          // Count-up animation; re-animates from the previous total whenever
          // the filtered total changes.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: analytics.total.toDouble()),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            builder: (_, value, __) => Text(
              ExpenseFmt.npr(value.round()),
              style: textTheme.bodyTextLarge?.copyWith(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'vs ${ExpenseFmt.npr(analytics.prevTotal)} previous period',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 56,
            child: RepaintBoundary(
              child: SfSparkAreaChart(
                data: analytics.series
                    .map((b) => b.value)
                    .toList(growable: false),
                color: LightColor.redColor.withValues(alpha: 0.12),
                borderColor: LightColor.redColor,
                borderWidth: 2,
                axisLineWidth: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Percentage delta pill — red when spend went up, green when it went down.
class ExpenseTrendPill extends StatelessWidget {
  const ExpenseTrendPill({super.key, required this.value, required this.up});

  final double value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final color = up ? LightColor.redColor : LightColor.secondaryColor;
    final bg = up
        ? LightColor.redLightColor
        : LightColor.secondaryColor.withValues(alpha: 0.10);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${value.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: AppDimens.fontBodySubTitle,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Four-up snapshot grid: avg/day, entries, top category and top venue.
class ExpenseKpiGrid extends StatelessWidget {
  const ExpenseKpiGrid({
    super.key,
    required this.analytics,
    required this.venues,
  });

  final ExpenseAnalytics analytics;
  final List<VenueModel> venues;

  @override
  Widget build(BuildContext context) {
    final largestCat = analytics.largestCategory;
    final largestVenueId = analytics.largestVenueId;
    final largestVenue = largestVenueId == null
        ? null
        : venues.firstWhere(
            (v) => v.id == largestVenueId,
            orElse: () => const VenueModel(id: '?', name: '—'),
          );

    final items = <_Kpi>[
      _Kpi(
        icon: Icons.functions_rounded,
        label: 'Avg / day',
        value: ExpenseFmt.npr(analytics.avgPerDay),
        sub: '${analytics.range.days} days in range',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.format_list_numbered_rounded,
        label: 'Entries',
        value: '${analytics.count}',
        sub: 'Avg ${ExpenseFmt.npr(analytics.avgPerEntry)} / entry',
        accent: LightColor.blueColor,
      ),
      _Kpi(
        icon: largestCat?.icon ?? Icons.category_outlined,
        label: 'Top category',
        value: largestCat?.label ?? '—',
        sub: largestCat == null
            ? 'No expenses yet'
            : ExpenseFmt.npr(analytics.byCategory[largestCat] ?? 0),
        accent: largestCat?.color ?? LightColor.iconGrey,
      ),
      _Kpi(
        icon: Icons.stadium_outlined,
        label: 'Top venue',
        value: largestVenue?.name ?? '—',
        sub: largestVenueId == null
            ? 'No expenses yet'
            : ExpenseFmt.npr(analytics.byVenue[largestVenueId] ?? 0),
        accent: LightColor.warningColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        const spacing = AppDimens.paddingX10;
        final w = (c.maxWidth - spacing) / 2;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: items.map((k) => SizedBox(width: w, child: k)).toList(),
        );
      },
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return ExpenseSurface(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
