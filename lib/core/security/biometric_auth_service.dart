import 'package:local_auth/local_auth.dart';

/// Small wrapper around device authentication so biometric policy stays
/// consistent between Settings and the login screen.
final class BiometricAuthService {
  BiometricAuthService({LocalAuthentication? authentication})
    : _authentication = authentication ?? LocalAuthentication();

  final LocalAuthentication _authentication;

  Future<bool> isAvailable() async {
    try {
      return await _authentication.isDeviceSupported() &&
          await _authentication.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      if (!await isAvailable()) return false;
      return await _authentication.authenticate(
        localizedReason: 'Authenticate to sign in to Hamro Futsal',
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
