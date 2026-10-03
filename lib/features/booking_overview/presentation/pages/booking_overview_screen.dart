import 'package:flutter/material.dart';
import 'package:hamro_futsal/features/booking_overview/domain/repository/booking_overview_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/features/booking_overview/data/repositories/booking_overview_repository_impl.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/domain/usecase/booking_overview_usecase.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/bloc/booking_overview_bloc/booking_overview_bloc.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_common.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_filter_widgets.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_dashboard.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_tabs.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class BookingOverviewScreen extends StatelessWidget {
  const BookingOverviewScreen({super.key, this.repository});

  /// Injected in tests; the app uses the live repository.
  final BookingOverviewRepository? repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingOverviewBloc(
        BookingOverviewUseCase(repository ?? BookingOverviewRepositoryImpl()),
        // Initial window matches the default selected chip (Week).
      )..add(const LoadBookingOverviewEvent(dateFilter: 'week')),
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

  /// Maps the selected chip to the optional `/booking-overview` filter params.
  /// Presets send just `date_filter`; a custom range adds `date_from`/`date_to`.
  LoadBookingOverviewEvent _loadEvent() {
    final venueIds = _futsalId == null ? null : <String>[_futsalId!];
    if (_period == BookingPeriod.custom) {
      final r = _customRange;
      return LoadBookingOverviewEvent(
        dateFilter: 'custom',
        dateFrom: r == null ? null : _fmtDate(r.start),
        dateTo: r == null ? null : _fmtDate(r.end),
        venueIds: venueIds,
      );
    }
    return LoadBookingOverviewEvent(
      dateFilter: _period.key,
      venueIds: venueIds,
    );
  }

  void _reload() => context.read<BookingOverviewBloc>().add(_loadEvent());

  String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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
      _reload();
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
            final overview = state.overview;
            if (overview != null) {
              return _buildContent(
                context,
                overview,
                isLoading: state.status == BookingOverviewStatus.loading,
              );
            }
            if (state.status == BookingOverviewStatus.failure) {
              return _LoadError(
                message: state.errorMessage ?? 'Could not load bookings.',
                onRetry: _reload,
              );
            }
            return const Center(
              child: CircularProgressIndicator(
                color: LightColor.secondaryColor,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BookingOverviewResponse overview, {
    required bool isLoading,
  }) {
    final range = BookingRange.fromApi(
      overview.period.dateFrom,
      overview.period.dateTo,
    );
    final analytics = BookingAnalytics(
      data: overview,
      period: _period,
      range: range,
    );

    // Tablet / desktop: one scrolling dashboard instead of the phone's tabs.
    if (context.isTabletOrWider) {
      return BookingOverviewDashboard(
        analytics: analytics,
        isLoading: isLoading,
        contextLine: BookingContextLine(
          range: range,
          count: analytics.totalBookings,
          revenue: analytics.revenue,
          summaryLine: analytics.summaryLine,
        ),
        filters: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            BookingPeriodChips(
              period: _period,
              customRange: _customRange,
              onPeriod: (p) {
                if (p == BookingPeriod.custom) {
                  _pickRange();
                } else {
                  setState(() => _period = p);
                  _reload();
                }
              },
              onEditCustom: _pickRange,
            ),
            const SizedBox(height: AppDimens.paddingX10),
            BookingVenueFilter(
              venues: overview.availableVenues,
              selectedId: _futsalId,
              onChange: (id) {
                setState(() => _futsalId = id);
                _reload();
              },
            ),
          ],
        ),
      );
    }

    // Phone: filters above three tabs.
    final bool wide = context.isTabletOrWider;
    final double inset = context.responsive<double>(
      mobile: AppDimens.paddingX20,
      tablet: AppDimens.paddingX32,
    );
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: wide ? kDashboardMaxWidth : double.infinity,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Shared filters — pinned above the tabs so they apply everywhere.
            Padding(
              padding: EdgeInsets.only(
                left: context.responsive<double>(
                  mobile: AppDimens.paddingX20,
                  tablet: AppDimens.paddingX32,
                ),
                right: context.responsive<double>(
                  mobile: AppDimens.paddingX20,
                  tablet: AppDimens.paddingX32,
                ),
                top: AppDimens.paddingX4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BookingContextLine(
                    range: range,
                    count: analytics.totalBookings,
                    revenue: analytics.revenue,
                    summaryLine: analytics.summaryLine,
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
                        _reload();
                      }
                    },
                    onEditCustom: _pickRange,
                  ),
                  const SizedBox(height: AppDimens.paddingX10),
                  BookingVenueFilter(
                    venues: overview.availableVenues,
                    selectedId: _futsalId,
                    onChange: (id) {
                      setState(() => _futsalId = id);
                      _reload();
                    },
                  ),
                  // Keep the current dashboard visible while a filter refreshes.
                  // The refresh indicator intentionally has zero thickness.
                  if (isLoading) const SizedBox.shrink(),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.paddingX8),
            // Tablet / desktop: indented to the content, so the labels, the indicator
            // and the divider line share the cards' edges.
            Padding(
              padding: EdgeInsets.symmetric(horizontal: wide ? inset : 0),
              child: TabBar(
                controller: _tabController,
                // Tablet / desktop: tabs together at the start, in line with the
                // content, instead of a third of the window apart.
                isScrollable: wide,
                tabAlignment: wide ? TabAlignment.start : null,
                // The first label starts at the content's edge; the gap goes between
                // tabs instead.
                labelPadding: wide
                    ? const EdgeInsets.only(right: AppDimens.paddingX32)
                    : null,
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
        ),
      ),
    );
  }
}

/// Widest the overview dashboard grows before centring in the window.
const double kDashboardMaxWidth = 1280;

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
            Icon(Icons.cloud_off_rounded, size: 40, color: LightColor.iconGrey),
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
