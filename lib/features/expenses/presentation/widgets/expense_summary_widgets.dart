import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_model.dart';
import 'package:hamro_footsall/features/expenses/data/model/expense_report_model.dart';
import 'package:hamro_footsall/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_footsall/features/expenses/presentation/widgets/expense_common.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Total-spend hero card: animated count-up total, per-day/entries subtitle
/// and a sparkline of the server-computed trend series.
class ExpenseHeroCard extends StatelessWidget {
  const ExpenseHeroCard({super.key, required this.report});

  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final summary = report.summary;
    final spark = report.trend.buckets
        .map((b) => b.value)
        .toList(growable: false);

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
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 18,
                  color: LightColor.redColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                StringConstants.totalExpenses,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          // Count-up animation; re-animates whenever the total changes.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: summary.totalSpend.toDouble()),
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
            '≈ ${ExpenseFmt.npr(summary.avgPerDay.round())} / day · '
            '${summary.entries} ${summary.entries == 1 ? 'entry' : 'entries'}',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
          if (spark.isNotEmpty) ...[
            const SizedBox(height: AppDimens.paddingX14),
            SizedBox(
              height: 56,
              child: RepaintBoundary(
                child: SfSparkAreaChart(
                  data: spark,
                  color: LightColor.redColor.withValues(alpha: 0.12),
                  borderColor: LightColor.redColor,
                  borderWidth: 2,
                  axisLineWidth: 0,
                ),
              ),
            ),
          ],
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

class ExpenseKpiGrid extends StatelessWidget {
  const ExpenseKpiGrid({super.key, required this.report});

  final ExpenseReport report;

  @override
  Widget build(BuildContext context) {
    final summary = report.summary;
    final topCat = summary.topCategory;
    final topVenue = summary.topVenue;

    ExpenseCategory? topCatEnum;
    for (final c in report.byCategory) {
      if (c.id == topCat?.id) {
        topCatEnum = c.asEnum;
        break;
      }
    }

    final items = <_Kpi>[
      _Kpi(
        icon: Icons.functions_rounded,
        label: StringConstants.avgDay,
        value: ExpenseFmt.npr(summary.avgPerDay.round()),
        sub: 'Daily average',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.format_list_numbered_rounded,
        label: StringConstants.entries,
        value: '${summary.entries}',
        sub: 'Avg ${ExpenseFmt.npr(summary.avgPerEntry)} / entry',
        accent: LightColor.blueColor,
      ),
      _Kpi(
        icon: topCatEnum?.icon ?? Icons.category_outlined,
        category: topCatEnum,
        categoryId: topCat?.id,
        label: StringConstants.topCategory,
        value: topCat?.name.isNotEmpty == true ? topCat!.name : '—',
        sub: topCat == null ? 'No expenses yet' : ExpenseFmt.npr(topCat.total),
        accent: topCatEnum?.color ?? LightColor.iconGrey,
      ),
      _Kpi(
        icon: Icons.stadium_outlined,
        label: StringConstants.topVenue,
        value: topVenue?.name.isNotEmpty == true ? topVenue!.name : '—',
        sub: topVenue == null
            ? 'No expenses yet'
            : ExpenseFmt.npr(topVenue.total),
        accent: LightColor.warningColor,
      ),
    ];

    // Fixed tile extent (scaled with the user's text size) keeps all four
    // tiles the same height — unlike a Wrap, where a subtitle wrapping to a
    // second line makes one tile taller than its row neighbour.
    final tileExtent = 72 + MediaQuery.textScalerOf(context).scale(48);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimens.paddingX10,
        mainAxisSpacing: AppDimens.paddingX10,
        mainAxisExtent: tileExtent,
      ),
      itemBuilder: (_, i) => items[i],
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
    this.category,
    this.categoryId,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color accent;

  final ExpenseCategory? category;
  final String? categoryId;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return ExpenseSurface(
      padding: const EdgeInsets.all(AppDimens.paddingX12),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (category != null)
                ExpenseCategoryIcon(
                  category: category!,
                  categoryId: categoryId,
                  boxSize: 32,
                  iconSize: 16,
                  radius: AppDimens.radiusX8,
                )
              else
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
              const SizedBox(width: AppDimens.paddingX8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            maxLines: 1,
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
