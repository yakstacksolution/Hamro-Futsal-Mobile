import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Net revenue hero with delta pill and revenue sparkline.
class BookingHeroCard extends StatelessWidget {
  const BookingHeroCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final delta = analytics.revenue - analytics.prevRevenue;
    final pct = analytics.prevRevenue == 0
        ? null
        : (delta / analytics.prevRevenue) * 100;
    final up = delta >= 0;
    return BookingSurface(
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
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX10),
              Text(
                StringConstants.netRevenue,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (pct != null) BookingTrendPill(value: pct, up: up),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            BookingFmt.npr(analytics.revenue),
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'vs ${BookingFmt.npr(analytics.prevRevenue)} previous period',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.hintTextColor,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX14),
          SizedBox(
            height: 56,
            child: CustomPaint(
              size: Size.infinite,
              painter: BookingSparklinePainter(
                values: analytics.series,
                color: LightColor.secondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BookingTrendPill extends StatelessWidget {
  const BookingTrendPill({super.key, required this.value, required this.up});

  final double value;
  final bool up;

  @override
  Widget build(BuildContext context) {
    final color = up ? LightColor.secondaryColor : LightColor.redColor;
    final bg = up
        ? LightColor.secondaryColor.withValues(alpha: 0.10)
        : LightColor.redLightColor;
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

class BookingSparklinePainter extends CustomPainter {
  BookingSparklinePainter({required this.values, required this.color});

  final List<int> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.fold<int>(0, math.max);
    if (maxV == 0) return;
    final dx = values.length == 1 ? 0.0 : size.width / (values.length - 1);
    final path = Path();
    final fill = Path();
    for (int i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = size.height - (values[i] / maxV) * (size.height - 4) - 2;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.20), color.withValues(alpha: 0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(BookingSparklinePainter old) =>
      old.values != values || old.color != color;
}

class BookingKpiGrid extends StatelessWidget {
  const BookingKpiGrid({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final items = <_Kpi>[
      _Kpi(
        icon: Icons.calendar_month_rounded,
        label: StringConstants.totalBookings,
        value: '${analytics.totalBookings}',
        sub: '${analytics.confirmed + analytics.completed} paid',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.cancel_outlined,
        label: StringConstants.cancelled,
        value: '${analytics.cancelled}',
        sub: '${(analytics.cancelRate * 100).toStringAsFixed(1)}% of bookings',
        accent: LightColor.redColor,
      ),
      _Kpi(
        icon: Icons.payments_outlined,
        label: StringConstants.revenue,
        value: BookingFmt.npr(analytics.revenue),
        sub: 'Avg ${BookingFmt.npr(analytics.avgBookingValue)} / booking',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.receipt_long_outlined,
        label: StringConstants.expenses,
        value: BookingFmt.npr(analytics.expenses),
        sub: 'Overheads + processing',
        accent: LightColor.warningColor,
      ),
      _Kpi(
        icon: Icons.timer_outlined,
        label: StringConstants.hoursPlayed,
        value: '${analytics.hoursPlayed}h',
        sub: 'Across all paid slots',
        accent: LightColor.secondaryColor,
      ),
      _Kpi(
        icon: Icons.stadium_outlined,
        label: StringConstants.occupancy,
        value: '${(analytics.occupancy * 100).round()}%',
        sub: 'Of available court hours',
        accent: LightColor.secondaryColor,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = AppDimens.paddingX10;
        final w = (constraints.maxWidth - spacing) / 2;
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
    return BookingSurface(
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

class BookingProfitCard extends StatelessWidget {
  const BookingProfitCard({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final profitable = analytics.profit >= 0;
    final margin = analytics.revenue == 0
        ? 0.0
        : analytics.profit / analytics.revenue;
    final color = profitable ? LightColor.secondaryColor : LightColor.redColor;

    return BookingSurface(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            ),
            child: Icon(
              profitable
                  ? Icons.trending_up_rounded
                  : Icons.trending_down_rounded,
              size: 22,
              color: color,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  StringConstants.netProfit,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  BookingFmt.npr(analytics.profit),
                  style: textTheme.bodyTextLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                StringConstants.margin,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.hintTextColor,
                  fontSize: AppDimens.fontBodySubTitle,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${(margin * 100).toStringAsFixed(1)}%',
                style: textTheme.bodyTextMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
