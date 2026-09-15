import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/auth/domain/entities/auth_entities.dart';

void main() {
  group('ResetPasswordEntity', () {
    test('matches the POST /auth/reset-password body', () {
      const ResetPasswordEntity entity = ResetPasswordEntity(
        email: 'john@example.com',
        otp: '1234',
        password: 'newpassword123',
        passwordConfirmation: 'newpassword123',
      );

      expect(entity.toMap(), <String, dynamic>{
        'email': 'john@example.com',
        'otp': '1234',
        'password': 'newpassword123',
        'password_confirmation': 'newpassword123',
      });
    });

    test('keeps a leading zero in the OTP', () {
      const ResetPasswordEntity entity = ResetPasswordEntity(
        email: 'john@example.com',
        otp: '0412',
        password: 'newpassword123',
        passwordConfirmation: 'newpassword123',
      );

      // Sent as a string, not an int: 0412 parsed as a number reaches the
      // server as 412 and the reset is rejected.
      expect(entity.toMap()['otp'], '0412');
    });
  });

  group('ForgotPasswordOtpRequestEntity', () {
    test('sends only the email', () {
      const ForgotPasswordOtpRequestEntity entity =
          ForgotPasswordOtpRequestEntity(email: 'john@example.com');

      expect(entity.toMap(), <String, dynamic>{'email': 'john@example.com'});
    });
  });
}
