import 'dart:convert';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthPreferenceKeys {
  static const tokenModel = 'token_model';
  static const isInitialViewOnboarding = 'is_initial_view_onboarding';
}

class AppSettings {
  static final AppSettings _instance = AppSettings._internal();
  late final Preferences _preferences;

  factory AppSettings() {
    return _instance;
  }

  AppSettings._internal();

  Future<void> init(Preferences preferences) async {
    _preferences = preferences;
  }

  String get khaltiPublicKey =>
      'test_public_key_d5d9f63743584dc38753056b0cc737d5';

  set token(TokenModel token) => _preferences.setString(
    _AuthPreferenceKeys.tokenModel,
    jsonEncode(token.toJson()),
  );
  TokenModel get tokenModel {
    final tokenString = _preferences.getString(_AuthPreferenceKeys.tokenModel);
    if (tokenString == null || tokenString.isEmpty) {
      return TokenModel();
    }
    return TokenModel.fromJson(jsonDecode(tokenString));
  }

  set isInitialViewOnboarding(bool val) =>
      _preferences.setBool(_AuthPreferenceKeys.isInitialViewOnboarding, val);

  bool get isInitialViewOnboarding =>
      _preferences.getBool(_AuthPreferenceKeys.isInitialViewOnboarding) ??
      false;

  void logout() {
    _preferences.remove(_AuthPreferenceKeys.tokenModel);
  }
}

abstract class Preferences {
  Future<bool> setString(String key, String value);

  Future<bool> setStringList(String key, List<String> permissions);
  List<String> getStringList(String key);

  String? getString(String key);

  Future<bool> setBool(String key, bool value);

  bool? getBool(String key);

  Future<bool> setDouble(String key, double value);

  double? getDouble(String key);

  Future<bool> remove(String key);

  int? getInt(String key);

  Future<bool> setInt(String key, int value);

  bool containsKey(String key);
}

class SharedPreferencesWrapper implements Preferences {
  final SharedPreferences _sharedPreferences;

  SharedPreferencesWrapper(this._sharedPreferences);

  @override
  Future<bool> setString(String key, String value) {
    return _sharedPreferences.setString(key, value);
  }

  @override
  List<String> getStringList(String key) {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) {
    return _sharedPreferences.setStringList(key, permissions);
  }

  @override
  String? getString(String key) {
    return _sharedPreferences.getString(key);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    return _sharedPreferences.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return _sharedPreferences.getBool(key);
  }

  @override
  Future<bool> setDouble(String key, double value) {
    return _sharedPreferences.setDouble(key, value);
  }

  @override
  double? getDouble(String key) {
    return _sharedPreferences.getDouble(key);
  }

  @override
  Future<bool> remove(String key) {
    return _sharedPreferences.remove(key);
  }

  @override
  bool containsKey(String key) {
    return _sharedPreferences.containsKey(key);
  }

  @override
  int? getInt(String key) {
    return _sharedPreferences.getInt(key);
  }

  @override
  Future<bool> setInt(String key, int value) async {
    return await _sharedPreferences.setInt(key, value);
  }
}
