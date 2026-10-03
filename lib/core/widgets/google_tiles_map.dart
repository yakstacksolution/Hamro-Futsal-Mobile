import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// A session for Google's Map Tiles API, shared by every desktop map.
///
/// Tile requests must carry a session token from `createSession`; one lasts
/// about two weeks, so it is fetched once and reused until shortly before it
/// expires. Resolves to null when the API is unavailable — not enabled for the
/// key, offline — and callers then fall back to a static map.
abstract final class GoogleMapTilesSession {
  static String? _token;
  static DateTime? _expiresAt;
  static Future<String?>? _pending;

  static String get _key => AppEnvironment.read('GOOGLE_MAPS_API_KEY');

  /// `{z}/{x}/{y}` template for [TileLayer], or null without a session.
  static Future<String?> urlTemplate() async {
    final String? token = await _session();
    if (token == null) return null;
    return 'https://tile.googleapis.com/v1/2dtiles/{z}/{x}/{y}'
        '?session=$token&key=$_key';
  }

  static Future<String?> _session() {
    final DateTime? expiresAt = _expiresAt;
    if (_token != null &&
        expiresAt != null &&
        DateTime.now().isBefore(
          expiresAt.subtract(const Duration(minutes: 10)),
        )) {
      return Future<String?>.value(_token);
    }
    return _pending ??= _create().whenComplete(() => _pending = null);
  }

  static Future<String?> _create() async {
    if (_key.isEmpty) return null;
    try {
      final http.Response response = await http
          .post(
            Uri.https(
              'tile.googleapis.com',
              '/v1/createSession',
              <String, String>{'key': _key},
            ),
            headers: const <String, String>{'Content-Type': 'application/json'},
            body: jsonEncode(<String, Object>{
              'mapType': 'roadmap',
              'language': 'en-US',
              'region': 'NP',
              // 512px tiles drawn into 256px cells: sharp on Retina screens.
              'scale': 'scaleFactor2x',
              'highDpi': true,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        if (kDebugMode) {
          // Google's own reason — e.g. SERVICE_DISABLED when the Map Tiles
          // API is not enabled in the key's Cloud project. The picker falls
          // back to OpenStreetMap tiles meanwhile.
          debugPrint(
            '[GoogleMapTiles] createSession ${response.statusCode} '
            '(${AppEnvironment.name} key): ${response.body}',
          );
        }
        return null;
      }
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final String? token = body['session'] as String?;
      if (token == null || token.isEmpty) return null;
      final int? expiry = int.tryParse('${body['expiry'] ?? ''}');
      _token = token;
      _expiresAt = expiry == null
          ? DateTime.now().add(const Duration(days: 1))
          : DateTime.fromMillisecondsSinceEpoch(expiry * 1000);
      return token;
    } catch (_) {
      return null;
    }
  }
}

/// OpenStreetMap's public tiles: no key needed. The fallback while Google's
/// Map Tiles API is unavailable (not enabled for the key, quota), so a map
/// that must be interactive — the location picker — still works.
abstract final class OsmTiles {
  static const String urlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String attribution = '© OpenStreetMap contributors';

  /// OSM serves tiles up to zoom 19.
  static const int maxNativeZoom = 19;
}

/// A draggable, zoomable Google map of one point for macOS / desktop, where
/// `google_maps_flutter` has no implementation: Google's own tiles (Map Tiles
/// API, same key as Android and iOS) drawn by `flutter_map`.
///
/// Drag to pan, scroll / pinch / double-click to zoom. [controller] lets the
/// page drive zoom and recentre buttons.
class GoogleTilesMap extends StatelessWidget {
  const GoogleTilesMap({
    super.key,
    required this.urlTemplate,
    required this.latitude,
    required this.longitude,
    required this.controller,
    this.initialZoom = 16,
    this.bottomPadding = 0,
    this.showMarker = true,
    this.onTap,
    this.onMapReady,
    this.attribution = 'Google',
    this.maxNativeZoom = 20,
  });

  /// From [GoogleMapTilesSession.urlTemplate].
  final String urlTemplate;
  final double latitude;
  final double longitude;
  final MapController controller;
  final double initialZoom;

  /// Keeps the attribution clear of anything floating over the map's foot.
  final double bottomPadding;

  /// False while nothing is pinned yet (a location picker).
  final bool showMarker;

  /// A tap on the map, at that point (a location picker pins it).
  final void Function(double latitude, double longitude)? onTap;

  /// [controller] may be driven only after this fires.
  final VoidCallback? onMapReady;

  /// Credit for [urlTemplate]'s tiles, drawn on the map as their terms ask.
  final String attribution;

  /// Deepest zoom [urlTemplate] serves; deeper zooms upscale it.
  final int maxNativeZoom;

  static const double minZoom = 3;
  static const double maxZoom = 20;

  @override
  Widget build(BuildContext context) {
    final LatLng point = LatLng(latitude, longitude);
    return FlutterMap(
      mapController: controller,
      options: MapOptions(
        initialCenter: point,
        initialZoom: initialZoom,
        minZoom: minZoom,
        maxZoom: maxZoom,
        backgroundColor: LightColor.background,
        onMapReady: onMapReady,
        onTap: onTap == null
            ? null
            : (TapPosition _, LatLng at) => onTap!(at.latitude, at.longitude),
        interactionOptions: const InteractionOptions(
          // Pan, pinch, scroll-wheel and double-tap zoom; no rotation, to
          // match the phone map.
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: urlTemplate,
          maxNativeZoom: maxNativeZoom,
          maxZoom: maxZoom,
          userAgentPackageName: 'com.hamrofutsal.app',
          tileDisplay: const TileDisplay.fadeIn(
            duration: Duration(milliseconds: 120),
          ),
        ),
        MarkerLayer(
          markers: <Marker>[
            if (showMarker)
              Marker(
                point: point,
                width: 44,
                height: 44,
                alignment: Alignment.topCenter,
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 44,
                  color: LightColor.secondaryColor,
                  shadows: <Shadow>[
                    Shadow(color: Color(0x55000000), blurRadius: 6),
                  ],
                ),
              ),
          ],
        ),
        // The tiles' provider must be credited on the map.
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: SimpleAttributionWidget(
            source: Text(attribution),
            alignment: Alignment.bottomLeft,
          ),
        ),
      ],
    );
  }
}
