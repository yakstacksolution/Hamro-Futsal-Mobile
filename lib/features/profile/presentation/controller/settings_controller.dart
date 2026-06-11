import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';

/// Holds the user's app preferences and keeps them in sync with persistent
/// storage. Every mutation writes through to [AppSettings] immediately and
/// notifies listeners, so the Settings page survives restarts without any
/// per-screen plumbing.
class SettingsController extends ChangeNotifier {
  SettingsController({AppSettings? settings})
    : _settings = settings ?? AppSettings() {
    _load();
  }

  final AppSettings _settings;

  late bool _pushNotifications;
  late bool _bookingAlerts;
  late bool _opponentRequests;
  late bool _promotionalEmails;
  late bool _biometricLogin;
  late bool _darkMode;
  late String _language;

  bool get pushNotifications => _pushNotifications;
  bool get bookingAlerts => _bookingAlerts;
  bool get opponentRequests => _opponentRequests;
  bool get promotionalEmails => _promotionalEmails;
  bool get biometricLogin => _biometricLogin;
  bool get darkMode => _darkMode;
  String get language => _language;

  /// Languages the app advertises in the picker.
  static const List<String> languages = <String>['English', 'नेपाली', 'हिन्दी'];

  void _load() {
    _pushNotifications = _settings.pushNotifications;
    _bookingAlerts = _settings.bookingAlerts;
    _opponentRequests = _settings.opponentRequests;
    _promotionalEmails = _settings.promotionalEmails;
    _biometricLogin = _settings.biometricLogin;
    _darkMode = _settings.darkMode;
    _language = _settings.appLanguage;
  }

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    _settings.pushNotifications = value;
    notifyListeners();
  }

  void setBookingAlerts(bool value) {
    if (_bookingAlerts == value) return;
    _bookingAlerts = value;
    _settings.bookingAlerts = value;
    notifyListeners();
  }

  void setOpponentRequests(bool value) {
    if (_opponentRequests == value) return;
    _opponentRequests = value;
    _settings.opponentRequests = value;
    notifyListeners();
  }

  void setPromotionalEmails(bool value) {
    if (_promotionalEmails == value) return;
    _promotionalEmails = value;
    _settings.promotionalEmails = value;
    notifyListeners();
  }

  void setBiometricLogin(bool value) {
    if (_biometricLogin == value) return;
    _biometricLogin = value;
    _settings.biometricLogin = value;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_darkMode == value) return;
    _darkMode = value;
    _settings.darkMode = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    if (_language == value) return;
    _language = value;
    _settings.appLanguage = value;
    notifyListeners();
  }
}
