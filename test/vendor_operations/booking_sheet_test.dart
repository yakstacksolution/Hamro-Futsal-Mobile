import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_booking_panel.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/vendor_operations/data/demo/vendor_ops_demo.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';

Future<void> settle(WidgetTester tester, {int steps = 8}) async {
  for (int i = 0; i < steps; i++) {
    await tester.pump(VendorOpsDemoStore.latency ~/ 2);
  }
}

/// Phone, demo data: picks two free slots on Court 1 from the Week table
/// and opens the booking sheet from the selection bar.
Future<void> openSheet(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: FutsalTheme.lightTheme,
      home: const Scaffold(body: VendorOperationsHome(demo: true)),
    ),
  );
  await settle(tester);
  await tester.scrollUntilVisible(
    find.text('Week'),
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.tap(find.text('Week'));
  await settle(tester);
  for (final String time in <String>['7:00 PM', '9:00 PM']) {
    final Finder cell = find.bySemanticsLabel(
      RegExp('^Sat 26, $time, available'),
    );
    await tester.ensureVisible(cell);
    await tester.pump();
    await tester.tap(cell);
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.tap(find.text('Review'));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

Future<void> fillCustomer(WidgetTester tester) async {
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Phone number'),
    '9841234567',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Customer name'),
    'Sita',
  );
  await tester.pump();
}

void main() {
  setUp(() {
    // Saturday 26 Sep 2026, 10:00 in Kathmandu.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 4, 15));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('the sheet walks slots → customer → review → done', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await openSheet(tester);

    // Slots: labelled steps, the court card with its subtotal, clear all.
    expect(find.text('Manual booking'), findsWidgets);
    expect(find.text('2 slots · 1 court'), findsOneWidget);
    expect(find.bySemanticsLabel('Step 1 of 3, Slots'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.textContaining('Today · '),
      ),
      findsOneWidget,
    );
    expect(find.text('Clear all'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Step 2 of 3, Customer'), findsOneWidget);
    // The customer is only a name and a phone number.
    expect(find.widgetWithText(TextFormField, 'Email'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Internal note'), findsNothing);
    await fillCustomer(tester);

    // Payment method, payment status, booking status and a payment note.
    Future<void> choose(String field, String option) async {
      final Finder dropdown = find.byKey(Key(field));
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(option).last);
      await tester.pumpAndSettle();
    }

    // Customer name comes before the phone number.
    expect(
      tester.getTopLeft(find.widgetWithText(TextFormField, 'Customer name')).dy,
      lessThan(
        tester
            .getTopLeft(find.widgetWithText(TextFormField, 'Phone number'))
            .dy,
      ),
    );
    final Finder amount = find.widgetWithText(
      TextFormField,
      'Amount received (NPR)',
    );
    expect(amount, findsOneWidget);

    // The payment status is worked out from the amounts, with the methods.
    String status() => tester
        .widgetList<Text>(
          find.descendant(
            of: find.byKey(const Key('ops-payment-status')),
            matching: find.byType(Text),
          ),
        )
        .map((Text t) => t.data ?? '')
        .firstWhere(
          (String d) =>
              d.startsWith('Paid') ||
              d.startsWith('Partly paid') ||
              d.startsWith('Pending'),
          orElse: () => '',
        );

    await tester.ensureVisible(find.text('Full'));
    await tester.tap(find.text('Full'));
    await tester.pumpAndSettle();
    expect(status(), 'Paid · Cash');
    await tester.enterText(amount, '0');
    await tester.pumpAndSettle();
    expect(status(), 'Pending');

    // Half online…
    await tester.tap(find.text('Online'));
    await tester.tap(find.text('50%'));
    await tester.pumpAndSettle();
    expect(status(), 'Partly paid · Online');
    expect(find.textContaining('Remaining'), findsOneWidget);

    // …and the rest in cash: the other method only, and no third line.
    await tester.tap(find.widgetWithText(TextButton, 'Add cash'));
    await tester.pumpAndSettle();
    final Finder second = find.widgetWithText(
      TextFormField,
      'Cash received (NPR)',
    );
    expect(second, findsOneWidget);
    expect(
      find.widgetWithText(TextFormField, 'Online received (NPR)'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Add online'), findsNothing);
    expect(find.widgetWithText(TextButton, 'Add cash'), findsNothing);
    expect(status(), 'Paid · Online + Cash');
    // Only part of the rest in cash.
    await tester.enterText(second, '100');
    await tester.pumpAndSettle();
    expect(status(), 'Partly paid · Online + Cash');

    await choose('ops-booking-status', 'Completed');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Payment note'),
      'Rest at the counter',
    );
    await tester.pump();

    await tester.tap(find.text('Hold slots & review'));
    await settle(tester);
    expect(find.text('Review booking'), findsOneWidget);
    expect(find.text('Sita'), findsOneWidget);
    expect(find.text('Payment method · Online + Cash'), findsOneWidget);
    expect(find.text('Payment status · Partly paid'), findsOneWidget);
    expect(find.text('Booking status · Completed'), findsOneWidget);
    expect(find.text('Received now (Online)'), findsOneWidget);
    expect(find.text('Received now (Cash)'), findsOneWidget);
    expect(find.text('Rest at the counter'), findsOneWidget);

    // Closing with slots held asks first; "Keep reviewing" keeps the sheet.
    await tester.tap(find.byTooltip('Close panel'));
    await tester.pumpAndSettle();
    expect(find.text('Release held slots?'), findsOneWidget);
    await tester.tap(find.text('Keep reviewing'));
    await tester.pumpAndSettle();
    expect(find.text('Review booking'), findsOneWidget);

    // System back asks too.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Release held slots?'), findsOneWidget);
    await tester.tap(find.text('Keep reviewing'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Confirm booking'));
    await settle(tester);
    expect(find.text('Booking confirmed'), findsOneWidget);
    expect(find.textContaining('to collect'), findsOneWidget);

    // Done closes the sheet; the selection was booked and cleared.
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Booking confirmed'), findsNothing);
    expect(find.text('Review'), findsNothing);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('the first step: no swipe-to-close, and Back before Continue', (
    tester,
  ) async {
    await openSheet(tester);
    final Finder sheet = find.byType(OpsBookingPanel);
    final double height = tester.getSize(sheet).height;

    // Back sits before Continue, sharing the bar.
    final Finder back = find.text('Back');
    final Finder next = find.text('Continue');
    expect(back, findsOneWidget);
    expect(next, findsOneWidget);
    expect(tester.getCenter(back).dx, lessThan(tester.getCenter(next).dx));
    expect(
      (tester.getCenter(back).dy - tester.getCenter(next).dy).abs(),
      lessThan(2),
    );

    // Scrolling the form down and flinging the sheet never shrink or close
    // it; nor does a tap outside.
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, 400),
    );
    await tester.pumpAndSettle();
    await tester.flingFrom(
      tester.getTopLeft(sheet) + const Offset(120, 20),
      const Offset(0, 800),
      2000,
    );
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(sheet, findsOneWidget);
    expect(tester.getSize(sheet).height, height);

    // Back leaves the booking; the picked slots stay on the board.
    await tester.tap(back);
    await tester.pumpAndSettle();
    expect(sheet, findsNothing);
    expect(find.textContaining('2 slots · 2 court-h'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('releasing held slots closes the sheet and keeps the selection', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await openSheet(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await fillCustomer(tester);
    await tester.tap(find.text('Hold slots & review'));
    await settle(tester);

    // Dragging the sheet down or tapping outside it does nothing: the sheet
    // only closes from the panel.
    await tester.fling(find.text('Review booking'), const Offset(0, 600), 1500);
    await tester.pumpAndSettle();
    expect(find.text('Review booking'), findsOneWidget);
    expect(find.text('Release held slots?'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('Review booking'), findsOneWidget);

    // Closing from the panel asks before letting go of the held slots.
    await tester.tap(find.byTooltip('Close panel'));
    await tester.pumpAndSettle();
    expect(find.text('Release held slots?'), findsOneWidget);
    await tester.tap(find.text('Release & close'));
    await tester.pumpAndSettle();
    expect(find.text('Review booking'), findsNothing);
    // The selection bar is back with both slots.
    expect(find.textContaining('2 slots · 2 court-h'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('with the keyboard up the footer sits right on it', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    // A phone with a home indicator.
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    await openSheet(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    final Finder hold = find.widgetWithText(
      CustomButton,
      'Hold slots & review',
    );
    double gapBelowButton() =>
        tester.view.physicalSize.height / tester.view.devicePixelRatio -
        tester.view.viewInsets.bottom / tester.view.devicePixelRatio -
        tester.getBottomLeft(hold).dy;
    // Keyboard down: summary shown, safe-area padding kept.
    expect(find.textContaining('court-h · '), findsOneWidget);
    expect(gapBelowButton(), greaterThanOrEqualTo(34 + 12));

    // Keyboard up (300 px): the sheet rises with it, the footer drops the
    // safe-area gap and the summary line.
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.view.padding = FakeViewPadding.zero;
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.textContaining('court-h · '), findsNothing);
    expect(gapBelowButton(), lessThanOrEqualTo(8.5));
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('a second tap while the sheet closes never pops the page', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await openSheet(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await fillCustomer(tester);
    await tester.tap(find.text('Hold slots & review'));
    await settle(tester);
    await tester.tap(find.text('Confirm booking'));
    await settle(tester);
    expect(find.text('Booking confirmed'), findsOneWidget);

    // Done twice, the second while the sheet is still animating away.
    await tester.tap(find.text('Done'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Done'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Booking confirmed'), findsNothing);
    // The dashboard is still there.
    expect(find.text('Availability'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
