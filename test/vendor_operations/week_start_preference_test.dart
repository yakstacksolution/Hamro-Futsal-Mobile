import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the Week table begins is kept in shared preferences: Calendar week
/// until the vendor picks otherwise, then whatever they picked, across
/// visits to the dashboard and app restarts.
void main() {
  late SharedPreferences prefs;
  const String key = 'settings_vendor_ops_week_start';

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    await AppSettings().init(SharedPreferencesWrapper(prefs));
  });

  setUp(() async {
    await prefs.remove(key);
    // Saturday 26 Sep 2026, 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  Future<void> settle(WidgetTester tester) async {
    for (int i = 0; i < 8; i++) {
      await tester.pump(VendorOpsDemoStore.latency ~/ 2);
    }
  }

  /// Opens the dashboard afresh — a new page and bloc, as on a new visit —
  /// and switches to the Week table.
  Future<void> openWeek(WidgetTester tester, {required int visit}) async {
    tester.view.physicalSize = const Size(1600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        key: ValueKey<int>(visit),
        theme: FutsalTheme.lightTheme,
        home: const Scaffold(body: VendorOperationsHome(demo: true)),
      ),
    );
    await settle(tester);
    final Finder week = find.text('Week');
    await tester.scrollUntilVisible(
      week,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(week);
    await settle(tester);
  }

  Future<void> pick(WidgetTester tester, String option) async {
    await tester.tap(find.byKey(const Key('ops-week-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(option));
    await settle(tester);
  }

  testWidgets('nothing saved: opens on Calendar week', (tester) async {
    await openWeek(tester, visit: 1);
    expect(find.text('Sun – Sat'), findsOneWidget);
    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
    // Opening is not a choice: nothing is written until one is made.
    expect(prefs.getString(key), isNull);
  });

  testWidgets('picking Starting today is saved and comes back', (tester) async {
    await openWeek(tester, visit: 1);
    await pick(tester, 'Starting today');
    expect(prefs.getString(key), 'today');
    expect(find.text('Sep 26 – Oct 2, 2026'), findsOneWidget);

    // A later visit opens where the vendor left it.
    await openWeek(tester, visit: 2);
    expect(find.text('From today'), findsOneWidget);
    expect(find.text('Sep 26 – Oct 2, 2026'), findsOneWidget);

    // And back to Calendar week, which is saved too.
    await pick(tester, 'Calendar week');
    expect(prefs.getString(key), 'sunday');
    await openWeek(tester, visit: 3);
    expect(find.text('Sun – Sat'), findsOneWidget);
    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
  });

  testWidgets('a value saved before launch is applied', (tester) async {
    await prefs.setString(key, 'today');
    await openWeek(tester, visit: 1);
    expect(find.text('From today'), findsOneWidget);
    expect(find.text('Sep 26 – Oct 2, 2026'), findsOneWidget);
  });

  testWidgets('an unknown saved value falls back to Calendar week', (
    tester,
  ) async {
    await prefs.setString(key, 'monday');
    await openWeek(tester, visit: 1);
    expect(find.text('Sun – Sat'), findsOneWidget);
  });
}
