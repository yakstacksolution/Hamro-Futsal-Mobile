import 'dart:io';

import 'package:flutter/foundation.dart';

abstract final class FirebasePlatformSupport {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Firebase is configured for the native app targets that have complete
  /// Firebase options and plugin implementations in this project.
  static bool get core => isAndroid || isIOS || isMacOS;

  static bool get analytics => core;

  static bool get crashlytics => core;

  static bool get messaging => core;
}
