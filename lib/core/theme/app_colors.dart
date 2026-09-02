import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_theme_colors.dart';
import 'package:hamro_futsal/core/theme/app_theme_controller.dart';

export 'package:hamro_futsal/core/theme/app_theme_colors.dart';

/// Brand palette + brightness-aware semantic aliases.
///
/// Anything that must flip between light and dark is a **getter** resolving
/// through [AppThemeColors]; only true brand constants stay `const`. Prefer
/// `context.appColors.<token>` in widgets — these statics exist for call sites
/// that have no [BuildContext] to hand.
class LightColor {
  LightColor._();

  // ---------------------------------------------------------------------------
  // Brand constants — identical in both themes.
  // ---------------------------------------------------------------------------
  static const Color yellowColor = Color(0xfff27819);
  static const Color secondaryColor = Color(0xff2c7969);
  static const Color secondaryLight = Color(0xff6FB3A5);
  static const Color secondaryLightMedium = Color(0xff9CCFC5);
  static const Color transparentColor = Colors.transparent;
  static const MaterialColor primarySwatch =
      MaterialColor(0xFF2C7969, <int, Color>{
        50: Color(0xFFE6F2EF),
        100: Color(0xFFBFDCD6),
        200: Color(0xFF95C4BB),
        300: Color(0xFF6BAC9F),
        400: Color(0xFF4C998A),
        500: Color(0xFF2C7969),
        600: Color(0xFF276F61),
        700: Color(0xFF216456),
        800: Color(0xFF1B5A4C),
        900: Color(0xFF11473A),
      });

  static const categorySelectionGredients = [
    Color(0xFF0D9E5C),
    Color(0xFF0B7A47),
  ];

  static AppThemeColors get _semantic => AppThemeController.instance.isDark
      ? AppThemeColors.dark
      : AppThemeColors.light;

  static bool get _isDark => AppThemeController.instance.isDark;

  // ---------------------------------------------------------------------------
  // Brand.
  // ---------------------------------------------------------------------------
  /// Brand FILL. Deliberately identical in both themes — a filled brand button
  /// should look the same everywhere, and white on it clears AA contrast.
  /// For a brand tone used as *text/icon on the page background*, where this
  /// green would be unreadable in dark mode, use [brandTextColor] instead.
  static Color get primaryColor => secondaryColor;
  static Color get buttonColor => primaryColor;
  static Color get successColor => _semantic.success;

  /// Foreground that stays legible on [primaryColor] / filled brand surfaces.
  static Color get inverseTextColor => _semantic.onAccent;

  /// Opaque near-white/near-black card surface. Historically `0xffFAFAFA`.
  static Color get whiteColor => _semantic.surfaceElevated;

  // ---------------------------------------------------------------------------
  // Surfaces & content.
  // ---------------------------------------------------------------------------
  static Color get background => _semantic.background;
  static Color get cardColor => _semantic.surface;
  static Color get elevatedCardColor => _semantic.surfaceElevated;
  static Color get sunkenColor => _semantic.surfaceSunken;

  static Color get primaryTextColor => _semantic.primaryText;
  static Color get secondaryTextColor => _semantic.secondaryText;
  static Color get hintTextColor => _semantic.hintText;
  static Color get disabledTextColor => _semantic.disabled;
  static Color get buttonDisabledColor => _semantic.disabled;
  static Color get iconGrey => _semantic.iconMuted;

  /// A QR code's ground stays light in BOTH themes — scanners rely on the
  /// contrast, and QR art with a transparent background vanishes on a dark
  /// surface. Content drawn on it must use [onQrSurface] / [onQrSurfaceMuted]
  /// rather than the theme's text tokens.
  static const Color qrSurface = Color(0xFFFFFFFF);
  static const Color onQrSurface = Color(0xFF14181A);
  static const Color onQrSurfaceMuted = Color(0xFF6B7280);

  /// Tint for supplied monochrome glyphs — the amenity/facility marks the API
  /// serves as flat single-colour art. They carry no hue of their own to
  /// preserve, so they invert with the ground: black on light, white on dark.
  static Color get monoIconColor =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  static Color get shadowColor => _semantic.shadow;
  static Color get scrimColor => _semantic.scrim;
  static Color get dividerColor => _semantic.divider;
  static Color get borderColor => _semantic.accentSoft;
  static Color get greyBorderColor => _semantic.border;

