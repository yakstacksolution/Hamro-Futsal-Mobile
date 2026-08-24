import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/auth/data/repositories/authentication_repository_impl.dart';
import 'package:hamro_footsall/features/dashboard/presentation/page/dashboard_screen.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/presentation/profile_bloc/profile_bloc.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_details_page.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/vendor_request_bottom_sheet.dart';
import 'package:hamro_footsall/features/rewards/presentation/widgets/profile_rewards_badge.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false;

  late final List<_ProfileItem> _generalItems = <_ProfileItem>[
    _ProfileItem(
      title: StringConstants.myRewards,
      icon: Icons.workspace_premium_outlined,
      onTap: () => context.pushNamed(AppRouterParams.rewards.name),
    ),
    _ProfileItem(
      title: StringConstants.settings,
      icon: Icons.settings_outlined,
      onTap: () => context.pushNamed(AppRouterParams.settings.name),
    ),
    _ProfileItem(
      title: StringConstants.opponentRequests,
      icon: Icons.sports_kabaddi_rounded,
      onTap: () => context.pushNamed(AppRouterParams.opponentMatch.name),
    ),
    _ProfileItem(
      title: StringConstants.transactionHistory,
      icon: Icons.receipt_long_outlined,
      onTap: () {
        final bool isVendor =
            context.read<ProfileBloc>().state.profile?.data.role == 'vendor';
        context.pushNamed(
          AppRouterParams.transactions.name,
          queryParameters: <String, String>{'futsal': isVendor.toString()},
        );
      },
    ),
  ];

  late final List<_ProfileItem> _vendorItems = <_ProfileItem>[
    _ProfileItem(
      title: StringConstants.yourVenues,
      icon: Icons.stadium_outlined,
      onTap: () => context.pushNamed(AppRouterParams.yourVenues.name),
    ),
    _ProfileItem(
      title: StringConstants.bookingOverview,
      icon: Icons.insights_rounded,
      onTap: () => context.pushNamed(AppRouterParams.bookingOverview.name),
    ),
    _ProfileItem(
      title: 'Finance & Payouts',
      icon: Icons.account_balance_outlined,
      onTap: () => context.pushNamed(AppRouterParams.account.name),
    ),
    _ProfileItem(
      title: 'Products',
      icon: Icons.inventory_2_outlined,
      onTap: () => context.pushNamed(AppRouterParams.products.name),
    ),
    _ProfileItem(
      title: StringConstants.expenses,
      icon: Icons.account_balance_wallet_outlined,
      onTap: () => context.pushNamed(AppRouterParams.expenses.name),
    ),
  ];

  late final List<_ProfileItem> _supportItems = <_ProfileItem>[
    _ProfileItem(
      title: StringConstants.helpAndFaq,
      icon: Icons.help_outline_rounded,
      onTap: () => context.pushNamed(AppRouterParams.helpFaq.name),
    ),
    _ProfileItem(
      title: StringConstants.feedback,
      icon: Icons.rate_review_outlined,
      onTap: () => context.pushNamed(AppRouterParams.feedback.name),
    ),
    _ProfileItem(
      title: StringConstants.aboutApp,
      icon: Icons.info_outline_rounded,
      onTap: () => context.pushNamed(AppRouterParams.aboutApp.name),
    ),
  ];

  @override
  void initState() {
    super.initState();
    DashboardScreen.selectedNavIndex.addListener(_retryFailedFetchOnTabVisible);
  }

  @override
  void dispose() {
    DashboardScreen.selectedNavIndex.removeListener(
      _retryFailedFetchOnTabVisible,
    );
    super.dispose();
  }

  void _retryFailedFetchOnTabVisible() {
    if (!mounted || DashboardScreen.selectedNavIndex.value != 4) return;
    final ProfileBloc bloc = context.read<ProfileBloc>();
    if (bloc.state.profile == null &&
        bloc.state.status != ProfileStatus.loading) {
      bloc.add(const FetchProfileEvent());
    }
  }

  Future<void> _showVendorRequestSheet(UserData user) async {
    final ProfileBloc bloc = context.read<ProfileBloc>();
    await showAppBottomSheet<void>(
      context: context,
      bottomSpacing: 0,
      builder: (_) => BlocProvider<ProfileBloc>.value(
        value: bloc,
        child: VendorRequestBottomSheet(user: user),
      ),
    );
  }

  Future<bool> _confirmLogout() async {
    final bool? confirmed = await showAppBottomSheet<bool>(
      context: context,
      bottomSpacing: AppDimens.paddingX20,
      builder: (_) => const _LogoutConfirmationSheet(),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          AppUtils().showSnackBar(context, MsgType.error, state.errorMessage!);
        } else if (state.successMessage != null) {
          AppUtils().showSnackBar(
            context,
            MsgType.success,
            state.successMessage!,
          );
        }
      },
      builder: (context, state) {
        final ProfileModel? profile = state.profile;
        final bool isLoading =
            state.status == ProfileStatus.loading && profile == null;

        final bool isVendor = profile?.data.role == 'vendor';
        final bool isVendorRequested = profile?.data.isVendorRequested == true;
        final List<_ProfileItem> candidateVendorItems = <_ProfileItem>[
          _ProfileItem(
            title: isVendorRequested
                ? StringConstants.vendorRequestAlreadySubmitted
                : StringConstants.upgradeToVendor,
            icon: isVendorRequested
                ? Icons.hourglass_top_rounded
                : Icons.storefront_outlined,
            loading: state.isRequestingVendor,
            enabled: !isVendorRequested && !state.isRequestingVendor,
            onTap: profile == null
                ? () {}
                : () => _showVendorRequestSheet(profile.data),
          ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _pageHeader(context),
            const SizedBox(height: AppDimens.paddingX12),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: AppDimens.paddingX50 * 3,
                ),
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
                  // if (profile != null && isVendor) ...[
                  //   _VendorStatusCard(user: profile.data),
                  //   const SizedBox(height: AppDimens.paddingX20),
                  // ],
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(
                    label: StringConstants.general,
                    items: _generalItems,
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(
                    label: StringConstants.vendor,
                    items: isVendor ? _vendorItems : candidateVendorItems,
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(
                    label: StringConstants.support,
                    items: _supportItems,
                  ),
                  const SizedBox(height: AppDimens.paddingX20),
                  _SectionGroup(
                    label: StringConstants.account,
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
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              StringConstants.profile,
              style: textTheme.bodyTextLarge?.copyWith(
                fontSize: AppDimens.fontHeadingSmall,
                fontWeight: FontWeight.w700,
                color: LightColor.primaryTextColor,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          // Points balance rides the heading rather than taking a card of its
          // own further down the page.
          const ProfileRewardsBadge(),
        ],
      ),
    );
  }

  Widget _appVersion(BuildContext context) {
    return Center(
      child: Text(
        StringConstants.hamroFutsalV100,
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.hintTextColor,
          fontSize: AppDimens.fontBodySubTitle,
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final bool confirmed = await _confirmLogout();
    if (!confirmed || !mounted) return;

    setState(() => _isLoggingOut = true);

    final response = await AuthenticationRepositoryImpl().logout();
    if (!mounted) return;

    setState(() => _isLoggingOut = false);

    response?.fold(
      (failure) =>
          AppUtils().showSnackBar(context, MsgType.error, failure.errorMessage),
      (_) {
        AppUtils().showSnackBar(
          context,
          MsgType.success,
          StringConstants.logoutSuccessful,
        );
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

    final String? fullName = user?.fullName.trim().isNotEmpty == true
        ? user!.fullName.trim()
        : null;
    final String? email = user?.email.trim().isNotEmpty == true
        ? user!.email.trim()
        : null;
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
                      isLoading
                          ? 'Loading…'
                          : fullName ?? 'Profile unavailable',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email ?? 'Pull to refresh your account',
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
                StringConstants.view,
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

class _LogoutConfirmationSheet extends StatelessWidget {
  const _LogoutConfirmationSheet();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: AppDimens.sizeX44,
              height: AppDimens.sizeX44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: LightColor.redColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: LightColor.redColor,
                size: AppDimens.sizeX24,
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Log out?',
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimens.paddingX6),
                  Text(
                    'You will need to sign in again to access your bookings, chats, and profile.',
                    style: textTheme.bodyTextSmall?.copyWith(
                      color: LightColor.secondaryTextColor,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingX20),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                key: const Key('cancel-logout-button'),
                text: StringConstants.cancel,
                isOutlined: true,
                backgroundColor: LightColor.whiteColor,
                foregroundColor: LightColor.primaryTextColor,
                borderColor: LightColor.greyBorderColor,
                minHeight: AppDimens.sizeX44,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: AppDimens.paddingX12),
            Expanded(
              child: CustomButton(
                key: const Key('confirm-logout-button'),
                text: 'Log out',
                icon: Icons.logout_rounded,
                backgroundColor: LightColor.redColor,
                foregroundColor: LightColor.inverseTextColor,
                minHeight: AppDimens.sizeX44,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Kept ready for the vendor-status section while that section is feature gated.
// ignore: unused_element
class _VendorStatusCard extends StatelessWidget {
  const _VendorStatusCard({required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final (
      String title,
      String message,
      Color color,
      IconData icon,
    ) = switch (user.vendorStatus) {
      VendorLifecycleStatus.active => (
        'Vendor account active',
        user.businessVerified
            ? 'Your business is verified and ready to receive bookings.'
            : 'Your vendor account is active. Business verification is pending.',
        LightColor.secondaryColor,
        Icons.verified_rounded,
      ),
      VendorLifecycleStatus.underReview => (
        'Business under review',
        'Hamro Futsal is reviewing your submitted business information.',
        LightColor.warningColor,
        Icons.hourglass_top_rounded,
      ),
      VendorLifecycleStatus.rejected => (
        'Business verification rejected',
        user.vendorStatusReason.isNotEmpty
            ? user.vendorStatusReason
            : 'Review your business information and submit it again.',
        LightColor.redColor,
        Icons.error_outline_rounded,
      ),
      VendorLifecycleStatus.suspended => (
        'Vendor account suspended',
        user.vendorStatusReason.isNotEmpty
            ? user.vendorStatusReason
            : 'Contact Hamro Futsal support for assistance.',
        LightColor.redColor,
        Icons.block_rounded,
      ),
      VendorLifecycleStatus.actionRequired => (
        'Action required',
        user.vendorStatusReason.isNotEmpty
            ? user.vendorStatusReason
            : 'Update your vendor information to continue.',
        LightColor.warningColor,
        Icons.notification_important_outlined,
      ),
      VendorLifecycleStatus.incomplete => (
        'Complete vendor setup',
        'Finish your venue and business details to start accepting bookings.',
        LightColor.warningColor,
        Icons.edit_note_rounded,
      ),
      VendorLifecycleStatus.notStarted => (
        'Start vendor setup',
        'Add your business and venue details to become a verified vendor.',
        LightColor.secondaryColor,
        Icons.storefront_outlined,
      ),
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX16),
      padding: const EdgeInsets.all(AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: AppDimens.sizeX22),
          const SizedBox(width: AppDimens.paddingX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX4),
                Text(
                  message,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    Padding(
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
        onTap: item.enabled ? item.onTap : null,
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
                Icon(
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
    this.enabled = true,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;
  final bool loading;
  final bool enabled;
}
