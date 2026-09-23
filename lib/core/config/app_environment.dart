import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// The environments the app can run against. One env file per value.
enum AppFlavor { staging, production }

/// Single source of truth for which backend the app talks to.
///
/// The flavour is chosen in `main.dart` via `kAppFlavor`, and that choice
/// decides which bundled asset is loaded:
///
/// | `kAppFlavor`            | file loaded           |
/// |-------------------------|-----------------------|
/// | [AppFlavor.staging]     | `env_staging.env`     |
/// | [AppFlavor.production]  | `env_production.env`  |
///
/// Every env-backed value in the app (`APIEndpoint`, the Reverb sockets, the
/// Google sign-in client ids, the store ids) reads from the `dotenv` instance
/// this class fills, so they all follow the same choice automatically.
abstract final class AppEnvironment {
  /// Keys that must be present and non-empty for the app to work at all.
  /// A missing one means the wrong file was bundled, or a key was added to one
  /// env file but not the other.
  static const List<String> requiredKeys = <String>[
    'API_URL',
    'SECURE_API_TOKEN',
  ];

  static AppFlavor get _defaultFlavor =>
      kDebugMode ? AppFlavor.staging : AppFlavor.production;

  static const String _raw = String.fromEnvironment('ENV');

  /// Hard override set from `main.dart` (`kAppFlavor`). It wins over
  /// `--dart-define=ENV` so that editing `kAppFlavor` always takes effect,
  /// whatever the IDE launch config or Makefile target passes. Leave it `null`
  /// to follow the build flag (what CI relies on).
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

  /// Bundled asset for the current [flavor] — `env_staging.env` or
  /// `env_production.env`. Must match the `assets:` list in `pubspec.yaml`.
  static String get envFileName => 'env_$name.env';

  /// The flavour whose file is actually loaded, or `null` before [load] runs.
  /// It can differ from [flavor] only if someone reassigns [selected] after
  /// start-up, which [assertLoaded] catches.
  static AppFlavor? loadedFlavor;

  static bool get isLoaded => loadedFlavor != null;

  /// Reads one key. Returns `''` when absent, so callers never see a `null`
  /// leaking into a URL or header.
  static String read(String key) =>
      dotenv.isInitialized ? (dotenv.maybeGet(key)?.trim() ?? '') : '';

  /// Reads one key, falling back to [fallback] when it is absent or blank.
  static String readOr(String key, String fallback) {
    final String value = read(key);
    return value.isEmpty ? fallback : value;
  }

  /// Loads [envFileName] into `dotenv`.
  ///
  /// Throws [EnvLoadException] in debug builds if the file is missing or a
  /// [requiredKeys] entry is blank — a packaging mistake should stop the app
  /// at start-up rather than surface later as confusing network failures.
  /// Release builds do not throw; they leave the values empty (requests then
  /// fail loudly at the API) and let the caller report the error.
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

  /// Leaves `dotenv` in a usable (empty) state after a failed [load], so that
  /// [read] keeps returning `''` instead of throwing.
  static void ensureInitialized() {
    if (!dotenv.isInitialized) dotenv.loadFromString(envString: '');
  }

  /// Guards a code path that must not run before [load] has succeeded, and
  /// catches a flavour that changed after start-up. Debug builds only.
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

/// Raised when the env file for the selected flavour cannot be loaded or is
/// incomplete.
class EnvLoadException implements Exception {
  const EnvLoadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => cause == null
      ? 'EnvLoadException: $message'
      : 'EnvLoadException: $message ($cause)';
}
