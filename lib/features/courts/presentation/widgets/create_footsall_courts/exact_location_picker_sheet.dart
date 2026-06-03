import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/image_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/courts/data/model/picked_location.dart';
 import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ExactLocationPickerSheet extends StatefulWidget {
  const ExactLocationPickerSheet({
    super.key,
    this.initialLabel,
    this.initialLatitude,
    this.initialLongitude,
  });

  final String? initialLabel;
  final double? initialLatitude;
  final double? initialLongitude;

  @override
  State<ExactLocationPickerSheet> createState() =>
      _ExactLocationPickerSheetState();
}

class _ExactLocationPickerSheetState extends State<ExactLocationPickerSheet> {
  static const LatLng _defaultCenter = LatLng(27.7172, 85.3240);

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  Timer? _searchDebounce;
  LatLng? _selectedPoint;
  String? _selectedLabel;
  bool _isSearching = false;
  bool _isResolving = false;
  List<_LocationSearchResult> _results = <_LocationSearchResult>[];
  int _searchRequestId = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedPoint = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _selectedLabel = widget.initialLabel;
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    final String query = value.trim();
    final int requestId = ++_searchRequestId;

    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _results = <_LocationSearchResult>[];
      });
      return;
    }

    setState(() => _isSearching = true);
    _searchDebounce = Timer(
      const Duration(milliseconds: 450),
      () => _searchPlaces(query, requestId),
    );
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _searchRequestId++;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = false;
      _results = <_LocationSearchResult>[];
    });
  }

  Future<void> _searchPlaces(String query, int requestId) async {
    if (query.isEmpty) return;

    try {
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'q': query,
          'format': 'jsonv2',
          'limit': '8',
          'addressdetails': '1',
        },
      );

      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'User-Agent': 'hamro_footsall/1.0 (exact-location-picker)',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed with code ${response.statusCode}');
      }

      final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
      final List<_LocationSearchResult> matches = decoded
          .map((dynamic item) {
            final Map<String, dynamic> json = item as Map<String, dynamic>;
            return _LocationSearchResult(
              displayName: (json['display_name'] as String? ?? '').trim(),
              latitude: double.parse(json['lat'] as String),
              longitude: double.parse(json['lon'] as String),
            );
          })
          .where((result) => result.displayName.isNotEmpty)
          .toList();

      if (!mounted || requestId != _searchRequestId) return;
      setState(() {
        _results = matches;
        _isSearching = false;
      });

      if (matches.isEmpty) {
        AppUtils().showSnackBar(
          context,
          MsgType.error,
          'No locations found for that search.',
        );
      }
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => _isSearching = false);
      AppUtils().showSnackBar(
        context,
        MsgType.error,
        'Unable to search locations right now.',
      );
    }
  }

  Future<void> _selectPoint(LatLng point, {String? label}) async {
    setState(() {
      _selectedPoint = point;
      _selectedLabel =
          label ??
          'Searching exact location for ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
      _isResolving = label == null;
      _results = <_LocationSearchResult>[];
    });

    _mapController.move(point, 16);

    if (label != null) return;

    try {
      final Uri uri =
          Uri.https('nominatim.openstreetmap.org', '/reverse', <String, String>{
            'lat': point.latitude.toString(),
            'lon': point.longitude.toString(),
            'format': 'jsonv2',
          });

      final http.Response response = await http.get(
        uri,
        headers: <String, String>{
          'User-Agent': 'hamro_footsall/1.0 (exact-location-picker)',
          'Accept-Language': 'en',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Reverse geocoding failed');
      }

      final Map<String, dynamic> json =
          jsonDecode(response.body) as Map<String, dynamic>;

      final String resolved =
          (json['display_name'] as String?)?.trim().isNotEmpty == true
          ? (json['display_name'] as String).trim()
          : 'Pinned location (${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})';

      if (!mounted) return;
      setState(() {
        _selectedLabel = resolved;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _selectedLabel =
            'Pinned location (${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})';
      });
    } finally {
      if (mounted) {
        setState(() => _isResolving = false);
      }
    }
  }

  void _selectSearchResult(_LocationSearchResult result) {
    _selectPoint(
      LatLng(result.latitude, result.longitude),
      label: result.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final LatLng mapCenter = _selectedPoint ?? _defaultCenter;
    final bool hasSearchText = _searchController.text.trim().isNotEmpty;
    final bool isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final double mapHeight = isKeyboardOpen ? 190 : 290;
    final double resultsHeight = isKeyboardOpen ? 124 : 164;

    return Container(
      height: mediaQuery.size.height * (isKeyboardOpen ? 0.88 : 0.82),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX30),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.12),
            blurRadius: AppDimens.radiusX28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimens.sizeX18,
        AppDimens.sizeX12,
        AppDimens.sizeX18,
        AppDimens.sizeX18 + mediaQuery.viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: AppDimens.sizeX44,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[
                      LightColor.borderColor,
                      LightColor.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX12),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,

                      padding: AppUtils().getPadding(
                        horizontal: AppDimens.sizeX16,
                        vertical: AppDimens.sizeX12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX10,
                        ),
                        border: Border.all(color: LightColor.greyBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Pick Exact Location',

                            style: FutsalTheme.getTextTheme(context)
                                .headingSubTitle
                                ?.copyWith(color: LightColor.primaryTextColor),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search an address or tap directly on the map to pin the futsal location.',
                            style: FutsalTheme.getTextTheme(context)
                                .bodyTextSmall
                                ?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    CustomTextField(
                      controller: _searchController,
                      labelText: 'Search exact place',
                      hintText: 'Area, landmark, or street name',
                      icon: Icons.search_rounded,
                      textInputAction: TextInputAction.search,
                      suffixIcon: _isSearching
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: LoadingWidget(),
                            )
                          : IconButton(
                              onPressed: hasSearchText ? _clearSearch : null,
                              icon: Icon(
                                hasSearchText
                                    ? Icons.close_rounded
                                    : Icons.search_rounded,
                                color: LightColor.secondaryColor,
                                size: 20,
                              ),
                            ),
                      onChanged: _onSearchChanged,
                    ),

                    if (_results.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        constraints: BoxConstraints(maxHeight: resultsHeight),
                        decoration: BoxDecoration(
                          color: LightColor.cardColor,
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX18,
                          ),
                          border: Border.all(
                            color: LightColor.borderColor.withValues(
                              alpha: 0.9,
                            ),
                          ),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _results.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: LightColor.borderColor),
                          itemBuilder: (context, index) {
                            final result = _results[index];
                            return InkWell(
                              onTap: () => _selectSearchResult(result),
                              child: Padding(
                                padding: AppUtils().getPadding(
                                  horizontal: AppDimens.sizeX14,
                                  vertical: AppDimens.sizeX12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: AppDimens.sizeX34,
                                      height: AppDimens.sizeX34,
                                      decoration: BoxDecoration(
                                        color: LightColor.secondaryColor
                                            .withValues(alpha: 0.10),
                                        borderRadius: BorderRadius.circular(
                                          AppDimens.radiusX10,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.place_outlined,
                                        color: LightColor.secondaryColor,
                                        size: AppDimens.sizeX18,
                                      ),
                                    ),
                                    const SizedBox(width: AppDimens.sizeX10),
                                    Expanded(
                                      child: Text(
                                        result.displayName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: AppDimens.sizeX12),

                    SizedBox(
                      height: mapHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusX22,
                        ),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: mapCenter,
                            initialZoom: _selectedPoint == null ? 13.2 : 16,
                            onTap: (_, point) => _selectPoint(point),
                          ),
                          children: <Widget>[
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'hamro_footsall',
                            ),
                            if (_selectedPoint != null)
                              MarkerLayer(
                                markers: <Marker>[
                                  Marker(
                                    point: _selectedPoint!,
                                    width: AppDimens.sizeX48,
                                    height: AppDimens.sizeX48,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: AppDimens.sizeX36,
                                    ),
                                  ),
                                ],
                              ),
                            const RichAttributionWidget(
                              attributions: <SourceAttribution>[
                                TextSourceAttribution(
                                  'OpenStreetMap contributors',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppDimens.sizeX12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimens.sizeX14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                        border: Border.all(color: LightColor.greyBorderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              CustomImageView(
                                imagePath: ImageConstants.locationBoundaryIcon,
                                color: LightColor.secondaryColor,
                              ),
                              const SizedBox(width: AppDimens.sizeX6),
                              Text(
                                'Selected location',
                                style: FutsalTheme.getTextTheme(context)
                                    .bodyTextMedium
                                    ?.copyWith(
                                      color: LightColor.secondaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const Spacer(),
                              if (_isResolving)
                                Text(
                                  'Resolving...',
                                  style: FutsalTheme.getTextTheme(context)
                                      .bodyTextMedium
                                      ?.copyWith(
                                        color: LightColor.secondaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                            ],
                          ),
                          const SizedBox(height: AppDimens.sizeX8),
                          Text(
                            _selectedLabel ??
                                'Search a place or tap on the map to capture the exact location.',
                            style: FutsalTheme.getTextTheme(context)
                                .bodyTextSmall
                                ?.copyWith(
                                  color: LightColor.secondaryTextColor,
                                  height: 1.45,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX14),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    backgroundColor: LightColor.whiteColor,
                    foregroundColor: LightColor.secondaryColor,
                    borderColor: LightColor.secondaryColor,
                    minHeight: AppDimens.sizeX46,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX22),
                Expanded(
                  child: CustomButton(
                    text: _isResolving ? 'Locating...' : 'Use Location',
                    minHeight: AppDimens.sizeX46,
                    onPressed: _selectedPoint == null || _selectedLabel == null
                        ? null
                        : () {
                            Navigator.of(context).pop(
                              PickedLocation(
                                label: _selectedLabel!,
                                latitude: _selectedPoint!.latitude,
                                longitude: _selectedPoint!.longitude,
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSearchResult {
  final String displayName;
  final double latitude;
  final double longitude;

  _LocationSearchResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}
