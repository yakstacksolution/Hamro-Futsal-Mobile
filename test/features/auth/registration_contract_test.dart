import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/auth/domain/entities/auth_entities.dart';

void main() {
  test('Futsal Vendor keeps the vendor API value', () {
    const SignUpEntity entity = SignUpEntity(
      fullName: 'Vendor Owner',
      password: r'p@$$word!with-specials',
      passwordConfirmation: r'p@$$word!with-specials',
      email: 'vendor@example.com',
      termAccepted: true,
      accountType: 'Futsal Vendor',
    );

    expect(entity.toMap()['account_type'], 'vendor');
    expect(entity.toMap()['password'], r'p@$$word!with-specials');
  });
}
