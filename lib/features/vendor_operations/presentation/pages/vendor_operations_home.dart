import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/widgets/app_message_view.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/data/manual_group_booking_service.dart';
import 'package:hamro_futsal/features/vendor_operations/data/service/vendor_ops_socket_service.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_court_cards.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_style.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_booking_details.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_booking_panel.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_day_overview.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_toolbar.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_week_table.dart';
import 'package:shimmer/shimmer.dart';

/// The page's side margin.
const double _kGutter = 16;

double _opsGutter(BuildContext context) => context.responsive<double>(
  mobile: _kGutter,
  tablet: 20,
  desktop: 24,
  large: 32,
);

double _opsHeaderTopGap(BuildContext context) =>
    context.responsive<double>(mobile: 14, tablet: 18, desktop: 22, large: 24);

/// The vendor's Home tab: today's operations across every venue and court,
/// with manual booking on the same page.
class VendorOperationsHome extends StatefulWidget {
  const VendorOperationsHome({
    super.key,
    this.topInset = 0,
    this.repository,
    this.demo,
    this.operationalHomeEnabled = true,
    this.onHomeModeChanged,
    this.hasUnreadNotifications = false,
    this.onNotifications,
    this.userName,
  });

  /// Space reserved at the top for the dashboard's own chrome.
  final double topInset;

  /// Injected in tests; ignored while demo data is on.
  final VendorOpsRepository? repository;

  /// Starts on demo data. Defaults to [kVendorOpsDemoByDefault].
  final bool? demo;

  final bool operationalHomeEnabled;
  final ValueChanged<bool>? onHomeModeChanged;
  final bool hasUnreadNotifications;
  final VoidCallback? onNotifications;

  /// Who the toolbar greets — the vendor's first name.
  final String? userName;

  @override
  State<VendorOperationsHome> createState() => _VendorOperationsHomeState();
}

class _VendorOperationsHomeState extends State<VendorOperationsHome> {
  late bool _demo = widget.demo ?? kVendorOpsDemoByDefault;

  final VendorOpsDemoStore _demoStore = VendorOpsDemoStore();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VendorOpsBloc>(
      key: ValueKey<bool>(_demo),
      create: (_) => VendorOpsBloc(
        repository: _demo
            ? DemoVendorOpsRepository(_demoStore)
            : widget.repository,
        // Demo data never goes live.
        socket: _demo ? const NoopVendorOpsSocketService() : null,
        weekStartMode: OpsWeekStart.fromKey(AppSettings().vendorOpsWeekStart),
      )..add(const VendorOpsStarted()),
      child: BlocListener<VendorOpsBloc, VendorOpsState>(
        listenWhen: (VendorOpsState a, VendorOpsState b) =>
            a.weekStartMode != b.weekStartMode,
        listener: (BuildContext context, VendorOpsState state) {
          if (AppSettings().isInitialized) {
            AppSettings().vendorOpsWeekStart = state.weekStartMode.key;
          }
        },
        child: _OperationsView(
          topInset: widget.topInset,
          demo: _demo,
          service: _demo ? demoBookingService(_demoStore) : null,
          operationalHomeEnabled: widget.operationalHomeEnabled,
          onHomeModeChanged: widget.onHomeModeChanged,
          hasUnreadNotifications: widget.hasUnreadNotifications,
          onNotifications: widget.onNotifications,
          userName: widget.userName,
          onDemoChanged: (bool value) => setState(() => _demo = value),
        ),
      ),
    );
  }
}

class _OperationsView extends StatefulWidget {
  const _OperationsView({
    required this.topInset,
    required this.demo,
    required this.onDemoChanged,
    required this.operationalHomeEnabled,
    required this.hasUnreadNotifications,
    this.service,
    this.onHomeModeChanged,
    this.onNotifications,
    this.userName,
  });

  final double topInset;
  final bool demo;
  final ValueChanged<bool> onDemoChanged;
  final bool operationalHomeEnabled;
  final bool hasUnreadNotifications;
  final ValueChanged<bool>? onHomeModeChanged;
  final VoidCallback? onNotifications;
  final String? userName;

