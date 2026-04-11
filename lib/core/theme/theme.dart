// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// import 'app_colors.dart';

// class AppTheme {
//   AppTheme._();

//   static const ColorScheme _colorScheme = ColorScheme(
//     brightness: Brightness.light,
//     primary: LightColor.secondaryColor,
//     onPrimary: LightColor.whiteColor,
//     secondary: LightColor.secondaryColor,
//     onSecondary: LightColor.whiteColor,
//     error: LightColor.redColor,
//     onError: LightColor.whiteColor,
//     surface: LightColor.cardColor,
//     onSurface: LightColor.primaryTextColor,
//   );

//   static TextTheme _buildTextTheme() {
//     final TextTheme base = GoogleFonts.mulishTextTheme();
//     return base.copyWith(
//       displayLarge: base.displayLarge?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -1.2,
//       ),
//       displayMedium: base.displayMedium?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -0.9,
//       ),
//       displaySmall: base.displaySmall?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -0.6,
//       ),
//       headlineLarge: base.headlineLarge?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -0.6,
//       ),
//       headlineMedium: base.headlineMedium?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -0.5,
//       ),
//       headlineSmall: base.headlineSmall?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//         letterSpacing: -0.3,
//       ),
//       titleLarge: base.titleLarge?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w800,
//       ),
//       titleMedium: base.titleMedium?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w700,
//       ),
//       titleSmall: base.titleSmall?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w700,
//       ),
//       bodyLarge: base.bodyLarge?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w600,
//         height: 1.5,
//       ),
//       bodyMedium: base.bodyMedium?.copyWith(
//         color: LightColor.secondaryTextColor,
//         fontWeight: FontWeight.w500,
//         height: 1.45,
//       ),
//       bodySmall: base.bodySmall?.copyWith(
//         color: LightColor.hintTextColor,
//         fontWeight: FontWeight.w500,
//         height: 1.4,
//       ),
//       labelLarge: base.labelLarge?.copyWith(
//         color: LightColor.primaryTextColor,
//         fontWeight: FontWeight.w700,
//         letterSpacing: 0.1,
//       ),
//       labelMedium: base.labelMedium?.copyWith(
//         color: LightColor.secondaryTextColor,
//         fontWeight: FontWeight.w600,
//       ),
//       labelSmall: base.labelSmall?.copyWith(
//         color: LightColor.hintTextColor,
//         fontWeight: FontWeight.w600,
//       ),
//     );
//   }

