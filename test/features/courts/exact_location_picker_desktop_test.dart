import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide TileOverlay;
import 'package:hamro_futsal/core/widgets/google_tiles_map.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/courts/presentation/widgets/create_futsal_courts/exact_location_picker_sheet.dart';

/// `google_maps_flutter` has no macOS implementation: a `GoogleMap` there
/// renders "TargetPlatform.macOS is not yet supported by the maps plugin"
/// in place of the map. The location picker must use the tile map instead.
void main() {
  setUpAll(() async => AppSettings().init(_MemoryPreferences()));

  Future<void> pumpPicker(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => const MaterialApp(
          home: Scaffold(
            body: ExactLocationPickerSheet(
              initialLabel: 'Harisiddhi, Lalitpur',
              initialLatitude: 27.6475,
              initialLongitude: 85.3463,
            ),
          ),
        ),
      ),
    );
    // Let the tile-session lookup finish (no key in tests: it fails fast).
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  testWidgets('macOS: the picker never builds the unsupported GoogleMap', (
    WidgetTester tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    try {
      await pumpPicker(tester);

      expect(tester.takeException(), isNull);
      expect(find.byType(GoogleMap), findsNothing);
      expect(find.textContaining('not yet supported'), findsNothing);
      // No Google tile session in tests: the picker falls back to
      // OpenStreetMap tiles, still a live map you can tap to pin.
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text(OsmTiles.attribution), findsOneWidget);
      expect(find.text('Harisiddhi, Lalitpur'), findsOneWidget);
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

final class _MemoryPreferences implements Preferences {
  final Map<String, Object> values = <String, Object>{};
  int writes = 0;

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String> getStringList(String key) =>
      (values[key] as List<String>?) ?? <String>[];

  @override
  Future<bool> remove(String key) async {
    writes++;
    return values.remove(key) != null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) async {
    writes++;
    values[key] = List<String>.from(permissions);
    return true;
  }
}
