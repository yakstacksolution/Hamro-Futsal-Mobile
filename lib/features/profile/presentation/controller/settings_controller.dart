import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/security/biometric_auth_service.dart';
import 'package:hamro_futsal/core/theme/app_theme_controller.dart';
import 'package:hamro_futsal/core/security/biometric_session_store.dart';
import 'package:hamro_futsal/features/profile/data/model/profile_model.dart';
import 'package:hamro_futsal/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:hamro_futsal/features/profile/domain/usecase/profile_usecase.dart';

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
  late NotificationPreferences _syncedNotificationPrefs;
  bool _notificationPrefsEdited = false;
  bool _notificationSyncing = false;
  bool _disposed = false;

  /// Signed-in user's id, from `/auth/me`. Kept for pages that need account
  /// context; deletion itself now targets the signed-in account directly.
  int? _userId;
  bool _deletingAccount = false;

  /// True once `/auth/me` has answered, either way. Distinguishes "still
  /// loading" from "loaded, but the fetch failed" for the delete row.
  bool _profileResolved = false;

  bool get pushNotifications => _pushNotifications;
  bool get bookingAlerts => _bookingAlerts;
  bool get opponentRequests => _opponentRequests;
  bool get promotionalEmails => _promotionalEmails;
  bool get biometricLogin => _biometricLogin;
  bool get darkMode => _darkMode;
  String get language => _language;
  int? get userId => _userId;
  bool get deletingAccount => _deletingAccount;
  bool get profileResolved => _profileResolved;

  /// Whether the account can be deleted yet.
  bool get canDeleteAccount => !_deletingAccount;

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
    _syncedNotificationPrefs = _currentNotificationPrefs;
  }

  /// The server is the source of truth for the notification flags — refresh
  /// them from `/auth/me` so the toggles reflect the stored preferences.
  Future<void> _seedNotificationPrefsFromProfile() async {
    final result = await _profileUseCase.getProfile();
    _profileResolved = true;
    result.fold(
      (_) {
        // Offline or failed fetch: keep the locally cached values.
      },
      (profile) {
        _userId = profile.data.id;
        final NotificationPreferences serverPrefs =
            profile.data.notificationPreferences;
        _syncedNotificationPrefs = serverPrefs;
        if (_notificationPrefsEdited) {
          _scheduleNotificationSync();
          return;
        }
        _applyNotificationPrefs(serverPrefs);
        _notifyIfActive();
      },
    );
    // The id arrives on the success path only; notify either way so a
    // successful fetch that changed no toggle still enables the delete row.
    _notifyIfActive();
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

  /// Serializes full-set updates. If several switches are tapped quickly, the
  /// newest state is posted after the in-flight request rather than racing it.
  Future<void> _scheduleNotificationSync() async {
    if (_notificationSyncing || _disposed) return;
    _notificationSyncing = true;
    while (!_disposed &&
        _syncedNotificationPrefs != _currentNotificationPrefs) {
      final NotificationPreferences target = _currentNotificationPrefs;
      final result = await _profileUseCase.updateNotificationPreferences(
        target,
      );
      if (_disposed) break;
      result.fold((failure) {
        // Only revert when the failed request still represents the visible
        // state. A newer user choice must never be overwritten by an older
        // response.
        if (_currentNotificationPrefs == target) {
          _applyNotificationPrefs(_syncedNotificationPrefs);
          _notifyIfActive();
        }
        onError?.call(failure.errorMessage);
      }, (_) => _syncedNotificationPrefs = target);
    }
    _notificationSyncing = false;
  }

  void _notificationChanged() {
    _notificationPrefsEdited = true;
    _notifyIfActive();
    _scheduleNotificationSync();
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    _settings.pushNotifications = value;
    _notificationChanged();
  }

  void setBookingAlerts(bool value) {
    if (_bookingAlerts == value) return;
    _bookingAlerts = value;
    _settings.bookingAlerts = value;
    _notificationChanged();
  }

  void setOpponentRequests(bool value) {
    if (_opponentRequests == value) return;
    _opponentRequests = value;
    _settings.opponentRequests = value;
    _notificationChanged();
  }

  void setPromotionalEmails(bool value) {
    if (_promotionalEmails == value) return;
    _promotionalEmails = value;
    _settings.promotionalEmails = value;
    _notificationChanged();
  }

  Future<void> setBiometricLogin(bool value) async {
    if (_biometricLogin == value) return;
    if (value) {
      final BiometricAuthService biometricAuth = BiometricAuthService();
      if (!await biometricAuth.isAvailable()) {
        onError?.call(
          'Face ID or fingerprint is not available on this device.',
        );
        return;
      }
      if (!await biometricAuth.authenticate()) return;
      await BiometricSessionStore().save(_settings.tokenModel);
    } else {
      await BiometricSessionStore().clear();
    }
    _biometricLogin = value;
    _settings.biometricLogin = value;
    _notifyIfActive();
  }

  void setDarkMode(bool value) {
    if (_darkMode == value) return;
    _darkMode = value;
    AppThemeController.instance.setDarkMode(value);
    _notifyIfActive();
  }

  void setLanguage(String value) {
    if (_language == value) return;
    _language = value;
    _settings.appLanguage = value;
    _notifyIfActive();
  }

  /// `DELETE /auth/account` — irreversible. The repository clears
  /// the token, the biometric session and the socket on success, so the caller
  /// only has to navigate away from the signed-in shell.
  ///
  /// Returns true when the account was deleted; failures are reported through
  /// [onError] and leave the session untouched.
  Future<bool> deleteAccount({required String reason}) async {
    final String trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      onError?.call('Please add a reason for deleting your account.');
      return false;
    }
    if (_deletingAccount) return false;
    _deletingAccount = true;
    _notifyIfActive();

    final result = await _profileUseCase.deleteAccount(reason: trimmedReason);
    _deletingAccount = false;
    _notifyIfActive();

    return result.fold(
      (failure) {
        onError?.call(failure.errorMessage);
        return false;
      },
      (_) {
        // The biometric switch is off now that its stored session is gone.
        _biometricLogin = false;
        return true;
      },
    );
  }

  @override
  void dispose() {
    _disposed = true;
    onError = null;
    super.dispose();
  }
}
