import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:hamro_futsal/features/bookings/domain/usecase/get_bookings_use_case.dart';
import 'package:hamro_futsal/features/bookings/presentation/bloc/booking_bloc/booking_bloc.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_date_filter_widgets.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_futsal/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_shared_widgets.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_status_page.dart';

enum _BookingTab { futsal, mine }

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  /// Which list a caller outside the page wants shown — a notification tap
  /// lands on the booking the push is about, and the list behind it should be
  /// the one that booking belongs to.
  ///
  /// Held as a notifier rather than a route argument because the page lives in
  /// the dashboard's [IndexedStack]: it is usually already built and is never
  /// re-created when the bookings tab is selected again.
  static final ValueNotifier<BookingListKind?> requestedList =
      ValueNotifier<BookingListKind?>(null);

  @override
  Widget build(BuildContext context) {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String role =
        profileState.profile?.data.role.trim().toLowerCase() ?? '';

    if (role.isEmpty) {
      // Which list to show depends on the account role, so the page waits for
      // the profile. If that fetch failed — or came back without a role —
      // there is nothing left to wait for, so show the error with a retry
      // instead of spinning forever.
      final bool fetchFailed = profileState.status == ProfileStatus.failure;
      final bool roleMissing = profileState.profile != null;
      if (fetchFailed || roleMissing) {
        return BookingErrorView(
          message: fetchFailed
              ? (profileState.errorMessage ??
                    'We could not load your account details, so your bookings '
                        'cannot be shown.')
              : 'Your account role is missing, so we cannot tell which '
                    'bookings to show.',
          onRetry: () =>
              context.read<ProfileBloc>().add(const FetchProfileEvent()),
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: LightColor.secondaryColor),
      );
    }
    final bool isCandidate = role == 'candidate';

    return BlocProvider<BookingBloc>(
      create: (_) =>
          BookingBloc(GetBookingsUseCase(BookingRepositoryImpl()))..add(
            isCandidate
                ? const FetchMyBookingsEvent()
                : const FetchFutsalBookingsEvent(),
          ),
      child: _BookingsView(isCandidate: isCandidate),
    );
  }
}

class _BookingsView extends StatefulWidget {
  const _BookingsView({required this.isCandidate});

  final bool isCandidate;

