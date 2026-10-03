import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';

/// Lets the demo's simulated network latency elapse.
Future<void> settle(WidgetTester tester, {int steps = 8}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(VendorOpsDemoStore.latency ~/ 2);
  }
}

Future<void> fillCustomer(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Phone number'),
    '9841234567',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Customer name'),
    'Demo Customer',
  );
  await tester.pump();
}

void main() {
  setUp(() {
    // 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('demo data shows every state and every booking outcome', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(2200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: FutsalTheme.lightTheme,
        home: const Scaffold(body: VendorOperationsHome(demo: true)),
      ),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);

    // Day view: court cards and their states.
    expect(find.text('Closed'), findsWidgets); // Court C badge
    expect(find.text('Closed all day'), findsOneWidget);
    expect(find.text('ON COURT NOW'), findsOneWidget); // Court A, 10:00
    expect(find.textContaining('free'), findsWidgets);

    // Week view: book a slot the server re-prices, and one whose first
    // booking fails.
    await tester.ensureVisible(find.text('Week'));
    await tester.tap(find.text('Week'));
    await settle(tester);
    Future<void> pick(String court, String slot) async {
      await tester.ensureVisible(find.text(court).first);
      await tester.pump();
      await tester.tap(find.text(court).first);
      await tester.pump();
      final Finder cell = find.bySemanticsLabel(
        RegExp('^Sat 26, $slot, available'),
      );
      await tester.ensureVisible(cell);
      await tester.pump();
      await tester.tap(cell);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await pick('Court B · Server re-prices', '1:00 PM');
    await pick('Court 3 · 30-min slots', '3:00 PM');
    expect(find.textContaining('2 slots · 1.5 court-h'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    await fillCustomer(tester);
    await tester.tap(find.text('Hold slots & review'));
    await settle(tester);

    // Review: the server's price differs and must be accepted.
    expect(find.textContaining('Slots held for'), findsOneWidget);
    expect(
      find.textContaining('priced some slots differently'),
      findsOneWidget,
    );
    final Finder confirm = find.widgetWithText(CustomButton, 'Confirm booking');
    expect(tester.widget<CustomButton>(confirm).onPressed, isNull);
    await tester.tap(find.textContaining('priced some slots differently'));
    await tester.pump();
    expect(tester.widget<CustomButton>(confirm).onPressed, isNotNull);

    // Court 3 fails the first time: nothing is booked, and confirming
    // again books it all in one go.
    await tester.tap(confirm);
    await settle(tester);
    expect(find.textContaining('Nothing was booked'), findsOneWidget);
    expect(find.textContaining('retry succeeds'), findsOneWidget);
    await tester.tap(find.text('Confirm booking'));
    await settle(tester);
    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.text('2 bookings for Demo Customer'), findsOneWidget);
    expect(find.textContaining('Booking #'), findsNWidgets(2));

    // The new bookings appear in the week table.
    await settle(tester);
    expect(find.text('Demo Customer'), findsWidgets);

    // A slot someone else just booked: nothing is booked, the slot is named.
    await tester.tap(find.text('New booking'));
    await tester.pump();
    await pick('Court A · Busy after 7 PM', '7:00 PM');
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await fillCustomer(tester);
    await tester.tap(find.text('Hold slots & review'));
    await settle(tester);
    expect(find.textContaining('demo conflict'), findsOneWidget);
    expect(find.textContaining('Nothing was booked'), findsOneWidget);

    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
