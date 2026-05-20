import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_app_bar.dart';
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
      appBar: const CustomAppBar(title: 'About App'),
      body: SafeArea(
        top: false,
        child: FutureBuilder<PackageInfo>(
          future: _packageInfoFuture,
          builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
            final PackageInfo? info = snapshot.data;
            final String version = info == null
                ? 'Loading version…'
                : '${info.version} (${info.buildNumber})';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Subtitle(version: version),
                const SizedBox(height: AppDimens.paddingX10),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: AppUtils().getPadding(
                      symmetricHorizontal: AppDimens.paddingX20,
                      top: AppDimens.paddingX6,
                      bottom: AppDimens.paddingX28,
                    ),
                    children: <Widget>[
                      _HeroCard(version: version),
                      const SizedBox(height: AppDimens.paddingX16),
                      const _SectionLabel('Made by'),
                      const _ProductOfCard(),
                      const SizedBox(height: AppDimens.paddingX16),
                      const _SectionLabel('Our mission'),
                      const _MissionCard(),
                      const SizedBox(height: AppDimens.paddingX16),
                      const _SectionLabel('What we offer'),
                      const _FeatureGrid(),
                      const SizedBox(height: AppDimens.paddingX16),
                      const _SectionLabel('Why we built this'),
                      const _InfoCard(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  HEADER + SUBTITLE
// ─────────────────────────────────────────────

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX20,
      ),
      child: Text(
        'Hamro Footsall · v$version',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CARDS
// ─────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                ),
                child: const Icon(
                  Icons.sports_soccer_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX24,
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Hamro Footsall',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextLarge?.copyWith(
                        fontSize: AppDimens.fontHeadingSmall,
                        fontWeight: FontWeight.w700,
                        color: LightColor.primaryTextColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Futsal booking, simplified.',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _VersionPill(version: version),
            ],
          ),
          const SizedBox(height: AppDimens.paddingX14),
          const Divider(
            height: 1,
            thickness: 1,
            color: LightColor.dividerColor,
          ),
          const SizedBox(height: AppDimens.paddingX12),
          Text(
            'Book courts, manage matches, and keep your futsal plans moving without the back-and-forth.',
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionPill extends StatelessWidget {
  const _VersionPill({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: LightColor.secondaryColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      child: Text(
        'v${version.split(' ').first}',
        style: textTheme.bodyTextSmall?.copyWith(
          fontSize: AppDimens.fontBodySubTitle,
          fontWeight: FontWeight.w600,
          color: LightColor.secondaryColor,
        ),
      ),
    );
  }
}

class _ProductOfCard extends StatelessWidget {
  const _ProductOfCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _SurfaceCard(
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 48,
            padding: AppUtils().getPadding(all: AppDimens.paddingX6),
            decoration: BoxDecoration(
              color: LightColor.background,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
              border: Border.all(color: LightColor.dividerColor),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              child: CustomImageView(
                imagePath: 'assets/icons/location.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Yak Stack Solution',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Digital products for modern sports businesses.',
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.4,
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
    final textTheme = FutsalTheme.getTextTheme(context);
    return _SurfaceCard(
      child: Text(
        'Hamro Footsall is built to make local futsal easier for players, teams, and venue owners. Discover available courts, compare facilities, and book with confidence.',
        style: textTheme.bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          height: 1.6,
        ),
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
    ),
    _AboutFeature(
      icon: Icons.groups_rounded,
      title: 'Match Ready',
      subtitle: 'Organize games with less effort.',
    ),
    _AboutFeature(
      icon: Icons.verified_rounded,
      title: 'Trusted Venues',
      subtitle: 'Review facilities before booking.',
    ),
    _AboutFeature(
      icon: Icons.support_agent_rounded,
      title: 'Helpful Support',
      subtitle: 'Clear info when you need it.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double spacing = AppDimens.paddingX12;
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

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: const Column(
        children: <Widget>[
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

// ─────────────────────────────────────────────
//  PRIMITIVES
// ─────────────────────────────────────────────

class _SurfaceCard extends StatelessWidget {
  const _SurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
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
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppUtils().getPadding(
        left: AppDimens.paddingX2,
        bottom: AppDimens.paddingX8,
      ),
      child: Text(
        text,
        style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }
}

class _AboutFeature extends StatelessWidget {
  const _AboutFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return _SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Icon(
              icon,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX18,
            ),
          ),
          const SizedBox(height: AppDimens.paddingX10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: LightColor.primaryTextColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.4,
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
    final textTheme = FutsalTheme.getTextTheme(context);
    return Padding(
      padding: AppUtils().getPadding(
        symmetricHorizontal: AppDimens.paddingX14,
        symmetricVertical: AppDimens.paddingX14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Icon(
              icon,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX18,
            ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: textTheme.bodyTextMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
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
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.paddingX14),
      child: Divider(
        height: 1,
        thickness: 1,
        color: LightColor.dividerColor,
      ),
    );
  }
}

