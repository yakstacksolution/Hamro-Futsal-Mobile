import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum AppFlavor { staging, production }

abstract final class AppEnvironment {
  static const List<String> requiredKeys = <String>[
    'API_URL',
    'SECURE_API_TOKEN',
  ];

  static AppFlavor get _defaultFlavor =>
      kDebugMode ? AppFlavor.staging : AppFlavor.production;

  static const String _raw = String.fromEnvironment('ENV');

  static AppFlavor? selected;

  static AppFlavor get flavor => selected ?? _fromFlag ?? _defaultFlavor;

  static AppFlavor? get _fromFlag => switch (_raw.trim().toLowerCase()) {
    'staging' || 'stage' || 'dev' => AppFlavor.staging,
    'production' || 'prod' || 'live' => AppFlavor.production,
    _ => null,
  };

  static String get source {
    if (selected != null) return 'kAppFlavor in main.dart';
    if (_fromFlag != null) return '--dart-define=ENV';
    return 'default for this build mode';
  }

  static bool get isStaging => flavor == AppFlavor.staging;

  static bool get isProduction => flavor == AppFlavor.production;

  static String get name => flavor.name;

  static bool get isExplicit => selected != null || _raw.trim().isNotEmpty;

  static String get envFileName => 'env_$name.env';

  static AppFlavor? loadedFlavor;

  static bool get isLoaded => loadedFlavor != null;

  static String read(String key) =>
      dotenv.isInitialized ? (dotenv.maybeGet(key)?.trim() ?? '') : '';

  static String readOr(String key, String fallback) {
    final String value = read(key);
    return value.isEmpty ? fallback : value;
  }

  static Future<void> load() async {
    final AppFlavor target = flavor;
    try {
      await dotenv.load(fileName: envFileName);
    } catch (error) {
      throw EnvLoadException(
        'Could not load "$envFileName" for the $name environment. '
        'Check that it exists and is listed under assets: in pubspec.yaml, '
        'then do a full restart (env files are bundled assets).',
        error,
      );
    }

    final List<String> missing = requiredKeys
        .where((String key) => read(key).isEmpty)
        .toList(growable: false);
    if (missing.isNotEmpty) {
      throw EnvLoadException(
        '"$envFileName" is missing values for: ${missing.join(', ')}. '
        'Run `make env-check` to compare the env files key by key.',
      );
    }

    loadedFlavor = target;
    if (kDebugMode) {
      debugPrint('[env] $name ($source) → $envFileName → ${read('API_URL')}');
    }
  }

  static void ensureInitialized() {
    if (!dotenv.isInitialized) dotenv.loadFromString(envString: '');
  }

  static void assertLoaded() {
    assert(
      isLoaded,
      'AppEnvironment.load() has not run — env values are empty.',
    );
    assert(
      loadedFlavor == flavor,
      'Environment changed after start-up: loaded $loadedFlavor but flavor is '
      '$flavor. Set kAppFlavor before runApp and do not reassign it.',
    );
  }

  @visibleForTesting
  static void reset() {
    selected = null;
    loadedFlavor = null;
  }
}

class EnvLoadException implements Exception {
  const EnvLoadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'EnvLoadException: $message'
      : 'EnvLoadException: $message ($cause)';
}
