import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/dashboard_layout.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_chart_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_leaderboard_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_summary_widgets.dart';

/// Widest the overview dashboard grows before centring in the window.
const double kBookingDashboardMaxWidth = 1280;

/// Tablet / desktop Booking Overview: one scrolling dashboard instead of the
/// phone's three tabs — header and filters, earnings beside the KPI snapshot,
/// the trend beside the status mix, venue performance as a table, and the two
/// leaderboards side by side. Desktop pairs sections; tablet stacks them.
class BookingOverviewDashboard extends StatelessWidget {
  const BookingOverviewDashboard({
    super.key,
    required this.analytics,
    required this.contextLine,
    required this.filters,
    this.isLoading = false,
  });

  final BookingAnalytics analytics;

  /// "N bookings this week" summary under the title.
  final Widget contextLine;

  /// Period chips and venue chips.
  final Widget filters;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final bool desktop = context.isDesktop;
    final textTheme = FutsalTheme.getTextTheme(context);

    const Widget gap = SizedBox(height: AppDimens.paddingX24);

    return ListView(
      key: const PageStorageKey<String>('booking_overview_dashboard'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppDimens.paddingX24,
        AppDimens.paddingX16,
        AppDimens.paddingX24,
        AppDimens.paddingX40,
      ),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: kBookingDashboardMaxWidth,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // ── Header ──
                Text(
                  'Booking overview',
                  style: textTheme.headingSmall?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                contextLine,
                const SizedBox(height: AppDimens.paddingX16),
                _FilterBar(isLoading: isLoading, child: filters),
                gap,

                // ── Snapshot: every KPI in one row, profit beneath ──
                const DashboardSectionLabel('Snapshot'),
                BookingKpiGrid(analytics: analytics),
                const SizedBox(height: AppDimens.paddingX12),
                BookingProfitCard(analytics: analytics),
                gap,

                // ── Earnings and status: one row, equal heights ──
                DashboardPair(
                  stacked: !desktop,
                  leftLabel: 'Net earnings',
                  left: BookingHeroCard(analytics: analytics),
                  rightLabel: analytics.statusTitle,
                  right: BookingStatusCard(analytics: analytics),
                ),
                gap,

                // ── Trend across the full width ──
                DashboardSectionLabel(analytics.trendTitle),
                BookingTrendCard(analytics: analytics),
                gap,

                // ── Venues ──
                const DashboardSectionLabel('Performance by venue'),
                _VenuePerformanceTable(rows: analytics.futsalLeaderboard),
                gap,

                // ── Leaderboards: one row, equal heights ──
                DashboardPair(
                  stacked: !desktop,
                  leftLabel: 'Top courts',
                  left: BookingTopCourtsCard(analytics: analytics),
                  rightLabel: 'Top customers',
                  right: BookingTopCustomersCard(analytics: analytics),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The filters in a single bordered toolbar, with a slim progress line while
/// a filter change is loading.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.child, required this.isLoading});

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX14),
            child: child,
          ),
          SizedBox(
            height: 2,
            child: isLoading
                ? const LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    color: LightColor.secondaryColor,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

/// Venue performance as a table: one row per venue, figures in aligned
/// columns, occupancy as a bar.
class _VenuePerformanceTable extends StatelessWidget {
  const _VenuePerformanceTable({required this.rows});

  final List<VenuePerformanceRow> rows;

  static const int _fVenue = 4;
  static const int _fNum = 2;
  static const int _fOcc = 3;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final TextStyle? head = textTheme.bodyMiniSubTitle?.copyWith(
      color: LightColor.hintTextColor,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final TextStyle? figure = textTheme.bodyTextSmall?.copyWith(
      color: LightColor.primaryTextColor,
      fontWeight: FontWeight.w600,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );

    Widget headCell(String t, int flex, {TextAlign align = TextAlign.end}) =>
        Expanded(
          flex: flex,
          child: Text(t.toUpperCase(), textAlign: align, style: head),
        );
    Widget numCell(String t, int flex) => Expanded(
      flex: flex,
      child: Text(t, textAlign: TextAlign.end, style: figure),
    );

    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            color: LightColor.inputFillColor,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX10,
            ),
            child: Row(
              children: <Widget>[
                headCell('Venue', _fVenue, align: TextAlign.start),
                headCell('Courts', _fNum),
                headCell('Bookings', _fNum),
                headCell('Booked hrs', _fNum),
                headCell('Revenue', _fNum),
                const SizedBox(width: AppDimens.paddingX24),
                headCell('Occupancy', _fOcc, align: TextAlign.start),
              ],
            ),
          ),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AppDimens.paddingX24),
              child: Center(
                child: Text(
                  'No venue activity in this period.',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                  ),
                ),
              ),
            )
          else
            for (int i = 0; i < rows.length; i++) ...<Widget>[
              if (i > 0) Divider(height: 1, color: LightColor.dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.paddingX16,
                  vertical: AppDimens.paddingX14,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: _fVenue,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            rows[i].name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (rows[i].area.trim().isNotEmpty)
                            Text(
                              rows[i].area,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyMiniSubTitle?.copyWith(
                                color: LightColor.hintTextColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                    numCell('${rows[i].courtCount}', _fNum),
                    numCell('${rows[i].bookings}', _fNum),
                    numCell('${BookingFmt.hours(rows[i].bookedHours)}h', _fNum),
                    numCell(BookingFmt.npr(rows[i].revenue), _fNum),
                    const SizedBox(width: AppDimens.paddingX24),
                    Expanded(
                      flex: _fOcc,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: rows[i].occupancy.clamp(0.0, 1.0),
                                minHeight: 6,
                                color: LightColor.secondaryColor,
                                backgroundColor: LightColor.secondaryColor
                                    .withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.paddingX10),
                          SizedBox(
                            width: 40,
                            child: Text(
                              '${BookingFmt.percent(rows[i].occupancy * 100)}%',
                              textAlign: TextAlign.end,
                              style: figure,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
        ],
      ),
    );
  }
}
