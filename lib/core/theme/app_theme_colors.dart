import 'package:flutter/material.dart';

/// Semantic colour tokens for the app, resolved per [Brightness].
///
/// Rules of thumb when adding a call site:
///  * Never reach for `Colors.white` / `Colors.black` / `Colors.grey` directly.
///  * Surfaces come from the elevation ramp: [background] < [surfaceSunken] <
///    [surface] < [surfaceElevated].
///  * Status colours come in pairs: the vivid token ([success], [warning],
///    [danger], [info]) is for text/icons/strokes, the `*Container` token is the
///    tinted fill behind it and `on*Container` is what sits on top of that fill.
///  * [onAccent] is the foreground for content on a brand-filled surface. The
///    brand fill is the same deep green in both themes, so this is white in
///    both. For a brand tone used as text/icon directly on the page background,
///    use `LightColor.brandTextColor`, which lightens in dark mode.
@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.surfaceSunken,
    required this.primaryText,
    required this.secondaryText,
    required this.hintText,
    required this.disabled,
    required this.divider,
    required this.border,
    required this.inputFill,
    required this.inputBorder,
    required this.shadow,
    required this.iconMuted,
    required this.onAccent,
    required this.accentSoft,
    required this.success,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.danger,
    required this.dangerContainer,
    required this.onDangerContainer,
    required this.info,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.accentAlt,
    required this.accentAltContainer,
    required this.rating,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.scrim,
  });

  // Surfaces / elevation ramp.
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color surfaceSunken;

  // Content.
  final Color primaryText;
  final Color secondaryText;
  final Color hintText;
  final Color disabled;
  final Color iconMuted;

  // Strokes.
  final Color divider;
  final Color border;

  // Inputs.
  final Color inputFill;
  final Color inputBorder;

  final Color shadow;

  /// Foreground for content on a brand-filled surface. White in both themes,
  /// because the brand fill itself is the same deep green in both.
  final Color onAccent;

  /// Low-emphasis brand tint, for selected chips and highlight rows.
  final Color accentSoft;

  // Status: vivid / container / on-container triplets.
  final Color success;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color danger;
  final Color dangerContainer;
  final Color onDangerContainer;

  final Color info;
  final Color infoContainer;
  final Color onInfoContainer;

  /// Secondary decorative accent (used for rewards / promo surfaces).
  final Color accentAlt;
  final Color accentAltContainer;

  final Color rating;

  // Shimmer / skeleton loaders.
  final Color skeletonBase;
  final Color skeletonHighlight;

  /// Barrier behind modals and image overlays.
  final Color scrim;

  static const AppThemeColors light = AppThemeColors(
    background: Color(0xffF4F4F8),
    surface: Color(0xffFAFAFA),
    surfaceElevated: Color(0xFFFFFFFF),
    surfaceSunken: Color(0xFFECEDF2),
    primaryText: Color(0xff252534),
    secondaryText: Color(0xff6B6B7A),
    hintText: Color(0xff9EA0B0),
    disabled: Color(0xffC2C4D0),
    divider: Color(0xffE5E7EB),
    border: Color(0xFFE8ECF0),
    inputFill: Color(0xffF1F2F6),
    inputBorder: Color(0xffDADCE0),
    shadow: Color.fromRGBO(0, 0, 0, 0.04),
    iconMuted: Color(0xFFB0B7C3),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0x1A2C7969),
    success: Color(0xFF1E7A5F),
    successContainer: Color(0xFFE3F4EE),
    onSuccessContainer: Color(0xFF10503D),
    warning: Color(0xFFB26A00),
    warningContainer: Color(0xFFFFF3DC),
    onWarningContainer: Color(0xFF7A4A00),
    danger: Color(0xffD32F2F),
    dangerContainer: Color(0xFFFDE7E7),
    onDangerContainer: Color(0xFF8E1B1B),
    info: Color(0xFF2563EB),
    infoContainer: Color(0xFFEFF6FF),
    onInfoContainer: Color(0xFF1B47A8),
    accentAlt: Color(0xFF7C3AED),
    accentAltContainer: Color(0xFFF5EEFF),
    rating: Color(0xffF27819),
    skeletonBase: Color(0xFFE4E6EC),
    skeletonHighlight: Color(0xFFF4F5F8),
    scrim: Color.fromRGBO(0, 0, 0, 0.45),
  );

  /// OLED-first: a true-black ground with slightly lifted surfaces above it.
  /// The black is deliberate — do not raise it to a dark grey.
  static const AppThemeColors dark = AppThemeColors(
    background: Color(0xFF000000),
    surface: Color(0xFF101311),
    surfaceElevated: Color(0xFF171B18),
    surfaceSunken: Color(0xFF000000),
    primaryText: Color(0xFFF5F7F5),
    secondaryText: Color(0xFFAEB8B2),
    hintText: Color(0xFF818B84),
    disabled: Color(0xFF59615C),
    divider: Color(0xFF2A302C),
    border: Color(0xFF343B36),
    inputFill: Color(0xFF161A17),
    inputBorder: Color(0xFF343B36),
    shadow: Color.fromRGBO(0, 0, 0, 0.45),
    iconMuted: Color(0xFF818B84),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0x336FB3A5),
    success: Color(0xFF6FD3B0),
    successContainer: Color(0xFF12302A),
    onSuccessContainer: Color(0xFFA9EBD4),
    warning: Color(0xFFF0B45C),
    warningContainer: Color(0xFF33260F),
    onWarningContainer: Color(0xFFF8D9A6),
    danger: Color(0xFFFF9E96),
    dangerContainer: Color(0xFF3A1A18),
    onDangerContainer: Color(0xFFFFC8C3),
    info: Color(0xFF7EA9FF),
    infoContainer: Color(0xFF16233D),
    onInfoContainer: Color(0xFFBFD3FF),
    accentAlt: Color(0xFFB794FF),
    accentAltContainer: Color(0xFF241A38),
    rating: Color(0xFFFFA94D),
    skeletonBase: Color(0xFF1E2522),
    skeletonHighlight: Color(0xFF2A322E),
    scrim: Color.fromRGBO(0, 0, 0, 0.65),
  );

  @override
  AppThemeColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? surfaceSunken,
    Color? primaryText,
    Color? secondaryText,
    Color? hintText,
    Color? disabled,
    Color? divider,
    Color? border,
    Color? inputFill,
    Color? inputBorder,
    Color? shadow,
    Color? iconMuted,
    Color? onAccent,
    Color? accentSoft,
    Color? success,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? danger,
    Color? dangerContainer,
    Color? onDangerContainer,
    Color? info,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? accentAlt,
    Color? accentAltContainer,
    Color? rating,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? scrim,
  }) => AppThemeColors(
    background: background ?? this.background,
    surface: surface ?? this.surface,
    surfaceElevated: surfaceElevated ?? this.surfaceElevated,
    surfaceSunken: surfaceSunken ?? this.surfaceSunken,
    primaryText: primaryText ?? this.primaryText,
    secondaryText: secondaryText ?? this.secondaryText,
    hintText: hintText ?? this.hintText,
    disabled: disabled ?? this.disabled,
    divider: divider ?? this.divider,
    border: border ?? this.border,
    inputFill: inputFill ?? this.inputFill,
    inputBorder: inputBorder ?? this.inputBorder,
    shadow: shadow ?? this.shadow,
    iconMuted: iconMuted ?? this.iconMuted,
    onAccent: onAccent ?? this.onAccent,
    accentSoft: accentSoft ?? this.accentSoft,
    success: success ?? this.success,
    successContainer: successContainer ?? this.successContainer,
    onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
    warning: warning ?? this.warning,
    warningContainer: warningContainer ?? this.warningContainer,
    onWarningContainer: onWarningContainer ?? this.onWarningContainer,
    danger: danger ?? this.danger,
    dangerContainer: dangerContainer ?? this.dangerContainer,
    onDangerContainer: onDangerContainer ?? this.onDangerContainer,
    info: info ?? this.info,
    infoContainer: infoContainer ?? this.infoContainer,
    onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    accentAlt: accentAlt ?? this.accentAlt,
    accentAltContainer: accentAltContainer ?? this.accentAltContainer,
    rating: rating ?? this.rating,
    skeletonBase: skeletonBase ?? this.skeletonBase,
    skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
    scrim: scrim ?? this.scrim,
  );

  @override
  AppThemeColors lerp(covariant AppThemeColors? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppThemeColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      surfaceElevated: l(surfaceElevated, other.surfaceElevated),
      surfaceSunken: l(surfaceSunken, other.surfaceSunken),
      primaryText: l(primaryText, other.primaryText),
      secondaryText: l(secondaryText, other.secondaryText),
      hintText: l(hintText, other.hintText),
      disabled: l(disabled, other.disabled),
      divider: l(divider, other.divider),
      border: l(border, other.border),
      inputFill: l(inputFill, other.inputFill),
      inputBorder: l(inputBorder, other.inputBorder),
      shadow: l(shadow, other.shadow),
      iconMuted: l(iconMuted, other.iconMuted),
      onAccent: l(onAccent, other.onAccent),
      accentSoft: l(accentSoft, other.accentSoft),
      success: l(success, other.success),
      successContainer: l(successContainer, other.successContainer),
      onSuccessContainer: l(onSuccessContainer, other.onSuccessContainer),
      warning: l(warning, other.warning),
      warningContainer: l(warningContainer, other.warningContainer),
      onWarningContainer: l(onWarningContainer, other.onWarningContainer),
      danger: l(danger, other.danger),
      dangerContainer: l(dangerContainer, other.dangerContainer),
      onDangerContainer: l(onDangerContainer, other.onDangerContainer),
      info: l(info, other.info),
      infoContainer: l(infoContainer, other.infoContainer),
      onInfoContainer: l(onInfoContainer, other.onInfoContainer),
      accentAlt: l(accentAlt, other.accentAlt),
      accentAltContainer: l(accentAltContainer, other.accentAltContainer),
      rating: l(rating, other.rating),
      skeletonBase: l(skeletonBase, other.skeletonBase),
      skeletonHighlight: l(skeletonHighlight, other.skeletonHighlight),
      scrim: l(scrim, other.scrim),
    );
  }
}

extension AppThemeContext on BuildContext {
  AppThemeColors get appColors =>
      Theme.of(this).extension<AppThemeColors>() ?? AppThemeColors.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
