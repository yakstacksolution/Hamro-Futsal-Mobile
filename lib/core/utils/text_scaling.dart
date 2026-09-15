import 'package:flutter/material.dart';

/// Scales every piece of text in the app with the size of the device.
///
/// Type sizes live in `AppDimens` as fixed logical pixels, chosen against the
/// 375pt-wide design. Read literally, they are the same physical size on a
/// 320pt phone (where they crowd the layout) as on a 430pt one or a tablet
/// (where they look undersized). Rather than touch several hundred call sites,
/// the factor is folded into the [MediaQuery.textScaler] that every [Text]
/// already consults — including labels built with a hardcoded `fontSize`.
///
/// The device factor multiplies the user's own accessibility scale, so the
/// product is clamped: text never drops below [minFactor] of the design size,
/// and never grows past [maxCompositeFactor] — the ceiling the layouts were
/// checked against.
class AppTextScaling extends StatelessWidget {
  const AppTextScaling({super.key, required this.child});

  final Widget child;

  /// Shortest side the type scale was designed against — the same design width
  /// given to `ScreenUtilInit` in `main.dart`.
  static const double designShortestSide = 375;

  /// Floor for the device factor: small phones (320pt) read at 0.85, below
  /// which body copy stops being comfortable.
  static const double minFactor = 0.85;

  /// Ceiling for the device factor. Deliberately modest — large phones and
  /// tablets already gain room through the width breakpoints, and type that
  /// grows with every extra pixel of width overruns fixed-height rows.
  static const double maxFactor = 1.12;

  /// Ceiling on the device factor *times* the user's accessibility scale.
  /// Matches the clamp the app applied before device scaling existed.
  static const double maxCompositeFactor = 1.3;

  /// The device factor for a screen whose shortest side is [shortestSide].
  ///
  /// Driven by the shortest side, not the width, so rotating a phone does not
  /// resize its text.
  static double deviceFactorFor(double shortestSide) {
    if (!shortestSide.isFinite || shortestSide <= 0) return 1;
    return (shortestSide / designShortestSide).clamp(minFactor, maxFactor);
  }

  /// The device factor for the screen [context] is on.
  static double deviceFactorOf(BuildContext context) =>
      deviceFactorFor(MediaQuery.sizeOf(context).shortestSide);

  /// The scaler [child] is given: the user's scale, scaled by the device, with
  /// the product clamped.
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

/// The user's [TextScaler] with a device factor folded in.
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
