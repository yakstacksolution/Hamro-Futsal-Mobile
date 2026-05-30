import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class FutsalTheme {
  static ThemeData setTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      primaryColor: LightColor.secondaryColor,
      primarySwatch: LightColor.primarySwatch,
      scaffoldBackgroundColor: LightColor.background,
      cardColor: LightColor.cardColor,
      dividerColor: LightColor.dividerColor,

      textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

      textSelectionTheme: TextSelectionThemeData(
        selectionColor: LightColor.secondaryColor.withValues(alpha: 0.3),
        selectionHandleColor: LightColor.secondaryColor,
      ),

      bottomAppBarTheme: BottomAppBarThemeData(
        color: LightColor.cardColor,
        elevation: 10,
        shadowColor: LightColor.shadowColor,
        surfaceTintColor: Colors.transparent,
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LightColor.cardColor,

        selectedItemColor: LightColor.secondaryColor,
        unselectedItemColor: LightColor.secondaryTextColor,

        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: LightColor.secondaryColor,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: LightColor.secondaryTextColor,
        ),

        selectedIconTheme: IconThemeData(
          color: LightColor.secondaryColor,
          size: 24,
        ),
        unselectedIconTheme: IconThemeData(
          color: LightColor.secondaryTextColor,
          size: 22,
        ),

        showUnselectedLabels: true,

        elevation: 12,

        type: BottomNavigationBarType.fixed,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: LightColor.background,
        centerTitle: true,
        iconTheme: IconThemeData(color: LightColor.primaryTextColor),
        titleTextStyle: GoogleFonts.poppins(
          textStyle: getTextTheme(context).headingSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: LightColor.primaryTextColor,
          ),
        ),
      ),

      elevatedButtonTheme: getElevatedButtonTheme(context),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightColor.inputFillColor,
        hintStyle: TextStyle(color: LightColor.hintTextColor),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          borderSide: BorderSide(color: LightColor.inputBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          borderSide: BorderSide(color: LightColor.inputBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          borderSide: BorderSide(color: LightColor.inputFocusBorderColor),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: LightColor.redColor,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),

      iconTheme: IconThemeData(color: LightColor.secondaryTextColor),

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
    backgroundColor ??= LightColor.buttonColor;
    radius ??= AppDimens.radiusX8;
    fontSize ??= AppDimens.fontBodyTextLarge;

    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: LightColor.buttonDisabledColor,
        foregroundColor: LightColor.inverseTextColor,
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
    textColor ??= LightColor.primaryTextColor;

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
