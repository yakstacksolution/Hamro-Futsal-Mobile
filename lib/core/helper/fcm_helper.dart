import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/manager/authmanager/auth_manager.dart';
import 'package:hamro_futsal/core/firebase/firebase_platform_support.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/routers/notification_redirection.dart';
import 'package:hamro_futsal/firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';

const AndroidNotificationChannel _notificationChannel =
    AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'Important updates from Hamro Futsal.',
      importance: Importance.max,
      showBadge: true,
    );

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!FirebasePlatformSupport.messaging) return;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('FCM background message: ${message.messageId}');

  if (message.notification != null ||
      !isSupportedNotificationPayload(message.data)) {
    return;
  }

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
    ),
  );
  await localNotifications
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(_notificationChannel);
  await localNotifications.show(
    id: _notificationId(message),
    title: _notificationTitle(message),
    body: _notificationBody(message),
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannel.id,
        _notificationChannel.name,
        channelDescription: _notificationChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: 'mipmap/launcher_icon',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      macOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(message.data),
  );
}

int _notificationId(RemoteMessage message) =>
    int.tryParse(message.data['message_id']?.toString() ?? '') ??
    message.messageId?.hashCode ??
    DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

String _notificationTitle(RemoteMessage message) {
  final value =
      (message.notification?.title ??
              message.data['title'] ??
              message.data['sender_name'])
          ?.toString()
          .trim() ??
      '';
  return value.isEmpty ? 'Hamro Futsal' : value;
}

String _notificationBody(RemoteMessage message) {
  final value =
      (message.notification?.body ??
              message.data['body'] ??
              message.data['message'])
          ?.toString()
          .trim() ??
      '';
  return value.isEmpty ? 'You have a new notification.' : value;
}

class FcmHelper {
  FcmHelper._internal();

  static final FcmHelper _instance = FcmHelper._internal();

  factory FcmHelper() => _instance;

  /// Read lazily: on Windows / Linux Firebase is never initialised, and
  /// touching `FirebaseMessaging.instance` there throws — which used to break
  /// login, since every login path builds this helper to sync the token.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  /// Firebase Messaging runs on Android, iOS and macOS only (Windows and
  /// Linux have no implementation), and only once Firebase is initialised.
  static bool get isPushSupported {
    return FirebasePlatformSupport.messaging && Firebase.apps.isNotEmpty;
  }

  bool _loggedUnsupported = false;

  /// True when push can run here; says once why not when it cannot.
  bool _pushAvailable() {
    if (isPushSupported) return true;
    if (!_loggedUnsupported) {
      _loggedUnsupported = true;
      debugPrint(
        'FCM: push notifications are not available on '
        '${kIsWeb ? 'web' : Platform.operatingSystem} '
        '(Firebase Messaging supports Android, iOS and macOS).',
      );
    }
    return false;
  }

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _nativeNavigationChannel = MethodChannel(
    'com.np.hamrofutsal/notification_navigation',
  );

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundMessageSub;
  StreamSubscription<RemoteMessage>? _openedMessageSub;

  String? _lastPushedToken;

  bool _initialized = false;
  // The launch notification is read from three places (Firebase's initial
  // message, the local-notifications launch details, the Android intent), and
  // each keeps returning the same value for the life of the process. Opening
  // the app again would otherwise navigate as if the user had tapped, so the
  // launch is handled once and later reads are dropped.
  bool _launchNotificationHandled = false;

