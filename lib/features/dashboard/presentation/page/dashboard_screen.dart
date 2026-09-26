import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/socket/reverb_connection.dart';
import 'package:hamro_futsal/features/bookings/presentation/pages/bookings_page.dart';
import 'package:hamro_futsal/features/dashboard/presentation/page/futsal_home_page.dart';
import 'package:hamro_futsal/features/message/presentation/pages/messages_page.dart';
import 'package:hamro_futsal/features/mobile_banner/presentation/widgets/mobile_banner_dialog.dart';
import 'package:hamro_futsal/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:hamro_futsal/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_futsal/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/dashboard_side_nav.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/category_filter_widget.dart';
import 'package:hamro_futsal/features/public/data/repositories/public_repository_impl.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_category_filter_use_case.dart';
import 'package:hamro_futsal/features/public/presentation/bloc/category_filter/category_filter_bloc.dart';
import 'package:hamro_futsal/features/dashboard/presentation/widgets/search_bar_widget.dart';
import 'package:hamro_futsal/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_futsal/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_futsal/features/profile/presentation/pages/profile_page.dart';
import 'package:hamro_futsal/core/helper/device_location_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static final ValueNotifier<int> selectedNavIndex = ValueNotifier<int>(0);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<int> _selectedNavIndexNotifier =
      DashboardScreen.selectedNavIndex;
  final ValueNotifier<VenueFilter> _venueFilterNotifier =
      ValueNotifier<VenueFilter>(VenueFilter.empty);
  late final CategoryFilterBloc _categoryFilterBloc;
  bool _hasHandledVendorOnboarding = false;
  bool _hasUnreadNotifications = false;
  int _notificationRefreshGeneration = 0;
  late final Set<int> _visitedTabIndexes;

  /// How much of the home header is on screen: 1 fully shown, 0 scrolled
  /// away. It tracks the feed's scroll 1:1 (LinkedIn-style) and only animates
  /// for the snap once a scroll settles.
  late final AnimationController _headerController;
  late final Animation<Offset> _headerOffset;

  /// Measured height of the home header. The header floats over the feed
  /// rather than sitting above it, so the feed reserves this much space at the
  /// top of its scroll content.
  final ValueNotifier<double> _homeHeaderHeight = ValueNotifier<double>(0);

  @override
  void initState() {
    super.initState();
    _visitedTabIndexes = <int>{_selectedNavIndexNotifier.value};
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1,
    );
    // Linear on purpose: the header must move exactly as far as the finger.
    _headerOffset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(_headerController);
    _categoryFilterBloc = CategoryFilterBloc(
      GetCategoryFilterUseCase(PublicRepositoryImpl()),
    );
    if (_selectedNavIndexNotifier.value == 0) {
      _categoryFilterBloc.add(const FetchCategoryFilterEvent());
    }
    // The router keeps signed-out users off this screen, but a session can also
    // end while it is alive; neither the socket nor the badge has anything to
    // fetch without one.
    if (AppSettings().hasSession) {
      ReverbConnection.instance.connect();
      _refreshNotificationBadge();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) MobileBannerPresenter.showIfAny(context);
      });
    }
    DeviceLocationHelper.instance.ensurePosition();
    _selectedNavIndexNotifier.addListener(_onNavIndexChanged);
  }

  void _onNavIndexChanged() {
    final int selectedIndex = _selectedNavIndexNotifier.value;
    _visitedTabIndexes.add(selectedIndex);
    // Coming back to home always shows the header, whatever it was left at.
    _headerController.value = 1;

    if (selectedIndex == 0) {
      _fetchCategoryFiltersIfNeeded();
      return;
    }

    final VenueFilter filter = _venueFilterNotifier.value;
    if (filter.search == null) return;
    _venueFilterNotifier.value = filter.copyWith(clearSearch: true);
  }

  bool _onHomeScroll(ScrollNotification notification) {
    // Only the feed itself: horizontal carousels and nested scrollables must
    // not move the header.
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final double headerHeight = _homeHeaderHeight.value;
    if (headerHeight <= 0) return false;

    final ScrollMetrics metrics = notification.metrics;
    // The header may never be hidden by more than the feed has scrolled:
    // otherwise the space the feed reserves for it would show as a blank band.
    final double maxHidden = (metrics.pixels - metrics.minScrollExtent).clamp(
      0.0,
      headerHeight,
    );
    final double hidden = (1 - _headerController.value) * headerHeight;

    if (notification is ScrollUpdateNotification) {
      // The bounce back after overscrolling past the end reads as an upward
      // scroll; ignore it so reaching the bottom does not pull the header in.
      if (metrics.pixels > metrics.maxScrollExtent) return false;
      final double delta = notification.scrollDelta ?? 0;
      if (delta == 0) return false;
      final double next = (hidden + delta).clamp(0.0, maxHidden);
      if (next != hidden) {
        // Assigning the value also stops any snap still running.
        _headerController.value = 1 - next / headerHeight;
      }
    } else if (notification is ScrollEndNotification) {
      // Never leave it half-shown: settle to whichever end is nearer, and
      // shown whenever there is not enough scroll to hide it fully.
      if (hidden == 0 || hidden == headerHeight) return false;
      final bool hide = hidden > headerHeight / 2 && maxHidden >= headerHeight;
      _headerController.animateTo(hide ? 0 : 1, curve: Curves.easeOutCubic);
    }
    return false;
  }

  void _fetchCategoryFiltersIfNeeded() {
    if (_categoryFilterBloc.state.status == CategoryFilterStatus.loading ||
        _categoryFilterBloc.state.status == CategoryFilterStatus.success) {
      return;
    }
    _categoryFilterBloc.add(const FetchCategoryFilterEvent());
  }

  Future<void> _refreshNotificationBadge() async {
    if (!AppSettings().hasSession) return;
    final int generation = ++_notificationRefreshGeneration;
    final result = await NotificationRepositoryImpl().getNotifications(
      filter: NotificationFilter.all,
      perPage: 1,
    );
    if (!mounted || generation != _notificationRefreshGeneration) return;

    result.fold(
      (_) {},
      (page) => setState(() => _hasUnreadNotifications = page.unreadCount > 0),
    );
  }

  Future<void> _openNotifications() async {
    await context.pushNamed(AppRouterParams.notifications.name);
    if (!mounted) return;
    await _refreshNotificationBadge();
  }

  // a cached shadow keeps the brightness it was first built under and never
  // follows a theme toggle.
  static List<BoxShadow> get _cardShadow => <BoxShadow>[
    BoxShadow(
      color: LightColor.shadowColor,
      blurRadius: AppDimens.radiusX18,
      offset: const Offset(0, 8),
      spreadRadius: 1,
    ),
  ];

  void _onBottomIconPressed(int index) {
    _selectedNavIndexNotifier.value = index;
  }

  Future<void> _openVenueFilter() async {
    final VenueFilter? result = await context.pushNamed<VenueFilter>(
      AppRouterParams.venueFilter.name,
      extra: _venueFilterNotifier.value,
    );
    if (result != null) {
      _venueFilterNotifier.value = _withCurrentLocation(
        result.copyWith(search: _venueFilterNotifier.value.search),
      );
    }
  }

  void _onSearchSubmitted(String term) {
    final String trimmed = term.trim();
    _venueFilterNotifier.value = _withCurrentLocation(
      _venueFilterNotifier.value.copyWith(
        search: trimmed.isEmpty ? null : trimmed,
        clearSearch: trimmed.isEmpty,
      ),
    );
  }

  void _onCategoryFilterChanged(Set<int> ids) {
    _venueFilterNotifier.value = _withCurrentLocation(
      _venueFilterNotifier.value.copyWith(categoryFilterIds: ids),
    );
  }

  VenueFilter _withCurrentLocation(VenueFilter filter) {
    final position = DeviceLocationHelper.instance.position.value;
    if (position == null) {
      return filter.copyWith(clearLocation: true, clearRadius: true);
    }
    return filter.copyWith(
      latitude: position.latitude,
      longitude: position.longitude,
      radius: filter.radius ?? 10,
    );
  }

  Widget _tapable({
    required Widget child,
    required VoidCallback onTap,
    required BorderRadius borderRadius,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(borderRadius: borderRadius, onTap: onTap, child: child),
    );
  }

  Widget _buildActionIcon(IconData icon, {Color? color, VoidCallback? onTap}) {
    return _tapable(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingX10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          color: LightColor.whiteColor,
          boxShadow: _cardShadow,
        ),
        child: Icon(icon, color: color ?? context.appColors.secondaryText),
      ),
    );
  }

  Widget _appBar() {
    final AppUtils appUtils = AppUtils();
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String firstName =
        profileState.profile?.data.fullName.trim().isNotEmpty == true
        ? profileState.profile!.data.fullName.split(' ').first
        : 'there';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.responsive<double>(
          mobile: AppDimens.paddingX20,
          tablet: AppDimens.paddingX32,
        ),
        vertical: AppDimens.paddingX10,
      ),
      child: HomeGreeting(
        text: "${appUtils.greeting()}, $firstName 👋",
        trailing: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            _buildActionIcon(
              Icons.notifications_outlined,
              color: LightColor.secondaryColor,
              onTap: _openNotifications,
            ),
            if (_hasUnreadNotifications)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: AppDimens.sizeX10,
                  height: AppDimens.sizeX10,
                  decoration: BoxDecoration(
                    color: LightColor.redColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: LightColor.whiteColor,
                      width: AppDimens.sizeX2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // The nav-index notifier is static and shared, so only the listener goes.
    _selectedNavIndexNotifier.removeListener(_onNavIndexChanged);
    _headerController.dispose();
    _homeHeaderHeight.dispose();
    _categoryFilterBloc.close();
    _venueFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provided here, above both the header's category strip and the home
    // tab's venue list, so the list's "Retry" can refetch the strip too.
    return BlocProvider<CategoryFilterBloc>.value(
      value: _categoryFilterBloc,
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: LightColor.background,
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (BuildContext context, ProfileState state) {
          final bool requiresVendorOnboarding =
              state.profile?.data.requiresVendorOnboarding == true &&
              state.status == ProfileStatus.success;

          if (requiresVendorOnboarding && !_hasHandledVendorOnboarding) {
            _hasHandledVendorOnboarding = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              final bool isDashboardOnTop =
                  ModalRoute.of(context)?.isCurrent ?? false;
              if (!isDashboardOnTop) return;
              final String? futsalSlug = state.profile!.data.futsalSlug;
              context.pushNamed(
                AppRouterParams.vendorStepper.name,
                queryParameters: {
                  'futsalId': state.profile!.data.futsalId.toString(),
                  if (futsalSlug != null && futsalSlug.isNotEmpty)
                    'futsalSlug': futsalSlug,
                  'mainStep': state.profile!.data.mainStep.toString(),
                  'subStep': state.profile!.data.subStep.toString(),
                },
              );
            });
          }

          if (!requiresVendorOnboarding) {
            _hasHandledVendorOnboarding = false;
          }
        },
        child: SafeArea(
          bottom: context.isTabletOrWider,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[
              _selectedNavIndexNotifier,
              _venueFilterNotifier,
            ]),
            builder: (BuildContext context, Widget? child) {
              final int selectedNavIndex = _selectedNavIndexNotifier.value;

              if (context.isTabletOrWider) {
                return Row(
                  children: <Widget>[
                    DashboardSideNav(
                      currentIndex: selectedNavIndex,
                      extended: context.isDesktop,
                      onTap: _onBottomIconPressed,
                    ),
                    Expanded(
                      child: DecoratedBox(
                        decoration: _shellGradient,

                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: AppDimens.dashboardContentMaxWidth,
                            ),
                            child: _buildContent(selectedNavIndex),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              // Phone: unchanged.
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  DecoratedBox(
                    decoration: _shellGradient,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppDimens.paddingX10,
                      ),
                      child: _buildContent(selectedNavIndex),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomBottomNavigationBar(
                      currentIndex: selectedNavIndex,
                      onTap: _onBottomIconPressed,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static BoxDecoration get _shellGradient => BoxDecoration(
    gradient: LinearGradient(
      colors: <Color>[LightColor.background, LightColor.cardColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  Widget _buildContent(int selectedNavIndex) {
    // The header floats over the feed and only slides — a paint-time
    // transform. Collapsing it inside a Column instead would resize the feed's
    // viewport every frame, relaying out the list mid-scroll.
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: IndexedStack(
            index: selectedNavIndex,
            sizing: StackFit.expand,
            children: <Widget>[
              _stackChild(
                index: 0,
                selectedIndex: selectedNavIndex,
                childBuilder: () => NotificationListener<ScrollNotification>(
                  onNotification: _onHomeScroll,
                  child: ValueListenableBuilder<double>(
                    valueListenable: _homeHeaderHeight,
                    builder: (BuildContext context, double height, _) =>
                        FutsalHomePage(
                          filter: _venueFilterNotifier.value,
                          topInset: height,
                        ),
                  ),
                ),
              ),
              _stackChild(
                index: 1,
                selectedIndex: selectedNavIndex,
                childBuilder: () => const BookingsPage(),
              ),
              _stackChild(
                index: 2,
                selectedIndex: selectedNavIndex,
                childBuilder: () => MessagesPage(),
              ),
              _stackChild(
                index: 3,
                selectedIndex: selectedNavIndex,
                childBuilder: () => const WishlistPage(),
              ),
              _stackChild(
                index: 4,
                selectedIndex: selectedNavIndex,
                childBuilder: () => ProfilePage(),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: selectedNavIndex == 0
                ? SlideTransition(
                    key: const ValueKey<String>('home-header'),
                    position: _headerOffset,
                    child: RepaintBoundary(
                      child: _SizeReporter(
                        onHeightChanged: (double height) =>
                            _homeHeaderHeight.value = height,
                        // Opaque, since the cards now scroll underneath it.
                        child: ColoredBox(
                          color: LightColor.background,
                          child: _homeHeader(),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(
                    key: ValueKey<String>('no-home-header'),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _stackChild({
    required int index,
    required int selectedIndex,
    required Widget Function() childBuilder,
  }) {
    final bool active = index == selectedIndex;
    final bool visited = _visitedTabIndexes.contains(index);

    return TickerMode(
      enabled: active,
      child: visited ? childBuilder() : const SizedBox.shrink(),
    );
  }

  Widget _homeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _appBar(),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.responsive<double>(
              mobile: AppDimens.paddingX20,
              tablet: AppDimens.paddingX32,
            ),
          ),
          child: Column(
            children: [
              ExpandableFocusSearchBar(
                onSubmitted: _onSearchSubmitted,
                onFilterTap: _openVenueFilter,
                filterCount: _venueFilterNotifier.value.activeCount,
              ),
              const SizedBox(height: AppDimens.sizeX22),
              CategoryFilterWidget(
                selectedFilterIds: _venueFilterNotifier.value.categoryFilterIds,
                onSelectionChanged: _onCategoryFilterChanged,
              ),
              // Matches the gap above the chips. It is part of the opaque
              // header, so the spacing holds while cards scroll underneath.
              const SizedBox(height: AppDimens.sizeX22),
            ],
          ),
        ),
      ],
    );
  }
}

class HomeGreeting extends StatelessWidget {
  const HomeGreeting({super.key, required this.text, required this.trailing});

  final String text;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              fontSize: AppDimens.fontBodyTextLarge,
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),
        ),
        const SizedBox(width: AppDimens.paddingX8),
        trailing,
      ],
    );
  }
}

/// Reports its child's height after layout, whenever it changes.
class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onHeightChanged, super.child});

  final ValueChanged<double> onHeightChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeReporter(onHeightChanged);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderSizeReporter renderObject,
  ) {
    renderObject.onHeightChanged = onHeightChanged;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onHeightChanged);

  ValueChanged<double> onHeightChanged;
  double? _lastHeight;

  @override
  void performLayout() {
    super.performLayout();
    final double height = size.height;
    if (height == _lastHeight) return;
    _lastHeight = height;
    // Listeners rebuild widgets, which is not allowed during layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) onHeightChanged(height);
    });
  }
}
