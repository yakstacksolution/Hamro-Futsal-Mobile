import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Revenue trend bar chart bucketed by the selected period.
class BookingTrendCard extends StatelessWidget {
  const BookingTrendCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final values = analytics.series;
    final avg = values.isEmpty
        ? 0
        : (values.reduce((a, b) => a + b) / values.length).round();
    final points = <_TrendPoint>[
      for (int i = 0; i < values.length; i++)
        _TrendPoint(index: i, value: values[i]),
    ];

    return BookingSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                analytics.seriesLabel,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                'Avg ${BookingFmt.npr(avg)}',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 120,
            child: RepaintBoundary(
              child: SfCartesianChart(
                key: ValueKey<int>(Object.hashAll(values)),
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: const NumericAxis(isVisible: false),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  maximum: values.every((int value) => value == 0) ? 1 : null,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.y',
                  color: LightColor.primaryTextColor,
                  textStyle: TextStyle(
                    color: LightColor.inverseTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                series: <ColumnSeries<_TrendPoint, int>>[
                  ColumnSeries<_TrendPoint, int>(
                    dataSource: points,
                    xValueMapper: (_TrendPoint point, _) => point.index,
                    yValueMapper: (_TrendPoint point, _) => point.value,
                    color: LightColor.secondaryColor,
                    width: values.length > 31 ? 0.9 : 0.72,
                    spacing: values.length > 31 ? 0.05 : 0.12,
                    isTrackVisible: true,
                    trackColor: LightColor.dividerColor.withValues(alpha: 0.4),
                    trackBorderWidth: 0,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    animationDuration: 650,
                    animationDelay: 40,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Row(
            children: [
              Text(
                analytics.period == BookingPeriod.today
                    ? '12 AM'
                    : BookingFmt.shortDate(analytics.range.start),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              const Spacer(),
              Text(
                analytics.period == BookingPeriod.today
                    ? '11 PM'
                    : BookingFmt.shortDate(
                        analytics.range.end.subtract(const Duration(days: 1)),
                      ),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrendPoint {
  const _TrendPoint({required this.index, required this.value});

  final int index;
  final int value;
}

/// Stacked status bar + per-status legend rows.
class BookingStatusCard extends StatelessWidget {
  const BookingStatusCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final breakdown = analytics.statusBreakdown;
    final total = breakdown.values.fold<int>(0, (a, b) => a + b);
    final chartData = <_StatusPoint>[
      _StatusPoint(category: StringConstants.statusMix, values: breakdown),
    ];

    return BookingSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                StringConstants.statusMix,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                '$total bookings',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          SizedBox(
            height: 18,
            child: total == 0
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    child: Container(color: LightColor.dividerColor),
                  )
                : RepaintBoundary(
                    child: SfCartesianChart(
                      key: ValueKey<int>(
                        Object.hashAll(<int>[
                          for (final status in BookingStatus.values)
                            breakdown[status] ?? 0,
                        ]),
                      ),
                      margin: EdgeInsets.zero,
                      plotAreaBorderWidth: 0,
                      primaryXAxis: const CategoryAxis(isVisible: false),
                      primaryYAxis: const NumericAxis(
                        isVisible: false,
                        minimum: 0,
                        maximum: 100,
                      ),
                      series: <StackedBar100Series<_StatusPoint, String>>[
                        for (final status in BookingStatus.values)
                          StackedBar100Series<_StatusPoint, String>(
                            dataSource: chartData,
                            xValueMapper: (_StatusPoint point, _) =>
                                point.category,
                            yValueMapper: (_StatusPoint point, _) =>
                                point.values[status] ?? 0,
                            color: status.color,
                            animationDuration: 650,
                          ),
                      ],
                    ),
                  ),
          ),
          const SizedBox(height: AppDimens.paddingX12),
          ...BookingStatus.values.map((s) {
            final n = breakdown[s] ?? 0;
            final pct = total == 0 ? 0.0 : n / total;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingX8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: s.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingX8),
                  Expanded(
                    child: Text(
                      s.label,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    '$n  ·  ${(pct * 100).toStringAsFixed(1)}%',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatusPoint {
  const _StatusPoint({required this.category, required this.values});

  final String category;
  final Map<BookingStatus, int> values;
}
