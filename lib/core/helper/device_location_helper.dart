import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// The device's location, shared app-wide.
///
/// Venue distances are computed server-side now (`distance_km` in the venue
/// listing), so this helper only acquires and publishes a fix — the coordinates
/// sent as `latitude`/`longitude` with `GET /venues`, and used by the chat
/// location share.
///
/// [position] is a notifier so widgets can rebuild on the first GPS lock
/// without polling, and [ensurePosition] de-duplicates concurrent callers.
class DeviceLocationHelper {
  DeviceLocationHelper._();

  static final DeviceLocationHelper instance = DeviceLocationHelper._();

  /// The latest known fix, or null before one is acquired (or when permission
  /// is denied / location services are off).
  final ValueNotifier<Position?> position = ValueNotifier<Position?>(null);

  Future<void>? _inFlight;
  DateTime? _lastFreshFixAt;

  /// How long a fix is reused before a new one is requested.
  static const Duration _staleAfter = Duration(minutes: 5);

  /// Cap on a single fix attempt, so a cold GPS start cannot hang a caller.
  static const Duration _fixTimeout = Duration(seconds: 10);

  /// Publishes a fix on [position] if the current one is missing or stale.
  ///
  /// Never throws: a denied permission or a dead GPS leaves [position] as-is,
  /// and callers fall back to whatever they can do without coordinates.
  Future<void> ensurePosition() {
    final DateTime? lastFix = _lastFreshFixAt;
    final bool isFresh =
        lastFix != null && DateTime.now().difference(lastFix) < _staleAfter;
    if (isFresh) return Future<void>.value();

    return _inFlight ??= _resolve().whenComplete(() => _inFlight = null);
  }

  Future<void> _resolve() async {
    if (!await _ensurePermission()) return;

    try {
      final Position? lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && position.value == null) {
        position.value = lastKnown;
      }
    } catch (error) {
      // Cached fix is a best-effort optimisation only.
      _log('getLastKnownPosition failed: $error');
    }

    try {
      position.value = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(_fixTimeout);
      _lastFreshFixAt = DateTime.now();
    } catch (error) {
      // Keep whatever fix (if any) is already published.
      _log('getCurrentPosition failed: $error');
    }
  }

  Future<bool> _ensurePermission() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        _log('Location services are disabled on this device.');
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Triggers the system "Allow location?" dialog on both platforms.
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _log(
          'Location permission permanently denied — enable it from app '
          'settings (Geolocator.openAppSettings()).',
        );
        return false;
      }
      final bool granted =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
      if (!granted) _log('Location permission denied: $permission');
      return granted;
    } catch (error) {
      // A MissingPluginException here means the app binary was not rebuilt
      // after adding geolocator — hot reload cannot register native plugins.
      _log('Permission check failed: $error');
      return false;
    }
  }

  /// Opens the OS app-settings page so the user can grant a permanently
  /// denied location permission.
  Future<void> openAppSettings() => Geolocator.openAppSettings();

  /// `1.2 km` / `450 m` — the venue distance as returned by the API.
  static String? formatKm(double? km) {
    if (km == null || km.isNaN || km < 0) return null;
    if (km < 1) return '${(km * 1000).round()} m';
    return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[DeviceLocation] $message');
  }
}
