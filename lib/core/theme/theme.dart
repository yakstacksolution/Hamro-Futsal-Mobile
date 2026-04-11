import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static const ColorScheme _colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: LightColor.primary,
    onPrimary: LightColor.white,
    secondary: LightColor.secondary,
    onSecondary: LightColor.white,
    error: LightColor.red,
    onError: LightColor.white,
    surface: LightColor.surface,
    onSurface: LightColor.titleText,
  );

  static TextTheme _buildTextTheme() {
    final TextTheme base = GoogleFonts.mulishTextTheme();
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
      ),
      displayMedium: base.displayMedium?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.9,
      ),
      displaySmall: base.displaySmall?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineLarge: base.headlineLarge?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w700,
      ),
      titleSmall: base.titleSmall?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w600,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: LightColor.subtitleText,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: LightColor.hintText,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: LightColor.titleText,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.1,
      ),
      labelMedium: base.labelMedium?.copyWith(
        color: LightColor.subtitleText,
        fontWeight: FontWeight.w600,
      ),
      labelSmall: base.labelSmall?.copyWith(
        color: LightColor.hintText,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme.copyWith(
      outline: LightColor.border,
      outlineVariant: LightColor.divider,
      surfaceContainerHighest: LightColor.surfaceSubtle,
      shadow: LightColor.shadow.withValues(alpha: 0.12),
    ),
    scaffoldBackgroundColor: LightColor.background,
    canvasColor: LightColor.background,
    splashColor: LightColor.primarySoft,
    highlightColor: LightColor.primarySoft,
    disabledColor: LightColor.mutedText,
    dividerColor: LightColor.divider,
    textTheme: _buildTextTheme(),
    cardTheme: const CardThemeData(
      color: LightColor.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: LightColor.surface,
      foregroundColor: LightColor.titleText,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: LightColor.titleText),
      titleTextStyle: TextStyle(
        color: LightColor.titleText,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    iconTheme: const IconThemeData(color: LightColor.icon),
    primaryIconTheme: const IconThemeData(color: LightColor.white),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: LightColor.surface,
      hintStyle: _buildTextTheme().bodyMedium?.copyWith(
        color: LightColor.hintText,
      ),
      labelStyle: _buildTextTheme().labelMedium?.copyWith(
        color: LightColor.subtitleText,
      ),
      floatingLabelStyle: _buildTextTheme().labelMedium?.copyWith(
        color: LightColor.primary,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColor.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColor.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColor.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColor.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: LightColor.red, width: 1.2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: LightColor.surfaceSubtle,
      disabledColor: LightColor.divider,
      selectedColor: LightColor.secondarySoft,
      secondarySelectedColor: LightColor.secondarySoft,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      labelStyle: _buildTextTheme().labelMedium!,
      secondaryLabelStyle: _buildTextTheme().labelMedium!.copyWith(
        color: LightColor.secondaryDark,
      ),
      side: const BorderSide(color: LightColor.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: LightColor.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: _buildTextTheme().titleLarge,
      contentTextStyle: _buildTextTheme().bodyMedium,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: LightColor.surface,
      surfaceTintColor: Colors.transparent,
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: LightColor.secondary,
        textStyle: _buildTextTheme().labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColor.secondary,
        foregroundColor: LightColor.white,
        elevation: 0,
        textStyle: _buildTextTheme().labelLarge?.copyWith(
          color: LightColor.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: LightColor.titleText,
        side: const BorderSide(color: LightColor.border),
        textStyle: _buildTextTheme().labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
  );

  static const TextStyle titleStyle = TextStyle(
    color: LightColor.titleText,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle subTitleStyle = TextStyle(
    color: LightColor.subtitleText,
    fontSize: 12,
    height: 1.45,
  );

  static const TextStyle h1Style = TextStyle(
    color: LightColor.titleText,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle h2Style = TextStyle(
    color: LightColor.titleText,
    fontSize: 22,
    fontWeight: FontWeight.w800,
  );
  static const TextStyle h3Style = TextStyle(
    color: LightColor.titleText,
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h4Style = TextStyle(
    color: LightColor.titleText,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h5Style = TextStyle(
    color: LightColor.titleText,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle h6Style = TextStyle(
    color: LightColor.titleText,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  static const List<BoxShadow> shadow = <BoxShadow>[
    BoxShadow(
      color: Color(0x120F2240),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: 1,
    ),
  ];

  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  );
  static const EdgeInsets hPadding = EdgeInsets.symmetric(horizontal: 10);

  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
