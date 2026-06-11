import 'dart:convert';
import 'package:hamro_footsall/features/auth/data/model/token_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _AuthPreferenceKeys {
  static const tokenModel = 'token_model';
  static const isInitialViewOnboarding = 'is_initial_view_onboarding';
  static const recentVenueSearches = 'recent_venue_searches';
}

class _SettingsPreferenceKeys {
  static const pushNotifications = 'settings_push_notifications';
  static const bookingAlerts = 'settings_booking_alerts';
  static const opponentRequests = 'settings_opponent_requests';
  static const promotionalEmails = 'settings_promotional_emails';
  static const biometricLogin = 'settings_biometric_login';
  static const darkMode = 'settings_dark_mode';
  static const appLanguage = 'settings_app_language';
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

  set recentVenueSearches(List<String> searches) => _preferences.setStringList(
    _AuthPreferenceKeys.recentVenueSearches,
    searches,
  );

  List<String> get recentVenueSearches =>
      _preferences.getStringList(_AuthPreferenceKeys.recentVenueSearches);

  // ---------------------------------------------------------------------------
  // User-facing app settings. Each preference falls back to a sensible default
  // when it has never been written, so the Settings page reflects opt-in
  // notification behaviour out of the box.
  // ---------------------------------------------------------------------------

  set pushNotifications(bool val) =>
      _preferences.setBool(_SettingsPreferenceKeys.pushNotifications, val);
  bool get pushNotifications =>
      _preferences.getBool(_SettingsPreferenceKeys.pushNotifications) ?? true;

  set bookingAlerts(bool val) =>
      _preferences.setBool(_SettingsPreferenceKeys.bookingAlerts, val);
  bool get bookingAlerts =>
      _preferences.getBool(_SettingsPreferenceKeys.bookingAlerts) ?? true;

  set opponentRequests(bool val) =>
      _preferences.setBool(_SettingsPreferenceKeys.opponentRequests, val);
  bool get opponentRequests =>
      _preferences.getBool(_SettingsPreferenceKeys.opponentRequests) ?? true;

  set promotionalEmails(bool val) =>
      _preferences.setBool(_SettingsPreferenceKeys.promotionalEmails, val);
  bool get promotionalEmails =>
      _preferences.getBool(_SettingsPreferenceKeys.promotionalEmails) ?? false;

  set biometricLogin(bool val) =>
      _preferences.setBool(_SettingsPreferenceKeys.biometricLogin, val);
  bool get biometricLogin =>
      _preferences.getBool(_SettingsPreferenceKeys.biometricLogin) ?? false;

  set darkMode(bool val) =>
      _preferences.setBool(_SettingsPreferenceKeys.darkMode, val);
  bool get darkMode =>
      _preferences.getBool(_SettingsPreferenceKeys.darkMode) ?? false;

  set appLanguage(String val) =>
      _preferences.setString(_SettingsPreferenceKeys.appLanguage, val);
  String get appLanguage =>
      _preferences.getString(_SettingsPreferenceKeys.appLanguage) ?? 'English';

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
