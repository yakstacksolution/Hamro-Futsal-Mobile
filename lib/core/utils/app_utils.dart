import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/top_snack_bar.dart';

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

  double getHorizontalSize(double px) {
    return (px * width) / _designWidth;
  }

  double getVerticalSize(double px) {
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

  showSnackBar(BuildContext context, MsgType msgType, String message, {Object? key}) {
    // Create a unique key based on message content to prevent duplicates
    final messageKey = key ?? '${msgType.name}_${message.hashCode}';
    
    showTopSnackBar(
      Overlay.of(context),
      msgType == MsgType.error
          ? CustomSnackBar.error(message: message)
          : msgType == MsgType.success
          ? CustomSnackBar.success(message: message)
          : CustomSnackBar.info(message: message),
      key: messageKey,
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
