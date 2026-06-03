import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/helper/venue_distance_helper.dart';
import 'package:hamro_footsall/features/bookings/presentation/pages/bookings_page.dart';
import 'package:hamro_footsall/features/courts/presentation/pages/venue_courts_list_page_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/messages_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/category_filter_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/search_bar_widget.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/features/public/presentation/pages/venue_filter_page.dart';
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
  static const DashboardUser _user = DashboardUser(
    id: 'USR-1024',
    name: 'Hamro Futsal',
    email: 'merchant@hamrofutsal.com',
  );

  bool _hasHandledVendorOnboarding = false;

  @override
  void initState() {
    super.initState();
    VenueDistanceHelper.instance.position.addListener(_syncVenueLocation);
    VenueDistanceHelper.instance.ensurePosition();
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
    final VenueFilter? result = await Navigator.of(context).push<VenueFilter>(
      MaterialPageRoute<VenueFilter>(
        builder: (_) =>
            VenueFilterPage(initialFilter: _venueFilterNotifier.value),
      ),
    );
    if (result != null) {
      _venueFilterNotifier.value = _withCurrentLocation(result);
    }
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

  void _syncVenueLocation() {
    _venueFilterNotifier.value = _withCurrentLocation(
      _venueFilterNotifier.value,
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
        : _user.name.split(' ').first;

    return Padding(
      padding: appUtils.getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
        symmetricVertical: AppDimens.paddingX10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Good morning, $firstName 👋",
            style: textTheme.bodyTextLarge?.copyWith(
              fontSize: AppDimens.fontBodyTextLarge,
              fontWeight: FontWeight.w600,
              color: LightColor.primaryTextColor,
            ),
          ),

          _tapable(
            onTap: () => context.goNamed(AppRouterParams.login.name),
            borderRadius: BorderRadius.circular(13),
            child: _buildActionIcon(
              Icons.notifications_outlined,
              color: LightColor.secondaryLight,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTabSection(int selectedNavIndex) {
    switch (selectedNavIndex) {
      case 0:
        return FootsallHomePage(filter: _venueFilterNotifier.value);
      case 1:
        return VenueCourtsListPage();
      case 2:
        return const BookingsPage();
      case 3:
        return MessagesPage();

      default:
        return ProfilePage();
    }
  }

  @override
  void dispose() {
    VenueDistanceHelper.instance.position.removeListener(_syncVenueLocation);
    _venueFilterNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                      child: selectedNavIndex == 0
                          ? _homeAppBarSectionWidget(selectedNavIndex)
                          : _contentSectionWidget(selectedNavIndex),
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

  Widget _homeAppBarSectionWidget(int selectedNavIndex) {
    return Column(
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
        Expanded(child: _buildCurrentTabSection(selectedNavIndex)),
      ],
    );
  }

  Widget _contentSectionWidget(int selectedNavIndex) {
    return Column(
      children: <Widget>[
        Expanded(child: _buildCurrentTabSection(selectedNavIndex)),
      ],
    );
  }
}
