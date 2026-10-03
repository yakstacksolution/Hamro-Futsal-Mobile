import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';

Future<void> settle(WidgetTester tester, {int steps = 8}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(VendorOpsDemoStore.latency ~/ 2);
  }
}

Future<void> openWeek(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
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

void main() {
  setUp(() {
    // Saturday 26 Sep 2026, 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('week table: court-wise, a column per day', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await openWeek(tester, const Size(1600, 1400));
    expect(tester.takeException(), isNull);

    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
    expect(find.text('Time slot'), findsOneWidget);
    for (final String d in <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']) {
      expect(find.text(d), findsOneWidget);
    }
    expect(find.text('Today'), findsWidgets); // Saturday's column

    // A free slot later today goes into the booking from the table.
    await tester.tap(
      find.bySemanticsLabel(RegExp(r'^Sat 26, 9:00 PM, available')),
    );
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('1 slot · 1 court-h'), findsOneWidget);

    // Next week, then another court.
    await tester.tap(find.byTooltip('Next week'));
    await settle(tester);
    expect(find.text('Sep 27 – Oct 3, 2026'), findsOneWidget);
    await tester.tap(find.text('Court 2 · 90-min slots').first);
    await tester.pump();
    // Rows read as ranges; Court 2's are 90 minutes long.
    expect(find.text('6:00 AM – 7:30 AM'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('the week can start from today instead of Sunday', (
    tester,
  ) async {
    await openWeek(tester, const Size(1600, 1400));
    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
    expect(find.text('Sun – Sat'), findsOneWidget);

    await tester.tap(find.byKey(const Key('ops-week-start')));
    await tester.pumpAndSettle();
    expect(find.text('WEEK STARTS FROM'), findsOneWidget);
    // Each choice shows the week it would give today.
    expect(find.text('This week · Sep 20 – 26'), findsOneWidget);
    expect(find.text('This week · Sep 26 – Oct 2'), findsOneWidget);
    await tester.tap(find.text('Starting today'));
    await settle(tester);

    // Saturday the 26th leads, and the week runs to next Friday.
    expect(find.text('From today'), findsOneWidget);
    expect(find.text('Sep 26 – Oct 2, 2026'), findsOneWidget);
    for (final String d in <String>['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri']) {
      expect(find.text(d), findsOneWidget);
    }
    expect(find.text('Sat'), findsNothing); // today's column says "Today"
    expect(find.text('Today'), findsWidgets);

    // Paging moves a whole week.
    await tester.tap(find.byTooltip('Next week'));
    await settle(tester);
    expect(find.text('Oct 3 – 9, 2026'), findsOneWidget);
    expect(find.text('Sat'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous week'));
    await settle(tester);
    expect(find.text('Sep 26 – Oct 2, 2026'), findsOneWidget);
    // There is no "This week" button: the dropdown sits in its place.
    expect(find.text('This week'), findsNothing);

    // And back to the calendar week.
    await tester.tap(find.byKey(const Key('ops-week-start')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calendar week'));
    await settle(tester);
    expect(find.text('Sep 20 – 26, 2026'), findsOneWidget);
    expect(find.text('Sun – Sat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('week table fits a phone and scrolls sideways', (tester) async {
    await openWeek(tester, const Size(390, 1600));
    expect(tester.takeException(), isNull);
    expect(find.text('Time slot'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    // Narrow column: the range stacks, start over end.
    expect(find.text('6:00 AM'), findsWidgets);
    expect(find.text('– 7:00 AM'), findsOneWidget);
  });
}
