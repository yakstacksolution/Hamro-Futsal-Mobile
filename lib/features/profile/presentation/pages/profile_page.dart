import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
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
    _ProfileItem(title: 'My Profile', icon: Icons.person_outline_rounded),
    _ProfileItem(title: 'Settings', icon: Icons.settings_outlined),
    _ProfileItem(
      title: 'Notifications',
      icon: Icons.notifications_none_rounded,
    ),
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
      backgroundColor: LightColor.background,
      appBar: AppBar(
        toolbarHeight: 20,
        backgroundColor: LightColor.transparentColor,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: LightColor.transparentColor,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
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
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: Column(
              children: <Widget>[
                _buildProfileCard(
                  profile: profile,
                  isLoading: isProfileLoading,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 28),
                    children: <Widget>[
                      _buildSectionLabel('General'),
                      const SizedBox(height: 8),
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ProfileDetailsPage(
                                          user: profile?.data,
                                        ),
                                      ),
                                    );
                                    break;
                                  case 1:
                                    // Handle settings tap
                                    break;
                                  case 2:
                                    // Handle notifications tap
                                    break;
                                  case 3:
                                    // Handle transaction history tap
                                    break;
                                  case 4:
                                    // Handle FAQ tap
                                    break;
                                  case 5:
                                    // Handle about app tap
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[
            LightColor.secondaryLight,
            LightColor.secondaryLight.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: LightColor.secondaryLightMedium),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LightColor.whiteColor,
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: LightColor.secondaryColor.withValues(alpha: 0.16),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipOval(
              child: profilePhoto != null && profilePhoto.trim().isNotEmpty
                  ? CustomImageView(
                      url: profilePhoto,
                      width: 78,
                      height: 78,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 78,
                      height: 78,
                      color: LightColor.secondaryLight,
                      child: const Icon(
                        Icons.person_rounded,
                        color: LightColor.secondaryDark,
                        size: 30,
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
                  style: TextStyle(
                    color: LightColor.secondaryTextColor.withValues(alpha: 0.92),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: LightColor.whiteColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: LightColor.secondaryDark,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        color: LightColor.secondaryTextColor.withValues(alpha: 0.86),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: LightColor.cardColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: LightColor.borderColor.withValues(alpha: 0.15)),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: LightColor.shadowColor.withValues(alpha: 0.04),
          blurRadius: 10,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 2,
          ),
          minTileHeight: 62,
          leading: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(item.icon, color: LightColor.secondaryColor, size: 18),
          ),
          title: Text(
            item.title,
            style: const TextStyle(
              color: LightColor.primaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: LightColor.borderColor.withValues(alpha: 0.9),
          ),
        ),
        if (!isLast)
          Divider(
            height: 0.5,
            indent: 40,
            endIndent: 10,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      minTileHeight: 62,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: LightColor.redLightColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(10),
                child: CircularProgressIndicator(
                  strokeWidth: 1,
                  valueColor: AlwaysStoppedAnimation<Color>(LightColor.redColor),
                ),
              )
            : const Icon(Icons.logout_rounded, color: LightColor.redColor, size: 20),
      ),
      title: Text(
        isLoading ? 'Logging out...' : 'Logout',
        style: const TextStyle(
          color: LightColor.redColor,
          fontSize: 14.5,
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