  static Color get inputFillColor => _semantic.inputFill;
  static Color get inputBorderColor => _semantic.inputBorder;
  static Color get inputFocusBorderColor => primaryColor;

  /// Drop shadow at a caller-tuned strength. Dark mode deepens the alpha,
  /// because a faint black shadow is invisible against a dark ground.
  static Color shadowOf(double alpha) =>
      Color.fromRGBO(0, 0, 0, _isDark ? (alpha * 2.2).clamp(0.0, 0.8) : alpha);

  static Color get skeletonBaseColor => _semantic.skeletonBase;
  static Color get skeletonHighlightColor => _semantic.skeletonHighlight;

  // ---------------------------------------------------------------------------
  // Status. Vivid token = text/icon/stroke; `*LightColor` = tinted fill.
  // ---------------------------------------------------------------------------
  static Color get redColor => _semantic.danger;
  static Color get redLightColor => _semantic.dangerContainer;
  static Color get onRedLightColor => _semantic.onDangerContainer;

  static Color get warningColor => _semantic.warning;
  static Color get warningLightColor => _semantic.warningContainer;
  static Color get onWarningLightColor => _semantic.onWarningContainer;

  static Color get blueColor => _semantic.info;
  static Color get blueLightColor => _semantic.infoContainer;
  static Color get onBlueLightColor => _semantic.onInfoContainer;

  static Color get purpleColor => _semantic.accentAlt;
  static Color get purpleLightColor => _semantic.accentAltContainer;

  static Color get greenLightColor => _semantic.successContainer;
  static Color get onGreenLightColor => _semantic.onSuccessContainer;

  static Color get ratingColor => _semantic.rating;

  // ---------------------------------------------------------------------------
  // Brand gradient stops. These stay saturated in BOTH themes — they paint
  // branded hero surfaces (profile headers, reward cards), not page chrome, so
  // they must not follow the page background. Foreground on top of them is
  // always [onBrandSurface], never [inverseTextColor].
  // ---------------------------------------------------------------------------
  static const Color secondaryDark = Color(0xFF059669);
  static const Color primaryDark = Color(0xFF14532D);

  /// Text/icon colour for content sitting on a brand gradient surface.
  static const Color onBrandSurface = Color(0xFFFFFFFF);

  /// Brand tone for *text/icons on the page background*.
  ///
  /// Light mode is the brand green itself, so swapping a foreground from
  /// [secondaryColor] to this token is a no-op there. Dark mode steps up to a
  /// light mint, because the brand green only manages ~3:1 on a dark surface.
  static Color get brandTextColor =>
      _isDark ? const Color(0xFF5FD3A6) : secondaryColor;

  static Color get secondarySoft => _semantic.accentSoft;
  static Color get primarySoft => _semantic.accentSoft;

  // ---------------------------------------------------------------------------
  // Categorical hues (amenity chips, expense categories, plan cards). Authors
  // pick one vivid brand-agnostic hue; these adapt it to the active brightness
  // instead of forcing every call site to maintain a second dark palette.
  // ---------------------------------------------------------------------------

  /// The hue, lightened in dark mode so it stays legible on a dark ground.
  static Color categoryAccent(Color base) {
    if (!_isDark) return base;
    final HSLColor hsl = HSLColor.fromColor(base);
    return hsl
        .withLightness(
          hsl.lightness.clamp(0.0, 1.0) < 0.62 ? 0.68 : hsl.lightness,
        )
        .withSaturation((hsl.saturation * 0.85).clamp(0.0, 1.0))
        .toColor();
  }

  /// For third-party brand marks (Facebook blue, YouTube red, …), whose hue is
  /// part of the brand and must survive theming. Only lifts colours that are
  /// genuinely too dark to read on the dark background — e.g. TikTok's black —
  /// and leaves every already-legible brand hue untouched.
  static Color brandSafe(Color base) {
    if (!_isDark) return base;
    final HSLColor hsl = HSLColor.fromColor(base);
    if (hsl.lightness >= 0.35) return base;
    return hsl.withLightness(0.72).toColor();
  }

  /// Tinted fill that pairs with [categoryAccent] for the same hue.
  static Color categoryContainer(Color base) {
    final HSLColor hsl = HSLColor.fromColor(base);
    return _isDark
        ? hsl.withLightness(0.16).withSaturation(0.34).toColor()
        : hsl.withLightness(0.93).withSaturation(0.55).toColor();
  }
}