//   static final ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     colorScheme: _colorScheme.copyWith(
//       outline: LightColor.borderColor,
//       outlineVariant: LightColor.dividerColor,
//       surfaceContainerHighest: LightColor.inputFillColor,
//       shadow: LightColor.shadowColor.withValues(alpha: 0.12),
//     ),
//     scaffoldBackgroundColor: LightColor.background,
//     canvasColor: LightColor.background,
//     splashColor: LightColor.primarySoft,
//     highlightColor: LightColor.primarySoft,
//     disabledColor: LightColor.disabledTextColor,
//     dividerColor: LightColor.dividerColor,
//     textTheme: _buildTextTheme(),
//     cardTheme: const CardThemeData(
//       color: LightColor.cardColor,
//       surfaceTintColor: Colors.transparent,
//       elevation: 0,
//     ),
//     appBarTheme: const AppBarTheme(
//       backgroundColor: LightColor.cardColor,
//       foregroundColor: LightColor.primaryTextColor,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       centerTitle: false,
//       iconTheme: IconThemeData(color: LightColor.primaryTextColor),
//       titleTextStyle: TextStyle(
//         color: LightColor.primaryTextColor,
//         fontSize: 20,
//         fontWeight: FontWeight.w800,
//       ),
//     ),
//     iconTheme: const IconThemeData(color: LightColor.secondaryTextColor),
//     primaryIconTheme: const IconThemeData(color: LightColor.whiteColor),
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: LightColor.cardColor,
//       hintStyle: _buildTextTheme().bodyMedium?.copyWith(
//         color: LightColor.hintTextColor,
//       ),
//       labelStyle: _buildTextTheme().labelMedium?.copyWith(
//         color: LightColor.secondaryTextColor,
//       ),
//       floatingLabelStyle: _buildTextTheme().labelMedium?.copyWith(
//         color: LightColor.secondaryColor,
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: LightColor.borderColor),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: LightColor.borderColor),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: LightColor.secondaryColor, width: 1.2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: LightColor.redColor),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(14),
//         borderSide: const BorderSide(color: LightColor.redColor, width: 1.2),
//       ),
//     ),
//     chipTheme: ChipThemeData(
//       backgroundColor: LightColor.inputFillColor,
//       disabledColor: LightColor.dividerColor,
//       selectedColor: LightColor.secondarySoft,
//       secondarySelectedColor: LightColor.secondarySoft,
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       labelStyle: _buildTextTheme().labelMedium!,
//       secondaryLabelStyle: _buildTextTheme().labelMedium!.copyWith(
//         color: LightColor.secondaryDark,
//       ),
//       side: const BorderSide(color: LightColor.borderColor),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
//     ),
//     dialogTheme: DialogThemeData(
//       backgroundColor: LightColor.cardColor,
//       surfaceTintColor: Colors.transparent,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       titleTextStyle: _buildTextTheme().titleLarge,
//       contentTextStyle: _buildTextTheme().bodyMedium,
//     ),
//     bottomSheetTheme: const BottomSheetThemeData(
//       backgroundColor: LightColor.cardColor,
//       surfaceTintColor: Colors.transparent,
//     ),
//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: LightColor.secondaryColor,
//         textStyle: _buildTextTheme().labelLarge,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       ),
//     ),
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: LightColor.secondaryColor,
//         foregroundColor: LightColor.whiteColor,
//         elevation: 0,
//         textStyle: _buildTextTheme().labelLarge?.copyWith(
//           color: LightColor.whiteColor,
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       ),
//     ),
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: LightColor.primaryTextColor,
//         side: const BorderSide(color: LightColor.borderColor),
//         textStyle: _buildTextTheme().labelLarge,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//       ),
//     ),
//   );

//   static const TextStyle titleStyle = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 16,
//     fontWeight: FontWeight.w700,
//   );
//   static const TextStyle subTitleStyle = TextStyle(
//     color: LightColor.secondaryTextColor,
//     fontSize: 12,
//     height: 1.45,
//   );

//   static const TextStyle h1Style = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 24,
//     fontWeight: FontWeight.w800,
//   );
//   static const TextStyle h2Style = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 22,
//     fontWeight: FontWeight.w800,
//   );
//   static const TextStyle h3Style = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 20,
//     fontWeight: FontWeight.w700,
//   );
//   static const TextStyle h4Style = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 18,
//     fontWeight: FontWeight.w700,
//   );
//   static const TextStyle h5Style = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 16,
//     fontWeight: FontWeight.w700,
//   );
//   static const TextStyle h6Style = TextStyle(
//     color: LightColor.primaryTextColor,
//     fontSize: 14,
//     fontWeight: FontWeight.w700,
//   );

//   static const List<BoxShadow> shadow = <BoxShadow>[
//     BoxShadow(
//       color: Color(0x120F2240),
//       blurRadius: 18,
//       offset: Offset(0, 8),
//       spreadRadius: 1,
//     ),
//   ];

//   static const EdgeInsets padding = EdgeInsets.symmetric(
//     horizontal: 20,
//     vertical: 10,
//   );
//   static const EdgeInsets hPadding = EdgeInsets.symmetric(horizontal: 10);

//   static double fullWidth(BuildContext context) {
//     return MediaQuery.of(context).size.width;
//   }

//   static double fullHeight(BuildContext context) {
//     return MediaQuery.of(context).size.height;
//   }
// }