  /// Booking service for the panel; the live one when null.
  final ManualGroupBookingService? service;

  @override
  State<_OperationsView> createState() => _OperationsViewState();
}

class _OperationsViewState extends State<_OperationsView> {
  static const double _panelWidth = 380;
  static const double _wideBreakpoint = 900;

  bool _panelOpen = false;

  bool _isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _wideBreakpoint;

  void _openBooking(BuildContext context) {
    if (_isWide(context)) {
      setState(() => _panelOpen = !_panelOpen);
    } else {
      _openBookingSheet(context);
    }
  }

  Future<void> _openBookingSheet(BuildContext context) {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // Only the panel closes the sheet — its close and Back buttons, or
      // system back through its PopScope — so a booking in progress is never
      // dropped by a stray swipe or a tap outside, and held slots are asked
      // about first.
      enableDrag: false,
      isDismissible: false,
      backgroundColor: LightColor.cardColor,
      clipBehavior: Clip.antiAlias,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) => BlocProvider<VendorOpsBloc>.value(
        value: bloc,
        child: Padding(
          // Lifts the form above the keyboard.
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),

          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.92,
            minChildSize: 0.92,
            maxChildSize: 0.92,
            builder: (BuildContext context, ScrollController controller) =>
                OpsBookingPanel(
                  service: widget.service,
                  scrollController: controller,
                  inSheet: true,
                  onClose: () => _closeSheet(sheetContext),
                ),
          ),
        ),
      ),
    );
  }

  /// Closes the booking sheet — and only the sheet. A bare `pop()` pops
  /// whatever is on top of the navigator: called after the sheet has already
  /// gone (a second close landing while it animates away), it would pop the
  /// dashboard page itself, and go_router asserts it has no page left.
  void _closeSheet(BuildContext sheetContext) {
    final ModalRoute<Object?>? route = ModalRoute.of(sheetContext);
    if (route == null || !route.isActive) return;
    final NavigatorState navigator = Navigator.of(sheetContext);
    if (route.isCurrent) {
      navigator.pop();
    } else {
      // Something (a dialog) is above it: take the sheet out from under it
      // rather than popping what is on top.
      navigator.removeRoute(route);
    }
  }

  void _openDetails(BuildContext context, BookingModel booking) {
    showOpsBookingDetails(
      context,
      booking,
      demo: widget.demo,
      nowMinute: context.read<VendorOpsBloc>().state.board?.nowMinute,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = _isWide(context);
    final double navInset = context.isTabletOrWider
        ? 0
        : CustomBottomNavigationBar.heightOf(context);

    return BlocListener<VendorOpsBloc, VendorOpsState>(
      // Open on every slot added, not only on the first: closing the panel
      // keeps the selection, so the next tap only grows a selection that is
      // already non-empty — and the panel used to stay closed for good.
      listenWhen: (VendorOpsState a, VendorOpsState b) =>
          b.selection.keys.any((String key) => !a.selection.containsKey(key)),
      listener: (BuildContext context, _) {
        if (wide && !_panelOpen) setState(() => _panelOpen = true);
      },
      child: ColoredBox(
        color: LightColor.background,
        child: Column(
          children: <Widget>[
            SizedBox(height: widget.topInset),
            OpsToolbar(
              operationalHomeEnabled: widget.operationalHomeEnabled,
              onHomeModeChanged: widget.onHomeModeChanged,
              hasUnreadNotifications: widget.hasUnreadNotifications,
              onNotifications: widget.onNotifications,
              userName: widget.userName,
              onManualBooking: () => _openBooking(context),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Stack(
                      children: <Widget>[
                        _Content(
                          demo: widget.demo,
                          onDemoChanged: widget.onDemoChanged,
                          bottomInset: navInset + (wide ? 16 : 96),
                          onBookingTap: (BookingModel b) =>
                              _openDetails(context, b),
                        ),
                        if (!wide)
                          Positioned(
                            left: 12,
                            right: 12,
                            bottom: navInset + 10,
                            child: _SelectionBar(
                              onReview: () => _openBookingSheet(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: wide && _panelOpen
                        ? Container(
                            width: _panelWidth,
                            decoration: BoxDecoration(
                              color: LightColor.cardColor,
                              border: Border(
                                left: BorderSide(
                                  color: LightColor.dividerColor,
                                ),
                              ),
                            ),
                            child: OpsBookingPanel(
                              service: widget.service,
                              onClose: () => setState(() => _panelOpen = false),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({
    required this.bottomInset,
    required this.onBookingTap,
    required this.demo,
    required this.onDemoChanged,
  });

  final bool demo;
  final ValueChanged<bool> onDemoChanged;

  final double bottomInset;
  final OpsBookingTap onBookingTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.status != b.status ||
          a.courts.isEmpty != b.courts.isEmpty ||
          a.bookingsError != b.bookingsError ||
          a.errorMessage != b.errorMessage,
      builder: (BuildContext context, VendorOpsState state) {
        final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
        switch (state.status) {
          case VendorOpsStatus.initial:
          case VendorOpsStatus.loading:
            return const _LoadingSkeleton();
          case VendorOpsStatus.failure:
            return AppMessageView(
              icon: Icons.cloud_off_rounded,
              title: 'Could not load your venues',
              message: state.errorMessage ?? 'Check your connection and retry.',
              actionLabel: 'Retry',
              onAction: () => bloc.add(const VendorOpsStarted()),
            );
          case VendorOpsStatus.success:
            break;
        }
        if (state.courts.isEmpty) {
          return AppMessageView(
            icon: Icons.stadium_outlined,
            title: 'No venues to manage yet',
            message:
                'Once a venue with courts is approved, today\'s bookings and '
                'availability appear here.',
            actionLabel: 'Refresh',
            onAction: () => bloc.add(const VendorOpsStarted()),
          );
        }
        final double gutter = _opsGutter(context);
        return RefreshIndicator(
          color: LightColor.secondaryColor,
          onRefresh: () {
            final Completer<void> done = Completer<void>();
            bloc.add(VendorOpsRefreshed(completer: done));
            return done.future;
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            scrollCacheExtent: const ScrollCacheExtent.pixels(700),
            slivers: <Widget>[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  gutter,
                  _opsHeaderTopGap(context),
                  gutter,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // if (demo || kVendorOpsDemoByDefault) ...<Widget>[
                      // _DemoBanner(demo: demo, onChanged: onDemoChanged),
                      // const SizedBox(height: 12),
                      // ],
                      // Shown in both views, but always the Day board's: on the
                      // Week table it keeps the last day's values while weeks
                      // are browsed.
                      const _ActiveContext(),
                      const SizedBox(height: 12),
                      if (state.bookingsError)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _InlineError(
                            message:
                                state.errorMessage ??
                                'Bookings for this date could not be loaded.',
                            onRetry: () => bloc.add(const VendorOpsRefreshed()),
                          ),
                        ),
                      const OpsDayOverview(),
                      SizedBox(
                        height: context.responsive<double>(
                          mobile: 18,
                          tablet: 20,
                          desktop: 22,
                          large: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _AvailabilitySection(onBookingTap: onBookingTap),
              SliverToBoxAdapter(child: SizedBox(height: bottomInset)),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveContext extends StatelessWidget {
  const _ActiveContext();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      // Follows the Day board only: browsing weeks on the Week table moves
      // the date, but this keeps the day last shown.
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          b.view == OpsAvailabilityView.day &&
          (a.view != b.view || a.date != b.date),
      builder: (BuildContext context, VendorOpsState state) {
        return Semantics(
          liveRegion: true,
          child: Text(
            state.isToday
                ? 'Today · ${DateFmt.date(state.date)}'
                : DateFmt.date(state.date),
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
            ),
          ),
        );
      },
    );
  }
}

/// Phone: the selection's size and estimate, always in reach, with Review
/// to book it and a way to drop it.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.onReview});

  final VoidCallback onReview;

  static const Duration _motion = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.selection != b.selection,
      builder: (BuildContext context, VendorOpsState state) {
        return AnimatedSwitcher(
          duration: _motion,
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (Widget child, Animation<double> a) =>
              FadeTransition(
                opacity: a,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(a),
                  child: child,
                ),
              ),
          child: state.selection.isEmpty
              ? const SizedBox.shrink(key: ValueKey<bool>(false))
              : KeyedSubtree(
                  key: const ValueKey<bool>(true),
                  child: _bar(context, state),
                ),
        );
      },
    );
  }

  Widget _bar(BuildContext context, VendorOpsState state) {
    final int slots = state.selection.length;
    final int courts = state.selection.values
        .map((OpsSelectionItem i) => i.courtId)
        .toSet()
        .length;
    final Iterable<double?> prices = state.selection.values.map(
      (OpsSelectionItem i) => i.price,
    );
    final bool anyPriced = prices.any((double? p) => p != null);
    final bool allPriced = prices.every((double? p) => p != null);
    final double estimate = prices.fold<double>(
      0,
      (double sum, double? p) => sum + (p ?? 0),
    );

    final String headline =
        '$slots ${slots == 1 ? 'slot' : 'slots'} · '
        '${formatHours(state.selectedMinutes)} court-h';
    // Unpriced slots are priced by the server on confirmation, so a partial
    // total is a floor, not the estimate.
    final String price = !anyPriced
        ? 'Price on confirmation'
        : 'Est. ${allPriced ? '' : 'from '}${Money.npr(estimate)}';
    final String detail =
        '$courts ${courts == 1 ? 'court' : 'courts'} · $price';

    const Color fg = LightColor.onBrandSurface;
    const List<FontFeature> figures = <FontFeature>[
      FontFeature.tabularFigures(),
    ];
    return Semantics(
      container: true,
      label: 'Selected: $headline, $detail',
      child: Material(
        color: LightColor.secondaryColor,
        elevation: 6,
        shadowColor: LightColor.secondaryColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onReview,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 10, 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    tooltip: 'Clear selection',
                    visualDensity: VisualDensity.compact,
                    color: fg,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => context.read<VendorOpsBloc>().add(
                      const VendorOpsSelectionCleared(),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            headline,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: fg,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              fontFeatures: figures,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fg.withValues(alpha: 0.85),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFeatures: figures,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: onReview,
                    style: FilledButton.styleFrom(
                      backgroundColor: fg,
                      foregroundColor: LightColor.secondaryColor,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      minimumSize: const Size(0, 40),
                    ),
                    child: const Text(
                      'Review',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
      decoration: BoxDecoration(
        color: LightColor.redLightColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.error_outline_rounded,
            color: LightColor.redColor,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: LightColor.onRedLightColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bone(double h, {double? w, double r = 12}) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: LightColor.skeletonBaseColor,
        borderRadius: BorderRadius.circular(r),
      ),
    );
    return Semantics(
      label: 'Loading today\'s operations',
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: LightColor.skeletonBaseColor,
          highlightColor: LightColor.skeletonHighlightColor,
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              bone(20, w: 200, r: 6),
              const SizedBox(height: 8),
              bone(12, w: 160, r: 6),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(child: bone(84)),
                  const SizedBox(width: 10),
                  Expanded(child: bone(84)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(child: bone(84)),
                  const SizedBox(width: 10),
                  Expanded(child: bone(84)),
                ],
              ),
              const SizedBox(height: 20),
              bone(16, w: 120, r: 6),
              const SizedBox(height: 10),
              for (int i = 0; i < 3; i++) ...<Widget>[
                bone(130),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilitySection extends StatelessWidget {
  const _AvailabilitySection({required this.onBookingTap});

  final OpsBookingTap onBookingTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.view != b.view || a.date != b.date,
      builder: (BuildContext context, VendorOpsState state) {
        final bool week = state.view == OpsAvailabilityView.week;
        final double gutter = _opsGutter(context);
        return SliverMainAxisGroup(
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _AvailabilityHeaderDelegate(
                view: state.view,
                gutter: gutter,
                onChanged: (OpsAvailabilityView v) =>
                    context.read<VendorOpsBloc>().add(VendorOpsViewChanged(v)),
              ),
            ),
            if (week)
              SliverPadding(
                padding: EdgeInsets.only(left: gutter),
                sliver: SliverToBoxAdapter(
                  child: OpsWeekTableView(
                    onBookingTap: onBookingTap,
                    rightInset: gutter,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                sliver: _DayAvailability(
                  state: state,
                  onBookingTap: onBookingTap,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AvailabilityHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _AvailabilityHeaderDelegate({
    required this.view,
    required this.gutter,
    required this.onChanged,
  });

  final OpsAvailabilityView view;
  final double gutter;
  final ValueChanged<OpsAvailabilityView> onChanged;

  static const double _height = 54;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: LightColor.background,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: LightColor.shadowColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(gutter, 6, gutter, 12),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'Availability',
                style: FutsalTheme.getTextTheme(context).bodyTextMedium
                    ?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: LightColor.primaryTextColor,
                    ),
              ),
            ),
            SizedBox(
              width: 168,
              child: _ViewTabs(value: view, onChanged: onChanged),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_AvailabilityHeaderDelegate oldDelegate) =>
      oldDelegate.view != view ||
      oldDelegate.gutter != gutter ||
      oldDelegate.onChanged != onChanged;
}

/// The Day board: the date row, the status key on demand, and the courts.
class _DayAvailability extends StatefulWidget {
  const _DayAvailability({required this.state, required this.onBookingTap});

  final VendorOpsState state;
  final OpsBookingTap onBookingTap;

  @override
  State<_DayAvailability> createState() => _DayAvailabilityState();
}

class _DayAvailabilityState extends State<_DayAvailability> {
  /// The status key stays out of the way until asked for.
  bool _showStatus = false;

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: <Widget>[
        // The same `‹ date › [Today]` as the top bar; the status key's
        // toggle sits at the right.
        SliverToBoxAdapter(
          child: Row(
            children: <Widget>[
              // Left-aligned, taking whatever the toggle leaves.
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: OpsDateControls(
                    state: widget.state,
                    showDayLabel: false,
                    alignStart: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusToggle(
                open: _showStatus,
                onPressed: () => setState(() => _showStatus = !_showStatus),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _showStatus
                ? const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: OpsLegend(),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        OpsCourtCardsSliver(onBookingTap: widget.onBookingTap),
      ],
    );
  }
}

/// Shows or hides the key of slot and payment statuses: a quiet text
/// button — grey while the key is hidden, brand-coloured while it shows.
class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.open, required this.onPressed});

  final bool open;
  final VoidCallback onPressed;

  static const Duration _motion = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    final Color color = open
        ? LightColor.brandTextColor
        : LightColor.secondaryTextColor;
    return Semantics(
      button: true,
      expanded: open,
      label: open ? 'Hide statuses' : 'View statuses',
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            // A full-size tap target around a small-looking control.
            constraints: const BoxConstraints(minHeight: 40),
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: _motion,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewTabs extends StatelessWidget {
  const _ViewTabs({required this.value, required this.onChanged});

  final OpsAvailabilityView value;
  final ValueChanged<OpsAvailabilityView> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(OpsAvailabilityView v, String label, String hint) {
      final bool selected = v == value;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: '$label. $hint',
          child: ExcludeSemantics(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(v),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? LightColor.secondaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? LightColor.onBrandSurface
                        : LightColor.secondaryTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Row(
        children: <Widget>[
          tab(OpsAvailabilityView.day, 'Day', 'Every court today'),
          const SizedBox(width: 3),
          tab(OpsAvailabilityView.week, 'Week', 'One court, whole week'),
        ],
      ),
    );
  }
}
