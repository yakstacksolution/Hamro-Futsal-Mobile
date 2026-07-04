import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';
import 'package:hamro_footsall/features/profile/data/model/profile_model.dart';
import 'package:hamro_footsall/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_footsall/features/profile/domain/usecase/profile_usecase.dart';

/// Holds the user's app preferences and keeps them in sync with persistent
/// storage. Every mutation writes through to [AppSettings] immediately and
/// notifies listeners, so the Settings page survives restarts without any
/// per-screen plumbing.
///
/// The four notification flags are server-backed: their current values are
/// seeded from `GET /auth/me` and every toggle posts the full set to
/// `POST /auth/notification-preferences` (optimistically — the switch flips
/// at once and reverts if the call fails).
class SettingsController extends ChangeNotifier {
  SettingsController({AppSettings? settings, ProfileUseCase? profileUseCase})
    : _settings = settings ?? AppSettings(),
      _profileUseCase =
          profileUseCase ?? ProfileUseCase(ProfileRepositoryImpl()) {
    _load();
    _seedNotificationPrefsFromProfile();
  }

  final AppSettings _settings;
  final ProfileUseCase _profileUseCase;

  /// Surfaces sync failures (e.g. as a snackbar); set by the Settings page.
  ValueChanged<String>? onError;

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

  /// The server is the source of truth for the notification flags — refresh
  /// them from `/auth/me` so the toggles reflect the stored preferences.
  Future<void> _seedNotificationPrefsFromProfile() async {
    final result = await _profileUseCase.getProfile();
    result.fold(
      (_) {
        // Offline or failed fetch: keep the locally cached values.
      },
      (profile) {
        _applyNotificationPrefs(profile.data.notificationPreferences);
        notifyListeners();
      },
    );
  }

  void _applyNotificationPrefs(NotificationPreferences prefs) {
    _pushNotifications = prefs.pushNotification;
    _bookingAlerts = prefs.bookingAlert;
    _opponentRequests = prefs.opponentRequest;
    _promotionalEmails = prefs.promotionalEmails;
    _settings.pushNotifications = prefs.pushNotification;
    _settings.bookingAlerts = prefs.bookingAlert;
    _settings.opponentRequests = prefs.opponentRequest;
    _settings.promotionalEmails = prefs.promotionalEmails;
  }

  NotificationPreferences get _currentNotificationPrefs =>
      NotificationPreferences(
        pushNotification: _pushNotifications,
        bookingAlert: _bookingAlerts,
        opponentRequest: _opponentRequests,
        promotionalEmails: _promotionalEmails,
      );

  /// Posts the full preference set; on failure restores [previous] so the
  /// switch snaps back and the page can show the error.
  Future<void> _syncNotificationPrefs(NotificationPreferences previous) async {
    final result = await _profileUseCase.updateNotificationPreferences(
      _currentNotificationPrefs,
    );
    result.fold((failure) {
      _applyNotificationPrefs(previous);
      notifyListeners();
      onError?.call(failure.errorMessage);
    }, (_) {});
  }

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    final previous = _currentNotificationPrefs;
    _pushNotifications = value;
    _settings.pushNotifications = value;
    notifyListeners();
    _syncNotificationPrefs(previous);
  }

  void setBookingAlerts(bool value) {
    if (_bookingAlerts == value) return;
    final previous = _currentNotificationPrefs;
    _bookingAlerts = value;
    _settings.bookingAlerts = value;
    notifyListeners();
    _syncNotificationPrefs(previous);
  }

  void setOpponentRequests(bool value) {
    if (_opponentRequests == value) return;
    final previous = _currentNotificationPrefs;
    _opponentRequests = value;
    _settings.opponentRequests = value;
    notifyListeners();
    _syncNotificationPrefs(previous);
  }

  void setPromotionalEmails(bool value) {
    if (_promotionalEmails == value) return;
    final previous = _currentNotificationPrefs;
    _promotionalEmails = value;
    _settings.promotionalEmails = value;
    notifyListeners();
    _syncNotificationPrefs(previous);
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
