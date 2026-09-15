import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/presentation/utils/booking_search.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_date_filter_widgets.dart';

/// Catches what the sheet pops. The sheet is still open when [_openSheet]
/// returns, so the result can only be read after it is dismissed.
final class _Catcher {
  BookingDateFilterResult? result;
  bool returned = false;
}

Future<_Catcher> _openSheet(
  WidgetTester tester, {
  BookingDateFilter current = const BookingDateFilter.all(),
  BookingDateOrder order = BookingDateOrder.descending,
}) async {
  final _Catcher catcher = _Catcher();
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext context) => TextButton(
              onPressed: () async {
                catcher.result = await showBookingDateFilterSheet(
                  context,
                  current: current,
                  currentOrder: order,
                );
                catcher.returned = true;
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return catcher;
}

void main() {
  testWidgets('all four modes are offered', (WidgetTester tester) async {
    await _openSheet(tester);

    for (final BookingDateMode mode in BookingDateMode.values) {
      expect(
        find.byKey(Key('date-mode-${mode.name}')),
        findsOneWidget,
        reason: mode.name,
      );
    }
  });

  testWidgets('the sheet opens on the mode it was given', (
    WidgetTester tester,
  ) async {
    await _openSheet(
      tester,
      current: BookingDateFilter.day(DateTime(2026, 9, 10)),
    );

    // Day mode's own field, not the range pair.
    expect(find.byKey(const Key('date-sheet-day')), findsOneWidget);
    expect(find.byKey(const Key('date-sheet-from')), findsNothing);
  });

  testWidgets('picking a month applies that whole month', (
    WidgetTester tester,
  ) async {
    final _Catcher catcher = await _openSheet(tester);
    final int year = DateTime.now().year;

    await tester.tap(find.byKey(const Key('date-mode-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-sheet-month-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-sheet-apply')));
    await tester.pumpAndSettle();

    expect(catcher.result!.filter.mode, BookingDateMode.month);
    expect(catcher.result!.filter.fromDate, DateTime(year, 2, 1));
    expect(catcher.result!.filter.toDate, DateTime(year, 3, 0));
  });

  testWidgets('a range quick pick fills both ends', (
    WidgetTester tester,
  ) async {
    final _Catcher catcher = await _openSheet(tester);

    await tester.tap(find.byKey(const Key('date-mode-range')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-quick-last-7-days')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-sheet-apply')));
    await tester.pumpAndSettle();

    final BookingDateFilter filter = catcher.result!.filter;
    expect(filter.mode, BookingDateMode.range);
    expect(filter.toDate!.difference(filter.fromDate!).inDays, 6);
  });

  testWidgets('the order comes back alongside the window', (
    WidgetTester tester,
  ) async {
    final _Catcher catcher = await _openSheet(tester);

    await tester.tap(find.byKey(const Key('date-sheet-order-oldest')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('date-sheet-apply')));
    await tester.pumpAndSettle();

    expect(catcher.result!.order, BookingDateOrder.ascending);
  });

  // Clearing is about the window, not about how the list is read, so the order
  // the user already chose has to survive it.
  testWidgets('clear drops the window but keeps the order', (
    WidgetTester tester,
  ) async {
    final _Catcher catcher = await _openSheet(
      tester,
      current: BookingDateFilter.day(DateTime(2026, 9, 10)),
      order: BookingDateOrder.ascending,
    );

    await tester.tap(find.byKey(const Key('date-sheet-clear')));
    await tester.pumpAndSettle();

    expect(catcher.result!.filter, const BookingDateFilter.all());
    expect(catcher.result!.order, BookingDateOrder.ascending);
  });

  testWidgets('dismissing without applying changes nothing', (
    WidgetTester tester,
  ) async {
    final _Catcher catcher = await _openSheet(tester);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(catcher.returned, isTrue);
    expect(catcher.result, isNull);
  });
}
