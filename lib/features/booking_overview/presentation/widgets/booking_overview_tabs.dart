import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_chart_widgets.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_leaderboard_widgets.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_summary_widgets.dart';

/// "How is the business doing?" — net revenue hero, KPI snapshot, profit.
class BookingOverviewTab extends StatelessWidget {
  const BookingOverviewTab({super.key, required this.analytics});

  final BookingAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey('booking_overview'),
      physics: const BouncingScrollPhysics(),
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX20,
      ),
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
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX20,
      ),
      children: [
        BookingSectionLabel('Revenue trend'),
        BookingTrendCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        BookingSectionLabel('Booking statuses'),
        BookingStatusCard(analytics: analytics),
      ],
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
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        top: AppDimens.paddingX4,
        bottom: AppDimens.paddingX20,
      ),
      children: [
        BookingSectionLabel('Performance by venue'),
        BookingVenuePerformanceCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        BookingSectionLabel('Top courts'),
        BookingTopCourtsCard(analytics: analytics),
        const SizedBox(height: AppDimens.paddingX18),
        BookingSectionLabel('Top customers'),
        BookingTopCustomersCard(analytics: analytics),
      ],
    );
  }
}
