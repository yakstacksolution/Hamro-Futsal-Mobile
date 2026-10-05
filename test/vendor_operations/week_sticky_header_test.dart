import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';

Future<void> _settle(WidgetTester tester) async {
  for (int i = 0; i < 8; i++) {
    await tester.pump(VendorOpsDemoStore.latency ~/ 2);
  }
}

/// Scrolling the operations page down the Week table keeps its day header —
/// the dates and the time-slot corner — pinned under the Availability bar,
/// so every slot can still be read against its date.
void main() {
  setUpAll(() async => AppSettings().init(_MemoryPreferences()));
  setUp(() {
    // Saturday 26 Sep 2026, 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('the week day header sticks while the page scrolls', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: const Scaffold(body: VendorOperationsHome(demo: true)),
      ),
    );
    await _settle(tester);
    final Finder page = find.byType(CustomScrollView);
    await tester.scrollUntilVisible(
      find.text('Week'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Week'));
    await _settle(tester);

    // At rest the corner names its column.
    expect(find.text('Time slot'), findsOneWidget);

    // Well past the table's top.
    await tester.drag(page, const Offset(0, -900));
    await tester.pumpAndSettle();

    // Stuck: the corner now carries the week, sitting right under the
    // pinned Availability bar (54 px) at the top of the page.
    expect(find.text('Time slot'), findsNothing);
    final Finder week = find.text('Sep 20 – 26');
    expect(week, findsOneWidget);
    final double pageTop = tester.getTopLeft(page).dy;
    final double headerTop = tester
        .getTopLeft(
          find.ancestor(of: week, matching: find.byType(Container)).first,
        )
        .dy;
    expect(headerTop - pageTop, closeTo(54, 2));

    // Back up: the header returns to its place and names its column again.
    await tester.drag(page, const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(find.text('Time slot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the days scroll sideways under their own dates', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(390, 1600);
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

    // A 7-day week is wider than a phone; it opens on today (Saturday,
    // the last column). Slide the rows back to the week's start.
    final Finder satCell = find.bySemanticsLabel(RegExp(r'^Sat 26, '));
    final double satBefore = tester.getCenter(satCell.first).dx;
    await tester.drag(satCell.first, const Offset(700, 0));
    await tester.pumpAndSettle();
    expect(tester.getCenter(satCell.first).dx, greaterThan(satBefore + 100));

    // Sunday's header moved with its cells and sits right over them.
    final Finder sunCell = find.bySemanticsLabel(RegExp(r'^Sun 20, '));
    final double cellX = tester.getCenter(sunCell.first).dx;
    final double headerX = tester.getCenter(find.text('20').first).dx;
    expect(headerX, closeTo(cellX, 2));
    semantics.dispose();
  });

  testWidgets('desktop: the week controls sit in the pinned bar, once', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
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

    // One set of controls, level with the Day / Week tabs in the bar, and
    // above the table's own header.
    final Finder weekStart = find.byKey(const Key('ops-week-start'));
    expect(weekStart, findsOneWidget);
    expect(find.byTooltip('Next week'), findsOneWidget);
    final double tabsY = tester.getCenter(find.text('Week')).dy;
    expect(tester.getCenter(weekStart).dy, closeTo(tabsY, 6));
    expect(
      tester.getTopLeft(weekStart).dy,
      lessThan(tester.getTopLeft(find.text('Time slot')).dy),
    );
    // The table's corner keeps naming its column: the week is in the bar.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();
    expect(find.text('Time slot'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop: the day controls and status key sit in the bar', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: const Scaffold(body: VendorOperationsHome(demo: true)),
      ),
    );
    await _settle(tester);

    // One Status toggle, level with the Day / Week tabs.
    final Finder status = find.text('Status');
    expect(status, findsOneWidget);
    final double tabsY = tester.getCenter(find.text('Day')).dy;
    expect(tester.getCenter(status).dy, closeTo(tabsY, 6));

    // Scrolled well down the courts, the key still opens — under its toggle.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(find.text('STATUS KEY'), findsNothing);
    await tester.tap(find.text('Status'));
    await tester.pumpAndSettle();
    expect(find.text('STATUS KEY'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('STATUS KEY')).dy,
      greaterThan(tester.getBottomLeft(find.text('Status')).dy),
    );
    expect(tester.takeException(), isNull);
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
