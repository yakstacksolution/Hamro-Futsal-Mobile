import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' show MapController;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';

import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/google_map_style.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/google_tiles_map.dart';
import 'package:hamro_futsal/core/widgets/static_google_map.dart';

/// Full-screen, interactive map of a venue's location.
///
/// Pushed from [CourtLocationMapSection] when the user taps the preview /
/// "Open in Maps". Supports pan & zoom, recentre, and handing off to the
/// device maps app for turn-by-turn directions.
class CourtLocationMapPage extends StatefulWidget {
  const CourtLocationMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.venueName,
    this.address,
  });

  final double latitude;
  final double longitude;
  final String? venueName;
  final String? address;

  @override
  State<CourtLocationMapPage> createState() => _CourtLocationMapPageState();
}

class _CourtLocationMapPageState extends State<CourtLocationMapPage>
    with WidgetsBindingObserver {
  GoogleMapController? _mapController;
  bool _showMap = true;
  bool _handingOffToMaps = false;

  static const double _defaultZoom = 16;

  /// macOS / desktop: the live Google tiles map, once a tile session is
  /// granted. Null while it is being requested or when the Map Tiles API is
  /// unavailable, in which case the static image (and [_staticZoom]) is used.
  String? _tilesUrl;
  bool _tilesResolved = false;
  final MapController _tilesController = MapController();

  /// macOS / desktop fallback: the static map's zoom, stepped by +/-.
  int _staticZoom = _defaultZoom.toInt();

  bool get _usingTiles => _tilesUrl != null;

  Future<void> _resolveTiles() async {
    final String? url = await GoogleMapTilesSession.urlTemplate();
    if (!mounted) return;
    setState(() {
      _tilesUrl = url;
      _tilesResolved = true;
    });
  }

  /// The zoom the +/- buttons are bounded by. The live map clamps its own
  /// zoom (and is also zoomed by scroll and pinch), so its buttons stay on.
  double get _currentZoom =>
      _usingTiles ? _defaultZoom : _staticZoom.toDouble();

  void _zoomBy(int delta) {
    if (_usingTiles) {
      final double zoom = (_tilesController.camera.zoom + delta).clamp(
        GoogleTilesMap.minZoom,
        GoogleTilesMap.maxZoom,
      );
      _tilesController.move(_tilesController.camera.center, zoom);
      return;
    }
    setState(() => _staticZoom = (_staticZoom + delta).clamp(3, 20));
  }

  // Web Mercator cannot project the geographic poles.
  static const double _mercatorLatitudeLimit = 85.05112878;

  /// Guards against NaN/Infinity or out-of-range values reaching the map.
  bool get _hasValidPoint =>
      widget.latitude.isFinite &&
      widget.longitude.isFinite &&
      widget.latitude.abs() <= _mercatorLatitudeLimit &&
      widget.longitude.abs() <= 180;

  LatLng get _point => LatLng(widget.latitude, widget.longitude);

  void _recenter() {
    if (!supportsNativeGoogleMap) {
      if (_usingTiles) {
        _tilesController.move(
          ll.LatLng(widget.latitude, widget.longitude),
          _defaultZoom,
        );
        return;
      }
      setState(() => _staticZoom = _defaultZoom.toInt());
      return;
    }
    if (!_showMap) return;
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _point, zoom: _defaultZoom),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!supportsNativeGoogleMap) _resolveTiles();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _handingOffToMaps && mounted) {
      setState(() {
        _handingOffToMaps = false;
        _showMap = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _mapController?.dispose();
    _tilesController.dispose();
    super.dispose();
  }

  Future<void> _openInExternalMaps() async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${widget.latitude},${widget.longitude}',
    );
    if (_handingOffToMaps) return;
    // Desktop: the browser opens beside the app, and the static map holds no
    // GL surface worth releasing, so it stays on screen.
    if (!supportsNativeGoogleMap) {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        AppUtils().showSnackBar(
          context,
          MsgType.error,
          'Could not open the maps application.',
        );
      }
      return;
    }
    setState(() {
      _handingOffToMaps = true;
      // Tearing the map down releases its GL surface and tile memory before
      // Android backgrounds this activity for the maps app.
      _showMap = false;
      _mapController = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        setState(() {
          _handingOffToMaps = false;
          _showMap = true;
        });
        AppUtils().showSnackBar(
          context,
          MsgType.error,
          'Could not open the maps application.',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _handingOffToMaps = false;
        _showMap = true;
      });
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Could not open the maps application.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final String title = (widget.venueName ?? '').trim().isEmpty
        ? 'Location'
        : widget.venueName!.trim();
    final String addressText = widget.address?.trim() ?? '';
    final double bottomInset = MediaQuery.of(context).padding.bottom;

    if (!_hasValidPoint) {
      return Scaffold(
        backgroundColor: LightColor.background,
        appBar: CustomAppBar(title: title),
        body: Center(
          child: Padding(
            padding: AppUtils().getPadding(all: AppDimens.paddingX24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.location_off_rounded,
                  size: AppDimens.sizeX48,
                  color: LightColor.secondaryTextColor,
                ),
                const SizedBox(height: AppDimens.sizeX12),
                Text(
                  StringConstants.locationUnavailable,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX6),
                Text(
                  "This venue hasn't shared map coordinates yet.",
                  textAlign: TextAlign.center,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LightColor.background,
      appBar: CustomAppBar(title: title),
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: !supportsNativeGoogleMap
                ? (!_tilesResolved
                      ? ColoredBox(color: LightColor.background)
                      : _usingTiles
                      ? GoogleTilesMap(
                          urlTemplate: _tilesUrl!,
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          controller: _tilesController,
                          initialZoom: _defaultZoom,
                          // Clear of the floating address card.
                          bottomPadding:
                              (addressText.isEmpty
                                  ? AppDimens.sizeX90
                                  : AppDimens.sizeX130) +
                              bottomInset,
                        )
                      : StaticGoogleMap(
                          latitude: widget.latitude,
                          longitude: widget.longitude,
                          zoom: _staticZoom,
                          placeholderColor: LightColor.background,
                        ))
                : _showMap
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _point,
                      zoom: _defaultZoom,
                    ),
                    minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
                    onMapCreated: (GoogleMapController controller) =>
                        _mapController = controller,
                    markers: <Marker>{
                      venueMarker(
                        const MarkerId('venue'),
                        _point,
                        title: widget.venueName,
                      ),
                    },
                    rotateGesturesEnabled: false,
                    // The page has its own recentre button and directions.
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    // Keeps Google's logo clear of the floating address card.
                    padding: EdgeInsets.only(
                      bottom:
                          (addressText.isEmpty
                              ? AppDimens.sizeX90
                              : AppDimens.sizeX130) +
                          bottomInset,
                    ),
                  )
                : ColoredBox(
                    color: LightColor.background,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: LightColor.secondaryColor,
                      ),
                    ),
                  ),
          ),

          // ── Zoom controls (desktop static map) ──
          if (!supportsNativeGoogleMap)
            Positioned(
              right: AppDimens.sizeX16,
              bottom:
                  (addressText.isEmpty
                      ? AppDimens.sizeX100
                      : AppDimens.sizeX140) +
                  bottomInset +
                  AppDimens.sizeX52,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FloatingActionButton.small(
                    heroTag: 'zoom-in',
                    tooltip: 'Zoom in',
                    backgroundColor: LightColor.cardColor,
                    foregroundColor: LightColor.secondaryColor,
                    onPressed: _currentZoom < 20 ? () => _zoomBy(1) : null,
                    child: const Icon(Icons.add_rounded),
                  ),
                  FloatingActionButton.small(
                    heroTag: 'zoom-out',
                    tooltip: 'Zoom out',
                    backgroundColor: LightColor.cardColor,
                    foregroundColor: LightColor.secondaryColor,
                    onPressed: _currentZoom > 3 ? () => _zoomBy(-1) : null,
                    child: const Icon(Icons.remove_rounded),
                  ),
                ],
              ),
            ),

          // ── Recentre control ──
          Positioned(
            right: AppDimens.sizeX16,
            bottom:
                (addressText.isEmpty
                    ? AppDimens.sizeX100
                    : AppDimens.sizeX140) +
                bottomInset,
            child: FloatingActionButton.small(
              heroTag: 'recenter',
              backgroundColor: LightColor.cardColor,
              foregroundColor: LightColor.secondaryColor,
              onPressed: _showMap || !supportsNativeGoogleMap
                  ? _recenter
                  : null,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),

          // ── Address + directions footer ──
          Positioned(
            left: AppDimens.sizeX16,
            right: AppDimens.sizeX16,
            bottom: AppDimens.sizeX16 + bottomInset,
            child: Container(
              padding: AppUtils().getPadding(all: AppDimens.paddingX16),
              decoration: BoxDecoration(
                color: LightColor.cardColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: LightColor.shadowOf(0.1),
                    blurRadius: AppDimens.radiusX20,
                    offset: const Offset(0, AppDimens.sizeX6),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  Container(
                    width: AppDimens.sizeX36,
                    height: AppDimens.sizeX36,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                    child: const Icon(
                      Icons.place_outlined,
                      size: AppDimens.sizeX20,
                      color: LightColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyTextMedium?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (addressText.isNotEmpty) ...[
                          const SizedBox(height: AppDimens.sizeX2),
                          Text(
                            addressText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.secondaryTextColor,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX10),
                  Material(
                    color: LightColor.secondaryColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                      onTap: _handingOffToMaps ? null : _openInExternalMaps,
                      child: Padding(
                        padding: AppUtils().getPadding(
                          horizontal: AppDimens.paddingX12,
                          vertical: AppDimens.paddingX10,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.directions_rounded,
                              size: AppDimens.sizeX18,
                              color: LightColor.inverseTextColor,
                            ),
                            const SizedBox(width: AppDimens.sizeX6),
                            Text(
                              StringConstants.directions,
                              style: textTheme.bodySubTitle?.copyWith(
                                color: LightColor.inverseTextColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
