import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hamro_futsal/features/auth/data/model/token_model.dart';

/// Encrypted account session retained only when biometric login is enabled.
final class BiometricSessionStore {
  BiometricSessionStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _sessionKey = 'biometric_account_session';
  final FlutterSecureStorage _storage;

  Future<void> save(TokenModel token) async {
    if (token.accessToken?.trim().isEmpty ?? true) return;
    await _storage.write(key: _sessionKey, value: jsonEncode(token.toJson()));
  }

  Future<TokenModel?> read() async {
    try {
      final String? encoded = await _storage.read(key: _sessionKey);
      if (encoded == null || encoded.isEmpty) return null;
      return TokenModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> get hasSession async =>
      (await read())?.accessToken?.trim().isNotEmpty == true;

  Future<void> clear() => _storage.delete(key: _sessionKey);
}
