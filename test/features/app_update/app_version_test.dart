import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_version.dart';

void main() {
  group('AppVersion.tryParse', () {
    test('parses a plain dotted version', () {
      expect(AppVersion.tryParse('1.4.2')?.segments, <int>[1, 4, 2]);
    });

    test('tolerates a leading v, build suffix and pre-release tag', () {
      expect(AppVersion.tryParse('v2.0.1+18')?.segments, <int>[2, 0, 1]);
      expect(AppVersion.tryParse('3.1.0-beta.2')?.segments, <int>[3, 1, 0]);
      expect(AppVersion.tryParse('  1.2 ')?.segments, <int>[1, 2]);
    });

    test('parses a single-segment version', () {
      expect(AppVersion.tryParse('7')?.segments, <int>[7]);
    });

    test('returns null for values holding no number', () {
      expect(AppVersion.tryParse(null), isNull);
      expect(AppVersion.tryParse(''), isNull);
      expect(AppVersion.tryParse('latest'), isNull);
    });

    test('keeps the raw string for display', () {
      expect(AppVersion.tryParse('1.4.2')?.toString(), '1.4.2');
    });
  });

  group('comparison', () {
    AppVersion v(String value) => AppVersion.tryParse(value)!;

    test('compares segment by segment, not lexically', () {
      expect(v('1.10.0') > v('1.9.9'), isTrue);
      expect(v('2.0.0') > v('1.99.99'), isTrue);
      expect(v('1.0.0') < v('1.0.1'), isTrue);
    });

    test('treats missing segments as zero', () {
      expect(v('1.4') == v('1.4.0'), isTrue);
      expect(v('1.4').compareTo(v('1.4.0')), 0);
      expect(v('1.4.1') > v('1.4'), isTrue);
    });

    test('is symmetric', () {
      expect(v('1.2.3').compareTo(v('1.2.4')), lessThan(0));
      expect(v('1.2.4').compareTo(v('1.2.3')), greaterThan(0));
    });

    test('a four-segment version still compares against three', () {
      expect(v('1.2.3.4') > v('1.2.3'), isTrue);
    });
  });
}
