import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/profile/presentation/widgets/profile_header_background.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class DashboardUser {
  const DashboardUser({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.user,
    required this.currentIndex,
    required this.onNavTap,
    required this.onSignOut,
  });

  final DashboardUser user;
  final int currentIndex;
  final ValueChanged<int> onNavTap;
  final VoidCallback onSignOut;

  static const List<_DrawerNavConfig> _mainItems = <_DrawerNavConfig>[
    _DrawerNavConfig(
      index: 0,
      icon: Icons.add_business_rounded,
      label: StringConstants.addFootsallCourt,
    ),
  ];

  static const List<_DrawerNavConfig> _managementItems = <_DrawerNavConfig>[
    _DrawerNavConfig(
      icon: Icons.discount_rounded,
      label: StringConstants.discounts,
    ),
    _DrawerNavConfig(
      icon: Icons.category_rounded,
      label: StringConstants.categories,
    ),
  ];

  static const List<_DrawerNavConfig> _settingsItems = <_DrawerNavConfig>[
    _DrawerNavConfig(
      icon: Icons.store_rounded,
      label: StringConstants.storeSettings,
    ),
    _DrawerNavConfig(
      icon: Icons.notifications_rounded,
      label: StringConstants.notifications,
      badge: '3',
    ),
    _DrawerNavConfig(
      icon: Icons.help_outline_rounded,
      label: StringConstants.helpAndSupport,
    ),
  ];

  String get _displayName {
    final trimmedName = user.name.trim();
    if (trimmedName.isNotEmpty) return trimmedName;

    final emailName = user.email.split('@').first.trim();
    return emailName.isNotEmpty ? emailName : 'Merchant';
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 300,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[LightColor.cardColor, LightColor.background],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: ProfileHeaderBackground(
                  height: 80,
                  heroTag: kProfileHeaderSurfaceHeroTag,
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _DrawerHeader(
                      displayName: _displayName,
                      email: user.email,
                      onProfileTap: () => onNavTap(5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: <Widget>[
                    const _DrawerSectionLabel('Footsall Vendor'),
                    const SizedBox(height: 6),
                    ..._mainItems.map((item) {
                      return _DrawerNavItem(
                        icon: item.icon,
                        label: item.label,
                        badge: item.badge,
                        isActive: item.index == currentIndex,
                        onTap: () {
                          context.pushNamed(AppRouterParams.createCourts.name);
                          onNavTap(item.index!);
                        },
                      );
                    }),
                    const SizedBox(height: 16),
                    const _DrawerSectionLabel('Management'),
                    const SizedBox(height: 6),
                    ..._managementItems.map((item) {
                      return _DrawerNavItem(
                        icon: item.icon,
                        label: item.label,
                        badge: item.badge,
                        onTap: () {},
                      );
                    }),
                    const SizedBox(height: 16),
                    const _DrawerSectionLabel('Settings'),
                    const SizedBox(height: 6),
                    ..._settingsItems.map((item) {
                      return _DrawerNavItem(
                        icon: item.icon,
                        label: item.label,
                        badge: item.badge,
                        onTap: () {},
                      );
                    }),
                  ],
                ),
              ),
              _DrawerFooter(user: user, onSignOut: onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({
    required this.displayName,
    required this.email,
    required this.onProfileTap,
  });

  final String displayName;
  final String email;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
            onProfileTap();
          },
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                displayName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                email,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DrawerSectionLabel extends StatelessWidget {
  const _DrawerSectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: LightColor.secondaryTextColor,
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DrawerNavItem extends StatelessWidget {
  const _DrawerNavItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: isActive
                  ? LightColor.secondaryColor.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(
                      color: LightColor.secondaryColor.withValues(alpha: 0.2),
                    )
                  : null,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isActive
                        ? LightColor.secondaryColor.withValues(alpha: 0.15)
                        : LightColor.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: LightColor.borderColor),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isActive
                        ? LightColor.secondaryColor
                        : LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? LightColor.secondaryColor
                          : LightColor.primaryTextColor,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      badge!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                if (isActive)
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: LightColor.secondaryColor,
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

class _DrawerFooter extends StatelessWidget {
  const _DrawerFooter({required this.user, required this.onSignOut});

  final DashboardUser user;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColor.borderColor),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.cloud_done_rounded,
                  size: 16,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      StringConstants.connected,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    Text(
                      user.id,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: LightColor.secondaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          InkWell(
            onTap: onSignOut,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: LightColor.redColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: LightColor.redColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: LightColor.redColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    StringConstants.signOut,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: LightColor.redColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerNavConfig {
  const _DrawerNavConfig({
    required this.icon,
    required this.label,
    this.index,
    this.badge,
  });

  final int? index;
  final IconData icon;
  final String label;
  final String? badge;
}
