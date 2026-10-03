import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/config/app_environment.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';

/// Whether `google_maps_flutter` can draw a native map here.
///
/// The plugin ships Android, iOS and web implementations only; on macOS,
/// Windows and Linux a `GoogleMap` renders "TargetPlatform.x is not yet
/// supported by the maps plugin". Those platforms use [StaticGoogleMap].
bool get supportsNativeGoogleMap =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS;

/// A Google map of one point, drawn from the Maps Static API — the desktop
/// stand-in for `GoogleMap`, using the same `GOOGLE_MAPS_API_KEY` the
/// Android and iOS builds use.
///
/// The image is requested at the box's own size (Static API sizes cap at
/// 640×640 logical, doubled by `scale=2` for sharp Retina output) with the
/// venue pinned in the brand colour. It is a picture, not an interactive map:
/// callers add their own zoom controls by changing [zoom].
class StaticGoogleMap extends StatelessWidget {
  const StaticGoogleMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 15,
    this.placeholderColor = const Color(0xFFE0E0E0),
  });

  final double latitude;
  final double longitude;

  /// Google zoom level, 0 (world) to 21 (building).
  final int zoom;

  /// Shown while the image loads.
  final Color placeholderColor;

  /// The Static API's largest `size` per side.
  static const int _maxSide = 640;

  static String _hex(Color color) {
    final int argb = color.toARGB32();
    return '0x${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
  }

  Uri _uri(int width, int height) {
    final String point = '$latitude,$longitude';
    return Uri.https(
      'maps.googleapis.com',
      '/maps/api/staticmap',
      <String, String>{
        'center': point,
        'zoom': '${zoom.clamp(0, 21)}',
        'size': '${width}x$height',
        'scale': '2',
        'maptype': 'roadmap',
        'markers': 'color:${_hex(LightColor.secondaryColor)}|$point',
        'key': AppEnvironment.read('GOOGLE_MAPS_API_KEY'),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // Whole pixels, within the API's limits; the image is then scaled to
        // cover the box, so a box wider than 640 still fills edge to edge.
        final int width = math
            .min(
              constraints.maxWidth.isFinite ? constraints.maxWidth : 600,
              _maxSide.toDouble(),
            )
            .round()
            .clamp(1, _maxSide);
        final int height = math
            .min(
              constraints.maxHeight.isFinite ? constraints.maxHeight : 300,
              _maxSide.toDouble(),
            )
            .round()
            .clamp(1, _maxSide);
        return ColoredBox(
          color: placeholderColor,
          child: Image.network(
            _uri(width, height).toString(),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            // Keeps the current map on screen while a new zoom level loads.
            gaplessPlayback: true,
            loadingBuilder:
                (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? progress,
                ) {
                  if (progress == null) return child;
                  return const Center(
                    child: SizedBox.square(
                      dimension: AppDimens.sizeX24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: LightColor.secondaryColor,
                      ),
                    ),
                  );
                },
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stack) =>
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.map_outlined,
                            size: AppDimens.sizeX28,
                            color: LightColor.secondaryTextColor,
                          ),
                          const SizedBox(height: AppDimens.sizeX6),
                          Text(
                            'Map preview unavailable',
                            style: TextStyle(
                              color: LightColor.secondaryTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }
}
