import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/helper/venue_distance_helper.dart';
import 'package:hamro_footsall/core/socket/reverb_connection.dart';
import 'package:hamro_footsall/features/bookings/presentation/pages/bookings_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/message/presentation/pages/messages_page.dart';
import 'package:hamro_footsall/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:hamro_footsall/features/notifications/domain/repository/notification_repository.dart';
import 'package:hamro_footsall/features/wishlist/presentation/pages/wishlist_page.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/category_filter_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/search_bar_widget.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/profile_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  static final ValueNotifier<int> selectedNavIndex = ValueNotifier<int>(0);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<int> _selectedNavIndexNotifier =
      DashboardScreen.selectedNavIndex;
  final ValueNotifier<VenueFilter> _venueFilterNotifier =
      ValueNotifier<VenueFilter>(VenueFilter.empty);
  bool _hasHandledVendorOnboarding = false;
  bool _hasUnreadNotifications = false;
  int _notificationRefreshGeneration = 0;

  @override
  void initState() {
    super.initState();
    ReverbConnection.instance.connect();
    VenueDistanceHelper.instance.ensurePosition();
    _refreshNotificationBadge();
  }

  Future<void> _refreshNotificationBadge() async {
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

  static const List<BoxShadow> _cardShadow = <BoxShadow>[
    BoxShadow(
      color: LightColor.shadowColor,
      blurRadius: AppDimens.radiusX18,
      offset: Offset(0, 8),
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
    final position = VenueDistanceHelper.instance.position.value;
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

  Widget _buildActionIcon(
    IconData icon, {
    Color color = LightColor.secondaryTextColor,
    VoidCallback? onTap,
  }) {
    return _tapable(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          color: LightColor.whiteColor,
          boxShadow: _cardShadow,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _appBar() {
    final AppUtils appUtils = AppUtils();
    final textTheme = FutsalTheme.getTextTheme(context);
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String firstName =
        profileState.profile?.data.fullName.trim().isNotEmpty == true
        ? profileState.profile!.data.fullName.split(' ').first
        : 'there';

    return Padding(
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        symmetricVertical: AppDimens.paddingX10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "${appUtils.greeting()}, $firstName 👋",
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: AppDimens.fontBodyTextLarge,
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),

          Stack(
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _venueFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              context.pushNamed(
                AppRouterParams.vendorStepper.name,
                queryParameters: {
                  'futsalId': state.profile!.data.futsalId.toString(),
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
          bottom: false,
          child: AnimatedBuilder(
            animation: Listenable.merge(<Listenable>[
              _selectedNavIndexNotifier,
              _venueFilterNotifier,
            ]),
            builder: (BuildContext context, Widget? child) {
              final int selectedNavIndex = _selectedNavIndexNotifier.value;

              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  SingleChildScrollView(
                    child: Container(
                      height: math.max(
                        0,
                        MediaQuery.of(context).size.height - AppDimens.sizeX24,
                      ),
                      padding: AppUtils().getPadding(
                        bottom: AppDimens.paddingX10,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            LightColor.background,
                            LightColor.cardColor,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 280),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            transitionBuilder:
                                (Widget child, Animation<double> anim) {
                                  return FadeTransition(
                                    opacity: anim,
                                    child: SizeTransition(
                                      sizeFactor: anim,
                                      alignment: Alignment.topCenter,
                                      child: child,
                                    ),
                                  );
                                },
                            child: selectedNavIndex == 0
                                ? _homeHeader()
                                : const SizedBox.shrink(
                                    key: ValueKey<String>('no-home-header'),
                                  ),
                          ),
                          Expanded(
                            child: IndexedStack(
                              index: selectedNavIndex,
                              sizing: StackFit.expand,
                              children: <Widget>[
                                FootsallHomePage(
                                  filter: _venueFilterNotifier.value,
                                ),
                                const BookingsPage(),
                                MessagesPage(),
                                const WishlistPage(),
                                ProfilePage(),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _homeHeader() {
    return Column(
      key: const ValueKey<String>('home-header'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _appBar(),
        Padding(
          padding: AppUtils().getPadding(
            left: AppDimens.paddingX20,
            right: AppDimens.paddingX20,
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
            ],
          ),
        ),
      ],
    );
  }
}
