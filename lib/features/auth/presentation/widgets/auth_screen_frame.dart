import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/responsive.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

/// Who the auth screen is currently addressing.
///
/// Sign-in, forgot-password and OTP do not know yet, so they stay
/// [AuthAudience.general]. Registration switches as soon as an account type is
/// picked, so the brand panel argues the case for that specific audience.
enum AuthAudience { general, player, vendor }

/// Copy shown in the desktop brand panel for one [AuthAudience].
class _AudienceCopy {
  const _AudienceCopy({
    required this.headline,
    required this.tagline,
    required this.highlights,
    required this.icon,
  });

  final String headline;
  final String tagline;
  final List<String> highlights;
  final IconData icon;

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
        );
      case AuthAudience.general:
        return _AudienceCopy(
          headline: StringConstants.hamroFutsal,
          tagline: StringConstants.authBrandTagline,
          icon: fallbackIcon,
          highlights: const <String>[
            StringConstants.authBrandHighlightBook,
            StringConstants.authBrandHighlightManage,
            StringConstants.authBrandHighlightPlay,
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

  /// Drives the desktop brand panel's copy.
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

  /// The scrollable, width-capped form column. Shared by every breakpoint so
  /// the card itself only ever differs by its responsive metrics.
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Flexible(
          child: Text(
            secondaryPrefixText,
            overflow: TextOverflow.ellipsis,
            style: prefixStyle,
          ),
        ),
        const SizedBox(width: AppDimens.sizeX8),
        Flexible(
          child: InkWell(
            onTap: onSecondaryTap,
            child: Text(
              '$secondaryActionText ?',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: actionStyle,
            ),
          ),
        ),
      ],
    );
  }
}

/// Gradient marketing pane shown to the left of the form on wide layouts.
class _AuthBrandPanel extends StatelessWidget {
  const _AuthBrandPanel({required this.headerIcon, required this.audience});

  final IconData headerIcon;
  final AuthAudience audience;

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme theme = FutsalTheme.getTextTheme(context);
    final _AudienceCopy copy = _AudienceCopy.of(audience, headerIcon);
    return DecoratedBox(
      decoration: const BoxDecoration(color: LightColor.secondaryColor),
      // Content sits at the top of the pane and scrolls if the window is too
      // short for it. SafeArea here, not around the Row, so the colour still
      // reaches the screen edges behind the status and navigation bars.
      child: SafeArea(
        right: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX40,
              vertical: AppDimens.paddingX40,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              // Centre the capped block horizontally; its own text stays
              // left-aligned inside.
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Cap the text measure so lines stay readable and the
                // block reads as one tidy group on very wide windows.
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.authBrandPanelContentMaxWidth,
                  ),
                  // Cross-fade when the account type changes, so the copy
                  // swaps rather than snapping.
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: Column(
                      key: ValueKey<AuthAudience>(audience),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: AppDimens.sizeX72,
                          height: AppDimens.sizeX72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: LightColor.whiteColor.withValues(
                              alpha: 0.16,
                            ),
                          ),
                          child: Icon(
                            copy.icon,
                            color: LightColor.onBrandSurface,
                            size: AppDimens.sizeX34,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sizeX24),
                        Text(
                          copy.headline,
                          style: theme.headingLarge?.copyWith(
                            color: LightColor.onBrandSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: AppDimens.fontHeadingMedium,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sizeX10),
                        Text(
                          copy.tagline,
                          style: theme.bodyTextLarge?.copyWith(
                            color: LightColor.inverseTextColor.withValues(
                              alpha: 0.88,
                            ),
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                            fontSize: AppDimens.fontBodyTextLarge,
                          ),
                        ),
                        const SizedBox(height: AppDimens.sizeX28),
                        for (int i = 0; i < copy.highlights.length; i++) ...[
                          if (i > 0) const SizedBox(height: AppDimens.sizeX14),
                          Row(
                            children: <Widget>[
                              Icon(
                                Icons.check_circle_rounded,
                                color: LightColor.inverseTextColor.withValues(
                                  alpha: 0.9,
                                ),
                                size: AppDimens.sizeX18,
                              ),
                              const SizedBox(width: AppDimens.sizeX10),
                              Expanded(
                                child: Text(
                                  copy.highlights[i],
                                  style: theme.bodyTextLarge?.copyWith(
                                    color: LightColor.inverseTextColor.withValues(
                                      alpha: 0.92,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    fontSize: AppDimens.fontBodyTextMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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
