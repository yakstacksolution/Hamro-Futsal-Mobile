import 'package:flutter/material.dart';

final class AppBreakpoints {
  const AppBreakpoints._();

  static const double tablet = 600;

  static const double desktop = 900;

  static const double large = 1200;
}

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

extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < AppBreakpoints.tablet;

  bool get isTablet =>
      screenWidth >= AppBreakpoints.tablet &&
      screenWidth < AppBreakpoints.desktop;

  bool get isDesktop => screenWidth >= AppBreakpoints.desktop;

  bool get isLarge => screenWidth >= AppBreakpoints.large;

  bool get isTabletOrWider => screenWidth >= AppBreakpoints.tablet;

  T responsive<T>({required T mobile, T? tablet, T? desktop, T? large}) {
    if (isLarge) return large ?? desktop ?? tablet ?? mobile;
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }
}
