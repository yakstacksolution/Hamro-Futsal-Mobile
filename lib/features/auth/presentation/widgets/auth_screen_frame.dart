import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';

enum AuthAudience { general, player, vendor }

class _AudienceCopy {
  const _AudienceCopy({
    required this.headline,
    required this.tagline,
    required this.highlights,
    required this.highlightIcons,
    this.highlightDetails = const <String>[],
    required this.steps,
    required this.features,
    required this.icon,
  });

  final String headline;
  final String tagline;
  final List<String> highlights;

  final List<IconData> highlightIcons;

  final List<String> highlightDetails;

  final List<(IconData, String)> steps;

  final List<(IconData, String)> features;

  final IconData? icon;

  static const List<(IconData, String)> _playerSteps = <(IconData, String)>[
    (Icons.travel_explore_rounded, StringConstants.authStepFindCourt),
    (Icons.schedule_rounded, StringConstants.authStepPickSlot),
    (Icons.sports_soccer_rounded, StringConstants.authStepPlay),
  ];

  static const List<(IconData, String)> _playerFeatures = <(IconData, String)>[
    (Icons.bolt_rounded, StringConstants.authFeatureLiveSlots),
    (Icons.groups_rounded, StringConstants.authFeatureOpponents),
    (Icons.forum_rounded, StringConstants.authFeatureTeamChat),
    (Icons.card_giftcard_rounded, StringConstants.authFeatureRewards),
    (Icons.calendar_month_rounded, StringConstants.authFeatureNepaliCalendar),
  ];

  static _AudienceCopy of(AuthAudience audience, IconData fallbackIcon) {
    switch (audience) {
      case AuthAudience.player:
        return _AudienceCopy(
          headline: StringConstants.authPlayerHeadline,
          tagline: StringConstants.authPlayerTagline,
          icon: Icons.sports_soccer_rounded,
          highlights: const <String>[
            StringConstants.authPlayerHighlightDiscover,
            StringConstants.authPlayerHighlightBook,
            StringConstants.authPlayerHighlightCompete,
          ],
          steps: _playerSteps,
          features: _playerFeatures,
          highlightIcons: const <IconData>[
            Icons.travel_explore_rounded,
            Icons.event_available_rounded,
            Icons.emoji_events_rounded,
          ],
        );
      case AuthAudience.vendor:
        return _AudienceCopy(
          headline: StringConstants.authVendorHeadline,
          tagline: StringConstants.authVendorTagline,
          icon: Icons.storefront_rounded,
          highlights: const <String>[
            StringConstants.authVendorHighlightList,
            StringConstants.authVendorHighlightAutomate,
            StringConstants.authVendorHighlightInsights,
          ],
          steps: const <(IconData, String)>[
            (Icons.add_business_rounded, StringConstants.authStepListVenue),
            (Icons.schedule_rounded, StringConstants.authStepSetSlots),
            (
              Icons.notifications_active_rounded,
              StringConstants.authStepGetBooked,
            ),
          ],
          features: const <(IconData, String)>[
            (Icons.point_of_sale_rounded, StringConstants.authFeatureWalkIns),
            (Icons.receipt_long_rounded, StringConstants.authFeatureExpenses),
            (
              Icons.account_balance_wallet_rounded,
              StringConstants.authFeaturePayouts,
            ),
            (Icons.insights_rounded, StringConstants.authFeatureReports),
            (
              Icons.calendar_month_rounded,
              StringConstants.authFeatureNepaliCalendar,
            ),
          ],
          highlightIcons: const <IconData>[
            Icons.add_business_rounded,
            Icons.autorenew_rounded,
            Icons.insights_rounded,
          ],
        );
      case AuthAudience.general:
        return _AudienceCopy(
          // The wordmark is already at the top, so the promise leads.
          headline: StringConstants.authBrandTagline,
          tagline: StringConstants.authBrandSubline,
          icon: null,
          highlights: const <String>[
            StringConstants.authBrandHighlightBook,
            StringConstants.authBrandHighlightManage,
            StringConstants.authBrandHighlightPlay,
          ],
          steps: _playerSteps,
          features: _playerFeatures,
          highlightDetails: const <String>[
            StringConstants.authBrandDetailBook,
            StringConstants.authBrandDetailManage,
            StringConstants.authBrandDetailPlay,
          ],
          highlightIcons: const <IconData>[
            Icons.near_me_rounded,
            Icons.event_available_rounded,
            Icons.sports_soccer_rounded,
          ],
        );
    }
  }
}

