import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_chart_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_leaderboard_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_summary_widgets.dart';

/// "How is the business doing?" — net revenue hero, KPI snapshot, profit.
class BookingOverviewTab extends StatelessWidget {
  const BookingOverviewTab({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('booking_overview'),
      physics: const BouncingScrollPhysics(),
      padding: _tabPadding(context),
      children: [
        BookingSectionLabel('Net earnings'),
        BookingHeroCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        BookingSectionLabel('Snapshot'),
        BookingKpiGrid(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX12),
        BookingProfitCard(analytics: analytics),
      ],
    );
  }
}

/// "What's the trend?" — revenue chart + booking status mix.
class BookingAnalyticsTab extends StatelessWidget {
  const BookingAnalyticsTab({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('booking_analytics'),
      physics: const BouncingScrollPhysics(),
      padding: _tabPadding(context),
      children: _pairSections(
        context,
        firstLabel: 'Revenue trend',
        first: BookingTrendCard(analytics: analytics),
        secondLabel: 'Booking statuses',
        second: BookingStatusCard(analytics: analytics),
      ),
    );
  }
}

/// "Who performs best?" — venue, court and customer leaderboards.
class BookingRankingsTab extends StatelessWidget {
  const BookingRankingsTab({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('booking_rankings'),
      physics: const BouncingScrollPhysics(),
      padding: _tabPadding(context),
      children: <Widget>[
        BookingSectionLabel('Performance by venue'),
        BookingVenuePerformanceCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        // The two leaderboards are independent lists, so they pair well.
        ..._pairSections(
          context,
          firstLabel: 'Top courts',
          first: BookingTopCourtsCard(analytics: analytics),
          secondLabel: 'Top customers',
          second: BookingTopCustomersCard(analytics: analytics),
        ),
      ],
    );
  }
}

/// Horizontal inset for every tab body; wider once there is room for it.
EdgeInsets _tabPadding(BuildContext context) {
  final double horizontal = context.responsive<double>(
    mobile: AppDimens.paddingX20,
    tablet: AppDimens.paddingX32,
  );
  return EdgeInsets.only(
    left: horizontal,
    right: horizontal,
    top: AppDimens.paddingX4,
    bottom: AppDimens.paddingX20,
  );
}

/// Places two independent, self-contained cards side by side once the pane is
/// wide enough, and stacks them (labels above each) otherwise.
///
/// Stacking is the phone layout and must stay byte-identical, so the mobile
/// branch returns exactly the widgets the caller would have listed inline.
List<Widget> _pairSections(
  BuildContext context, {
  required String firstLabel,
  required Widget first,
  required String secondLabel,
  required Widget second,
}) {
  if (!context.isDesktop) {
    return <Widget>[
      BookingSectionLabel(firstLabel),
      first,
      const SizedBox(height: AppDimens.paddingX18),
      BookingSectionLabel(secondLabel),
      second,
    ];
  }
  return <Widget>[
    IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[BookingSectionLabel(firstLabel), first],
            ),
          ),
          const SizedBox(width: AppDimens.paddingX18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[BookingSectionLabel(secondLabel), second],
            ),
          ),
        ],
      ),
    ),
  ];
}
