import 'package:flutter/foundation.dart';

enum AppFlavor { staging, production }

abstract final class AppEnvironment {
  static AppFlavor get _defaultFlavor =>
      kDebugMode ? AppFlavor.staging : AppFlavor.production;

  static const String _raw = String.fromEnvironment('ENV');

  static AppFlavor? selected;

  static AppFlavor get flavor => _fromFlag ?? selected ?? _defaultFlavor;

  static AppFlavor? get _fromFlag => switch (_raw.trim().toLowerCase()) {
    'staging' || 'stage' || 'dev' => AppFlavor.staging,
    'production' || 'prod' || 'live' => AppFlavor.production,
    _ => null,
  };

  static String get source {
    if (_fromFlag != null) return '--dart-define=ENV';
    if (selected != null) return 'kAppFlavor in main.dart';
    return 'default for this build mode';
  }

  static bool get isStaging => flavor == AppFlavor.staging;

  static bool get isProduction => flavor == AppFlavor.production;

  static String get name => flavor.name;

  static bool get isExplicit => _raw.trim().isNotEmpty;

  static String get envFileName => '.env.$name';
}
