import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/auth/domain/entities/auth_entities.dart';

void main() {
  group('AppleSignInEntity.toMap', () {
    test('sends every field on the first authorization', () {
      final Map<String, dynamic> body = const AppleSignInEntity(
        idToken: 'eyJhbGciOiJSUzI1NiIsImtpZCI6',
        email: 'player@example.com',
        fullName: 'Apple Player',
      ).toMap();

      expect(body, <String, dynamic>{
        'id_token': 'eyJhbGciOiJSUzI1NiIsImtpZCI6',
        'email': 'player@example.com',
        'full_name': 'Apple Player',
      });
    });

    test('omits email and full_name on later sign-ins, keeping id_token', () {
      // Apple returns the name and email only once per Apple ID; the backend
      // has to fall back to the id_token claims after that.
      final Map<String, dynamic> body = const AppleSignInEntity(
        idToken: 'token-only',
      ).toMap();

      expect(body, <String, dynamic>{'id_token': 'token-only'});
      expect(body.containsKey('email'), isFalse);
      expect(body.containsKey('full_name'), isFalse);
    });

    test('omits blank strings rather than overwriting a stored name', () {
      final Map<String, dynamic> body = const AppleSignInEntity(
        idToken: 'token-only',
        email: '',
        fullName: '',
      ).toMap();

      expect(body, <String, dynamic>{'id_token': 'token-only'});
    });
  });
}
