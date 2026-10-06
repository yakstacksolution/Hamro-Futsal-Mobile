import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';

class OpsDayOverview extends StatelessWidget {
  const OpsDayOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      // Follows the Day board only: on the Week table, browsing weeks moves
      // the date and empties its bookings, but this keeps the last day's
      // values until the Day board is back.
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          b.view == OpsAvailabilityView.day &&
          (a.view != b.view ||
              a.summary != b.summary ||
              a.focus != b.focus ||
              a.bookingsLoading != b.bookingsLoading),
      builder: (BuildContext context, VendorOpsState state) {
        final OpsSummary s = state.summary;
        final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
        final _RingColors colors = _RingColors.of(context);
        void focus(OpsFocus f) => bloc.add(
          VendorOpsFocusChanged(state.focus == f ? OpsFocus.all : f),
        );

        List<Widget> metricsFor({required bool large}) => <Widget>[
          _Metric(
            value: '${s.bookingCount}',
            label: s.bookingCount == 1 ? 'booking' : 'bookings',
            active: state.focus == OpsFocus.upcoming,
            onTap: () => focus(OpsFocus.upcoming),
            large: large,
          ),
          _Metric(
            value: '${formatHours(s.bookedMinutes)} h',
            label: 'booked',
            large: large,
          ),
          _Metric(
            value: '${formatHours(s.availableMinutes)} h',
            label: 'free',
            active: state.focus == OpsFocus.available,
            onTap: () => focus(OpsFocus.available),
            large: large,
          ),
          _Metric(value: _rs(s.bookingValue), label: 'value', large: large),
          _Metric(
            value: _rs(s.outstanding),
            label: 'due',
            tone: s.outstanding > 0 ? colors.owed : null,
            active: state.focus == OpsFocus.outstanding,
            onTap: s.outstanding > 0 ? () => focus(OpsFocus.outstanding) : null,
            large: large,
          ),
          _Metric(
            value: _rs(s.paidValue.clamp(0, s.bookingValue)),
            label: 'paid',
            large: large,
          ),
        ];

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: state.bookingsLoading ? 0.55 : 1,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              // Tablet / desktop: a bigger ring and figures in equal,
              // divided columns. Phone keeps its compact two-row grid.
              final bool large = c.maxWidth >= 720;
              final double ring = large
                  ? 92
                  : c.maxWidth < 420
                  ? 68
                  : 78;
              final List<Widget> metrics = metricsFor(large: large);
              return Container(
                padding: large
                    ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                    : const EdgeInsets.fromLTRB(12, 12, 6, 12),
                decoration: BoxDecoration(
                  color: LightColor.cardColor,
                  borderRadius: BorderRadius.circular(large ? 12 : 8),
                  border: Border.all(color: LightColor.dividerColor),
                ),
                child: Row(
                  children: <Widget>[
                    _OccupancyRing(summary: s, size: ring, colors: colors),
                    SizedBox(
                      width: large
                          ? 20
                          : c.maxWidth < 420
                          ? 6
                          : 12,
                    ),
                    Expanded(
                      child: c.maxWidth >= 640
                          ? _MetricRow(metrics: metrics, divided: large)
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _MetricRow(metrics: metrics.sublist(0, 3)),
                                const SizedBox(height: 2),
                                _MetricRow(metrics: metrics.sublist(3)),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _RingColors {
  _RingColors.of(BuildContext context)
    : _dark = Theme.of(context).brightness == Brightness.dark;

  final bool _dark;

  Color get booked => _dark ? const Color(0xFF2B9E82) : const Color(0xFF1A8C74);
  Color get owed => _dark ? const Color(0xFFC4801F) : const Color(0xFFB26A00);
  Color get lapsed => _dark ? const Color(0xFF818B84) : const Color(0xFF9EA0B0);
  Color get track => LightColor.sunkenColor;
}

class _OccupancyRing extends StatelessWidget {
  const _OccupancyRing({
    required this.summary,
    required this.size,
    required this.colors,
  });

  final OpsSummary summary;
  final double size;
  final _RingColors colors;

  @override
  Widget build(BuildContext context) {
    final OpsSummary s = summary;
    final double total = s.sellableMinutes.toDouble();
    final double booked = total <= 0 ? 0 : s.bookedMinutes / total;
    final double lapsed = total <= 0 ? 0 : s.pastUnbookedMinutes / total;
    final int percent = (s.occupancy * 100).round();
    return Tooltip(
      message:
          '${formatHours(s.bookedMinutes)} of ${formatHours(s.sellableMinutes)} '
          'open court-hours booked'
          '${s.pastUnbookedMinutes > 0 ? ' · ${formatHours(s.pastUnbookedMinutes)} h passed unbooked' : ''}',
      child: Semantics(
        label:
            '$percent percent of open court time booked. '
            '${formatHours(s.bookedMinutes)} of '
            '${formatHours(s.sellableMinutes)} hours.',
        child: ExcludeSemantics(
          child: SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _RingPainter(
                booked: booked.clamp(0, 1).toDouble(),
                lapsed: lapsed.clamp(0, 1 - booked.clamp(0, 1)).toDouble(),
                bookedColor: colors.booked,
                lapsedColor: colors.lapsed,
                trackColor: colors.track,
                stroke: size * 0.11,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.w800,
                        color: LightColor.primaryTextColor,
                        height: 1,
                        fontFeatures: const <FontFeature>[
                          FontFeature.tabularFigures(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'booked',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.booked,
    required this.lapsed,
    required this.bookedColor,
    required this.lapsedColor,
    required this.trackColor,
    required this.stroke,
  });

  final double booked;
  final double lapsed;
  final Color bookedColor;
  final Color lapsedColor;
  final Color trackColor;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, 0, math.pi * 2, false, arc(trackColor));
    const double start = -math.pi / 2;
    const double gap = 0.035;
    if (booked > 0) {
      final double sweep = booked * math.pi * 2;
      canvas.drawArc(
        rect,
        start,
        math.max(sweep - (lapsed > 0 ? gap : 0), 0.01),
        false,
        arc(bookedColor),
      );
    }
    if (lapsed > 0) {
      canvas.drawArc(
        rect,
        start + booked * math.pi * 2,
        math.max(lapsed * math.pi * 2 - gap, 0.01),
        false,
        arc(lapsedColor),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.booked != booked ||
      old.lapsed != lapsed ||
      old.bookedColor != bookedColor ||
      old.trackColor != trackColor;
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.value,
    required this.label,
    this.onTap,
    this.active = false,
    this.tone,
    this.large = false,
  });

  final String value;
  final String label;
  final VoidCallback? onTap;
  final bool active;
  final Color? tone;

  final bool large;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      selected: active,
      label: '$value $label${onTap == null ? '' : '. Tap to show on board'}',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: BoxConstraints(minHeight: large ? 56 : 44),
            padding: EdgeInsets.symmetric(
              horizontal: large ? 12 : 8,
              vertical: large ? 8 : 4,
            ),
            decoration: BoxDecoration(
              color: active
                  ? LightColor.secondaryColor.withValues(alpha: 0.10)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  value,
                  style: TextStyle(
                    fontSize: large ? 17 : 12,
                    fontWeight: FontWeight.w800,
                    color: tone ?? LightColor.primaryTextColor,
                    fontFeatures: const <FontFeature>[
                      FontFeature.tabularFigures(),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: large ? 12 : 10.5,
                        fontWeight: FontWeight.w600,
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                    if (onTap != null) ...<Widget>[
                      const SizedBox(width: 3),
                      Icon(
                        active
                            ? Icons.filter_alt_rounded
                            : Icons.filter_alt_outlined,
                        size: 11,
                        color: active
                            ? LightColor.brandTextColor
                            : LightColor.hintTextColor,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.metrics, this.divided = false});

  final List<Widget> metrics;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int i = 0; i < metrics.length; i++) ...<Widget>[
            if (divided && i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: LightColor.dividerColor,
                ),
              ),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: metrics[i],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _rs(num amount) => Money.npr(amount).replaceFirst('NPR', 'Rs');
