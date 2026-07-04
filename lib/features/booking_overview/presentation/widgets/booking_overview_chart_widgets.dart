import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Revenue trend bar chart bucketed by the selected period.
class BookingTrendCard extends StatelessWidget {
  const BookingTrendCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final values = analytics.series;
    final maxV = values.fold<int>(0, math.max);
    final avg = values.isEmpty
        ? 0
        : (values.reduce((a, b) => a + b) / values.length).round();

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
            child: CustomPaint(
              size: Size.infinite,
              painter: _BarChartPainter(
                values: values,
                color: LightColor.secondaryColor,
                trackColor: LightColor.dividerColor,
                maxV: maxV == 0 ? 1 : maxV,
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

class _BarChartPainter extends CustomPainter {
  _BarChartPainter({
    required this.values,
    required this.color,
    required this.trackColor,
    required this.maxV,
  });

  final List<int> values;
  final Color color;
  final Color trackColor;
  final int maxV;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final n = values.length;
    final gap = n > 31 ? 1.0 : 2.0;
    final barW = (size.width - gap * (n - 1)) / n;
    final radius = math.min(barW / 2, 4.0);

    final trackPaint = Paint()..color = trackColor.withValues(alpha: 0.4);
    final barPaint = Paint()..color = color;

    for (int i = 0; i < n; i++) {
      final x = i * (barW + gap);
      // Track (full height)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, barW, size.height),
          Radius.circular(radius),
        ),
        trackPaint,
      );
      // Filled portion
      final h = (values[i] / maxV) * size.height;
      if (h > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, size.height - h, barW, h),
            Radius.circular(radius),
          ),
          barPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) =>
      old.values != values || old.maxV != maxV || old.color != color;
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
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            child: SizedBox(
              height: 10,
              child: total == 0
                  ? Container(color: LightColor.dividerColor)
                  : Row(
                      children: BookingStatus.values
                          .map(
                            (s) => Expanded(
                              flex: breakdown[s] ?? 0,
                              child: Container(color: s.color),
                            ),
                          )
                          .toList(),
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
