import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// Footsall App — Light Color Palette
/// ─────────────────────────────────────────────────────────────────────────────
///
///  PRIMARY   → Sky Blue   #2D86E5  (buttons, price, active nav, links)
///  SECONDARY → Teal       #26B58A  (open badge, success states)
///  DANGER    → Red        #E05252  (closed badge, errors)
///  RATING    → Amber      #F59E0B  (star icon)
///  SURFACE   → White / soft grey backgrounds
///
class LightColor {
  LightColor._();

  // ── Neutral Surfaces ──────────────────────────────────────────────────────
  /// Page scaffold background — very soft blue-grey
  static const Color background = Color(0xFFF3F6FB);

  /// Card / panel surface
  static const Color surface = Color(0xFFFFFFFF);

  /// Pure white (icons on coloured backgrounds, etc.)
  static const Color white = Color(0xFFFFFFFF);

  // ── Primary Brand — Sky Blue ──────────────────────────────────────────────
  /// Main action colour: CTA buttons, price text, active states
  static const Color primary = Color(0xFF2D86E5);

  /// Lighter tint: icon backgrounds, selected chip fill
  static const Color primaryLight = Color(0xFFE8F3FD);

  /// Deeper shade: pressed states, gradient end
  static const Color primaryDark = Color(0xFF1A5DAD);

  // ── Secondary — Teal / Mint ───────────────────────────────────────────────
  /// "Open Now" badge, success indicators
  static const Color secondary = Color(0xFF26B58A);

  /// Soft tint for "Open" badge background
  static const Color secondaryLight = Color(0xFFE6F7F3);

  // ── Accent — Deep Navy ────────────────────────────────────────────────────
  /// Header gradient end, dark overlays
  static const Color accent = Color(0xFF173A5E);

  // ── Status / Semantic ─────────────────────────────────────────────────────
  /// Warning / rating stars
  static const Color amber = Color(0xFFF59E0B);

  /// Destructive / "Closed" badge
  static const Color red = Color(0xFFE05252);

  /// Light red tint for "Closed" badge background
  static const Color redLight = Color(0xFFFFEEEE);

  // ── Feature Chip Palette (one colour per feature type) ────────────────────
  static const Color chipIndoorBg = Color(0xFFEBF4FF);
  static const Color chipIndoorText = Color(0xFF1A6FB5);

  static const Color chipOutdoorBg = Color(0xFFFFF4E5);
  static const Color chipOutdoorText = Color(0xFFB06A00);

  static const Color chipParkingBg = Color(0xFFF0EDFF);
  static const Color chipParkingText = Color(0xFF5B3FC8);

  static const Color chipLightsBg = Color(0xFFFFFBE6);
  static const Color chipLightsText = Color(0xFF9A7A00);

  static const Color chipTurfBg = Color(0xFFE6F7F3);
  static const Color chipTurfText = Color(0xFF0D7A44);

  static const Color chipShowerBg = Color(0xFFE5F6FF);
  static const Color chipShowerText = Color(0xFF0077A8);

  static const Color chipCafeBg = Color(0xFFFFF0F0);
  static const Color chipCafeText = Color(0xFFC0392B);

  static const Color chipTrainingBg = Color(0xFFEDFFF5);
  static const Color chipTrainingText = Color(0xFF0B7A44);

  static const Color chipEventsBg = Color(0xFFFCEDFF);
  static const Color chipEventsText = Color(0xFF8B1FA9);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Page titles, card names
  static const Color titleText = Color(0xFF1B2B41);

  /// Supporting text — location, meta info
  static const Color subtitleText = Color(0xFF5B6B7D);

  /// Placeholder / disabled text
  static const Color hintText = Color(0xFF9AA8B8);

  // ── Borders & Dividers ────────────────────────────────────────────────────
  static const Color border = Color(0xFFD9E2EC);
  static const Color divider = Color(0xFFEDF1F7);

  // ── Shadows ───────────────────────────────────────────────────────────────
  /// Soft card shadow colour
  static const Color shadow = Color(0xFF1B2B41);

  // ── Icon ──────────────────────────────────────────────────────────────────
  static const Color icon = primary;
  static const Color iconMuted = Color(0xFF9AA8B8);

  // ── Gradients (helpers) ───────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [LightColor.secondaryGreen, LightColor.secondaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFF2D86E5), Color(0xFF173A5E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Backward Compatibility Aliases ────────────────────────────────────────
  /// @deprecated Use [primary] instead
  static const Color skyBlue = primary;

  /// @deprecated Use [primaryLight] instead
  static const Color lightBlue = Color(0xFF69B9F5);

  /// @deprecated Use [primary] instead
  static const Color primaryGreen = Color(0xFF245FCC);

  /// @deprecated Use [secondary] instead
  static const Color secondaryGreen = secondary;

  /// @deprecated Use [accent] instead
  static const Color accentGreen = accent;

  /// @deprecated Use [amber] instead
  static const Color orange = amber;

  /// @deprecated Use [amber] instead
  static const Color yellowColor = Color(0xFFF6B73C);

  /// @deprecated Use [titleText] instead
  static const Color titleTextColor = titleText;

  /// @deprecated Use [subtitleText] instead
  static const Color subTitleTextColor = subtitleText;

  /// @deprecated Use [border] instead
  static const Color lightGrey = border;

  /// @deprecated Use [hintText] instead
  static const Color grey = hintText;

  /// @deprecated Use [subtitleText] instead
  static const Color darkgrey = Color(0xFF64748B);

  /// @deprecated Use [icon] instead
  static const Color iconColor = icon;

  /// Dark text color
  static const Color black = Color(0xFF1F2933);

  /// Slightly lighter black
  static const Color lightblack = Color(0xFF52606D);

  // ── Additional App Colors ─────────────────────────────────────────────────
  /// Price text, active elements (same as primary)
  static const Color priceText = primary;

  /// Card text primary
  static const Color cardTitle = Color(0xFF0F1923);

  /// Card text secondary
  static const Color cardSubtitle = Color(0xFF6B7280);

  /// Card border
  static const Color cardBorder = Color(0xFFE8ECF0);

  /// Transparent color
  static const Color transparent = Colors.transparent;

  static const Color borderLight = Color(0xFFF3F4F6);
}

// import 'package:flutter/material.dart';

// class LightColor {
//   // Neutral surfaces
//   static const Color background = Color(0xFFF3F6FB);
//   static const Color surface = Colors.white;
//   static const Color white = Colors.white;

//   // Primary brand palette
//   static const Color skyBlue = Color(0xFF2D86E5);
//   static const Color lightBlue = Color(0xFF69B9F5);
//   static const Color primaryGreen = Color(0xFF245FCC);
//   static const Color secondaryGreen = Color(0xFF26B58A);
//   static const Color accentGreen = Color(0xFF173A5E);

//   // Accent + status colors
//   static const Color orange = Color(0xFFF59E0B);
//   static const Color yellowColor = Color(0xFFF6B73C);
//   static const Color red = Color(0xFFE05252);

//   // Text + borders
//   static const Color titleTextColor = Color(0xFF1B2B41);
//   static const Color subTitleTextColor = Color(0xFF5B6B7D);
//   static const Color lightGrey = Color(0xFFD9E2EC);
//   static const Color grey = Color(0xFF9AA8B8);
//   static const Color darkgrey = Color(0xFF64748B);

//   static const Color iconColor = skyBlue;
//   static const Color black = Color(0xFF1F2933);
//   static const Color lightblack = Color(0xFF52606D);
// }
