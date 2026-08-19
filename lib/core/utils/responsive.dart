import 'package:flutter/material.dart';

/// Width breakpoints, in logical pixels, used to pick a layout for the current
/// screen or window size.
///
/// These match the common Material window-size classes closely enough for our
/// purposes: phones stay below [tablet], tablet portrait sits between [tablet]
/// and [desktop], and anything wider (tablet landscape, desktop windows) gets
/// the expanded two-pane treatment.
final class AppBreakpoints {
  const AppBreakpoints._();

  /// Below this width the mobile layout is used, untouched.
  static const double tablet = 600;

  /// At or above this width there is room for a side-by-side layout.
  static const double desktop = 900;

  /// Very wide windows, where content should stop growing and stay centred.
  static const double large = 1200;
}

/// How many columns of at least [minItemWidth] fit in [availableWidth].
///
/// Prefer this over a fixed column count per breakpoint. The width that
/// matters is the one the grid actually gets — the window minus the side rail,
/// panels and padding — and deriving the count from a minimum item width keeps
/// items readable instead of letting them get squeezed.
///
/// Pass `constraints.maxWidth` from a `LayoutBuilder`, not the screen width.
int columnsFor({
  required double availableWidth,
  required double minItemWidth,
  double spacing = 16,
  int maxColumns = 4,
}) {
  final int fits = ((availableWidth + spacing) / (minItemWidth + spacing))
      .floor();
  return fits.clamp(1, maxColumns);
}

/// Breakpoint helpers driven by [MediaQuery].
///
/// These intentionally read `MediaQuery.sizeOf(context)` rather than a cached
/// platform-view size, so widgets rebuild when a desktop window is resized or
/// a tablet is rotated.
extension ResponsiveContext on BuildContext {
  /// Current layout width in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Current layout height in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Phone-sized: the existing mobile layout, which must not change.
  bool get isMobile => screenWidth < AppBreakpoints.tablet;

  /// Tablet portrait sized: a single, roomier centred column.
  bool get isTablet =>
      screenWidth >= AppBreakpoints.tablet &&
      screenWidth < AppBreakpoints.desktop;

  /// Tablet landscape or a desktop window: wide enough for two panes.
  bool get isDesktop => screenWidth >= AppBreakpoints.desktop;

  /// Anything at least [AppBreakpoints.large] wide.
  bool get isLarge => screenWidth >= AppBreakpoints.large;

  /// Tablet or wider — i.e. anything that is not the phone layout.
  bool get isTabletOrWider => screenWidth >= AppBreakpoints.tablet;

  /// Picks the value matching the current width, falling back down the chain
  /// so that passing [mobile] alone is always valid.
  ///
  /// Keep the [mobile] value identical to the pre-existing hardcoded value so
  /// the phone layout is unaffected.
  T responsive<T>({required T mobile, T? tablet, T? desktop, T? large}) {
    if (isLarge) return large ?? desktop ?? tablet ?? mobile;
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}