  Future<void> init() async {
    if (_initialized || !_pushAvailable()) return;

    _nativeNavigationChannel.setMethodCallHandler((call) async {
      if (call.method == 'notificationTap') {
        _handleNativeNotificationData(call.arguments);
      }
    });

    try {
      await _initializeLocalNotifications();
    } catch (error, stackTrace) {
      debugPrint('Local notifications setup failed: $error\n$stackTrace');
    }

    // A refusal is the user's (or the system's) answer, not a failure: macOS
    // reports notifications switched off for the app in System Settings as an
    // error ("Notifications are not allowed for this application"). Say so in
    // one line and carry on — the rest of the setup does not depend on it.
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus.name}');
    } catch (error) {
      debugPrint(
        'FCM permission not granted: $error'
        '${Platform.isMacOS ? ' — allow it in System Settings → '
                  'Notifications → hamro_futsal.' : ''}',
      );
    }

    try {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error) {
      debugPrint('FCM presentation options failed: $error');
    }

    _tokenRefreshSub = _messaging.onTokenRefresh.listen(
      (String token) {
        if (_isLoggedIn) {
          unawaited(_pushToken(token));
        }
      },
      onError: (Object error) => debugPrint('FCM token refresh failed: $error'),
    );
    _foregroundMessageSub = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
      onError: (Object error) =>
          debugPrint('FCM foreground listener failed: $error'),
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _openedMessageSub = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
      onError: (Object error) =>
          debugPrint('FCM notification tap listener failed: $error'),
    );

    _initialized = true;
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null && _takeLaunchSlot()) {
        _handleNotificationTap(initialMessage);
      }
      if (Platform.isAndroid) {
        final nativeData = await _nativeNavigationChannel.invokeMethod<Object?>(
          'getLaunchNotification',
        );
        if (nativeData != null && _takeLaunchSlot()) {
          _handleNativeNotificationData(nativeData);
        }
      }
    } catch (error) {
      debugPrint('FCM initial message failed: $error');
    }
  }

  /// True the first time a launch notification is claimed; false afterwards,
  /// so the same launch is not replayed by another source or a later init.
  /// Taps that arrive while the app runs do not go through this.
  bool _takeLaunchSlot() {
    if (_launchNotificationHandled) return false;
    _launchNotificationHandled = true;
    return true;
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) =>
          _handleLocalNotificationPayload(response.payload),
    );

    final android = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_notificationChannel);
    await android?.requestNotificationsPermission();

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if ((launchDetails?.didNotificationLaunchApp ?? false) &&
        _takeLaunchSlot()) {
      _handleLocalNotificationPayload(
        launchDetails?.notificationResponse?.payload,
      );
    }
  }

  void _handleLocalNotificationPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        _handleNotificationData(Map<String, dynamic>.from(decoded));
      }
    } catch (error) {
      debugPrint('Invalid notification payload: $error');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (!Platform.isAndroid) return;

    if (!isSupportedNotificationPayload(message.data) &&
        message.notification == null) {
      debugPrint('Ignoring unsupported FCM data message: ${message.data}');
      return;
    }

    await _localNotifications.show(
      id: _notificationId(message),
      title: _notificationTitle(message),
      body: _notificationBody(message),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _notificationChannel.id,
          _notificationChannel.name,
          channelDescription: _notificationChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: 'mipmap/launcher_icon',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    notificationRedirection(data['type']?.toString() ?? '', payloadData: data);
  }

  void _handleNativeNotificationData(dynamic raw) {
    if (raw is! Map) return;
    final data = raw.map<String, dynamic>(
      (key, value) => MapEntry(key.toString(), value),
    );

    final localPayload = data['payload'];
    if (localPayload is String && localPayload.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(localPayload);
        if (decoded is Map) {
          _handleNotificationData(Map<String, dynamic>.from(decoded));
          return;
        }
      } catch (error) {
        debugPrint('Invalid native notification payload: $error');
      }
    }
    _handleNotificationData(data);
  }

  /// Whether this platform can produce an FCM token right now.
  ///
  /// * iOS / macOS: FCM needs the device's APNs token first, and asking before
  ///   it arrives throws `apns-token-not-set`. It is waited for briefly; if it
  ///   never comes (a macOS build without the Push Notifications capability,
  ///   or a simulator), the sync is skipped quietly — [onTokenRefresh] still
  ///   registers the token if APNs delivers one later.
  Future<bool> _canGetToken() async {
    if (!Platform.isIOS && !Platform.isMacOS) return true;
    for (int attempt = 0; attempt < _apnsAttempts; attempt++) {
      try {
        final String? apns = await _messaging.getAPNSToken();
        if (apns != null && apns.isNotEmpty) return true;
      } catch (_) {
        // Not ready yet; try again below.
      }
      await Future<void>.delayed(_apnsRetryDelay);
    }
    if (!_loggedMissingApns) {
      _loggedMissingApns = true;
      debugPrint(
        'FCM: no APNs token yet, so the push token is not registered. Check '
        'that notifications are allowed for the app and that the build is '
        'signed with the Push Notifications capability (aps-environment).',
      );
    }
    return false;
  }

  static const int _apnsAttempts = 5;
  static const Duration _apnsRetryDelay = Duration(seconds: 2);
  bool _loggedMissingApns = false;

  Future<void> syncTokenAfterLogin() async {
    if (!_isLoggedIn || !_pushAvailable()) return;
    if (!await _canGetToken()) return;
    try {
      final String? token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) return;
      // Debug only: paste it into Firebase console → Messaging → "Send test
      // message" to check delivery to this device, backend aside.
      if (kDebugMode) {
        debugPrint('FCM token (${Platform.operatingSystem}): $token');
      }
      await _pushToken(token);
    } catch (error, stackTrace) {
      debugPrint('FCM token sync failed: $error\n$stackTrace');
    }
  }

  void reset() {
    _lastPushedToken = null;
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundMessageSub?.cancel();
    await _openedMessageSub?.cancel();
    _tokenRefreshSub = null;
    _foregroundMessageSub = null;
    _openedMessageSub = null;
    _initialized = false;
  }

  void _handleNotificationTap(RemoteMessage message) {
    _handleNotificationData(message.data);
  }

  bool get _isLoggedIn =>
      AppSettings().tokenModel.accessToken?.trim().isNotEmpty ?? false;

  Future<void> _pushToken(String token) async {
    if (token.trim().isEmpty || token == _lastPushedToken) return;

    try {
      final Map<String, dynamic> payload = await _buildPayload(token);
      final Result result = await AuthManager().updateFcmToken(payload);
      if (result.isSuccess()) {
        _lastPushedToken = token;
        debugPrint('FCM token registered with the backend.');
      } else {
        // The backend's reason (e.g. a `platform` it does not accept) is the
        // one thing needed to fix a rejected registration.
        final Object? error = result.isError() ? result.getErrorMsg() : null;
        debugPrint(
          'FCM token registration was rejected by the backend'
          '${error is DataError ? ' (${error.errorCode}): ${error.message} ${error.data ?? ''}' : '.'}'
          ' — payload platform: ${payload['platform']}',
        );
      }
    } catch (error, stackTrace) {
      debugPrint('FCM token registration failed: $error\n$stackTrace');
    }
  }

  Future<Map<String, dynamic>> _buildPayload(String token) async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final _DeviceIdentity device = await _resolveDevice();

    return <String, dynamic>{
      'token': token,
      'platform': device.platform,
      'device_id': device.id,
      'device_name': device.name,
      'app_version': packageInfo.version,
    };
  }

  Future<_DeviceIdentity> _resolveDevice() async {
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo info = await _deviceInfo.androidInfo;
        final String name = '${info.manufacturer} ${info.model}'.trim();
        return _DeviceIdentity(
          platform: 'android',
          id: info.id,
          name: name.isEmpty ? 'Android device' : name,
        );
      }
      if (Platform.isIOS) {
        final IosDeviceInfo info = await _deviceInfo.iosInfo;
        return _DeviceIdentity(
          platform: 'ios',
          id: info.identifierForVendor ?? info.name,
          name: info.name,
        );
      }
      if (Platform.isMacOS) {
        // A stable id per Mac, so two Macs on one account each keep their
        // own token instead of sharing (and overwriting) 'unknown'.
        final MacOsDeviceInfo info = await _deviceInfo.macOsInfo;
        final String name = info.computerName.trim().isNotEmpty
            ? info.computerName.trim()
            : info.modelName;
        return _DeviceIdentity(
          platform: 'macos',
          id: info.systemGUID?.trim().isNotEmpty == true
              ? info.systemGUID!.trim()
              : '${info.model}-${info.hostName}',
          name: name.isEmpty ? 'Mac' : name,
        );
      }
    } catch (_) {}

    return _DeviceIdentity(
      platform: Platform.operatingSystem,
      id: 'unknown',
      name: Platform.operatingSystem,
    );
  }
}

class _DeviceIdentity {
  const _DeviceIdentity({
    required this.platform,
    required this.id,
    required this.name,
  });

  final String platform;
  final String id;
  final String name;
}
