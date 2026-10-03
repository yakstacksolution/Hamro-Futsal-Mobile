import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_booking_panel.dart';

Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tester.pump(VendorOpsDemoStore.latency ~/ 2);
  }
}

Future<void> _tapSlot(WidgetTester tester, String time) async {
  final Finder cell = find.bySemanticsLabel(
    RegExp('^Sat 26, $time, available'),
  );
  await tester.ensureVisible(cell);
  await tester.pump();
  await tester.tap(cell);
  await tester.pump(const Duration(milliseconds: 300));
}

/// Desktop keeps the booking panel beside the board. Closing it keeps the
/// selection, and the panel used to open only when the selection went from
/// empty to non-empty — so after a close, picking another slot never brought
/// it back.
void main() {
  setUpAll(() async => AppSettings().init(_MemoryPreferences()));

  setUp(() {
    // Saturday 26 Sep 2026, 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('desktop: the side panel reopens when a slot is picked after '
      'closing it', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: const Scaffold(body: VendorOperationsHome(demo: true)),
      ),
    );
    await _settle(tester);
    await tester.scrollUntilVisible(
      find.text('Week'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Week'));
    await _settle(tester);

    expect(find.byType(OpsBookingPanel), findsNothing);

    await _tapSlot(tester, '7:00 PM');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(OpsBookingPanel), findsOneWidget);

    await tester.tap(find.byTooltip('Close panel'));
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(OpsBookingPanel), findsNothing);

    // The selection was kept; adding to it must bring the panel back.
    await _tapSlot(tester, '9:00 PM');
    await tester.pumpAndSettle(const Duration(milliseconds: 100));
    expect(find.byType(OpsBookingPanel), findsOneWidget);
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
