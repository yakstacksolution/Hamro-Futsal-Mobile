import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
  final MapController _mapController = MapController();
  bool _showMap = true;
  bool _handingOffToMaps = false;

  static const double _defaultZoom = 16;
  // Web Mercator cannot project the geographic poles. Values beyond this
  // latitude produce infinite pixel coordinates inside flutter_map.
  static const double _mercatorLatitudeLimit = 85.05112878;

  /// Guards against NaN/Infinity or out-of-range values reaching the map,
  /// which throw inside flutter_map ("LatLng is not finite").
  bool get _hasValidPoint =>
      widget.latitude.isFinite &&
      widget.longitude.isFinite &&
      widget.latitude.abs() <= _mercatorLatitudeLimit &&
      widget.longitude.abs() <= 180;

  LatLng get _point => LatLng(widget.latitude, widget.longitude);

  void _recenter() {
    if (_showMap) _mapController.move(_point, _defaultZoom);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openInExternalMaps() async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${widget.latitude},${widget.longitude}',
    );
    if (_handingOffToMaps) return;
    setState(() {
      _handingOffToMaps = true;
      // Disposing FlutterMap cancels outstanding tile requests and releases
      // decoded tile images before Android backgrounds this activity.
      _showMap = false;
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
            child: _showMap
                ? FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _point,
                      initialZoom: _defaultZoom,
                      minZoom: 3,
                      maxZoom: 18,
                      cameraConstraint: CameraConstraint.contain(
                        bounds: LatLngBounds(
                          const LatLng(-_mercatorLatitudeLimit, -180),
                          const LatLng(_mercatorLatitudeLimit, 180),
                        ),
                      ),
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: <Widget>[
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'hamro_futsal',
                        panBuffer: 0,
                        keepBuffer: 0,
                      ),
                      MarkerLayer(
                        markers: <Marker>[
                          Marker(
                            point: _point,
                            width: AppDimens.sizeX48,
                            height: AppDimens.sizeX48,
                            alignment: Alignment.topCenter,
                            child: const Icon(
                              Icons.location_on,
                              color: LightColor.secondaryColor,
                              size: AppDimens.sizeX44,
                            ),
                          ),
                        ],
                      ),
                      const RichAttributionWidget(
                        attributions: <SourceAttribution>[
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ],
                      ),
                    ],
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
              onPressed: _showMap ? _recenter : null,
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
