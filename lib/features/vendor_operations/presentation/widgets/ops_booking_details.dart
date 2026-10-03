import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/routers/booking_details_route_args.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_style.dart';

/// Shows a booking over the dashboard — a side drawer on wide screens, a
/// bottom sheet on phones — so checking a slot never navigates away.
Future<void> showOpsBookingDetails(
  BuildContext context,
  BookingModel booking, {
  int? nowMinute,
  bool demo = false,
}) {
  final bool wide = MediaQuery.sizeOf(context).width >= 900;
  // The sheet and the drawer are new routes, outside the dashboard's
  // provider — hand them its bloc.
  final Widget body = BlocProvider<VendorOpsBloc>.value(
    value: context.read<VendorOpsBloc>(),
    child: _BookingDetails(booking: booking, nowMinute: nowMinute, demo: demo),
  );
  if (!wide) {
    return showAppBottomSheet<void>(context: context, child: body);
  }
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close booking details',
    barrierColor: LightColor.scrimColor,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (BuildContext context, _, __) => Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: LightColor.cardColor,
        elevation: 8,
        child: SizedBox(
          width: 420,
          height: double.infinity,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: body,
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (_, Animation<double> a, __, Widget child) =>
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
          child: child,
        ),
  );
}

class _BookingDetails extends StatelessWidget {
  const _BookingDetails({
    required this.booking,
    this.nowMinute,
    this.demo = false,
  });

  final BookingModel booking;
  final int? nowMinute;

  /// Demo bookings do not exist on the server, so the full details page
  /// (which fetches the booking) is not offered.
  final bool demo;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final BookingModel b = booking;
    final List<(int, int)> intervals = bookingIntervalsOn(b, isoDate(b.date));
    final (int, int)? first = intervals.isEmpty ? null : intervals.first;
    final OpsBookingPhase phase = phaseOf(
      b,
      start: first?.$1 ?? 0,
      end: first?.$2 ?? 0,
      nowMinute: nowMinute,
    );
    final OpsPaymentState payment = paymentStateOf(b);
    final OpsCellStyle phaseStyle = opsPhaseStyle(phase);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  b.playerName?.trim().isNotEmpty ?? false
                      ? b.playerName!.trim()
                      : 'Customer',
                  style: textTheme.bodyTextLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          if (b.playerPhone?.isNotEmpty ?? false)
            Text(
              b.playerPhone!,
              style: TextStyle(color: LightColor.secondaryTextColor),
            ),
          const SizedBox(height: 12),
          // Booking status and payment status side by side, never merged:
          // a confirmed booking can still be unpaid.
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _Pill(
                icon: phaseStyle.icon,
                label: phaseStyle.label,
                background: phaseStyle.background,
                foreground: phaseStyle.foreground,
              ),
              _Pill(
                icon: opsPaymentIcon(payment),
                label: opsPaymentLabel(payment),
                background: opsPaymentColor(payment).withValues(alpha: 0.12),
                foreground: opsPaymentColor(payment),
              ),
              if (b.bookingType?.isNotEmpty ?? false)
                _Pill(
                  icon: Icons.storefront_rounded,
                  label: _title(b.bookingType!),
                  background: LightColor.sunkenColor,
                  foreground: LightColor.secondaryTextColor,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _Row('Reference', b.bookingRef.isEmpty ? '#${b.id}' : b.bookingRef),
          _Row('Venue', b.futsalName),
          _Row('Court', b.courtName),
          _Row('Date', DateFmt.date(b.date)),
          _Row(
            intervals.length > 1 ? 'Slots' : 'Time',
            intervals.isEmpty
                ? b.displayTimeRange
                : intervals
                      .map(
                        ((int, int) iv) =>
                            '${formatMinuteOfDay(iv.$1)} – ${formatMinuteOfDay(iv.$2)}',
                      )
                      .join('\n'),
          ),
          const Divider(height: 24),
          _Row('Total', Money.npr(b.amount), strong: true),
          _Row('Paid', Money.npr(b.paidAmount)),
          _Row(
            'Balance due',
            Money.npr(b.balanceDue),
            color: b.balanceDue > 0 ? LightColor.warningColor : null,
            strong: b.balanceDue > 0,
          ),
          if (b.payments.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              'PAYMENTS',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w800,
                color: LightColor.hintTextColor,
              ),
            ),
            const SizedBox(height: 6),
            for (final BookingPaymentModel p in b.payments)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: <Widget>[
                    Icon(
                      p.status == 'success'
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                      size: 14,
                      color: p.status == 'success'
                          ? LightColor.successColor
                          : LightColor.warningColor,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${_title(p.method ?? 'payment')} · '
                        '${_title(p.verificationStatus ?? p.status ?? '')}'
                        '${p.createdAt == null ? '' : ' · ${DateFmt.dateTime(p.createdAt!)}'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: LightColor.secondaryTextColor,
                        ),
                      ),
                    ),
                    Text(
                      Money.npr(p.amount),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (b.notes?.trim().isNotEmpty ?? false) ...<Widget>[
            const SizedBox(height: 12),
            _Row('Note', b.notes!.trim()),
          ],
          const SizedBox(height: 16),
          // Payments, cancellation and edits arrive with the booking list in
          // phase 2; until then the existing details page has them.
          OutlinedButton.icon(
            onPressed: demo
                ? null
                : () {
                    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
                    final GoRouter router = GoRouter.of(context);
                    Navigator.of(context).maybePop();
                    router.pushNamed(
                      AppRouterParams.bookingDetails.name,
                      queryParameters: <String, String>{'futsal': 'true'},
                      extra: BookingDetailsRouteArgs(
                        booking: b,
                        isFutsalView: true,
                        onBookingUpdated: (BookingModel updated) =>
                            bloc.add(VendorOpsBookingUpdated(updated)),
                      ),
                    );
                  },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              foregroundColor: LightColor.brandTextColor,
            ),
            icon: const Icon(Icons.open_in_new_rounded, size: 16),
            label: Text(
              demo ? 'Actions & receipt (not in demo)' : 'Actions & receipt',
            ),
          ),
        ],
      ),
    );
  }

  static String _title(String raw) {
    final String t = raw.replaceAll('_', ' ').trim();
    return t.isEmpty ? t : t[0].toUpperCase() + t.substring(1);
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false, this.color});

  final String label;
  final String value;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: LightColor.hintTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '—' : value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
                color: color ?? LightColor.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
