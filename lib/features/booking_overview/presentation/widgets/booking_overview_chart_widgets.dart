import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/// Revenue trend bar chart bucketed by the selected period.
class BookingTrendCard extends StatelessWidget {
  const BookingTrendCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final values = analytics.series;
    final labels = analytics.seriesLabels;
    final points = <_TrendPoint>[
      for (int i = 0; i < values.length; i++)
        _TrendPoint(
          // Unique fallback keeps category slots distinct if labels are absent.
          label: i < labels.length && labels[i].isNotEmpty ? labels[i] : '#$i',
          value: values[i],
        ),
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
                analytics.averageLabel,
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
                primaryXAxis: const CategoryAxis(isVisible: false),
                primaryYAxis: NumericAxis(
                  isVisible: false,
                  maximum: values.every((int value) => value == 0) ? 1 : null,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: '',
                  format: 'point.x : NPR point.y',
                  color: LightColor.primaryTextColor,
                  textStyle: TextStyle(
                    color: LightColor.inverseTextColor,
                    fontSize: AppDimens.fontBodySubTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                series: <ColumnSeries<_TrendPoint, String>>[
                  ColumnSeries<_TrendPoint, String>(
                    dataSource: points,
                    xValueMapper: (_TrendPoint point, _) => point.label,
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
                labels.isNotEmpty
                    ? labels.first
                    : analytics.period == BookingPeriod.today
                    ? '12 AM'
                    : BookingFmt.shortDate(analytics.range.start),
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              const Spacer(),
              Text(
                labels.isNotEmpty
                    ? labels.last
                    : analytics.period == BookingPeriod.today
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
  const _TrendPoint({required this.label, required this.value});

  final String label;
  final int value;
}

/// Stacked status bar + per-status legend tiles, driven by the server's
/// `status_mix` (labels, colors and percentages as sent).
class BookingStatusCard extends StatelessWidget {
  const BookingStatusCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<StatusMixEntry> entries = analytics.statusMix;
    final int total = analytics.statusTotal;

    return BookingSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                analytics.statusChartTitle,
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: LightColor.primaryTextColor,
                ),
              ),
              const Spacer(),
              Text(
                '$total total bookings',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          _StatusMixBar(entries: entries, total: total),
          const SizedBox(height: AppDimens.paddingX14),
          // Two tiles per row, however many statuses the server sends.
          for (int i = 0; i < entries.length; i += 2) ...<Widget>[
            if (i > 0) const SizedBox(height: AppDimens.paddingX10),
            Row(
              children: <Widget>[
                Expanded(child: _StatusTile(entry: entries[i])),
                const SizedBox(width: AppDimens.paddingX10),
                Expanded(
                  child: i + 1 < entries.length
                      ? _StatusTile(entry: entries[i + 1])
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusMixBar extends StatelessWidget {
  const _StatusMixBar({required this.entries, required this.total});

  final List<StatusMixEntry> entries;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: SizedBox(
        height: 12,
        child: total == 0
            ? ColoredBox(color: LightColor.dividerColor)
            : Row(
                children: <Widget>[
                  for (final StatusMixEntry entry in entries)
                    if (entry.count > 0)
                      Expanded(
                        flex: entry.count,
                        child: ColoredBox(color: entry.color),
                      ),
                ],
              ),
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.entry});

  final StatusMixEntry entry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color color = entry.color;

    return Container(
      height: 82,
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Expanded(
                child: Text(
                  entry.displayLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${BookingFmt.percent(entry.percentage)}%',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${entry.count}',
            style: textTheme.headingSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w700,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