class AuthScreenFrame extends StatelessWidget {
  const AuthScreenFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.primaryButtonLabel,
    required this.onPrimaryTap,
    required this.secondaryPrefixText,
    required this.secondaryActionText,
    required this.onSecondaryTap,
    required this.formFields,
    this.primaryButtonIcon,
    this.primaryButtonEnabled = true,
    this.headerIcon = Icons.storefront_rounded,
    this.footer,
    this.isRotate = false,
    this.isLoading = false,
    this.audience = AuthAudience.general,
  });

  final String title;
  final String subtitle;
  final String primaryButtonLabel;
  final IconData? primaryButtonIcon;
  final VoidCallback? onPrimaryTap;
  final bool primaryButtonEnabled;
  final String secondaryPrefixText;
  final String secondaryActionText;
  final VoidCallback onSecondaryTap;
  final IconData headerIcon;
  final List<Widget> formFields;
  final Widget? footer;
  final bool isRotate;
  final bool isLoading;

  final AuthAudience audience;

  @override
  Widget build(BuildContext context) {
    // Two-pane split once there is room for it (tablet landscape, desktop
    // windows); the single centred column otherwise. The mobile branch is
    // byte-for-byte the pre-existing layout.
    if (context.isDesktop) {
      return Scaffold(
        // No SafeArea around the Row: the brand panel paints edge to edge,
        // top to bottom. Each pane applies its own inset instead.
        body: Row(
          // stretch, not the default center: otherwise each pane shrink-wraps
          // to its content height and the panel's colour stops short.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: _AuthBrandPanel(
                headerIcon: headerIcon,
                audience: audience,
              ),
            ),
            Expanded(child: SafeArea(child: _buildFormPane(context))),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _AuthBackground(),
          SafeArea(child: _buildFormPane(context)),
        ],
      ),
    );
  }

  Widget _buildFormPane(BuildContext context) {
    final bool wide = context.isTabletOrWider;
    return Center(
      child: SingleChildScrollView(
        padding: context.responsive<EdgeInsets>(
          mobile: const EdgeInsets.fromLTRB(
            AppDimens.paddingX20,
            AppDimens.paddingX24,
            AppDimens.paddingX20,
            AppDimens.paddingX20,
          ),
          tablet: const EdgeInsets.fromLTRB(
            AppDimens.paddingX32,
            AppDimens.paddingX40,
            AppDimens.paddingX32,
            AppDimens.paddingX32,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.responsive<double>(
              mobile: AppDimens.authCardMaxWidth,
              tablet: AppDimens.authCardMaxWidthTablet,
              desktop: AppDimens.authCardMaxWidthDesktop,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _AuthHeader(
                title: title,
                subtitle: subtitle,
                headerIcon: headerIcon,
                isRotate: isRotate,
                // The brand panel already shows the icon on desktop.
                showIcon: !context.isDesktop,
              ),
              SizedBox(height: wide ? AppDimens.sizeX24 : AppDimens.sizeX18),
              Container(
                padding: context.responsive<EdgeInsets>(
                  mobile: const EdgeInsets.fromLTRB(
                    AppDimens.paddingX20,
                    AppDimens.paddingX20,
                    AppDimens.paddingX20,
                    AppDimens.paddingX14,
                  ),
                  tablet: const EdgeInsets.fromLTRB(
                    AppDimens.paddingX32,
                    AppDimens.paddingX32,
                    AppDimens.paddingX32,
                    AppDimens.paddingX24,
                  ),
                ),
                decoration: BoxDecoration(
                  color: LightColor.whiteColor.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(
                    wide ? AppDimens.radiusX28 : AppDimens.radiusX20,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ...formFields,
                    SizedBox(
                      height: wide ? AppDimens.sizeX24 : AppDimens.sizeX18,
                    ),
                    CustomButton(
                      text: primaryButtonLabel,
                      minHeight: wide ? AppDimens.sizeX52 : AppDimens.sizeX44,
                      isLoading: isLoading,
                      backgroundColor: LightColor.buttonColor,
                      onPressed: primaryButtonEnabled ? onPrimaryTap : null,
                    ),
                    SizedBox(
                      height: wide ? AppDimens.sizeX24 : AppDimens.sizeX20,
                    ),
                    _buildSecondaryRow(context),
                    if (footer != null) ...<Widget>[
                      SizedBox(
                        height: wide ? AppDimens.sizeX14 : AppDimens.sizeX10,
                      ),
                      footer!,
                    ],
                    SizedBox(
                      height: wide ? AppDimens.sizeX14 : AppDimens.sizeX10,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryRow(BuildContext context) {
    final FutsalTextTheme theme = FutsalTheme.getTextTheme(context);
    final TextStyle? prefixStyle = theme.bodyTextSmall?.copyWith(
      color: LightColor.secondaryTextColor,
      // Fixed per-breakpoint size rather than `.sp`: the breakpoint already
      // encodes the step up, and stacking ScreenUtil's factor on top of it
      // overflows this row on wide layouts.
      fontSize: context.isTabletOrWider ? AppDimens.fontBodyTextLarge : null,
    );
    final TextStyle? actionStyle = theme.bodyTextSmall?.copyWith(
      color: LightColor.secondaryColor,
      // Fixed per-breakpoint size rather than `.sp`: the breakpoint already
      // encodes the step up, and stacking ScreenUtil's factor on top of it
      // overflows this row on wide layouts.
      fontSize: context.isTabletOrWider ? AppDimens.fontBodyTextLarge : null,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppDimens.sizeX6,
      runSpacing: AppDimens.sizeX4,
      children: <Widget>[
        Text(
          secondaryPrefixText,
          textAlign: TextAlign.center,
          style: prefixStyle,
        ),
        InkWell(
          onTap: onSecondaryTap,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX4,
              vertical: AppDimens.paddingX2,
            ),
            child: Text(
              secondaryActionText,
              textAlign: TextAlign.center,
              style: actionStyle?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({required this.headerIcon, required this.audience});

  final IconData headerIcon;
  final AuthAudience audience;

  static final Color _deep = Color.lerp(
    LightColor.secondaryColor,
    const Color(0xFF04140F),
    0.62,
  )!;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme theme = FutsalTheme.getTextTheme(context);
    final _AudienceCopy copy = _AudienceCopy.of(audience, headerIcon);
    final Color onBrand = LightColor.onBrandSurface;

    return DecoratedBox(
      key: const Key('auth-brand-panel'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[_deep, LightColor.secondaryColor],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Soft light, top right and bottom left.
          const Positioned(
            top: -160,
            right: -120,
            child: _Glow(size: 420, alpha: 0.16),
          ),
          const Positioned(
            bottom: -200,
            left: -140,
            child: _Glow(size: 460, alpha: 0.10),
          ),
          // The pitch, large and faint, running off the bottom right.
          const Positioned.fill(child: CustomPaint(painter: _PitchPainter())),
          // SafeArea here, not around the Row, so the colour still reaches
          // the screen edges behind the status and navigation bars.
          SafeArea(
            right: false,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                // Short windows (a 1280 × 800 laptop) tighten the spacing so
                // the longest copy still fits without scrolling.
                final bool compact = constraints.maxHeight < 880;
                // The extras (steps, chips) only where they fit unscrolled.
                final bool roomy = constraints.maxHeight >= 1000;
                final double gap = compact ? 24 : (roomy ? 44 : 28);
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        56,
                        compact ? 28 : 44,
                        56,
                        compact ? 24 : 36,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          _BrandMark(onBrand: onBrand, theme: theme),
                          SizedBox(height: gap),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            // Cross-fade when the account type changes, so
                            // the copy swaps rather than snapping.
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 320),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: _BrandPitch(
                                key: ValueKey<AuthAudience>(audience),
                                copy: copy,
                                theme: theme,
                                onBrand: onBrand,
                                compact: compact,
                                showExtras: !compact,
                                roomy: roomy,
                              ),
                            ),
                          ),
                          SizedBox(height: gap),
                          // Same column as the content, so both edges line up.
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: _BrandFooter(onBrand: onBrand, theme: theme),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({required this.onBrand, required this.theme});

  final Color onBrand;
  final FutsalTextTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: onBrand.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: onBrand.withValues(alpha: 0.22)),
          ),
          child: Icon(Icons.sports_soccer_rounded, color: onBrand, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          StringConstants.hamroFutsal,
          style: theme.bodyTextLarge?.copyWith(
            color: onBrand,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _BrandPitch extends StatelessWidget {
  const _BrandPitch({
    super.key,
    required this.copy,
    required this.theme,
    required this.onBrand,
    this.compact = false,
    this.showExtras = true,
    this.roomy = false,
  });

  final _AudienceCopy copy;
  final FutsalTextTheme theme;
  final Color onBrand;
  final bool compact;

  final bool showExtras;

  final bool roomy;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (copy.icon case final IconData emblem) ...<Widget>[
          Container(
            width: compact ? 48 : 64,
            height: compact ? 48 : 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  onBrand.withValues(alpha: 0.26),
                  onBrand.withValues(alpha: 0.08),
                ],
              ),
              border: Border.all(color: onBrand.withValues(alpha: 0.24)),
            ),
            child: Icon(emblem, color: onBrand, size: compact ? 24 : 30),
          ),
          SizedBox(height: compact ? 18 : 28),
        ],
        Text(
          copy.headline,
          style: theme.headingLarge?.copyWith(
            color: onBrand,
            fontWeight: FontWeight.w800,
            fontSize: compact ? 34 : (roomy ? 44 : 40),
            height: 1.08,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: compact ? 10 : 14),
        Text(
          copy.tagline,
          style: theme.bodyTextLarge?.copyWith(
            color: onBrand.withValues(alpha: 0.82),
            fontWeight: FontWeight.w500,
            fontSize: compact ? 16 : 18,
            height: 1.5,
          ),
        ),
        SizedBox(height: compact ? 20 : 32),
        _HighlightGroup(
          copy: copy,
          theme: theme,
          onBrand: onBrand,
          compact: compact,
        ),
        if (showExtras) ...<Widget>[
          SizedBox(height: roomy ? 32 : 22),
          _SectionTitle(StringConstants.authHowItWorks, onBrand, theme),
          const SizedBox(height: 12),
          _HowItWorks(steps: copy.steps, onBrand: onBrand, theme: theme),
        ],
        // The features are small enough to keep on short windows too.
        SizedBox(height: compact ? 18 : (roomy ? 28 : 20)),
        _SectionTitle(StringConstants.authAlsoInside, onBrand, theme),
        const SizedBox(height: 10),
        _FeatureChips(features: copy.features, onBrand: onBrand, theme: theme),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, this.onBrand, this.theme);

  final String text;
  final Color onBrand;
  final FutsalTextTheme theme;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: theme.bodyTextSmall?.copyWith(
        color: onBrand.withValues(alpha: 0.6),
        fontWeight: FontWeight.w700,
        fontSize: 11.5,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks({
    required this.steps,
    required this.onBrand,
    required this.theme,
  });

  final List<(IconData, String)> steps;
  final Color onBrand;
  final FutsalTextTheme theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (int i = 0; i < steps.length; i++) ...<Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: onBrand.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: onBrand.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(steps[i].$1, color: onBrand, size: 19),
                    ),
                    // The connector to the next step.
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[
                                onBrand.withValues(alpha: 0.35),
                                onBrand.withValues(alpha: 0.08),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Step ${i + 1}',
                  style: theme.bodyTextSmall?.copyWith(
                    color: onBrand.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w600,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  steps[i].$2,
                  style: theme.bodyTextSmall?.copyWith(
                    color: onBrand.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FeatureChips extends StatelessWidget {
  const _FeatureChips({
    required this.features,
    required this.onBrand,
    required this.theme,
  });

  final List<(IconData, String)> features;
  final Color onBrand;
  final FutsalTextTheme theme;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final (IconData icon, String label) in features)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: onBrand.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: onBrand.withValues(alpha: 0.16)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, color: onBrand.withValues(alpha: 0.85), size: 15),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.bodyTextSmall?.copyWith(
                    color: onBrand.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _HighlightGroup extends StatelessWidget {
  const _HighlightGroup({
    required this.copy,
    required this.theme,
    required this.onBrand,
    this.compact = false,
  });

  final _AudienceCopy copy;
  final FutsalTextTheme theme;
  final Color onBrand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < copy.highlights.length; i++) {
      final String? detail = i < copy.highlightDetails.length
          ? copy.highlightDetails[i]
          : null;
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 1,
            indent: compact ? 60 : 66,
            color: onBrand.withValues(alpha: 0.10),
          ),
        );
      }
      rows.add(
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: compact ? 11 : 14,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: compact ? 32 : 36,
                height: compact ? 32 : 36,
                decoration: BoxDecoration(
                  color: onBrand.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  copy.highlightIcons[i],
                  color: onBrand,
                  size: compact ? 17 : 19,
                ),
              ),
              SizedBox(width: compact ? 12 : 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      copy.highlights[i],
                      style: theme.bodyTextLarge?.copyWith(
                        color: onBrand,
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 14.5 : 15,
                        height: 1.3,
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: theme.bodyTextSmall?.copyWith(
                          color: onBrand.withValues(alpha: 0.66),
                          fontWeight: FontWeight.w500,
                          fontSize: compact ? 12.5 : 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: onBrand.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: onBrand.withValues(alpha: 0.13)),
      ),
      child: Column(children: rows),
    );
  }
}

class _BrandFooter extends StatelessWidget {
  const _BrandFooter({required this.onBrand, required this.theme});

  final Color onBrand;
  final FutsalTextTheme theme;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = theme.bodyTextSmall?.copyWith(
      color: onBrand.withValues(alpha: 0.6),
      fontWeight: FontWeight.w500,
    );
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            '© ${DateTime.now().year} ${StringConstants.hamroFutsal}'
            '  ·  ${StringConstants.yakStackSolution}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
        const SizedBox(width: 12),
        // Where the app runs.
        Tooltip(
          message: StringConstants.authWorksOn,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final IconData icon in const <IconData>[
                Icons.smartphone_rounded,
                Icons.tablet_mac_rounded,
                Icons.laptop_mac_rounded,
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(
                    icon,
                    size: 15,
                    color: onBrand.withValues(alpha: 0.55),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.alpha});

  final double size;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              LightColor.onBrandSurface.withValues(alpha: alpha),
              LightColor.onBrandSurface.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _PitchPainter extends CustomPainter {
  const _PitchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = LightColor.onBrandSurface.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // A 40 × 20 pitch, scaled to the panel and tucked into its lower right.
    final double width = size.width * 1.05;
    final double height = width / 2;
    canvas.save();
    canvas.translate(size.width * 0.62, size.height * 0.80);
    canvas.rotate(-0.22);
    final Rect pitch = Rect.fromCenter(
      center: Offset.zero,
      width: width,
      height: height,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(pitch, const Radius.circular(6)),
      line,
    );
    // Halfway line, centre circle and spot.
    canvas.drawLine(Offset(0, pitch.top), Offset(0, pitch.bottom), line);
    canvas.drawCircle(Offset.zero, height * 0.15, line);
    canvas.drawCircle(
      Offset.zero,
      3,
      Paint()..color = LightColor.onBrandSurface.withValues(alpha: 0.1),
    );
    // Penalty areas: quarter circles from each post, joined by a straight.
    final double r = height * 0.3;
    for (final double side in <double>[-1, 1]) {
      final double x = side * width / 2;
      final Path d = Path()
        ..moveTo(x, -r - height * 0.08)
        ..arcToPoint(
          Offset(x - side * r, -height * 0.08),
          radius: Radius.circular(r),
          clockwise: side > 0 ? false : true,
        )
        ..lineTo(x - side * r, height * 0.08)
        ..arcToPoint(
          Offset(x, r + height * 0.08),
          radius: Radius.circular(r),
          clockwise: side > 0 ? false : true,
        );
      canvas.drawPath(d, line);
      // Goal mouth.
      canvas.drawRect(
        Rect.fromLTRB(
          side > 0 ? x : x - 14,
          -height * 0.08,
          side > 0 ? x + 14 : x,
          height * 0.08,
        ),
        line,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PitchPainter oldDelegate) => false;
}

InputDecoration authInputDecoration({
  required BuildContext context,
  required String labelText,
  required IconData icon,
  String? hintText,
  Widget? suffixIcon,
}) {
  final ThemeData theme = Theme.of(context);
  final Color fillColor = LightColor.cardColor;

  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: 1.15),
    );
  }

  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: Icon(icon, color: LightColor.secondaryTextColor),
    suffixIcon: suffixIcon,
    floatingLabelBehavior: FloatingLabelBehavior.always,
    filled: true,
    fillColor: fillColor,
    labelStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.secondaryTextColor,
      fontSize: 13,
      fontWeight: FontWeight.w700,
    ),
    hintStyle: theme.textTheme.bodyMedium?.copyWith(
      color: LightColor.hintTextColor,
      fontSize: 13,
      fontWeight: FontWeight.w500,
    ),
    enabledBorder: border(LightColor.borderColor),
    focusedBorder: border(theme.colorScheme.secondary),
    border: border(LightColor.borderColor),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
  );
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({
    required this.title,
    required this.subtitle,
    required this.headerIcon,
    this.isRotate = false,
    this.showIcon = true,
  });

  final String title;
  final String subtitle;
  final IconData headerIcon;
  final bool isRotate;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final bool wide = context.isTabletOrWider;
    final double circleSize = wide ? AppDimens.sizeX72 : AppDimens.sizeX58;
    return Row(
      children: <Widget>[
        if (showIcon) ...<Widget>[
          Container(
            width: circleSize,
            height: circleSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  LightColor.secondaryColor,
                  LightColor.secondaryColor,
                  LightColor.secondaryDark,
                ],
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: LightColor.secondaryColor.withValues(alpha: 0.25),
                  blurRadius: AppDimens.radiusX18,
                  offset: const Offset(0, AppDimens.sizeX8),
                ),
              ],
            ),
            child: isRotate
                ? _RotatingIcon(headerIcon)
                : Icon(
                    headerIcon,
                    color: LightColor.onBrandSurface,
                    size: wide ? AppDimens.sizeX34 : AppDimens.sizeX28,
                  ),
          ),
          SizedBox(width: wide ? AppDimens.sizeX20 : AppDimens.sizeX14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: FutsalTheme.getTextTheme(context).headingSubTitle
                    ?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontSize: wide ? AppDimens.fontHeadingMedium : null,
                    ),
              ),
              SizedBox(height: wide ? AppDimens.sizeX6 : AppDimens.sizeX2),
              Text(
                subtitle,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: LightColor.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      fontSize: wide ? AppDimens.fontBodyTextLarge : null,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          top: -84,
          left: -52,
          child: _BackgroundBubble(
            size: AppDimens.sizeX190,
            colors: <Color>[LightColor.primarySoft, Color(0x1416A34A)],
          ),
        ),
        Positioned(
          top: 130,
          right: -70,
          child: _BackgroundBubble(
            size: AppDimens.sizeX230,
            colors: <Color>[LightColor.secondarySoft, Color(0x1410B981)],
          ),
        ),
        Positioned(
          bottom: -65,
          left: -40,
          child: _BackgroundBubble(
            size: AppDimens.sizeX170,
            colors: const <Color>[Color(0x1A14532D), Color(0x0F14532D)],
          ),
        ),
      ],
    );
  }
}

class _BackgroundBubble extends StatelessWidget {
  const _BackgroundBubble({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
      ),
    );
  }
}

class _RotatingIcon extends StatefulWidget {
  final IconData icon;
  const _RotatingIcon(this.icon);

  @override
  State<_RotatingIcon> createState() => _RotatingIconState();
}

class _RotatingIconState extends State<_RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: Icon(
            widget.icon,
            color: LightColor.onBrandSurface,
            size: AppDimens.sizeX34,
          ),
        );
      },
    );
  }
}
