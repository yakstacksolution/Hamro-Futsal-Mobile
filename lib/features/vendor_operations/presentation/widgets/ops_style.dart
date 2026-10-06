import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

typedef OpsBookingTap = void Function(BookingModel booking);

@immutable
class OpsCellStyle {
  const OpsCellStyle({
    required this.label,
    required this.icon,
    required this.background,
    required this.border,
    required this.foreground,
    this.solid = false,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color border;
  final Color foreground;

  final bool solid;
}

OpsCellStyle opsAvailableStyle() => OpsCellStyle(
  label: 'Available',
  icon: Icons.add_rounded,
  background: LightColor.greenLightColor,
  border: LightColor.successColor.withValues(alpha: 0.55),
  foreground: LightColor.onGreenLightColor,
);

OpsCellStyle opsSelectedStyle() => OpsCellStyle(
  label: 'Selected',
  icon: Icons.check_rounded,
  background: LightColor.successColor,
  border: LightColor.successColor,
  foreground: LightColor.onBrandSurface,
  solid: true,
);

OpsCellStyle opsBookedStyle([OpsBookingPhase? phase]) {
  final OpsCellStyle? of = phase == null ? null : opsPhaseStyle(phase);
  return OpsCellStyle(
    label: of?.label ?? 'Booked',
    icon: of?.icon ?? Icons.event_busy_rounded,
    background: LightColor.redColor,
    border: LightColor.redColor,
    foreground: LightColor.onBrandSurface,
    solid: true,
  );
}

OpsCellStyle opsClosedStyle() => OpsCellStyle(
  label: 'Closed',
  icon: Icons.block_rounded,
  background: LightColor.redLightColor,
  border: LightColor.redColor.withValues(alpha: 0.5),
  foreground: LightColor.onRedLightColor,
);

OpsCellStyle opsPastStyle() => OpsCellStyle(
  label: 'Past',
  icon: Icons.history_rounded,
  background: LightColor.sunkenColor,
  border: LightColor.dividerColor,
  foreground: LightColor.hintTextColor,
);

OpsCellStyle opsPhaseStyle(OpsBookingPhase phase) {
  switch (phase) {
    case OpsBookingPhase.pending:
      return OpsCellStyle(
        label: 'Pending',
        icon: Icons.hourglass_top_rounded,
        background: LightColor.warningLightColor,
        border: LightColor.warningColor.withValues(alpha: 0.6),
        foreground: LightColor.onWarningLightColor,
      );
    case OpsBookingPhase.confirmed:
      return OpsCellStyle(
        label: 'Confirmed',
        icon: Icons.event_available_rounded,
        background: LightColor.blueLightColor,
        border: LightColor.blueColor.withValues(alpha: 0.55),
        foreground: LightColor.onBlueLightColor,
      );
    case OpsBookingPhase.inProgress:
      return OpsCellStyle(
        label: 'In progress',
        icon: Icons.play_circle_fill_rounded,
        background: LightColor.purpleLightColor,
        border: LightColor.purpleColor.withValues(alpha: 0.6),
        foreground: LightColor.purpleColor,
      );
    case OpsBookingPhase.completed:
      return OpsCellStyle(
        label: 'Completed',
        icon: Icons.task_alt_rounded,
        background: LightColor.greenLightColor,
        border: LightColor.successColor.withValues(alpha: 0.55),
        foreground: LightColor.onGreenLightColor,
      );
  }
}

OpsCellStyle opsCellStyle(OpsCell cell, {required bool selected}) {
  if (selected) return opsSelectedStyle();
  switch (cell.kind) {
    case OpsCellKind.available:
      return opsAvailableStyle();
    case OpsCellKind.booked:
      return opsBookedStyle(cell.phase);
    case OpsCellKind.closed:
      return opsClosedStyle();
    case OpsCellKind.past:
      return opsPastStyle();
  }
}

String opsPaymentLabel(OpsPaymentState state) {
  switch (state) {
    case OpsPaymentState.paid:
      return 'Paid';
    case OpsPaymentState.partial:
      return 'Partly paid';
    case OpsPaymentState.unpaid:
      return 'Unpaid';
  }
}

Color opsPaymentColor(OpsPaymentState state) {
  switch (state) {
    case OpsPaymentState.paid:
      return LightColor.successColor;
    case OpsPaymentState.partial:
      return LightColor.warningColor;
    case OpsPaymentState.unpaid:
      return LightColor.redColor;
  }
}

IconData opsPaymentIcon(OpsPaymentState state) {
  switch (state) {
    case OpsPaymentState.paid:
      return Icons.check_circle_rounded;
    case OpsPaymentState.partial:
      return Icons.timelapse_rounded;
    case OpsPaymentState.unpaid:
      return Icons.error_outline_rounded;
  }
}

String opsCompactPrice(double? price) {
  if (price == null) return '—';
  return Money.npr(price).replaceFirst('NPR ', '');
}

class OpsPaymentBadge extends StatelessWidget {
  const OpsPaymentBadge({
    super.key,
    required this.state,
    this.compact = false,
    this.onSolid = false,
  });

  final OpsPaymentState state;

  final bool compact;

  final bool onSolid;

  @override
  Widget build(BuildContext context) {
    final Color color = opsPaymentColor(state);
    Widget icon = Icon(opsPaymentIcon(state), size: 12, color: color);
    if (onSolid) {
      icon = DecoratedBox(
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          shape: BoxShape.circle,
        ),
        child: Padding(padding: const EdgeInsets.all(1), child: icon),
      );
    }
    if (compact) {
      return Semantics(label: opsPaymentLabel(state), child: icon);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        icon,
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            opsPaymentLabel(state),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class OpsLegend extends StatelessWidget {
  const OpsLegend({super.key});

  static const double _itemWidth = 104;
  static const double _rowGap = 6;

  @override
  Widget build(BuildContext context) {
    final List<OpsCellStyle> styles = <OpsCellStyle>[
      opsAvailableStyle(),
      opsSelectedStyle(),
      opsBookedStyle(),
      opsClosedStyle(),
      opsPastStyle(),
    ];
    final List<Widget> items = <Widget>[
      for (final OpsCellStyle s in styles)
        Row(
          children: <Widget>[
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: s.background,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: s.border),
              ),
              child: Icon(s.icon, size: 12, color: s.foreground),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                s.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      for (final OpsPaymentState p in OpsPaymentState.values)
        Align(
          alignment: Alignment.centerLeft,
          child: OpsPaymentBadge(state: p),
        ),
    ];
    // Split evenly: the first row takes the extra item when the count is odd.
    final int perRow = (items.length / 2).ceil();
    Widget row(Iterable<Widget> children) => Row(
      children: <Widget>[
        for (final Widget child in children)
          SizedBox(width: _itemWidth, height: 20, child: child),
      ],
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          row(items.take(perRow)),
          const SizedBox(height: _rowGap),
          row(items.skip(perRow)),
        ],
      ),
    );
  }
}

class OpsLiveSlotsNotice extends StatelessWidget {
  const OpsLiveSlotsNotice({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 4, 4),
      decoration: BoxDecoration(
        color: LightColor.warningLightColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: LightColor.onWarningLightColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Live slots did not load — showing the court\'s schedule.',
              style: TextStyle(
                fontSize: 11.5,
                color: LightColor.onWarningLightColor,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
