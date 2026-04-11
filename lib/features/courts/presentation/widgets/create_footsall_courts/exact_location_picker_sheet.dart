import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/models/picked_location.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No locations found for that search.')),
        );
      }
    } catch (_) {
      if (!mounted || requestId != _searchRequestId) return;
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to search locations right now.')),
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final bool hasSearchText = _searchController.text.trim().isNotEmpty;
    final bool isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
    final double mapHeight = isKeyboardOpen ? 190 : 290;
    final double resultsHeight = isKeyboardOpen ? 124 : 164;

    return Container(
      height: mediaQuery.size.height * (isKeyboardOpen ? 0.88 : 0.82),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        18 + mediaQuery.viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: <Color>[LightColor.borderColor, LightColor.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: LightColor.borderColor.withValues(alpha: 0.85),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Pick Exact Location',
                            style: textTheme.headlineSmall?.copyWith(
                              color: LightColor.primaryTextColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search an address or tap directly on the map to pin the futsal location.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: LightColor.secondaryTextColor,
                              fontSize: 12.5,
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
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                              ),
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
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: LightColor.borderColor.withValues(alpha: 0.9),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: 34,
                                      height: 34,
                                      decoration: BoxDecoration(
                                        color: LightColor.secondaryColor.withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: const Icon(
                                        Icons.place_outlined,
                                        color: LightColor.secondaryColor,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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

                    const SizedBox(height: 12),

                    SizedBox(
                      height: mapHeight,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
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
                                    width: 48,
                                    height: 48,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                      size: 36,
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

                    const SizedBox(height: 12),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: LightColor.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const Icon(
                                Icons.place_rounded,
                                size: 16,
                                color: LightColor.secondaryColor,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Selected location',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const Spacer(),
                              if (_isResolving)
                                Text(
                                  'Resolving...',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: LightColor.secondaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedLabel ??
                                'Search a place or tap on the map to capture the exact location.',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    backgroundColor: Colors.white,
                    foregroundColor: LightColor.secondaryColor,
                    borderColor: LightColor.secondaryColor,
                    minHeight: 46,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 22),
                Expanded(
                  child: CustomButton(
                    text: _isResolving ? 'Locating...' : 'Use Location',
                    minHeight: 46,
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

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:hamro_footsall/core/theme/light_color.dart';
// import 'package:hamro_footsall/core/widgets/custom_button.dart';
// import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
// import 'package:hamro_footsall/features/courts/presentation/models/picked_location.dart';
// import 'package:http/http.dart' as http;
// import 'package:latlong2/latlong.dart';

// class ExactLocationPickerSheet extends StatefulWidget {
//   const ExactLocationPickerSheet({
//     super.key,
//     this.initialLabel,
//     this.initialLatitude,
//     this.initialLongitude,
//   });

//   final String? initialLabel;
//   final double? initialLatitude;
//   final double? initialLongitude;

//   @override
//   State<ExactLocationPickerSheet> createState() =>
//       _ExactLocationPickerSheetState();
// }

// class _ExactLocationPickerSheetState extends State<ExactLocationPickerSheet> {
//   static const LatLng _defaultCenter = LatLng(27.7172, 85.3240);

//   final TextEditingController _searchController = TextEditingController();
//   final MapController _mapController = MapController();

//   Timer? _searchDebounce;
//   LatLng? _selectedPoint;
//   String? _selectedLabel;
//   bool _isSearching = false;
//   bool _isResolving = false;
//   List<_LocationSearchResult> _results = <_LocationSearchResult>[];
//   int _searchRequestId = 0;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialLatitude != null && widget.initialLongitude != null) {
//       _selectedPoint = LatLng(
//         widget.initialLatitude!,
//         widget.initialLongitude!,
//       );
//       _selectedLabel = widget.initialLabel;
//     }
//   }

//   @override
//   void dispose() {
//     _searchDebounce?.cancel();
//     _searchController.dispose();
//     super.dispose();
//   }

//   void _onSearchChanged(String value) {
//     _searchDebounce?.cancel();
//     final String query = value.trim();
//     final int requestId = ++_searchRequestId;

//     if (query.isEmpty) {
//       setState(() {
//         _isSearching = false;
//         _results = <_LocationSearchResult>[];
//       });
//       return;
//     }

//     setState(() => _isSearching = true);
//     _searchDebounce = Timer(
//       const Duration(milliseconds: 450),
//       () => _searchPlaces(query, requestId),
//     );
//   }

//   void _clearSearch() {
//     _searchDebounce?.cancel();
//     _searchController.clear();
//     _searchRequestId++;
//     FocusScope.of(context).unfocus();
//     setState(() {
//       _isSearching = false;
//       _results = <_LocationSearchResult>[];
//     });
//   }

//   Future<void> _searchPlaces(String query, int requestId) async {
//     if (query.isEmpty) return;

//     try {
//       final Uri uri = Uri.https(
//         'nominatim.openstreetmap.org',
//         '/search',
//         <String, String>{
//           'q': query,
//           'format': 'jsonv2',
//           'limit': '8',
//           'addressdetails': '1',
//         },
//       );

//       final http.Response response = await http.get(
//         uri,
//         headers: <String, String>{
//           'User-Agent': 'hamro_footsall/1.0 (exact-location-picker)',
//           'Accept-Language': 'en',
//         },
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Search failed with code ${response.statusCode}');
//       }

//       final List<dynamic> decoded = jsonDecode(response.body) as List<dynamic>;
//       final List<_LocationSearchResult> matches = decoded
//           .map((dynamic item) {
//             final Map<String, dynamic> json = item as Map<String, dynamic>;
//             return _LocationSearchResult(
//               displayName: (json['display_name'] as String? ?? '').trim(),
//               latitude: double.parse(json['lat'] as String),
//               longitude: double.parse(json['lon'] as String),
//             );
//           })
//           .where((result) => result.displayName.isNotEmpty)
//           .toList();

//       if (!mounted || requestId != _searchRequestId) return;
//       setState(() {
//         _results = matches;
//         _isSearching = false;
//       });

//       if (matches.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No locations found for that search.')),
//         );
//       }
//     } catch (_) {
//       if (!mounted || requestId != _searchRequestId) return;
//       setState(() => _isSearching = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Unable to search locations right now.')),
//       );
//     }
//   }

//   Future<void> _selectPoint(LatLng point, {String? label}) async {
//     setState(() {
//       _selectedPoint = point;
//       _selectedLabel =
//           label ??
//           'Searching exact location for ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
//       _isResolving = label == null;
//       _results = <_LocationSearchResult>[];
//     });

//     _mapController.move(point, 16);

//     if (label != null) return;

//     try {
//       final Uri uri =
//           Uri.https('nominatim.openstreetmap.org', '/reverse', <String, String>{
//             'lat': point.latitude.toString(),
//             'lon': point.longitude.toString(),
//             'format': 'jsonv2',
//           });

//       final http.Response response = await http.get(
//         uri,
//         headers: <String, String>{
//           'User-Agent': 'hamro_footsall/1.0 (exact-location-picker)',
//           'Accept-Language': 'en',
//         },
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Reverse geocoding failed');
//       }

//       final Map<String, dynamic> json =
//           jsonDecode(response.body) as Map<String, dynamic>;
//       final String resolved =
//           (json['display_name'] as String?)?.trim().isNotEmpty == true
//           ? (json['display_name'] as String).trim()
//           : 'Pinned location (${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})';

//       if (!mounted) return;
//       setState(() {
//         _selectedLabel = resolved;
//       });
//     } catch (_) {
//       if (!mounted) return;
//       setState(() {
//         _selectedLabel =
//             'Pinned location (${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)})';
//       });
//     } finally {
//       if (mounted) {
//         setState(() => _isResolving = false);
//       }
//     }
//   }

//   void _selectSearchResult(_LocationSearchResult result) {
//     _selectPoint(
//       LatLng(result.latitude, result.longitude),
//       label: result.displayName,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final MediaQueryData mediaQuery = MediaQuery.of(context);
//     final LatLng mapCenter = _selectedPoint ?? _defaultCenter;
//     final ThemeData theme = Theme.of(context);
//     final TextTheme textTheme = theme.textTheme;
//     final bool hasSearchText = _searchController.text.trim().isNotEmpty;
//     final bool isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
//     final double mapHeight = isKeyboardOpen ? 190 : 290;
//     final double sheetHeight =
//         mediaQuery.size.height * (isKeyboardOpen ? 0.92 : 0.86);
//     final double resultsHeight = isKeyboardOpen ? 124 : 164;

//     return SafeArea(
//       top: false,
//       child: Container(
//         height: sheetHeight,
//         decoration: BoxDecoration(
//           color: LightColor.cardColor,
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//           boxShadow: <BoxShadow>[
//             BoxShadow(
//               color: LightColor.secondaryColor.withValues(alpha: 0.12),
//               blurRadius: 28,
//               offset: const Offset(0, -10),
//             ),
//           ],
//         ),
//         padding: EdgeInsets.fromLTRB(
//           18,
//           12,
//           18,
//           18 + mediaQuery.viewInsets.bottom,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             Expanded(
//               child: SingleChildScrollView(
//                 keyboardDismissBehavior:
//                     ScrollViewKeyboardDismissBehavior.onDrag,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Center(
//                       child: Container(
//                         width: 44,
//                         height: 4,
//                         decoration: BoxDecoration(
//                           gradient: const LinearGradient(
//                             colors: <Color>[
//                               LightColor.borderColor,
//                               LightColor.secondaryColor,
//                             ],
//                           ),
//                           borderRadius: BorderRadius.circular(999),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 12,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: LightColor.borderColor.withValues(alpha: 0.85),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Text(
//                             'Pick Exact Location',
//                             style: textTheme.headlineSmall?.copyWith(
//                               color: LightColor.primaryTextColor,
//                               fontWeight: FontWeight.w800,
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             'Search an address or tap directly on the map to pin the futsal location.',
//                             style: textTheme.bodyMedium?.copyWith(
//                               color: LightColor.secondaryTextColor,
//                               fontSize: 12.5,
//                               height: 1.45,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                     CustomTextField(
//                       controller: _searchController,
//                       labelText: 'Search exact place',
//                       hintText: 'Area, landmark, or street name',
//                       icon: Icons.search_rounded,
//                       textInputAction: TextInputAction.search,
//                       suffixIcon: _isSearching
//                           ? const SizedBox(
//                               width: 18,
//                               height: 18,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2.2,
//                               ),
//                             )
//                           : IconButton(
//                               onPressed: hasSearchText ? _clearSearch : null,
//                               icon: Icon(
//                                 hasSearchText
//                                     ? Icons.close_rounded
//                                     : Icons.search_rounded,
//                                 color: LightColor.secondaryColor,
//                                 size: 20,
//                               ),
//                             ),
//                       onChanged: _onSearchChanged,
//                     ),
//                     if (_results.isNotEmpty) ...<Widget>[
//                       const SizedBox(height: 10),
//                       Container(
//                         constraints: BoxConstraints(maxHeight: resultsHeight),
//                         decoration: BoxDecoration(
//                           color: LightColor.cardColor,
//                           borderRadius: BorderRadius.circular(18),
//                           border: Border.all(
//                             color: LightColor.borderColor.withValues(alpha: 0.9),
//                           ),
//                           boxShadow: <BoxShadow>[
//                             BoxShadow(
//                               color: LightColor.secondaryColor.withValues(alpha: 0.08),
//                               blurRadius: 18,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: ListView.separated(
//                           shrinkWrap: true,
//                           itemCount: _results.length,
//                           separatorBuilder: (_, __) =>
//                               Divider(height: 1, color: LightColor.borderColor),
//                           itemBuilder: (BuildContext context, int index) {
//                             final _LocationSearchResult result =
//                                 _results[index];
//                             return Material(
//                               color: Colors.transparent,
//                               child: InkWell(
//                                 onTap: () => _selectSearchResult(result),
//                                 child: Padding(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 14,
//                                     vertical: 12,
//                                   ),
//                                   child: Row(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Container(
//                                         width: 34,
//                                         height: 34,
//                                         decoration: BoxDecoration(
//                                           color: LightColor.secondaryColor.withValues(
//                                             alpha: 0.10,
//                                           ),
//                                           borderRadius: BorderRadius.circular(
//                                             11,
//                                           ),
//                                         ),
//                                         child: const Icon(
//                                           Icons.place_outlined,
//                                           color: LightColor.secondaryColor,
//                                           size: 18,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       Expanded(
//                                         child: Text(
//                                           result.displayName,
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                           style: textTheme.bodyMedium?.copyWith(
//                                             fontSize: 12.5,
//                                             color: LightColor.primaryTextColor,
//                                             fontWeight: FontWeight.w700,
//                                             height: 1.35,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                     const SizedBox(height: 12),
//                     SizedBox(
//                       height: mapHeight,
//                       child: Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(22),
//                           border: Border.all(color: LightColor.borderColor),
//                           boxShadow: <BoxShadow>[
//                             BoxShadow(
//                               color: LightColor.secondaryColor.withValues(
//                                 alpha: 0.08,
//                               ),
//                               blurRadius: 22,
//                               offset: const Offset(0, 10),
//                             ),
//                           ],
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(22),
//                           child: Stack(
//                             children: <Widget>[
//                               FlutterMap(
//                                 mapController: _mapController,
//                                 options: MapOptions(
//                                   initialCenter: mapCenter,
//                                   initialZoom: _selectedPoint == null
//                                       ? 13.2
//                                       : 16,
//                                   onTap: (_, LatLng point) =>
//                                       _selectPoint(point),
//                                 ),
//                                 children: <Widget>[
//                                   TileLayer(
//                                     urlTemplate:
//                                         'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
//                                     userAgentPackageName: 'hamro_footsall',
//                                   ),
//                                   if (_selectedPoint != null)
//                                     MarkerLayer(
//                                       markers: <Marker>[
//                                         Marker(
//                                           point: _selectedPoint!,
//                                           width: 48,
//                                           height: 48,
//                                           child: Column(
//                                             children: <Widget>[
//                                               Container(
//                                                 width: 30,
//                                                 height: 30,
//                                                 decoration: BoxDecoration(
//                                                   color: LightColor.redColor,
//                                                   shape: BoxShape.circle,
//                                                   boxShadow: <BoxShadow>[
//                                                     BoxShadow(
//                                                       color: LightColor.redColor
//                                                           .withValues(
//                                                             alpha: 0.25,
//                                                           ),
//                                                       blurRadius: 14,
//                                                       offset: const Offset(
//                                                         0,
//                                                         5,
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: const Icon(
//                                                   Icons.place_rounded,
//                                                   color: Colors.white,
//                                                   size: 18,
//                                                 ),
//                                               ),
//                                               Container(
//                                                 width: 10,
//                                                 height: 10,
//                                                 decoration: const BoxDecoration(
//                                                   color: LightColor.redColor,
//                                                   shape: BoxShape.circle,
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   const RichAttributionWidget(
//                                     attributions: <SourceAttribution>[
//                                       TextSourceAttribution(
//                                         'OpenStreetMap contributors',
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                               Positioned(
//                                 top: 12,
//                                 left: 12,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 10,
//                                     vertical: 7,
//                                   ),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white.withValues(alpha: 0.92),
//                                     borderRadius: BorderRadius.circular(999),
//                                     boxShadow: <BoxShadow>[
//                                       BoxShadow(
//                                         color: LightColor.secondaryColor
//                                             .withValues(alpha: 0.10),
//                                         blurRadius: 12,
//                                         offset: const Offset(0, 4),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: <Widget>[
//                                       const Icon(
//                                         Icons.touch_app_rounded,
//                                         size: 15,
//                                         color: LightColor.secondaryColor,
//                                       ),
//                                       const SizedBox(width: 6),
//                                       Text(
//                                         'Tap map to pin',
//                                         style: textTheme.bodySmall?.copyWith(
//                                           color: LightColor.primaryTextColor,
//                                           fontWeight: FontWeight.w700,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(18),
//                         border: Border.all(color: LightColor.borderColor),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: <Widget>[
//                           Row(
//                             children: <Widget>[
//                               const Icon(
//                                 Icons.place_rounded,
//                                 size: 16,
//                                 color: LightColor.secondaryColor,
//                               ),
//                               const SizedBox(width: 6),
//                               Text(
//                                 'Selected location',
//                                 style: textTheme.bodyMedium?.copyWith(
//                                   fontSize: 12,
//                                   fontWeight: FontWeight.w800,
//                                   color: LightColor.primaryTextColor,
//                                 ),
//                               ),
//                               const Spacer(),
//                               if (_isResolving)
//                                 Text(
//                                   'Resolving...',
//                                   style: textTheme.bodySmall?.copyWith(
//                                     color: LightColor.secondaryColor,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             _selectedLabel ??
//                                 'Search a place or tap on the map to capture the exact location.',
//                             style: textTheme.bodyMedium?.copyWith(
//                               fontSize: 12.5,
//                               color: _selectedLabel == null
//                                   ? LightColor.secondaryTextColor
//                                   : LightColor.primaryTextColor,
//                               height: 1.45,
//                             ),
//                           ),
//                           if (_selectedPoint != null) ...<Widget>[
//                             const SizedBox(height: 8),
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: <Widget>[
//                                 _LocationHintChip(
//                                   icon: Icons.north_rounded,
//                                   label: _selectedPoint!.latitude
//                                       .toStringAsFixed(6),
//                                   color: LightColor.secondaryColor,
//                                 ),
//                                 _LocationHintChip(
//                                   icon: Icons.east_rounded,
//                                   label: _selectedPoint!.longitude
//                                       .toStringAsFixed(6),
//                                   color: LightColor.secondaryColor,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 14),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: CustomButton(
//                     text: 'Cancel',
//                     isOutlined: true,
//                     backgroundColor: Colors.white,
//                     foregroundColor: LightColor.secondaryColor,
//                     borderColor: LightColor.secondaryColor,
//                     minHeight: 46,
//                     onPressed: () => Navigator.of(context).pop(),
//                   ),
//                 ),
//                 const SizedBox(width: 22),
//                 Expanded(
//                   child: CustomButton(
//                     text: _isResolving ? 'Locating...' : 'Use Location',

//                     minHeight: 46,
//                     onPressed: _selectedPoint == null || _selectedLabel == null
//                         ? null
//                         : () {
//                             Navigator.of(context).pop(
//                               PickedLocation(
//                                 label: _selectedLabel!,
//                                 latitude: _selectedPoint!.latitude,
//                                 longitude: _selectedPoint!.longitude,
//                               ),
//                             );
//                           },
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _LocationSearchResult {
//   const _LocationSearchResult({
//     required this.displayName,
//     required this.latitude,
//     required this.longitude,
//   });

//   final String displayName;
//   final double latitude;
//   final double longitude;
// }

// class _LocationHintChip extends StatelessWidget {
//   const _LocationHintChip({
//     required this.icon,
//     required this.label,
//     this.color = LightColor.secondaryColor,
//   });

//   final IconData icon;
//   final String label;
//   final Color color;

//   @override
//   Widget build(BuildContext context) {
//     final TextTheme textTheme = Theme.of(context).textTheme;

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//       decoration: BoxDecoration(
//         color: color.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: color.withValues(alpha: 0.16)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: <Widget>[
//           Icon(icon, size: 14, color: color),
//           const SizedBox(width: 6),
//           Text(
//             label,
//             style: textTheme.bodySmall?.copyWith(
//               color: color,
//               fontWeight: FontWeight.w700,
//               fontSize: 11.5,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
