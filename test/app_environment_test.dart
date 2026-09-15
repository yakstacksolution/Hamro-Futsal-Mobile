import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';

void main() {
  tearDown(() => AppEnvironment.selected = null);

  group('AppEnvironment', () {
    test('resolves the flavour passed via --dart-define=ENV', () {
      const String flag = String.fromEnvironment('ENV');
      // With no flag the build mode decides; `flutter test` is a debug build,
      // so it must resolve to staging rather than the live backend.
      final String expected = flag.isEmpty
          ? (kDebugMode ? 'staging' : 'production')
          : flag;

      expect(AppEnvironment.name, expected);
      expect(AppEnvironment.envFileName, '.env.$expected');
      expect(AppEnvironment.isStaging, expected == 'staging');
      expect(AppEnvironment.isProduction, expected == 'production');
      expect(AppEnvironment.isExplicit, flag.isNotEmpty);
    });

    test('a debug run never defaults to production', () {
      if (const String.fromEnvironment('ENV').isNotEmpty) return;

      expect(kDebugMode, isTrue, reason: 'tests run in debug');
      expect(AppEnvironment.isProduction, isFalse);
    });

    test('main.dart picks the flavour when no build flag is passed', () {
      if (const String.fromEnvironment('ENV').isNotEmpty) return;
      AppEnvironment.selected = AppFlavor.production;
      expect(AppEnvironment.flavor, AppFlavor.production);
      expect(AppEnvironment.envFileName, '.env.production');
      expect(AppEnvironment.source, 'kAppFlavor in main.dart');

      AppEnvironment.selected = AppFlavor.staging;
      expect(AppEnvironment.flavor, AppFlavor.staging);
      expect(AppEnvironment.envFileName, '.env.staging');
    });

    test('a build flag always beats the line in main.dart', () {
      const String flag = String.fromEnvironment('ENV');
      if (flag.isEmpty) return;

      // CI passes ENV explicitly; whatever main.dart says, the pipeline ships
      // the environment it named.
      AppEnvironment.selected = flag == 'production'
          ? AppFlavor.staging
          : AppFlavor.production;

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
