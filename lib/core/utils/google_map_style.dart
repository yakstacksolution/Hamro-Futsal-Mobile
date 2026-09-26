import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';

/// The venue pin, tinted to the brand colour so every map in the app marks a
/// venue the same way.
Marker venueMarker(MarkerId id, LatLng position, {String? title}) {
  return Marker(
    markerId: id,
    position: position,
    icon: BitmapDescriptor.defaultMarkerWithHue(
      HSVColor.fromColor(LightColor.secondaryColor).hue,
    ),
    infoWindow: title == null || title.trim().isEmpty
        ? InfoWindow.noText
        : InfoWindow(title: title.trim()),
  );
}
