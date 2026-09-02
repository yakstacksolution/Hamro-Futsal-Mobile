import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:hamro_futsal/core/routers/app_router_params.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
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
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: point,
                            initialZoom: 15.5,
                            cameraConstraint: CameraConstraint.contain(
                              bounds: LatLngBounds(
                                const LatLng(-_mercatorLatitudeLimit, -180),
                                const LatLng(_mercatorLatitudeLimit, 180),
                              ),
                            ),
                            // Static preview — taps open the external maps app
                            // and gestures don't hijack the page scroll.
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.none,
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
                                  point: point,
                                  width: AppDimens.sizeX48,
                                  height: AppDimens.sizeX48,
                                  alignment: Alignment.topCenter,
                                  child: const Icon(
                                    Icons.location_on,
                                    color: LightColor.secondaryColor,
                                    size: AppDimens.sizeX36,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // OpenStreetMap attribution (required by the tile usage
                    // policy).
                    Positioned(
                      left: AppDimens.sizeX6,
                      bottom: AppDimens.sizeX6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingX6,
                          vertical: AppDimens.paddingX2,
                        ),
                        decoration: BoxDecoration(
                          color: LightColor.onBrandSurface.withValues(
                            alpha: 0.8,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX4,
                          ),
                        ),
                        child: Text(
                          StringConstants.openstreetmap,
                          style: textTheme.bodyMiniSubTitle?.copyWith(
                            color: LightColor.secondaryTextColor,
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
