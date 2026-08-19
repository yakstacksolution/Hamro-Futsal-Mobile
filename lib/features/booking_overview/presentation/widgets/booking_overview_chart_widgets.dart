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
    const statuses = <BookingStatus>[
      BookingStatus.pending,
      BookingStatus.cancelled,
      BookingStatus.completed,
      BookingStatus.confirmed,
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
                '$total total bookings',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          _StatusMixBar(statuses: statuses, breakdown: breakdown, total: total),
          const SizedBox(height: AppDimens.paddingX14),
          _StatusTileRow(
            statuses: statuses.take(2).toList(growable: false),
            breakdown: breakdown,
            total: total,
          ),
          const SizedBox(height: AppDimens.paddingX10),
          _StatusTileRow(
            statuses: statuses.skip(2).toList(growable: false),
            breakdown: breakdown,
            total: total,
          ),
        ],
      ),
    );
  }
}

class _StatusMixBar extends StatelessWidget {
  const _StatusMixBar({
    required this.statuses,
    required this.breakdown,
    required this.total,
  });

  final List<BookingStatus> statuses;
  final Map<BookingStatus, int> breakdown;
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
                  for (final status in statuses)
                    if ((breakdown[status] ?? 0) > 0)
                      Expanded(
                        flex: breakdown[status]!,
                        child: ColoredBox(color: status.color),
                      ),
                ],
              ),
      ),
    );
  }
}

class _StatusTileRow extends StatelessWidget {
  const _StatusTileRow({
    required this.statuses,
    required this.breakdown,
    required this.total,
  });

  final List<BookingStatus> statuses;
  final Map<BookingStatus, int> breakdown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int i = 0; i < statuses.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: _StatusTile(
              status: statuses[i],
              count: breakdown[statuses[i]] ?? 0,
              total: total,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({
    required this.status,
    required this.count,
    required this.total,
  });

  final BookingStatus status;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final percentage = total == 0 ? 0 : (count * 100 / total).round();

    return Container(
      height: 82,
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: status.color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: status.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX6),
              Expanded(
                child: Text(
                  status.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$percentage%',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '$count',
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
