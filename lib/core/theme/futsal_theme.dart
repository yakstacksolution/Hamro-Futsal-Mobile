import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

class FutsalTheme {
  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final bool dark = brightness == Brightness.dark;
    final AppThemeColors colors = dark
        ? AppThemeColors.dark
        : AppThemeColors.light;
    // `primary` is the brand FILL: identical in both themes so a filled button
    // looks the same everywhere, with white on top (AA contrast).
    final Color primary = LightColor.secondaryColor;
    final Color onPrimary = colors.onAccent;
    // `accent` is the brand tone used as a foreground ON the page background —
    // tabs, indicators, focus rings. The deep green is unreadable on a dark
    // ground, so dark mode steps up to the light tint.
    final Color accent = dark ? LightColor.secondaryLight : primary;
    final ColorScheme colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: primary,
      onSecondary: onPrimary,
      error: colors.danger,
      onError: colors.onDangerContainer,
      surface: colors.surface,
      onSurface: colors.primaryText,
    );
    final TextTheme textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: colors.primaryText, displayColor: colors.primaryText);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      primaryColor: primary,
      primarySwatch: LightColor.primarySwatch,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      cardColor: colors.surface,
      dividerColor: colors.divider,
      disabledColor: colors.disabled,
      shadowColor: colors.shadow,
      extensions: <ThemeExtension<dynamic>>[colors],
      textTheme: textTheme,

      textSelectionTheme: TextSelectionThemeData(
        selectionColor: accent.withValues(alpha: 0.3),
        selectionHandleColor: accent,
      ),

      bottomAppBarTheme: BottomAppBarThemeData(
        color: colors.surface,
        elevation: 10,
        shadowColor: colors.shadow,
        surfaceTintColor: Colors.transparent,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: accent,
        unselectedItemColor: colors.secondaryText,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: accent,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: colors.secondaryText,
        ),
        selectedIconTheme: IconThemeData(color: accent, size: 24),
        unselectedIconTheme: IconThemeData(
          color: colors.secondaryText,
          size: 22,
        ),
        showUnselectedLabels: true,
        elevation: 12,
        type: BottomNavigationBarType.fixed,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: colors.background,
        foregroundColor: colors.primaryText,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        iconTheme: IconThemeData(color: colors.primaryText),
        titleTextStyle: GoogleFonts.poppins(
          textStyle: textTheme.headlineSmall?.copyWith(
            fontSize: AppDimens.fontHeadingSmall,
            fontWeight: FontWeight.w600,
            color: colors.primaryText,
          ),
        ),
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        modalBackgroundColor: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.primaryText,
        iconColor: colors.secondaryText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.inputFill,
        hintStyle: TextStyle(color: colors.hintText),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          borderSide: BorderSide(color: colors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          borderSide: BorderSide(color: accent, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: colors.disabled,
          foregroundColor: onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          ),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? onPrimary
              : colors.iconMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? primary : colors.divider,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll<Color>(onPrimary),
        side: BorderSide(color: colors.border),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: accent,
        unselectedLabelColor: colors.secondaryText,
        indicatorColor: accent,
        dividerColor: colors.divider,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceElevated,
        selectedColor: accent.withValues(alpha: 0.2),
        disabledColor: colors.inputFill,
        side: BorderSide(color: colors.border),
        labelStyle: TextStyle(color: colors.primaryText),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.dangerContainer,
        contentTextStyle: TextStyle(
          color: colors.onDangerContainer,
          fontWeight: FontWeight.w500,
        ),
      ),
      iconTheme: IconThemeData(color: colors.secondaryText),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  static ElevatedButtonThemeData getElevatedButtonTheme(
    BuildContext context, {
    Color? backgroundColor,
    double? radius,
    double? fontSize,
  }) {
    backgroundColor ??= Theme.of(context).colorScheme.primary;
    radius ??= AppDimens.radiusX8;
    fontSize ??= AppDimens.fontBodyTextLarge;

    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: context.appColors.disabled,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        textStyle: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(fontSize: fontSize),
      ),
    );
  }

  static FutsalTextTheme getTextTheme(
    BuildContext context, {
    Color? textColor,
  }) {
    textColor ??= context.appColors.primaryText;

    return FutsalTextTheme(
      bodyMiniSubTitle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: AppDimens.fontBodyMiniSubTitle,
        color: textColor,
      ),
      bodySubTitle: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: AppDimens.fontBodySubTitle,
        color: textColor,
      ),
      bodyTextSmall: Theme.of(context).textTheme.bodySmall?.copyWith(
        fontSize: AppDimens.fontBodyTextSmall,
        color: textColor,
      ),
      bodyTextMedium: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: AppDimens.fontBodyTextMedium,
        color: textColor,
      ),
      bodyTextLarge: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: AppDimens.fontBodyTextLarge,
        color: textColor,
      ),
      headingSubTitle: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: AppDimens.fontHeadingSubTitle,
        color: textColor,
      ),
      headingSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: AppDimens.fontHeadingSmall,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headingXSmall: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontSize: AppDimens.fontHeadingXSmall,
        color: textColor,
      ),
      headingMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontSize: AppDimens.fontHeadingMedium,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      headingLarge: Theme.of(context).textTheme.headlineLarge?.copyWith(
        fontSize: AppDimens.fontHeadingLarge,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }
}
