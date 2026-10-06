import 'package:flutter/material.dart';

class AppTextScaling extends StatelessWidget {
  const AppTextScaling({super.key, required this.child});

  final Widget child;

  static const double designShortestSide = 375;

  static const double minFactor = 0.85;

  static const double maxFactor = 1.12;

  static const double maxCompositeFactor = 1.3;

  static double deviceFactorFor(double shortestSide) {
    if (!shortestSide.isFinite || shortestSide <= 0) return 1;
    return (shortestSide / designShortestSide).clamp(minFactor, maxFactor);
  }

  static double deviceFactorOf(BuildContext context) =>
      deviceFactorFor(MediaQuery.sizeOf(context).shortestSide);

  static TextScaler scalerFor(MediaQueryData data) {
    return _DeviceTextScaler(
      data.textScaler,
      deviceFactorFor(data.size.shortestSide),
    ).clamp(minScaleFactor: minFactor, maxScaleFactor: maxCompositeFactor);
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData data = MediaQuery.of(context);
    return MediaQuery(
      data: data.copyWith(textScaler: scalerFor(data)),
      child: child,
    );
  }
}

class _DeviceTextScaler extends TextScaler {
  const _DeviceTextScaler(this.base, this.factor);

  final TextScaler base;
  final double factor;

  @override
  double scale(double fontSize) => base.scale(fontSize * factor);

  @override
  // ignore: deprecated_member_use
  double get textScaleFactor => base.textScaleFactor * factor;

  @override
  bool operator ==(Object other) =>
      other is _DeviceTextScaler &&
      other.base == base &&
      other.factor == factor;

  @override
  int get hashCode => Object.hash(base, factor);
}
