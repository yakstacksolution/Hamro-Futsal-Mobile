/// Which backend the build talks to.
///
/// Staging and production ship as the same app id and signing identity — the
/// only difference is which `.env.*` file gets loaded, so a build cannot be
/// pointed at the wrong host by editing a file on disk.
enum AppFlavor { staging, production }

/// Build-time environment selection.
///
/// Chosen with `--dart-define=ENV=staging` (or `production`); production is the
/// default so an un-flagged build — a local `flutter run`, or a workflow that
/// forgets the flag — can never silently point testers at staging data, only
/// the other way around, which fails loudly against real credentials.
abstract final class AppEnvironment {
  static const String _raw = String.fromEnvironment(
    'ENV',
    defaultValue: 'production',
  );

  static final AppFlavor flavor = _raw.trim().toLowerCase() == 'staging'
      ? AppFlavor.staging
      : AppFlavor.production;

  static bool get isStaging => flavor == AppFlavor.staging;

  static bool get isProduction => flavor == AppFlavor.production;

  /// `staging` | `production` — safe to show in a debug banner or a log line.
  static String get name => flavor.name;

  /// Asset path of the env file for this flavor; must be listed under
  /// `flutter/assets` in pubspec.yaml or it will not be in the bundle.
  static String get envFileName => '.env.$name';
}
