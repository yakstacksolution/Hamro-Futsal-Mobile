import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('resolves the flavour passed via --dart-define=ENV', () {
      // Run with no flag the value is `production`; the staging run below
      // passes --dart-define=ENV=staging.
      const String expected = String.fromEnvironment(
        'ENV',
        defaultValue: 'production',
      );

      expect(AppEnvironment.name, expected);
      expect(AppEnvironment.envFileName, '.env.$expected');
      expect(AppEnvironment.isStaging, expected == 'staging');
      expect(AppEnvironment.isProduction, expected == 'production');
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
