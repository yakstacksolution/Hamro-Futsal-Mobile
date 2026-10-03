import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_products_sheet.dart';

/// A confirmed booking with NPR 1,200 still to collect.
BookingModel _booking() => BookingModel.fromJson(<String, dynamic>{
  'id': 501,
  'booking_code': 'BK-SPLIT',
  'booking_date': '2026-10-02',
  'start_time': '18:00:00',
  'end_time': '19:00:00',
  'total_amount': 1200,
  'paid_amount': 0,
  'balance_due': 1200,
  'payment_status': 'pending',
  'booking_status': 'confirmed',
});

Future<BookingCompleteResult?> _open(
  WidgetTester tester,
  Future<void> Function() steps,
) async {
  tester.view.physicalSize = const Size(430, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  BookingCompleteResult? result;
  await tester.pumpWidget(
    MaterialApp(
      theme: FutsalTheme.lightTheme,
      home: Builder(
        builder: (BuildContext context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async =>
                  result = await showBookingCompleteSheet(context, _booking()),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  await steps();
  await tester.ensureVisible(find.text('Complete').last);
  await tester.tap(find.text('Complete').last);
  await tester.pumpAndSettle();
  return result;
}

String _status(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('complete-payment-status'))).data!;

void main() {
  testWidgets('opens on the whole amount in cash', (tester) async {
    final BookingCompleteResult? result = await _open(tester, () async {
      expect(
        find.widgetWithText(TextFormField, 'Amount received now (NPR)'),
        findsOneWidget,
      );
      expect(_status(tester), 'Paid in full · Cash');
    });
    expect(result, isNotNull);
    expect(result!.isPartial, isFalse);
    expect(result.paymentType, BookingPaymentType.cash);
    expect(
      result.payments.map((BookingPaymentLine l) => l.toJson()),
      <Map<String, dynamic>>[
        <String, dynamic>{'payment_type': 'cash', 'value': 1200},
      ],
    );
  });

  testWidgets('part in cash, the rest online — never the same type twice', (
    tester,
  ) async {
    final BookingCompleteResult? result = await _open(tester, () async {
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Amount received now (NPR)'),
        '800',
      );
      await tester.pumpAndSettle();
      expect(_status(tester), 'Partly paid · Cash');

      // The other type only, for what is still owed; no third line.
      await tester.ensureVisible(find.byKey(const Key('complete-add-split')));
      await tester.tap(find.byKey(const Key('complete-add-split')));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(TextFormField, 'Cash received (NPR)'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextFormField, 'Online received (NPR)'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('complete-add-split')), findsNothing);
      expect(_status(tester), 'Paid in full · Cash + Online');
    });
    expect(result, isNotNull);
    expect(result!.isPartial, isFalse);
    expect(result.amountPaid, 1200);
    expect(
      result.payments.map((BookingPaymentLine l) => l.toJson()),
      <Map<String, dynamic>>[
        <String, dynamic>{'payment_type': 'cash', 'value': 800},
        <String, dynamic>{'payment_type': 'online', 'value': 400},
      ],
    );
  });
}
