import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_footsall/core/routers/app_router_params.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
import 'package:hamro_footsall/core/widgets/custom_switch_widget.dart';
import 'package:hamro_footsall/features/profile/presentation/controller/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsController _controller = SettingsController();

  @override
  void initState() {
    super.initState();
    // A failed notification-preference sync reverts the switch; tell the
    // user why it snapped back.
    _controller.onError = (String message) {
      if (mounted) AppUtils().showSnackBar(context, MsgType.error, message);
    };
  }

  @override
  void dispose() {
    _controller.onError = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: const CustomAppBar(title: 'Settings'),
      body: SafeArea(
        top: false,
        // Only the preference list listens to the controller, so toggling a
        // switch rebuilds this subtree rather than the whole Scaffold.
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX16,
              top: AppDimens.paddingX12,
              bottom: AppDimens.paddingX32,
            ),
            itemCount: _sections.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppDimens.paddingX16),
            itemBuilder: (context, index) =>
                _SettingsSection(section: _sections[index]),
          ),
        ),
      ),
    );
  }

  /// Declarative description of the whole page. Adding a row is a one-line
  /// change here — no widget plumbing required.
  List<_Section> get _sections => <_Section>[
    _Section(
      label: 'Account',
      items: <_SettingsItem>[
        _SettingsItem.nav(
          icon: Icons.lock_outline_rounded,
          title: 'Change Password',
          subtitle: 'Keep your account secure',
          onTap: () => context.pushNamed(AppRouterParams.changePassword.name),
        ),
        _SettingsItem.toggle(
          icon: Icons.fingerprint_rounded,
          title: 'Biometric Login',
          subtitle: 'Use Face ID or fingerprint to sign in',
          value: _controller.biometricLogin,
          onChanged: _controller.setBiometricLogin,
        ),
      ],
    ),
    _Section(
      label: 'Notifications',
      items: <_SettingsItem>[
        _SettingsItem.toggle(
          icon: Icons.notifications_active_outlined,
          title: 'Push Notifications',
          subtitle: 'Receive updates on this device',
          value: _controller.pushNotifications,
          onChanged: _controller.setPushNotifications,
        ),
        _SettingsItem.toggle(
          icon: Icons.event_available_rounded,
          title: 'Booking Alerts',
          subtitle: 'Reminders before your matches start',
          value: _controller.bookingAlerts,
          onChanged: _controller.setBookingAlerts,
        ),
        _SettingsItem.toggle(
          icon: Icons.sports_kabaddi_rounded,
          title: 'Opponent Requests',
          subtitle: 'Notify me when someone wants to play',
          value: _controller.opponentRequests,
          onChanged: _controller.setOpponentRequests,
        ),
        _SettingsItem.toggle(
          icon: Icons.mark_email_unread_outlined,
          title: 'Promotional Emails',
          subtitle: 'Occasional offers and updates by email',
          value: _controller.promotionalEmails,
          onChanged: _controller.setPromotionalEmails,
        ),
      ],
    ),
    _Section(
      label: 'Preferences',
      items: <_SettingsItem>[
        _SettingsItem.toggle(
          icon: Icons.dark_mode_outlined,
          title: 'Dark Mode',
          subtitle: 'Switch to a darker appearance',
          value: _controller.darkMode,
          onChanged: _controller.setDarkMode,
        ),
        _SettingsItem.nav(
          icon: Icons.language_rounded,
          title: 'Language',
          subtitle: 'App display language',
          trailingValue: _controller.language,
          onTap: _showLanguagePicker,
        ),
      ],
    ),
  ];

  Future<void> _showLanguagePicker() async {
    final String? selected = await _showOptionSheet(
      title: 'Language',
      options: SettingsController.languages,
      current: _controller.language,
    );
    if (selected != null) _controller.setLanguage(selected);
  }

  Future<String?> _showOptionSheet({
    required String title,
    required List<String> options,
    required String current,
  }) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: LightColor.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: AppUtils().getPadding(
              symmetricHorizontal: AppDimens.paddingX16,
              top: AppDimens.paddingX16,
              bottom: AppDimens.paddingX16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: LightColor.dividerColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX14),
                Text(
                  title,
                  style: textTheme.bodyTextLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: AppDimens.paddingX10),
                for (final option in options)
                  InkWell(
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    onTap: () => Navigator.of(ctx).pop(option),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingX8,
                        vertical: AppDimens.paddingX12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              option,
                              style: textTheme.bodyTextMedium?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (option == current)
                            const Icon(
                              Icons.check_rounded,
                              color: LightColor.secondaryColor,
                              size: AppDimens.sizeX20,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.section});

  final _Section section;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final items = section.items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.paddingX4,
            0,
            AppDimens.paddingX4,
            AppDimens.paddingX8,
          ),
          child: Text(
            section.label.toUpperCase(),
            style: textTheme.bodyTextSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: LightColor.secondaryTextColor,
              fontSize: AppDimens.fontBodySubTitle,
              letterSpacing: 0.8,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            border: Border.all(color: LightColor.dividerColor),
            boxShadow: const [
              BoxShadow(
                color: LightColor.shadowColor,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX14),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  _SettingsRow(item: items[i]),
                  if (i != items.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: AppDimens.paddingX50),
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

  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isToggle = item.kind == _ItemKind.toggle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isToggle
            ? () => item.onChanged?.call(!(item.value ?? false))
            : item.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.paddingX14,
            vertical: AppDimens.paddingX12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(
                  item.icon,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX18,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title,
                      style: textTheme.bodyTextMedium?.copyWith(
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle!,
                        maxLines: 2,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.secondaryTextColor,
                          fontWeight: FontWeight.w400,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              _SettingsTrailing(item: item),
            ],
          ),
        ),
      ),
    );
  }
}

/// Trailing affordance for a row: a switch for toggles, otherwise an optional
/// current-value label followed by a chevron.
class _SettingsTrailing extends StatelessWidget {
  const _SettingsTrailing({required this.item});

  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    if (item.kind == _ItemKind.toggle) {
      return CustomSwitchWidget(
        value: item.value ?? false,
        onChanged: item.onChanged,
      );
    }

    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.trailingValue != null)
          Padding(
            padding: const EdgeInsets.only(right: AppDimens.paddingX6),
            child: Text(
              item.trailingValue!,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        const Icon(
          Icons.chevron_right_rounded,
          color: LightColor.iconGrey,
          size: AppDimens.sizeX20,
        ),
      ],
    );
  }
}

class _Section {
  const _Section({required this.label, required this.items});

  final String label;
  final List<_SettingsItem> items;
}

enum _ItemKind { nav, toggle }

class _SettingsItem {
  const _SettingsItem._({
    required this.kind,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingValue,
    this.onTap,
    this.value,
    this.onChanged,
  });

  factory _SettingsItem.nav({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingValue,
    required VoidCallback onTap,
  }) => _SettingsItem._(
    kind: _ItemKind.nav,
    icon: icon,
    title: title,
    subtitle: subtitle,
    trailingValue: trailingValue,
    onTap: onTap,
  );

  factory _SettingsItem.toggle({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) => _SettingsItem._(
    kind: _ItemKind.toggle,
    icon: icon,
    title: title,
    subtitle: subtitle,
    value: value,
    onChanged: onChanged,
  );

  final _ItemKind kind;
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailingValue;
  final VoidCallback? onTap;
  final bool? value;
  final ValueChanged<bool>? onChanged;
}
