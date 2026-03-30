import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/footsall_home_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/messages_page.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/app_drawer.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/theme/theme.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
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
    name: 'Hamro Footsall',
    email: 'merchant@hamrofootsall.com',
  );

  int _selectedNavIndex = 0;
  int _selectedFilter = 0;
  bool _hasHandledVendorOnboarding = false;

  static const _textSecondary = Color(0xFF6B7280);
  static const _border = Color(0xFFE8ECF0);

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

  Future<void> _handleSignOut() async {
    final response = await AuthenticationRepositoryImpl().logout();
    if (!mounted) return;

    response?.fold(
      (failure) =>
          AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage),
      (_) => context.goNamed(AppRouterParams.login.name),
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
    Color color = LightColor.iconColor,
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
          boxShadow: AppTheme.shadow,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }

  Widget _appBar() {
    final ProfileState profileState = context.watch<ProfileBloc>().state;
    final String firstName =
        profileState.profile?.data.fullName.trim().isNotEmpty == true
        ? profileState.profile!.data.fullName.split(' ').first
        : _user.name.split(' ').first;

    return Padding(
      padding: AppTheme.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Good morning, $firstName 👋",
            style: AppTheme.titleStyle.copyWith(fontSize: 16),
          ),

          _tapable(
            onTap: () => context.goNamed(AppRouterParams.login.name),
            borderRadius: BorderRadius.circular(13),
            child: _buildActionIcon(
              Icons.notifications_outlined,
              color: LightColor.darkgrey,
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

  Widget _shopsSection() {
    return ListView(
      key: const ValueKey<String>('shops'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[
                LightColor.primaryGreen,
                LightColor.secondaryGreen,
                LightColor.accentGreen,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: LightColor.primaryGreen.withAlpha(60),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Ready to launch a new shop?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Create a verified shop profile with registration and branding details.',
                style: TextStyle(color: Color(0xE8FFFFFF), fontSize: 12.5),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _openCourtsPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LightColor.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_business_rounded),
                label: const Text('Create Shop'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const _DashboardTile(
          title: 'Bhatbhateni Outlet',
          subtitle: 'Active · Kathmandu, Nepal',
          icon: Icons.storefront_outlined,
        ),
        const SizedBox(height: 12),
        const _DashboardTile(
          title: 'Hamro Mart',
          subtitle: 'Pending verification · Lalitpur, Nepal',
          icon: Icons.domain_verification_outlined,
        ),
      ],
    );
  }

  Widget _productsSection() {
    return ListView(
      key: const ValueKey<String>('products'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: const <Widget>[
        _DashboardTile(
          title: 'Tomato x2',
          subtitle: 'NPR 120',
          icon: Icons.shopping_bag_outlined,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Milk x1',
          subtitle: 'NPR 90',
          icon: Icons.shopping_bag_outlined,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Rice x1',
          subtitle: 'NPR 850',
          icon: Icons.shopping_bag_outlined,
        ),
      ],
    );
  }

  Widget _customersSection() {
    return const MessagesPage();
  }

  Widget _analyticsSection() {
    return ListView(
      key: const ValueKey<String>('analytics'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: const <Widget>[
        _DashboardTile(
          title: 'Revenue Trend',
          subtitle: 'NPR 1,20,000 this month',
          icon: Icons.trending_up_rounded,
        ),
        SizedBox(height: 12),
        _DashboardTile(
          title: 'Conversion Rate',
          subtitle: '3.8% from shop visits',
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }

  Widget _buildCurrentTabSection() {
    switch (_selectedNavIndex) {
      case 0:
        // return _overviewSection();
        return FootsallHomePage();
      case 1:
        return _shopsSection();
      case 2:
        return _productsSection();
      case 3:
        return _customersSection();
      case 4:
        return _analyticsSection();
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
      drawer: AppDrawer(
        user: _user,
        currentIndex: _selectedNavIndex,
        onNavTap: _onBottomIconPressed,
        onSignOut: _handleSignOut,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (BuildContext context, ProfileState state) {
          final bool requiresVendorOnboarding =
              state.profile?.data.requiresVendorOnboarding == true &&
              state.status == ProfileStatus.success;

          if (requiresVendorOnboarding && !_hasHandledVendorOnboarding) {
            _hasHandledVendorOnboarding = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.pushNamed(AppRouterParams.vendorStepper.name);
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
                  height: AppTheme.fullHeight(context) - 24,
                  padding: const EdgeInsets.only(bottom: 110),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        LightColor.background,
                        LightColor.surface,
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
              const SizedBox(height: 14),
              _buildOnboardingTestEntry(),
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

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: LightColor.orange.withAlpha(30), //Color(0xfffeece2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: LightColor.orange),
        ),
        title: Text(
          title,
          style: AppTheme.titleStyle.copyWith(
            fontWeight: FontWeight.w700,
            color: LightColor.titleTextColor,
          ),
        ),
        subtitle: Text(subtitle, style: AppTheme.subTitleStyle),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: LightColor.darkgrey,
        ),
      ),
    );
  }
}