  @override
  State<_BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<_BookingsView>
    with SingleTickerProviderStateMixin {
  _BookingTab _activeTab = _BookingTab.futsal;
  // A TabController keeps the bar and the view in lock-step: tapping a tab and
  // swiping both drive the same index, so the underline, filters, date control
  // and the walk-in FAB switch with the gesture instead of after it settles.
  late final TabController _tabController;
  // One page per status, per list. The pager and the chips are two views of
  // the same selection: tapping a chip animates the pager, swiping the pager
  // selects the chip.
  // Held in notifiers rather than in setState fields: a page change concerns
  // only the chip strip, and rebuilding the whole screen for it (tab bar,
  // search box, both pagers and every page inside them) is what made the swipe
  // stutter.
  final ValueNotifier<BookingStatusFilter> _futsalFilterVN =
      ValueNotifier<BookingStatusFilter>(BookingStatusFilter.all);
  final ValueNotifier<BookingStatusFilter> _myFilterVN =
      ValueNotifier<BookingStatusFilter>(BookingStatusFilter.all);
  late final PageController _futsalPageCtrl = PageController();
  late final PageController _myPageCtrl = PageController();
  final ScrollController _chipCtrl = ScrollController();
  Timer? _searchDebounce;
  // Newest bookings first — the most recent activity is what vendors and
  // players look for when they open the list.
  BookingDateOrder _dateOrder = BookingDateOrder.descending;

  // A date filter per list. One value covers day, month and range — see
  // [BookingDateFilter] — so there is no mode flag to fall out of step with
  // the dates it applies to.
  //
  // The two lists keep separate filters because they answer different
  // questions: a vendor works through the venue's day, a player looks back
  // over their own bookings. The order is shared — it is how a list is read,
  // not what it holds.
  BookingDateFilter _futsalDateFilter = const BookingDateFilter.all();
  BookingDateFilter _myDateFilter = const BookingDateFilter.all();
  final TextEditingController _futsalSearchController = TextEditingController();
  final TextEditingController _mySearchController = TextEditingController();

  static const List<BookingStatusFilter> _visibleFilters =
      <BookingStatusFilter>[
        BookingStatusFilter.all,
        BookingStatusFilter.pending,
        BookingStatusFilter.confirmed,
        BookingStatusFilter.completed,
        BookingStatusFilter.cancelled,
      ];

  /// Both lists offer the same statuses — the endpoints take the same `status`
  /// values — so one label map serves the chips of either tab.
  static String _filterLabel(BookingStatusFilter filter) => switch (filter) {
    BookingStatusFilter.all => StringConstants.all,
    BookingStatusFilter.pending => StringConstants.pending,
    BookingStatusFilter.confirmed => StringConstants.confirmed,
    BookingStatusFilter.completed => StringConstants.completed,
    BookingStatusFilter.cancelled => StringConstants.cancelled,
    BookingStatusFilter.rejected => StringConstants.rejected,
  };

  ValueNotifier<BookingStatusFilter> get _activeFilterVN =>
      _showsMyBookings ? _myFilterVN : _futsalFilterVN;

  BookingStatusFilter get _activeFilter => _activeFilterVN.value;

  TextEditingController get _activeSearchController =>
      _showsMyBookings ? _mySearchController : _futsalSearchController;

  BookingListKind get _activeKind =>
      _showsMyBookings ? BookingListKind.mine : BookingListKind.futsal;

  bool get _showsMyBookings =>
      widget.isCandidate || _activeTab == _BookingTab.mine;

  /// The visible list's date filter. Both tabs drive the same button and the
  /// same strip through this, so the section has one code path rather than a
  /// futsal branch and a my-bookings branch that drift apart.
  BookingDateFilter get _activeDateFilter =>
      _showsMyBookings ? _myDateFilter : _futsalDateFilter;

  void _setActiveDateFilter(
    BookingDateFilter filter, {
    BookingDateOrder? order,
  }) {
    final BookingDateOrder nextOrder = order ?? _dateOrder;
    setState(() {
      _dateOrder = nextOrder;
      if (_showsMyBookings) {
        _myDateFilter = filter;
      } else {
        _futsalDateFilter = filter;
      }
    });
    // The window and the order are the server's filters now, so the list has
    // to be asked again rather than re-sifted on the device. The bloc drops
    // the cached statuses and starts the visible one from page 1.
    final BookingBloc bloc = context.read<BookingBloc>();
    if (_showsMyBookings) {
      bloc.add(
        ApplyMyBookingsFiltersEvent(dateFilter: filter, order: nextOrder),
      );
    } else {
      bloc.add(
        ApplyFutsalBookingsFiltersEvent(dateFilter: filter, order: nextOrder),
      );
    }
  }

  ValueNotifier<BookingStatusFilter> _filterVNFor(BookingListKind kind) =>
      kind == BookingListKind.mine ? _myFilterVN : _futsalFilterVN;

  int _visibleFilterIndex(BookingStatusFilter filter) {
    final int index = _visibleFilters.indexOf(filter);
    return index < 0 ? 0 : index;
  }

  PageController _pageCtrlFor(BookingListKind kind) =>
      kind == BookingListKind.mine ? _myPageCtrl : _futsalPageCtrl;

  bool _kindIsVisible(BookingListKind kind) =>
      widget.isCandidate ? kind == BookingListKind.mine : kind == _activeKind;

  @override
  void initState() {
    super.initState();
    if (widget.isCandidate) _activeTab = _BookingTab.mine;
    // A notification tapped while the page was not built yet decides which
    // tab it opens on, so the request is consumed before the controller is
    // created rather than animated away afterwards.
    final _BookingTab? requested = _takeRequestedTab();
    if (requested != null) _activeTab = requested;
    _tabController = TabController(
      length: _BookingTab.values.length,
      initialIndex: _activeTab.index,
      vsync: this,
    )..addListener(_handleTabChanged);

    // Tabs stay alive inside the dashboard's IndexedStack, so re-fetch the
    // latest bookings automatically whenever this tab becomes visible again
    // (also recovers from a fetch that failed while offline).
    DashboardScreen.selectedNavIndex.addListener(_refreshOnTabVisible);
    BookingsPage.requestedList.addListener(_applyRequestedList);
  }

  /// Reads and clears [BookingsPage.requestedList]. A candidate only ever has
  /// their own bookings, so a request is consumed without moving anything.
  _BookingTab? _takeRequestedTab() {
    final BookingListKind? requested = BookingsPage.requestedList.value;
    if (requested == null) return null;
    BookingsPage.requestedList.value = null;
    if (widget.isCandidate) return null;
    return requested == BookingListKind.mine
        ? _BookingTab.mine
        : _BookingTab.futsal;
  }

  /// Honours a list requested while the page is already alive — the usual
  /// case, since the dashboard keeps this tab built.
  void _applyRequestedList() {
    final _BookingTab? tab = _takeRequestedTab();
    if (tab == null || !mounted || tab == _activeTab) return;
    _tabController.animateTo(tab.index);
  }

  @override
  void dispose() {
    DashboardScreen.selectedNavIndex.removeListener(_refreshOnTabVisible);
    BookingsPage.requestedList.removeListener(_applyRequestedList);
    _tabController
      ..removeListener(_handleTabChanged)
      ..dispose();
    _futsalSearchController.dispose();
    _mySearchController.dispose();
    _searchDebounce?.cancel();
    _myFilterVN.dispose();
    _futsalFilterVN.dispose();
    _futsalPageCtrl.dispose();
    _myPageCtrl.dispose();
    _chipCtrl.dispose();
    super.dispose();
  }

  void _refreshOnTabVisible() {
    if (!mounted || DashboardScreen.selectedNavIndex.value != 1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || DashboardScreen.selectedNavIndex.value != 1) return;
      _refreshCurrentTab();
    });
  }

  void _refreshCurrentTab() {
    if (!mounted) return;
    final BookingBloc bloc = context.read<BookingBloc>();
    if (_showsMyBookings) {
      final BookingStatusFilter filter = _myFilterVN.value;
      final BookingListSlice slice = bloc.state.mySlice(filter);
      if (slice.loadStatus == BookingLoadStatus.loading) return;
      bloc.add(
        FetchMyBookingsEvent(
          filter: filter,
          silent: slice.loadStatus == BookingLoadStatus.success,
          force: true,
        ),
      );
    } else {
      final BookingStatusFilter filter = _futsalFilterVN.value;
      final BookingListSlice slice = bloc.state.futsalSlice(filter);
      if (slice.loadStatus == BookingLoadStatus.loading) return;
      bloc.add(
        FetchFutsalBookingsEvent(
          filter: filter,
          silent: slice.loadStatus == BookingLoadStatus.success,
          force: true,
        ),
      );
    }
  }

  void _handleTabChanged() {
    if (widget.isCandidate) return;
    final _BookingTab tab = _BookingTab.values[_tabController.index];
    if (tab == _activeTab) return;

    setState(() => _activeTab = tab);

    final BookingBloc bloc = context.read<BookingBloc>();
    if (tab == _BookingTab.mine) {
      bloc.add(FetchMyBookingsEvent.select(_myFilterVN.value));
    } else {
      bloc.add(FetchFutsalBookingsEvent.select(_futsalFilterVN.value));
    }
    _revealChip(_visibleFilterIndex(_activeFilter));
  }

  void _onFilterSelected(BookingStatusFilter filter) {
    final BookingListKind kind = _activeKind;
    final ValueNotifier<BookingStatusFilter> filterVN = _filterVNFor(kind);
    final int target = _visibleFilterIndex(filter);
    if (filterVN.value == filter) {
      if (filter == BookingStatusFilter.all) _clearNarrowingFilters();
      return;
    }
    final PageController controller = _pageCtrlFor(kind);
    if (!controller.hasClients) {
      _onStatusPageChanged(kind, target);
      return;
    }
    final int current = (controller.page ?? controller.initialPage.toDouble())
        .round();
    if ((target - current).abs() > 1) {
      controller.jumpToPage(target);
    } else {
      controller.animateToPage(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onStatusPageChanged(BookingListKind kind, int index) {
    final BookingStatusFilter filter = _visibleFilters[index];
    final ValueNotifier<BookingStatusFilter> filterVN = _filterVNFor(kind);
    if (filter == filterVN.value) return;

    filterVN.value = filter;
    if (_kindIsVisible(kind)) _revealChip(index);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final BookingBloc bloc = context.read<BookingBloc>();
      if (kind == BookingListKind.mine) {
        bloc.add(FetchMyBookingsEvent.refresh(filter));
      } else {
        bloc.add(FetchFutsalBookingsEvent.refresh(filter));
      }
    });
    if (filter == BookingStatusFilter.all && _kindIsVisible(kind)) {
      _clearNarrowingFilters();
    }
  }

  /// The All page shows everything, so selecting it releases the search box
  /// and the date window too.
  void _clearNarrowingFilters() {
    setState(() => _activeSearchController.clear());
    if (_activeDateFilter.isActive) {
      // Goes through the same path as any other change, so the server is told
      // as well rather than the rows being re-sifted on the device.
      _setActiveDateFilter(const BookingDateFilter.all());
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (mounted) setState(() {});
    });
  }

  /// Keeps the selected chip on screen as the pager moves.
  void _revealChip(int index) {
    if (!_chipCtrl.hasClients) return;
    // Approximate chip pitch — enough to bring the active one into view, and
    // clamped to the strip's own extent either way.
    const double chipExtent = 104;
    final double target = (chipExtent * index - chipExtent).clamp(
      0.0,
      _chipCtrl.position.maxScrollExtent,
    );
    _chipCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  /// Opens the one sheet that holds all three ways of narrowing by date, plus
  /// the order the rows are listed in. Both tabs use it.
  Future<void> _openDateFilter() async {
    final BookingDateFilterResult? result = await showBookingDateFilterSheet(
      context,
      current: _activeDateFilter,
      currentOrder: _dateOrder,
    );
    if (result == null || !mounted) return;
    _setActiveDateFilter(result.filter, order: result.order);
  }

  /// The strip's arrows: a day at a time in day mode, a month at a time in
  /// month mode. [BookingDateFilter.stepped] knows which.
  void _stepActiveDate(int steps) =>
      _setActiveDateFilter(_activeDateFilter.stepped(steps));

  /// Resets the visible list's date filter back to "all dates".
  void _clearActiveDateFilter() =>
      _setActiveDateFilter(const BookingDateFilter.all());

  void _clearSearch() {
    if (_activeSearchController.text.isEmpty) return;
    _activeSearchController.clear();
    setState(() {});
  }

  /// Opens the manual (walk-in) booking flow. It pops `true` once a booking is
  /// created, so the futsal list is refreshed to show it straight away.
  Future<void> _openManualBooking() async {
    final bool? created = await context.pushNamed<bool>(
      AppRouterParams.manualBooking.name,
    );
    if (created != true || !mounted) return;
    context.read<BookingBloc>().add(
      const FetchFutsalBookingsEvent(silent: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    // The dashboard hosts this page, so the FAB lives in a Stack rather than a
    // nested Scaffold — walk-in bookings are a vendor-only action on the futsal
    // tab, so it is hidden everywhere else.
    if (!widget.isCandidate && _activeTab == _BookingTab.futsal) {
      return Stack(
        children: <Widget>[
          _buildBody(context),
          Positioned(
            right: AppDimens.paddingX16,
            // The dashboard paints its bottom navigation bar as a sibling laid
            // over this content, so the button must clear the bar — measured,
            // because the bar grows with the text scale and the system inset.
            // On tablets and wider the shell uses side navigation and has
            // already applied the bottom inset, so only a margin is needed.
            bottom: manualBookingFabBottomInset(context),
            // Same compact pill as the expenses screen's "New Expense" action.
            child: SizedBox(
              height: kManualBookingFabHeight,
              child: FloatingActionButton.extended(
                key: const Key('manual-booking-fab'),
                heroTag: 'manual-booking-fab',
                onPressed: _openManualBooking,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.inverseTextColor,
                elevation: 0,
                extendedPadding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const StadiumBorder(),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(
                  StringConstants.manualBooking,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.inverseTextColor,
                      ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppDimens.paddingX20),
        _tabBar(context),
        const SizedBox(height: AppDimens.paddingX14),
        _searchAndFilterSection(context),
        const SizedBox(height: AppDimens.paddingX8),
        Expanded(
          child: widget.isCandidate
              ? _statusPager(BookingListKind.mine)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _statusPager(BookingListKind.futsal),
                    _statusPager(BookingListKind.mine),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _tabBar(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    if (widget.isCandidate) {
      return Padding(
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        child: _TabItem(
          label: StringConstants.myBookings,
          isActive: true,
          onTap: () {},
        ),
      );
    }

    // Match Help & FAQ: the TabController drives both the indicator and the
    // horizontally swipeable booking pages, keeping taps and drag gestures in
    // sync throughout the transition.
    return TabBar(
      controller: _tabController,
      labelColor: LightColor.secondaryColor,
      unselectedLabelColor: LightColor.secondaryTextColor,
      indicatorColor: LightColor.secondaryColor,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: LightColor.dividerColor,
      labelStyle: textTheme.bodyTextSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: textTheme.bodyTextSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      tabs: const <Widget>[
        Tab(text: StringConstants.futsalBookings, height: 40),
        Tab(text: StringConstants.myBookings, height: 40),
      ],
    );
  }

  Widget _searchAndFilterSection(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final TextEditingController searchController = _activeSearchController;
    final bool hasQuery = searchController.text.trim().isNotEmpty;
    final String hint = _showsMyBookings
        // Names what the search actually reaches, which is more than the old
        // hint claimed: `bookingMatchesSearch` also matches the player's name
        // and phone on the vendor's list.
        ? 'Search venue, court or booking ID'
        : 'Search court, player or booking ID';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppUtils().getPadding(
            symmetricHorizontal: AppDimens.paddingX16,
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: AppDimens.sizeX44,
                  decoration: BoxDecoration(
                    color: LightColor.cardColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                    border: Border.all(
                      color: hasQuery
                          ? LightColor.secondaryColor.withValues(alpha: 0.45)
                          : LightColor.dividerColor,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: LightColor.shadowColor.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    key: const Key('booking-search-field'),
                    controller: searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.hintTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: AppDimens.sizeX20,
                        color: LightColor.secondaryTextColor,
                      ),
                      suffixIcon: hasQuery
                          ? IconButton(
                              key: const Key('clear-booking-search'),
                              tooltip: StringConstants.clearSearch,
                              onPressed: _clearSearch,
                              icon: Icon(
                                Icons.close_rounded,
                                size: AppDimens.sizeX18,
                                color: LightColor.secondaryTextColor,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              // One button, all three date modes, both tabs. The old pair —
              // an inline day-stepper on the futsal list and a range-only
              // button on My Bookings — could each express one shape of window
              // and nothing else.
              BookingDateFilterButton(
                filter: _activeDateFilter,
                onTap: _openDateFilter,
              ),
            ],
          ),
        ),
        // The applied window, with the stepping its mode allows.
        if (_activeDateFilter.isActive) ...<Widget>[
          const SizedBox(height: AppDimens.paddingX10),
          Padding(
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX16,
            ),
            child: BookingDateFilterStrip(
              filter: _activeDateFilter,
              onStep: _stepActiveDate,
              onEdit: _openDateFilter,
              onClear: _clearActiveDateFilter,
            ),
          ),
        ],
        const SizedBox(height: AppDimens.paddingX16),

        _filterRow(context),
      ],
    );
  }

  /// One page per status, swipeable left/right. Every page is built from the
  /// same state, so a status already fetched is there the moment it is swiped
  /// to — with the rows and the scroll offset it had — and one not fetched yet
  /// shows its own skeleton while [_onStatusPageChanged] triggers its call.
  Widget _statusPager(BookingListKind kind) {
    final bool isMine = kind == BookingListKind.mine;
    final ValueNotifier<BookingStatusFilter> filterVN = _filterVNFor(kind);
    final PageController controller = _pageCtrlFor(kind);

    // A TabBarView disposes the tab it scrolls away from, which detaches this
    // controller. Re-attaching builds a fresh ScrollPosition, and a fresh
    // position starts at `initialPage` — page 0, "All" — while the chip strip
    // still shows the status the user had selected. `onPageChanged` does not
    // fire for that, so the two disagreed for good: the chips read "Pending"
    // over the All page's rows.
    //
    // Only re-attachment is corrected, never a rebuild mid-gesture: with
    // clients attached this is a no-op, so a swipe in progress is left alone.
    if (!controller.hasClients) {
      final int target = _visibleFilterIndex(filterVN.value);
      if (target != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !controller.hasClients) return;
          if ((controller.page ?? 0).round() != target) {
            controller.jumpToPage(target);
          }
        });
      }
    }

    return PageView.builder(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      itemCount: _visibleFilters.length,
      onPageChanged: (int index) => _onStatusPageChanged(kind, index),
      // Each page paints into its own layer, so the one sliding in does not
      // force the one sliding out to repaint with it.
      itemBuilder: (BuildContext context, int index) {
        final BookingStatusFilter filter = _visibleFilters[index];
        // No TickerMode here. It used to be `selected == filter`, which
        // silenced every ticker in the page whenever the pager and the chips
        // disagreed — and the page it silenced was the one on screen. A muted
        // ticker freezes the RefreshIndicator's animations (the spinner stops
        // mid-air and never dismisses or re-arms) and the scroll position's
        // ballistic simulations (the list drags but never flings, which reads
        // as the whole app having seized up). The pager only builds the pages
        // at or beside the viewport, and the dashboard already mutes this
        // whole branch when another tab is showing, so there is nothing left
        // for a per-page gate to save.
        //
        // Semantics is left to the pager's own viewport, which already skips
        // the pages that are off screen. An ExcludeSemantics that flipped with
        // the page made each page detach and reattach to the semantics tree
        // mid-swipe — the parent-data assertion's cause.
        return RepaintBoundary(
          child: BookingStatusPage(
            kind: kind,
            filter: filter,
            searchQuery: isMine
                ? _mySearchController.text
                : _futsalSearchController.text,
            dateOrder: _dateOrder,
            fromDate: isMine
                ? _myDateFilter.fromDate
                : _futsalDateFilter.fromDate,
            toDate: isMine ? _myDateFilter.toDate : _futsalDateFilter.toDate,
          ),
        );
      },
    );
  }

  Widget _filterRow(BuildContext context) {
    return SizedBox(
      height: AppDimens.sizeX32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: AppUtils().getPadding(
          symmetricHorizontal: AppDimens.paddingX20,
        ),
        controller: _chipCtrl,
        itemCount: _visibleFilters.length,
        separatorBuilder: (_, __) {
          return const SizedBox(width: AppDimens.paddingX8);
        },
        itemBuilder: (context, index) {
          final BookingStatusFilter filter = _visibleFilters[index];

          return ValueListenableBuilder<BookingStatusFilter>(
            valueListenable: _activeFilterVN,
            builder: (_, BookingStatusFilter selected, __) => _FilterChipItem(
              label: _filterLabel(filter),
              isSelected: selected == filter,
              onTap: () => _onFilterSelected(filter),
            ),
          );
        },
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color: isActive
                        ? LightColor.primaryTextColor
                        : LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  height: 2,
                  decoration: BoxDecoration(
                    color: isActive
                        ? LightColor.secondaryColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  const _FilterChipItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? LightColor.secondaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimens.radiusX20),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.dividerColor,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: isSelected
                  ? LightColor.inverseTextColor
                  : LightColor.secondaryTextColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: AppDimens.fontBodySubTitle,
            ),
          ),
        ),
      ),
    );
  }
}
