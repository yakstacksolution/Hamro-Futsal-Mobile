import 'package:flutter/material.dart';

class LightColor {
  LightColor._();

  // ── Neutral Surfaces ──────────────────────────────────────────────────────
  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // ── Primary Brand — Green (Sports Optimized) ───────────────────────────────
  static const Color primary = Color(0xFF16A34A); // Main CTA
  static const Color primaryLight = Color(0xFF22C55E); // Active / highlight
  static const Color primaryDark = Color(0xFF14532D); // Header / pressed

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFFD1FAE5);
  static const Color secondaryDark = Color(0xFF059669);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color accent = Color(0xFF14532D); // deep green (premium feel)

  // ── Status / Semantic ─────────────────────────────────────────────────────
  static const Color amber = Color(0xFFFACC15); // energy (book now)
  static const Color red = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);

  // ── Feature Chips ─────────────────────────────────────────────────────────
  static const Color chipIndoorBg = Color(0xFFECFDF5);
  static const Color chipIndoorText = Color(0xFF15803D);

  static const Color chipOutdoorBg = Color(0xFFFEF3C7);
  static const Color chipOutdoorText = Color(0xFF92400E);

  static const Color chipParkingBg = Color(0xFFE0F2FE);
  static const Color chipParkingText = Color(0xFF0369A1);

  static const Color chipLightsBg = Color(0xFFFFF7ED);
  static const Color chipLightsText = Color(0xFFB45309);

  static const Color chipTurfBg = Color(0xFFD1FAE5);
  static const Color chipTurfText = Color(0xFF065F46);

  static const Color chipShowerBg = Color(0xFFE0F2FE);
  static const Color chipShowerText = Color(0xFF0284C7);

  static const Color chipCafeBg = Color(0xFFFFE4E6);
  static const Color chipCafeText = Color(0xFFBE123C);

  static const Color chipTrainingBg = Color(0xFFECFDF5);
  static const Color chipTrainingText = Color(0xFF166534);

  static const Color chipEventsBg = Color(0xFFF3E8FF);
  static const Color chipEventsText = Color(0xFF7E22CE);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color titleText = Color(0xFF111827);
  static const Color subtitleText = Color(0xFF6B7280);
  static const Color hintText = Color(0xFF9CA3AF);
  static const Color mutedText = Color(0xFFD1D5DB);

  // ── Borders ───────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);
  static const Color borderLight = Color(0xFFF9FAFB);

  // ── Extended Tokens ───────────────────────────────────────────────────────
  static const Color backgroundWarm = Color(0xFFF9FAFB);
  static const Color surfaceSubtle = Color(0xFFF0FDF4);

  static const Color primarySoft = Color(0x3316A34A);
  static const Color primaryGlow = Color(0x3316A34A);

  static const Color secondarySoft = Color(0x3310B981);

  static const Color accentLight = Color(0xFFECFDF5);

  static const Color successBorder = Color(0xFFBBF7D0);
  static const Color errorBorder = Color(0xFFFECACA);

  static const Color warningLight = Color(0xFFFFFBEB);

  // ── Shadow ────────────────────────────────────────────────────────────────
  static const Color shadow = Color(0xFF000000);

  // ── Icon ──────────────────────────────────────────────────────────────────
  static const Color icon = primary;
  static const Color iconMuted = Color(0xFF9CA3AF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [accent, primary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Backward Compatibility Aliases ────────────────────────────────────────
  static const Color skyBlue = primary;
  static const Color lightBlue = primaryLight;
  static const Color primaryGreen = primary;
  static const Color secondaryGreen = secondary;
  static const Color accentGreen = accent;
  static const Color orange = amber;
  static const Color yellowColor = amber;
  static const Color titleTextColor = titleText;
  static const Color subTitleTextColor = subtitleText;
  static const Color lightGrey = border;
  static const Color grey = hintText;
  static const Color darkgrey = subtitleText;
  static const Color iconColor = icon;

  // ── Additional App Colors ─────────────────────────────────────────────────
  static const Color priceText = primary;
  static const Color cardTitle = Color(0xFF111827);
  static const Color cardSubtitle = Color(0xFF6B7280);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color black = Color(0xFF111827);
  static const Color lightblack = Color(0xFF374151);

  static const Color transparent = Colors.transparent;
}
