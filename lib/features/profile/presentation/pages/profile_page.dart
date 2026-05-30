import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/expenses_screen.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/overview_screen.dart';
import 'package:hamro_footsall/features/dashboard/presentation/widgets/opponent_request_page.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/about_app_page.dart';
import 'package:hamro_footsall/features/profile/presentation/pages/settings_page.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  late final List<_ProfileItem> _generalItems = <_ProfileItem>[
    _ProfileItem(
      title: 'Settings',
      icon: Icons.settings_outlined,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage())),
    ),
    _ProfileItem(
      title: 'Opponent Requests',
      icon: Icons.sports_kabaddi_rounded,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => OpponentRequestScreen())),
    ),
    _ProfileItem(
      title: 'Transaction History',
      icon: Icons.receipt_long_outlined,
      onTap: () {},
    ),
  ];

  late final List<_ProfileItem> _vendorItems = <_ProfileItem>[
    _ProfileItem(
      title: 'Overview',
      icon: Icons.insights_rounded,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => OverviewScreen())),
    ),
    _ProfileItem(
      title: 'Expenses',
      icon: Icons.account_balance_wallet_outlined,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ExpensesScreen())),
    ),
  ];

  late final List<_ProfileItem> _supportItems = <_ProfileItem>[
    _ProfileItem(
      title: 'Help & FAQ',
      icon: Icons.help_outline_rounded,
      onTap: () {},
    ),
    _ProfileItem(
      title: 'About App',
      icon: Icons.info_outline_rounded,
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const AboutAppPage())),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
        }
      },
      builder: (context, state) {
        final ProfileModel? profile = state.profile;
        final bool isLoading =
            state.status == ProfileStatus.loading && profile == null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pageHeader(context),
            const SizedBox(height: AppDimens.paddingX12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: AppDimens.paddingX50),
                children: [
                  _ProfileRow(
                    profile: profile,
                    profileImage: state.profileImage,
                    isLoading: isLoading,
                    onTap: profile == null
                        ? null
                        : () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider<ProfileBloc>.value(
                                value: context.read<ProfileBloc>(),
                                child: ProfileDetailsPage(user: profile.data),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppDimens.paddingX24),
                  _SectionGroup(label: 'General', items: _generalItems),
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(label: 'Vendor', items: _vendorItems),
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(label: 'Support', items: _supportItems),
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(
                    label: 'Account',
                    items: [
                      _ProfileItem(
                        title: _isLoggingOut ? 'Logging out…' : 'Log out',
                        icon: Icons.logout_rounded,
                        destructive: true,
                        loading: _isLoggingOut,
                        onTap: _isLoggingOut ? () {} : _handleLogout,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX22),
                  _appVersion(context),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _pageHeader(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
        top: AppDimens.paddingX24,
      ),
      child: Text(
        'Profile',
        style: textTheme.bodyTextLarge?.copyWith(
          fontSize: AppDimens.fontHeadingSmall,
          fontWeight: FontWeight.w700,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }

  Widget _appVersion(BuildContext context) {
    return Center(
      child: Text(
        'Hamro Futsal · v1.0.0',
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.hintTextColor,
          fontSize: AppDimens.fontBodySubTitle,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    final response = await AuthenticationRepositoryImpl().logout();
    if (!mounted) return;

    setState(() => _isLoggingOut = false);

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

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.profile,
    required this.profileImage,
    required this.isLoading,
    required this.onTap,
  });

  final ProfileModel? profile;
  final String? profileImage;
  final bool isLoading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final UserData? user = profile?.data;

    final String fullName = (user?.fullName.trim().isNotEmpty ?? false)
        ? user!.fullName
        : 'Guest User';
    final String email = (user?.email.trim().isNotEmpty ?? false)
        ? user!.email
        : 'No email available';
    final String? profilePhoto = profileImage ?? user?.profilePhoto?.remoteUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX20,
            vertical: AppDimens.paddingX12,
          ),
          child: Row(
            children: [
              _Avatar(url: profilePhoto, size: 56),
              const SizedBox(width: AppDimens.paddingX14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isLoading ? 'Loading…' : fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX8),
              Text(
                'View',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool hasPhoto = url != null && url!.trim().isNotEmpty;
    return ClipOval(
      child: hasPhoto
          ? CustomImageView(
              url: url!,
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Container(
              width: size,
              height: size,
              color: LightColor.secondaryColor.withValues(alpha: 0.1),
              alignment: Alignment.center,
              child: const Icon(
                Icons.person_rounded,
                color: LightColor.secondaryColor,
                size: AppDimens.sizeX28,
              ),
            ),
    );
  }
}

class _SectionGroup extends StatelessWidget {
  const _SectionGroup({required this.label, required this.items});

  final String label;
  final List<_ProfileItem> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX24,
            0,
            AppDimens.paddingX24,
            AppDimens.paddingX8,
          ),
          child: Text(
            label.toUpperCase(),
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: AppDimens.fontBodySubTitle,
              letterSpacing: 0.8,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX16),
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(color: LightColor.dividerColor),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _SettingsRow(item: items[i]),
                  if (i != items.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: AppDimens.paddingX46),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: LightColor.dividerColor,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});

  final _ProfileItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color contentColor = item.destructive
        ? LightColor.redColor
        : LightColor.primaryTextColor;
    final Color iconColor = item.destructive
        ? LightColor.redColor
        : LightColor.secondaryTextColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX16,
            vertical: AppDimens.paddingX14,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: item.loading
                    ? const LoadingWidget(isButtonLoading: true)
                    : Icon(item.icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AppDimens.paddingX14),
              Expanded(
                child: Text(
                  item.title,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: contentColor,
                    fontWeight: item.destructive
                        ? FontWeight.w600
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (!item.destructive)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: LightColor.iconGrey,
                  size: AppDimens.sizeX20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileItem {
  _ProfileItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.destructive = false,
    this.loading = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
  final bool loading;
}
