import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/validation/app_validators.dart';

void main() {
  group('fullName', () {
    test('accepts alphabetic names and rejects numbers or symbols', () {
      expect(AppValidators.fullName('Anne Marie Oneill'), isNull);
      expect(AppValidators.fullName('José श्रेष्ठ'), isNull);
      expect(AppValidators.fullName('Player 2'), isNotNull);
      expect(AppValidators.fullName('Anne-Marie'), isNotNull);
      expect(AppValidators.fullName("O'Neill"), isNotNull);
      expect(AppValidators.fullName("' OR 1=1 --"), isNotNull);
      expect(
        AppValidators.fullName(List<String>.filled(81, 'A').join()),
        isNotNull,
      );
    });
  });

  group('Nepal mobile', () {
    test('normalizes local and country-prefixed numbers', () {
      expect(
        AppValidators.normalizeNepalMobile('9812345678'),
        '+9779812345678',
      );
      expect(
        AppValidators.normalizeNepalMobile('977-9712345678'),
        '+9779712345678',
      );
      expect(
        AppValidators.normalizeNepalMobile('+977 9812345678'),
        '+9779812345678',
      );
    });

    test('rejects unsupported prefixes, lengths, and characters', () {
      expect(AppValidators.nepalMobile('9612345678'), isNotNull);
      expect(AppValidators.nepalMobile('981234567'), isNotNull);
      expect(AppValidators.nepalMobile('98abc45678'), isNotNull);
    });
  });
}
