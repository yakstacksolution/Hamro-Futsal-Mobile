import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/auth/domain/entities/auth_entities.dart';

SignUpEntity _entityFor(String accountType) => SignUpEntity(
  fullName: 'Vendor Owner',
  password: r'p@$$word!with-specials',
  passwordConfirmation: r'p@$$word!with-specials',
  email: 'vendor@example.com',
  termAccepted: true,
  accountType: accountType,
);

void main() {
  // Uses AccountTypeLabels rather than a literal. The previous version of this
  // test passed 'Futsal Vendor', a label that exists nowhere in the app, so it
  // asserted the fallback branch and never actually guarded the vendor mapping.
  test('the vendor account type maps to the vendor API value', () {
    final SignUpEntity entity = _entityFor(AccountTypeLabels.vendor);

    expect(entity.toMap()['account_type'], 'vendor');
    expect(entity.toMap()['password'], r'p@$$word!with-specials');
  });

  test('the player account type maps to candidate', () {
    expect(
      _entityFor(AccountTypeLabels.player).toMap()['account_type'],
      'candidate',
    );
  });

  test('every label the picker offers maps to a known API value', () {
    for (final String label in AccountTypeLabels.all) {
      expect(
        _entityFor(label).toMap()['account_type'],
        anyOf('vendor', 'candidate'),
        reason: '$label produced an unexpected account_type',
      );
    }
    // The mapping is a plain `==` on a display string, so the vendor label must
    // be the exact one the picker offers — otherwise vendors register as
    // candidates with no error anywhere.
    expect(AccountTypeLabels.all, contains(AccountTypeLabels.vendor));
  });
}
