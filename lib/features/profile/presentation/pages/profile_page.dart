import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/overview_screen.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/opponent_request_page.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/about_app_page.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  static const List<_ProfileItem> _items = <_ProfileItem>[
    _ProfileItem(title: 'Settings', icon: Icons.settings_outlined),
    _ProfileItem(title: 'Opponent Request', icon: Icons.gamepad_outlined),
    _ProfileItem(title: 'Overview', icon: Icons.bar_chart_rounded),

    _ProfileItem(
      title: 'Transaction History',
      icon: Icons.receipt_long_outlined,
    ),
    _ProfileItem(title: 'FAQ', icon: Icons.help_outline_rounded),
    _ProfileItem(title: 'About App', icon: Icons.info_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: AppDimens.sizeX20,
        backgroundColor: LightColor.transparentColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: LightColor.transparentColor,
      ),
      body: Padding(
        padding: AppUtils().getPadding(bottom: AppDimens.paddingX50),
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (ProfileState previous, ProfileState current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (BuildContext context, ProfileState state) {
            if (state.errorMessage != null) {
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                state.errorMessage!,
              );
            }
          },
          builder: (BuildContext context, ProfileState state) {
            final ProfileModel? profile = state.profile;
            final bool isProfileLoading =
                state.status == ProfileStatus.loading && profile == null;

            return Padding(
              padding: AppUtils().getPadding(
                top: AppDimens.paddingX6,
                left: AppDimens.paddingX20,
                right: AppDimens.paddingX20,
              ),
              child: Column(
                children: <Widget>[
                  _buildProfileCard(
                    profile: profile,
                    isLoading: isProfileLoading,
                  ),
                  const SizedBox(height: AppDimens.sizeX18),
                  Expanded(
                    child: ListView(
                      padding: AppUtils().getPadding(
                        bottom: AppDimens.paddingX28,
                      ),
                      children: <Widget>[
                        _buildSectionLabel('General'),
                        const SizedBox(height: AppDimens.sizeX8),
                        Container(
                          decoration: _cardDecoration(),
                          child: Column(
                            children: List<Widget>.generate(_items.length, (
                              int index,
                            ) {
                              final bool isLast = index == _items.length - 1;
                              return _ProfileTile(
                                item: _items[index],
                                isLast: isLast,
                                onTap: () {
                                  switch (index) {
                                    case 0:
                                      break;
                                    case 1:
                                      // Handle settings tap
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) =>
                                              OpponentRequestScreen(),
                                        ),
                                      );
                                      break;
                                    case 2:
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => OverviewScreen(),
                                        ),
                                      );
                                      // OverviewScreen
                                      // Handle notifications tap
                                      break;
                                    case 3:
                                      // Handle transaction history tap
                                      break;
                                    case 4:
                                      // Handle FAQ tap
                                      break;
                                    case 5:
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => const AboutAppPage(),
                                        ),
                                      );
                                      break;
                                    default:
                                      break;
                                  }
                                },
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _buildSectionLabel('Account'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: _cardDecoration(),
                          child: _LogoutTile(
                            isLoading: _isLoggingOut,
                            onTap: _isLoggingOut ? null : _handleLogout,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required ProfileModel? profile,
    required bool isLoading,
  }) {
    final UserData? user = profile?.data;
    final String fullName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName
        : 'Guest User';
    final String email = user?.email.trim().isNotEmpty == true
        ? user!.email
        : 'No email available';
    final String role = user?.role.trim().isNotEmpty == true
        ? user!.role
        : 'Active member';
    final String? profilePhoto = user?.profilePhoto;

    return InkWell(
      onTap: () {
        if (profile != null) {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProfileDetailsPage(user: profile.data),
            ),
          );
        }
      },
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          border: Border.all(color: LightColor.secondaryLightMedium),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: AppDimens.sizeX68,
              height: AppDimens.sizeX68,
              padding: AppUtils().getPadding(all: AppDimens.paddingX2),

              child: ClipOval(
                child: profilePhoto != null && profilePhoto.trim().isNotEmpty
                    ? CustomImageView(
                        url: profilePhoto,
                        width: AppDimens.sizeX78,
                        height: AppDimens.sizeX78,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: AppDimens.sizeX78,
                        height: AppDimens.sizeX78,
                        color: LightColor.secondaryColor,
                        child: const Icon(
                          Icons.person_rounded,
                          color: LightColor.whiteColor,
                          size: AppDimens.sizeX30,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isLoading ? 'Loading profile...' : fullName,
                    style: const TextStyle(
                      color: LightColor.primaryTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,

                    style: FutsalTheme.getTextTheme(context).bodyTextSmall
                        ?.copyWith(
                          color: LightColor.secondaryTextColor.withValues(
                            alpha: 0.92,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: AppDimens.paddingX4),
                  Container(
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.paddingX12,
                      vertical: AppDimens.paddingX2,
                    ),
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    ),
                    child: Text(
                      role,
                      style: FutsalTheme.getTextTheme(context).bodySubTitle
                          ?.copyWith(
                            color: LightColor.whiteColor,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
        color: LightColor.secondaryTextColor.withValues(alpha: 0.86),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: LightColor.cardColor,
      // borderRadius: BorderRadius.circular(10),
      borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      border: Border.all(color: LightColor.borderColor.withValues(alpha: 0.15)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: LightColor.shadowColor.withValues(alpha: 0.04),
          blurRadius: AppDimens.radiusX12,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    setState(() {
      _isLoggingOut = true;
    });

    final response = await AuthenticationRepositoryImpl().logout();
    if (!mounted) return;

    setState(() {
      _isLoggingOut = false;
    });

    response?.fold(
      (failure) =>
          AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage),
      (_) {
        AppUtils().showSnackBar(context, MsgType.success, 'Logout successful');
        context.goNamed(AppRouterParams.login.name);
      },
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.item,
    required this.isLast,
    required this.onTap,
  });

  final _ProfileItem item;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          onTap: onTap,

          contentPadding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX2,
          ),
          minTileHeight: AppDimens.sizeX62,
          leading: Container(
            width: AppDimens.sizeX30,
            height: AppDimens.sizeX30,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX6),
            ),
            child: Icon(
              item.icon,
              color: LightColor.whiteColor,
              size: AppDimens.sizeX18,
            ),
          ),
          title: Text(
            item.title,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: LightColor.secondaryColor.withValues(alpha: 0.5),
          ),
        ),
        if (!isLast)
          Divider(
            height: 0.5,
            indent: AppDimens.sizeX40,
            endIndent: AppDimens.sizeX10,
            color: LightColor.dividerColor,
          ),
      ],
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.isLoading, required this.onTap});

  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX2,
      ),
      minTileHeight: AppDimens.sizeX62,
      leading: Container(
        width: AppDimens.sizeX38,
        height: AppDimens.sizeX38,
        decoration: BoxDecoration(
          color: LightColor.redLightColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        ),
        child: isLoading
            ? Padding(
                padding: AppUtils().getPadding(all: AppDimens.paddingX10),
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    LightColor.redColor,
                  ),
                ),
              )
            : const Icon(
                Icons.logout_rounded,
                color: LightColor.redColor,
                size: AppDimens.sizeX20,
              ),
      ),
      title: Text(
        isLoading ? 'Logging out...' : 'Logout',
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          color: LightColor.redColor,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: LightColor.hintTextColor.withValues(alpha: 0.9),
      ),
    );
  }
}

class _ProfileItem {
  const _ProfileItem({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
