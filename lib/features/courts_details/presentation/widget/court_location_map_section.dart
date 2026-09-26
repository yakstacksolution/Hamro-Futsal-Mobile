import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/google_map_style.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class CourtLocationMapSection extends StatelessWidget {
  const CourtLocationMapSection({
    super.key,
    required this.latitude,
    required this.longitude,
    this.venueName,
    this.address,
    this.height = AppDimens.sizeX180,
  });

  final double? latitude;
  final double? longitude;
  final String? venueName;
  final String? address;

  final double height;

  static const double _mercatorLatitudeLimit = 85.05112878;

  /// Close to Google's empty-map grey, shown until the map mounts.
  static const Color _mapBackgroundColor = Color(0xFFE0E0E0);

  bool get _hasCoordinates =>
      latitude != null &&
      longitude != null &&
      latitude!.isFinite &&
      longitude!.isFinite &&
      latitude!.abs() <= _mercatorLatitudeLimit &&
      longitude!.abs() <= 180 &&
      !(latitude == 0 && longitude == 0);

  void _openFullMap(BuildContext context) {
    if (!_hasCoordinates) return;
    context.pushNamed(
      AppRouterParams.courtLocationMap.name,
      queryParameters: <String, String>{
        'lat': latitude!.toString(),
        'lng': longitude!.toString(),
        if (venueName != null) 'name': venueName!,
        if (address != null) 'address': address!,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasCoordinates) return const SizedBox.shrink();

    final textTheme = FutsalTheme.getTextTheme(context);
    final LatLng point = LatLng(latitude!, longitude!);
    final String addressText = address?.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimens.paddingX16,
        top: AppDimens.paddingX12,
        right: AppDimens.paddingX16,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingX16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[LightColor.elevatedCardColor, LightColor.cardColor],
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.04),
              blurRadius: AppDimens.sizeX16,
              offset: const Offset(0, AppDimens.sizeX8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDimens.paddingX12),
              decoration: BoxDecoration(
                color: LightColor.secondaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              ),
              child: Row(
                children: [
                  Container(
                    width: AppDimens.sizeX34,
                    height: AppDimens.sizeX34,
                    decoration: BoxDecoration(
                      color: LightColor.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      size: AppDimens.sizeX18,
                      color: LightColor.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX10),
                  Expanded(
                    child: Text(
                      StringConstants.location,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (addressText.isNotEmpty) ...[
              const SizedBox(height: AppDimens.sizeX12),
              Padding(
                padding: const EdgeInsets.only(left: AppDimens.paddingX6),
                child: Text(
                  addressText,
                  style: textTheme.bodyTextSmall?.copyWith(
                    color: LightColor.secondaryTextColor,
                    height: 1.5,
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppDimens.sizeX14),

            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              child: SizedBox(
                height: height,
                width: double.infinity,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: () => _openFullMap(context),
                        child: _BuildAfterRouteTransition(
                          // FlutterMap's own background, so the box looks the
                          // same before the map mounts as while tiles load.
                          placeholderColor: _mapBackgroundColor,
                          // Lite mode (Android) renders a static bitmap: the
                          // right cost for a preview inside a scrolling page.
                          // IgnorePointer keeps the platform view from taking
                          // the page's scroll; the tap opens the full map.
                          child: IgnorePointer(
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: point,
                                zoom: 15.5,
                              ),
                              liteModeEnabled: true,
                              markers: <Marker>{
                                venueMarker(const MarkerId('venue'), point),
                              },
                              zoomControlsEnabled: false,
                              zoomGesturesEnabled: false,
                              scrollGesturesEnabled: false,
                              rotateGesturesEnabled: false,
                              tiltGesturesEnabled: false,
                              myLocationButtonEnabled: false,
                              mapToolbarEnabled: false,
                              compassEnabled: false,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Open-in-maps affordance.
                    Positioned(
                      right: AppDimens.sizeX10,
                      bottom: AppDimens.sizeX10,
                      child: Material(
                        color: LightColor.whiteColor,
                        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                        elevation: 2,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX8,
                          ),
                          onTap: () => _openFullMap(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimens.paddingX10,
                              vertical: AppDimens.paddingX8,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.map_rounded,
                                  size: AppDimens.sizeX16,
                                  color: LightColor.secondaryColor,
                                ),
                                const SizedBox(width: AppDimens.sizeX6),
                                Text(
                                  StringConstants.openInMaps,
                                  style: textTheme.bodySubTitle?.copyWith(
                                    color: LightColor.secondaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
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
      ),
    );
  }
}

/// Builds [child] only once the enclosing route has finished its entry
/// transition, showing a flat [placeholderColor] box until then.
///
/// The map is the heaviest thing on the venue page: mounting it kicks off tile
/// requests, image decodes and its own layer tree. Doing that in the same
/// frames as the page's fade/slide-in is what made opening the page stutter.
/// The tiles are network-bound and blank at first either way, so waiting
/// ~600ms to mount it is not visible.
class _BuildAfterRouteTransition extends StatefulWidget {
  const _BuildAfterRouteTransition({
    required this.child,
    required this.placeholderColor,
  });

  final Widget child;
  final Color placeholderColor;

  @override
  State<_BuildAfterRouteTransition> createState() =>
      _BuildAfterRouteTransitionState();
}

class _BuildAfterRouteTransitionState
    extends State<_BuildAfterRouteTransition> {
  Animation<double>? _routeAnimation;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    final Animation<double>? animation = ModalRoute.of(context)?.animation;
    if (identical(animation, _routeAnimation)) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = animation;
    if (animation == null || animation.status == AnimationStatus.completed) {
      _ready = true;
    } else {
      animation.addStatusListener(_onRouteStatus);
    }
  }

  void _onRouteStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    _routeAnimation = null;
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_onRouteStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.child;
    return ColoredBox(color: widget.placeholderColor);
  }
}
