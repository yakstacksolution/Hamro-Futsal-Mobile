import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/features/courts/presentation/pages/courts_list_page_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/messages_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/overall_performance_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/recent_bookings_widget.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/search_bar_widget.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/profile_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  static const DashboardUser _user = DashboardUser(
    id: 'USR-1024',
    name: 'Hamro Futsal',
    email: 'merchant@hamrofutsal.com',
  );

  int _selectedNavIndex = 0;
  int _selectedFilter = 0;
  bool _hasHandledVendorOnboarding = false;

  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE8ECF0);
  static const List<BoxShadow> _cardShadow = <BoxShadow>[
    BoxShadow(
      color: LightColor.shadowColor,
      blurRadius: AppDimens.radiusX18,
      offset: Offset(0, 8),
      spreadRadius: 1,
    ),
  ];

  void _onBottomIconPressed(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _openCourtsPage() {
    context.pushNamed(AppRouterParams.createCourts.name);
  }

  void _openVendorStepper() {
    context.pushNamed(AppRouterParams.vendorStepper.name);
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
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(13),
          color: Theme.of(context).colorScheme.surface,
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
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),

          _tapable(
            onTap: () => context.goNamed(AppRouterParams.login.name),
            borderRadius: BorderRadius.circular(13),
            child: _buildActionIcon(
              Icons.notifications_outlined,
              color: LightColor.secondaryTextColor,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewSection() {
    return ListView(
      key: const ValueKey<String>('overview'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      children: const <Widget>[
        OverallPerformanceWidget(),
        SizedBox(height: 20),
        RecentBookingsWidget(),
      ],
    );
  }

  Widget _buildCurrentTabSection() {
    switch (_selectedNavIndex) {
      case 0:
        // return _overviewSection();
        return FootsallHomePage();
      case 1:
        return CourtsListPage();
      case 2:
        return CourtsListPage();
      case 3:
        return MessagesPage();
      // case 4:
      //   return CourtsListPageWidget();
      case 5:
        return ProfilePage();
      default:
        return _overviewSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      // drawer: AppDrawer(
      //   user: _user,
      //   currentIndex: _selectedNavIndex,
      //   onNavTap: _onBottomIconPressed,
      //   onSignOut: _handleSignOut,
      // ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (BuildContext context, ProfileState state) {
          final bool requiresVendorOnboarding =
              state.profile?.data.requiresVendorOnboarding == true &&
              state.status == ProfileStatus.success;

          if (requiresVendorOnboarding && !_hasHandledVendorOnboarding) {
            _hasHandledVendorOnboarding = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
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
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SingleChildScrollView(
                child: Container(
                  height:
                      MediaQuery.of(context).size.height - AppDimens.sizeX24,
                  padding: const EdgeInsets.only(bottom: 110),
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
                  child: _selectedNavIndex == 0
                      ? _homeAppBarSectionWidget()
                      : _contentSectionWidget(),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: CustomBottomNavigationBar(
                  currentIndex: _selectedNavIndex,
                  onTap: _onBottomIconPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _homeAppBarSectionWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _appBar(),
        // _title(),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            children: [
              // _buildSearchBar(),
              ExpandableFocusSearchBar(),
              const SizedBox(height: 14),
              _buildFilterRow(),
              // const SizedBox(height: 14),
              // _buildOnboardingTestEntry(),
            ],
          ),
        ),
        Expanded(child: _buildCurrentTabSection()),
      ],
    );
  }

  Widget _contentSectionWidget() {
    return Column(
      children: <Widget>[Expanded(child: _buildCurrentTabSection())],
    );
  }

  Widget _buildFilterRow() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        itemBuilder: (context, i) {
          final selected = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [Color(0xFF0D9E5C), Color(0xFF0B7A47)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? Colors.transparent : _border,
                  width: 0.6,
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: selected ? Colors.white : _textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnboardingTestEntry() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openVendorStepper,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF173A5E), Color(0xFF2D86E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF173A5E).withValues(alpha: 0.14),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.rocket_launch_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Test Onboarding',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Open the latest vendor onboarding flow for futsal and court setup.',
                      style: TextStyle(
                        color: Color(0xE8FFFFFF),
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // final List<String> _filters = [
  //   'All',
  //   'Nearby',
  //   'Indoor',
  //   'Outdoor',
  //   'Open Now',
  //   'Top Rated',
  // ];
  final List<String> _filters = [
    '🔥 All',
    '📍 Nearby',
    '🏠 Indoor',
    '🌿 Outdoor',
    '🟢 Open Now',
    '⭐ Top Rated',
  ];
}
