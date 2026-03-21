import 'package:flutter/material.dart';

import 'light_color.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: LightColor.skyBlue,
          brightness: Brightness.light,
        ).copyWith(
          primary: LightColor.skyBlue,
          onPrimary: Colors.white,
          secondary: LightColor.secondaryGreen,
          onSecondary: Colors.white,
          surface: LightColor.surface,
          onSurface: LightColor.titleTextColor,
          error: LightColor.red,
          onError: Colors.white,
          outline: LightColor.lightGrey,
        ),
    scaffoldBackgroundColor: LightColor.background,
    dividerColor: LightColor.lightGrey,
    cardTheme: const CardThemeData(
      color: LightColor.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    iconTheme: const IconThemeData(color: LightColor.iconColor),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
        color: LightColor.titleTextColor,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: LightColor.titleTextColor),
      titleMedium: TextStyle(color: LightColor.titleTextColor, fontSize: 16),
      bodyMedium: TextStyle(color: LightColor.subTitleTextColor, fontSize: 12),
      bodySmall: TextStyle(color: LightColor.darkgrey),
    ),
    primaryTextTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: LightColor.skyBlue),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: LightColor.skyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );

  static const TextStyle titleStyle = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 16,
  );
  static const TextStyle subTitleStyle = TextStyle(
    color: LightColor.subTitleTextColor,
    fontSize: 12,
  );

  static const TextStyle h1Style = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle h2Style = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 22,
  );
  static const TextStyle h3Style = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 20,
  );
  static const TextStyle h4Style = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 18,
  );
  static const TextStyle h5Style = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 16,
  );
  static const TextStyle h6Style = TextStyle(
    color: LightColor.titleTextColor,
    fontSize: 14,
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
