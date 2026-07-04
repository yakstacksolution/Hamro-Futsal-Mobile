import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/features/booking_overview/data/repositories/booking_overview_repository_impl.dart';
import 'package:hamro_footsall/features/booking_overview/domain/usecase/booking_overview_usecase.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/bloc/booking_overview_bloc/booking_overview_bloc.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_filter_widgets.dart';
import 'package:hamro_footsall/features/booking_overview/presentation/widgets/booking_overview_tabs.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class BookingOverviewScreen extends StatelessWidget {
  const BookingOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingOverviewBloc(
        BookingOverviewUseCase(BookingOverviewRepositoryImpl()),
      )..add(const LoadBookingOverviewEvent()),
      child: const _BookingOverviewView(),
    );
  }
}

class _BookingOverviewView extends StatefulWidget {
  const _BookingOverviewView();

  @override
  State<_BookingOverviewView> createState() => _BookingOverviewViewState();
}

class _BookingOverviewViewState extends State<_BookingOverviewView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  BookingPeriod _period = BookingPeriod.week;
  String? _futsalId; // null = all
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  BookingRange _resolvedRange() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    switch (_period) {
      case BookingPeriod.today:
        return BookingRange(today, today.add(const Duration(days: 1)));
      case BookingPeriod.week:
        final start = today.subtract(Duration(days: today.weekday - 1));
        return BookingRange(start, start.add(const Duration(days: 7)));
      case BookingPeriod.month:
        final start = DateTime(today.year, today.month, 1);
        final end = DateTime(today.year, today.month + 1, 1);
        return BookingRange(start, end);
      case BookingPeriod.year:
        return BookingRange(
          DateTime(today.year, 1, 1),
          DateTime(today.year + 1, 1, 1),
        );
      case BookingPeriod.custom:
        final r = _customRange;
        if (r == null) {
          final start = today.subtract(const Duration(days: 6));
          return BookingRange(start, today.add(const Duration(days: 1)));
        }
        return BookingRange(
          DateTime(r.start.year, r.start.month, r.start.day),
          DateTime(
            r.end.year,
            r.end.month,
            r.end.day,
          ).add(const Duration(days: 1)),
        );
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange:
          _customRange ??
          DateTimeRange(
            start: today.subtract(const Duration(days: 6)),
            end: today,
          ),
      firstDate: today.subtract(const Duration(days: 365)),
      lastDate: today.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(
            ctx,
          ).colorScheme.copyWith(primary: LightColor.secondaryColor),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customRange = picked;
        _period = BookingPeriod.custom;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(
        title: StringConstants.bookingOverview,
        showBack: true,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<BookingOverviewBloc, BookingOverviewState>(
          builder: (context, state) {
            if (state.status == BookingOverviewStatus.initial ||
                state.status == BookingOverviewStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: LightColor.secondaryColor,
                ),
              );
            }
            if (state.status == BookingOverviewStatus.failure &&
                state.bookings.isEmpty) {
              return _LoadError(
                message: state.errorMessage ?? 'Could not load bookings.',
                onRetry: () => context.read<BookingOverviewBloc>().add(
                  const LoadBookingOverviewEvent(),
                ),
              );
            }
            return _buildContent(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BookingOverviewState state) {
    final range = _resolvedRange();
    final analytics = BookingAnalytics(
      futsals: state.futsals,
      bookings: state.bookings,
      period: _period,
      range: range,
      futsalFilter: _futsalId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Shared filters — pinned above the tabs so they apply everywhere.
        Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX20,
            top: AppDimens.paddingX4,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BookingContextLine(
                range: range,
                count: analytics.totalBookings,
                revenue: analytics.revenue,
              ),
              const SizedBox(height: AppDimens.paddingX12),
              BookingPeriodChips(
                period: _period,
                customRange: _customRange,
                onPeriod: (p) {
                  if (p == BookingPeriod.custom) {
                    _pickRange();
                  } else {
                    setState(() => _period = p);
                  }
                },
                onEditCustom: _pickRange,
              ),
              const SizedBox(height: AppDimens.paddingX10),
              BookingVenueFilter(
                futsals: state.futsals,
                selectedId: _futsalId,
                onChange: (id) => setState(() => _futsalId = id),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.paddingX8),
        TabBar(
          controller: _tabController,
          labelColor: LightColor.secondaryColor,
          unselectedLabelColor: LightColor.secondaryTextColor,
          indicatorColor: LightColor.secondaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: LightColor.dividerColor,
          labelStyle: FutsalTheme.getTextTheme(
            context,
          ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w700),
          unselectedLabelStyle: FutsalTheme.getTextTheme(
            context,
          ).bodyTextSmall?.copyWith(fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: StringConstants.overview, height: 40),
            Tab(text: StringConstants.analytics, height: 40),
            Tab(text: StringConstants.rankings, height: 40),
          ],
        ),
        // Breathing room between the tab bar and tab content.
        const SizedBox(height: AppDimens.paddingX12),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              BookingOverviewTab(analytics: analytics),
              BookingAnalyticsTab(analytics: analytics),
              BookingRankingsTab(analytics: analytics),
            ],
          ),
        ),
      ],
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: LightColor.iconGrey,
            ),
            const SizedBox(height: AppDimens.paddingX12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyTextMedium?.copyWith(
                color: LightColor.secondaryTextColor,
              ),
            ),
            const SizedBox(height: AppDimens.paddingX16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: LightColor.secondaryColor,
                side: const BorderSide(color: LightColor.secondaryColor),
              ),
              child: const Text(StringConstants.retry),
            ),
          ],
        ),
      ),
    );
  }
}
