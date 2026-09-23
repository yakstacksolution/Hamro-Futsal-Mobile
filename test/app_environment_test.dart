import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';

void main() {
  tearDown(AppEnvironment.reset);

  group('AppEnvironment', () {
    test('resolves the flavour passed via --dart-define=ENV', () {
      const String flag = String.fromEnvironment('ENV');
      // With no flag the build mode decides; `flutter test` is a debug build,
      // so it must resolve to staging rather than the live backend.
      final String expected = flag.isEmpty
          ? (kDebugMode ? 'staging' : 'production')
          : flag;

      expect(AppEnvironment.name, expected);
      expect(AppEnvironment.envFileName, 'env_$expected.env');
      expect(AppEnvironment.isStaging, expected == 'staging');
      expect(AppEnvironment.isProduction, expected == 'production');
      expect(AppEnvironment.isExplicit, flag.isNotEmpty);
      expect(
        AppEnvironment.source,
        flag.isEmpty ? 'default for this build mode' : '--dart-define=ENV',
      );
    });

    test('a debug run never defaults to production', () {
      if (const String.fromEnvironment('ENV').isNotEmpty) return;

      expect(kDebugMode, isTrue, reason: 'tests run in debug');
      expect(AppEnvironment.isProduction, isFalse);
    });

    test('main.dart picks the flavour', () {
      AppEnvironment.selected = AppFlavor.production;
      expect(AppEnvironment.flavor, AppFlavor.production);
      expect(AppEnvironment.envFileName, 'env_production.env');
      expect(AppEnvironment.source, 'kAppFlavor in main.dart');

      AppEnvironment.selected = AppFlavor.staging;
      expect(AppEnvironment.flavor, AppFlavor.staging);
      expect(AppEnvironment.envFileName, 'env_staging.env');
    });

    test('the line in main.dart always beats a build flag', () {
      const String flag = String.fromEnvironment('ENV');
      if (flag.isEmpty) return;

      // kAppFlavor is a hard override: editing it takes effect whatever the
      // IDE launch config or Makefile target passed.
      AppEnvironment.selected = flag == 'production'
          ? AppFlavor.staging
          : AppFlavor.production;

      expect(AppEnvironment.name, isNot(flag));
      expect(AppEnvironment.source, 'kAppFlavor in main.dart');
    });

    test('a build flag decides when main.dart selects nothing', () {
      const String flag = String.fromEnvironment('ENV');
      if (flag.isEmpty) return;

      AppEnvironment.selected = null;
      expect(AppEnvironment.name, flag);
      expect(AppEnvironment.source, '--dart-define=ENV');
    });

    test('clearing the selection falls back to the build rule', () {
      AppEnvironment.selected = AppFlavor.production;
      AppEnvironment.selected = null;

      expect(
        AppEnvironment.flavor,
        const String.fromEnvironment('ENV') == 'production'
            ? AppFlavor.production
            : AppFlavor.staging,
      );
    });

    test('each flavour maps to its own env asset', () {
      AppEnvironment.selected = AppFlavor.staging;
      expect(AppEnvironment.envFileName, 'env_staging.env');
      AppEnvironment.selected = AppFlavor.production;
      expect(AppEnvironment.envFileName, 'env_production.env');
    });

    test('load() has not run, so nothing is marked loaded', () {
      expect(AppEnvironment.isLoaded, isFalse);
      expect(AppEnvironment.loadedFlavor, isNull);
    });

    test('exposes exactly one flavour at a time', () {
      expect(AppEnvironment.isStaging && AppEnvironment.isProduction, isFalse);
      expect(AppEnvironment.isStaging || AppEnvironment.isProduction, isTrue);
      expect(AppFlavor.values, <AppFlavor>[
        AppFlavor.staging,
        AppFlavor.production,
      ]);
    });
  });
}
