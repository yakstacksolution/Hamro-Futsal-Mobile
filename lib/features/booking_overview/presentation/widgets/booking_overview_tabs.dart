import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_chart_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_leaderboard_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_summary_widgets.dart';

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
        firstLabel: analytics.trendTitle,
        first: BookingTrendCard(analytics: analytics),
        secondLabel: analytics.statusTitle,
        second: BookingStatusCard(analytics: analytics),
      ),
    );
  }
}

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
