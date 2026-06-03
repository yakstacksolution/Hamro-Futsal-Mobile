import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class VenueDistanceHelper {
  VenueDistanceHelper._();

  static final VenueDistanceHelper instance = VenueDistanceHelper._();

  final ValueNotifier<Position?> position = ValueNotifier<Position?>(null);

  Future<void>? _inFlight;
  DateTime? _lastFreshFixAt;

  static const Duration _staleAfter = Duration(minutes: 5);

  static const Duration _fixTimeout = Duration(seconds: 10);

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

  void _log(String message) {
    if (kDebugMode) debugPrint('[VenueDistanceHelper] $message');
  }

  /// Geodesic distance in meters from the current fix to ([latitude],
  /// [longitude]), or null when there is no fix or the venue has no
  /// coordinates.
  double? distanceMeters(double latitude, double longitude) {
    final Position? fix = position.value;
    if (fix == null || (latitude == 0 && longitude == 0)) return null;
    return Geolocator.distanceBetween(
      fix.latitude,
      fix.longitude,
      latitude,
      longitude,
    );
  }

  String? formatDistance(dynamic latitude, dynamic longitude) {
    final double? lat = _toDouble(latitude);
    final double? lng = _toDouble(longitude);

    if (lat == null || lng == null) return null;

    final double? meters = distanceMeters(lat, lng);
    if (meters == null) return null;

    if (meters < 1000) return '${meters.round()} m';

    final double km = meters / 1000;
    return km < 10 ? '${km.toStringAsFixed(1)} km' : '${km.round()} km';
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
