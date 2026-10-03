import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/top_snack_bar.dart';

enum MsgType { error, success, info }

const num _designWidth = 375;
const num _designHeight = 812;
const num _designStatusBarHeight = 0;

final class AppUtils {
  MediaQueryData get _mediaQueryData =>
      MediaQueryData.fromView(ui.PlatformDispatcher.instance.views.first);

  double get width => _mediaQueryData.size.width;

  double get height => _mediaQueryData.size.height;

  double get _availableHeight {
    final double statusBar = _mediaQueryData.viewPadding.top;
    final double bottomBar = _mediaQueryData.viewPadding.bottom;
    return _mediaQueryData.size.height - statusBar - bottomBar;
  }

  /// Time-of-day greeting: "Good morning" (before noon), "Good afternoon"
  /// (noon–5 PM) or "Good evening" (after 5 PM). Pass [now] to override the
  /// clock (useful for tests).
  String greeting({DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Phones scale the 375×812 design to the screen. From tablet width up the
  /// design values are used as they are: scaling by width there turned a 12px
  /// padding into ~48px on a desktop window (×4 at 1500px), which pushed
  /// content off its card edges and out of line across the app.
  bool get _usesDesignScale => width < _tabletWidth;

  /// Matches `AppBreakpoints.tablet`.
  static const double _tabletWidth = 600;

  double getHorizontalSize(double px) {
    if (!_usesDesignScale) return px;
    return (px * width) / _designWidth;
  }

  double getVerticalSize(double px) {
    if (!_usesDesignScale) return px;
    return (px * _availableHeight) / (_designHeight - _designStatusBarHeight);
  }

  EdgeInsets getPadding({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? symmetricHorizontal,
    double? symmetricVertical,
  }) {
    return _getMarginOrPadding(
      all: all,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      horizontal: horizontal,
      vertical: vertical,
      symmetricHorizontal: symmetricHorizontal,
      symmetricVertical: symmetricVertical,
    );
  }

  EdgeInsets getMargin({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? symmetricHorizontal,
    double? symmetricVertical,
  }) {
    return _getMarginOrPadding(
      all: all,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      horizontal: horizontal,
      vertical: vertical,
      symmetricHorizontal: symmetricHorizontal,
      symmetricVertical: symmetricVertical,
    );
  }

  EdgeInsets _getMarginOrPadding({
    double? all,
    double? left,
    double? top,
    double? right,
    double? bottom,
    double? horizontal,
    double? vertical,
    double? symmetricHorizontal,
    double? symmetricVertical,
  }) {
    if (all != null) {
      left = all;
      top = all;
      right = all;
      bottom = all;
    }

    horizontal ??= symmetricHorizontal;
    vertical ??= symmetricVertical;

    if (horizontal != null || vertical != null) {
      return EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );
    }

    return EdgeInsets.only(
      left: getHorizontalSize(left ?? 0),
      top: getVerticalSize(top ?? 0),
      right: getHorizontalSize(right ?? 0),
      bottom: getVerticalSize(bottom ?? 0),
    );
  }

  showSnackBar(
    BuildContext context,
    MsgType msgType,
    String message, {
    Object? key,
  }) {
    final OverlayState? overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    // Create a unique key based on message content to prevent duplicates
    final messageKey = key ?? '${msgType.name}_${message.hashCode}';
    final bool wideToast = MediaQuery.sizeOf(context).width >= _tabletWidth;
    final Widget snackBar = msgType == MsgType.error
        ? CustomSnackBar.error(message: message)
        : msgType == MsgType.success
        ? CustomSnackBar.success(message: message)
        : CustomSnackBar.info(message: message);

    showTopSnackBar(
      overlay,
      snackBar,
      key: messageKey,
      position: wideToast ? SnackBarPosition.bottomRight : SnackBarPosition.top,
      padding: wideToast
          ? const EdgeInsets.only(right: 24, bottom: 24)
          : const EdgeInsets.all(16),
      safeAreaValues: wideToast
          ? const SafeAreaValues(top: false, left: false)
          : const SafeAreaValues(),
      dismissDirection: wideToast
          ? const <DismissDirection>[DismissDirection.down]
          : const <DismissDirection>[DismissDirection.up],
      curve: wideToast ? Curves.easeOutCubic : Curves.elasticOut,
      animationDuration: wideToast
          ? const Duration(milliseconds: 260)
          : const Duration(milliseconds: 1000),
      reverseAnimationDuration: wideToast
          ? const Duration(milliseconds: 200)
          : const Duration(milliseconds: 550),
    );
  }

  Map<String, dynamic> cleanUnwantedMapValue(Map<String, dynamic> input) {
    Map<String, dynamic> cleanedMap = {};

    input.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        Map<String, dynamic> nestedMap = cleanUnwantedMapValue(value);
        if (nestedMap.isNotEmpty) {
          cleanedMap[key] = nestedMap;
        }
      } else if (value is List) {
        List<dynamic> cleanedList = value.where((item) {
          if (item is Map<String, dynamic>) {
            return cleanUnwantedMapValue(item).isNotEmpty;
          }
          return item != null && item.toString().isNotEmpty;
        }).toList();

        if (cleanedList.isNotEmpty) {
          cleanedMap[key] = cleanedList;
        }
      } else if (value != null && value.toString().isNotEmpty) {
        cleanedMap[key] = value;
      }
    });

    return cleanedMap;
  }
}
