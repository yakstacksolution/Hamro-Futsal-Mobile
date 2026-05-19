import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppPage extends StatefulWidget {
  const AboutAppPage({super.key});

  @override
  State<AboutAppPage> createState() => _AboutAppPageState();
}

class _AboutAppPageState extends State<AboutAppPage> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: LightColor.primaryTextColor,
            size: AppDimens.sizeX20,
          ),
        ),
        title: Text(
          'About App',
          style: FutsalTheme.getTextTheme(
            context,
          ).headingSubTitle?.copyWith(color: LightColor.primaryTextColor),
        ),
        backgroundColor: LightColor.background,
        surfaceTintColor: LightColor.transparentColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            final PackageInfo? info = snapshot.data;
            final String version = info == null
                ? 'Loading version...'
                : 'Version ${info.version} (${info.buildNumber})';

            return ListView(
              padding: AppUtils().getPadding(
                left: AppDimens.paddingX20,
                right: AppDimens.paddingX20,
                bottom: AppDimens.paddingX28,
              ),
              children: <Widget>[
                _HeroPanel(version: version),
                const SizedBox(height: AppDimens.sizeX16),
                const _ProductOfSection(),
                const SizedBox(height: AppDimens.sizeX16),
                const _MissionCard(),
                const SizedBox(height: AppDimens.sizeX16),
                const _FeatureGrid(),
                const SizedBox(height: AppDimens.sizeX16),
                const _InfoList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.28),
            blurRadius: AppDimens.sizeX24,
            offset: const Offset(0, AppDimens.sizeX10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX58,
                height: AppDimens.sizeX58,
                decoration: BoxDecoration(
                  color: LightColor.inverseTextColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: LightColor.inverseTextColor,
                  size: AppDimens.sizeX32,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hamro Footsall',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FutsalTheme.getTextTheme(context).headingSmall
                          ?.copyWith(
                            color: LightColor.inverseTextColor,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      version,
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.inverseTextColor.withValues(
                              alpha: 0.78,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX18),
          Text(
            'Book courts, manage matches, and keep your futsal plans moving without the back-and-forth.',
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.inverseTextColor.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductOfSection extends StatelessWidget {
  const _ProductOfSection();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX56,
            height: AppDimens.sizeX56,
            padding: AppUtils().getPadding(all: AppDimens.paddingX8),
            decoration: BoxDecoration(
              color: LightColor.inputFillColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              // child: Image.asset('assets/icon/logo.png', fit: BoxFit.contain),
              child: CustomImageView(
                imagePath: 'assets/icons/location.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Product of',
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  'Yak Stack Solution',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextLarge
                      ?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: AppDimens.sizeX4),
                Text(
                  'Digital products for modern sports businesses.',
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
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

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionHeader(
            icon: Icons.flag_rounded,
            title: 'Our Goal',
            accentColor: LightColor.secondaryColor,
            backgroundColor: LightColor.secondarySoft,
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Text(
            'Hamro Footsall is built to make local futsal easier for players, teams, and venue owners. Discover available courts, compare facilities, and book with confidence.',
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w400,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const List<_AboutFeature> _features = <_AboutFeature>[
    _AboutFeature(
      icon: Icons.calendar_month_rounded,
      title: 'Fast Booking',
      subtitle: 'Pick dates and slots quickly.',
      color: LightColor.blueColor,
      bg: LightColor.blueLightColor,
    ),
    _AboutFeature(
      icon: Icons.groups_rounded,
      title: 'Match Ready',
      subtitle: 'Organize games with less effort.',
      color: LightColor.purpleColor,
      bg: LightColor.purpleLightColor,
    ),
    _AboutFeature(
      icon: Icons.verified_rounded,
      title: 'Trusted Venues',
      subtitle: 'Review facilities before booking.',
      color: LightColor.secondaryColor,
      bg: LightColor.secondarySoft,
    ),
    _AboutFeature(
      icon: Icons.support_agent_rounded,
      title: 'Helpful Support',
      subtitle: 'Clear info when you need it.',
      color: LightColor.warningColor,
      bg: LightColor.warningLightColor,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double spacing = AppDimens.sizeX10;
        final double itemWidth = (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _features
              .map((feature) => SizedBox(width: itemWidth, child: feature))
              .toList(),
        );
      },
    );
  }
}

class _InfoList extends StatelessWidget {
  const _InfoList();

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        children: const <Widget>[
          _InfoRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy First',
            subtitle: 'Your account and booking information stay protected.',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.update_rounded,
            title: 'Always Improving',
            subtitle: 'We keep refining the app for smoother play planning.',
          ),
          _InfoDivider(),
          _InfoRow(
            icon: Icons.favorite_rounded,
            title: 'Made for Futsal',
            subtitle: 'Designed around the way local players actually book.',
          ),
        ],
      ),
    );
  }
}

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.06),
            blurRadius: AppDimens.sizeX16,
            offset: const Offset(0, AppDimens.sizeX6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.accentColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final Color accentColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: AppDimens.sizeX36,
          height: AppDimens.sizeX36,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          ),
          child: Icon(icon, color: accentColor, size: AppDimens.sizeX20),
        ),
        const SizedBox(width: AppDimens.sizeX10),
        Expanded(
          child: Text(
            title,
            style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _AboutFeature extends StatelessWidget {
  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.bg,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: AppDimens.sizeX38,
            height: AppDimens.sizeX38,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            ),
            child: Icon(icon, color: color, size: AppDimens.sizeX20),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppDimens.sizeX4),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: AppDimens.sizeX40,
          height: AppDimens.sizeX40,
          decoration: BoxDecoration(
            color: LightColor.secondarySoft,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          child: Icon(
            icon,
            color: LightColor.secondaryColor,
            size: AppDimens.sizeX20,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: FutsalTheme.getTextTheme(context).bodyTextMedium
                    ?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: AppDimens.sizeX4),
              Text(
                subtitle,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(vertical: AppDimens.paddingX14),
      child: Divider(
        height: AppDimens.sizeX1,
        color: LightColor.dividerColor.withValues(alpha: 0.7),
      ),
    );
  }
}
