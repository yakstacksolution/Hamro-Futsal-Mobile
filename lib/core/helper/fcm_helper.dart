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
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/routers/notification_redirection.dart';
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
  await Firebase.initializeApp();
  debugPrint('FCM background message: ${message.messageId}');

  if (message.notification != null ||
      !isSupportedNotificationType(message.data['type']?.toString())) {
    return;
  }

  final localNotifications = FlutterLocalNotificationsPlugin();
  await localNotifications.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(),
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

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
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

  Future<void> init() async {
    if (_initialized) return;

    _nativeNavigationChannel.setMethodCallHandler((call) async {
      if (call.method == 'notificationTap') {
        _handleNativeNotificationData(call.arguments);
      }
    });

    try {
      await _initializeLocalNotifications();
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission: ${settings.authorizationStatus.name}');
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (error, stackTrace) {
      debugPrint('FCM initialization failed: $error\n$stackTrace');
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
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage);
      }
      if (Platform.isAndroid) {
        final nativeData = await _nativeNavigationChannel.invokeMethod<Object?>(
          'getLaunchNotification',
        );
        _handleNativeNotificationData(nativeData);
      }
    } catch (error) {
      debugPrint('FCM initial message failed: $error');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
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
    if (launchDetails?.didNotificationLaunchApp ?? false) {
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

    if (!isSupportedNotificationType(message.data['type']?.toString()) &&
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

  Future<void> syncTokenAfterLogin() async {
    if (!_isLoggedIn) return;
    try {
      final String? token = await _messaging.getToken();
      if (token == null || token.trim().isEmpty) return;
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
        debugPrint('FCM token registration was rejected by the backend.');
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
