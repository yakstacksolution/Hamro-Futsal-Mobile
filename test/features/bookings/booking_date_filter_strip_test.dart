import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_date_filter_widgets.dart';

Future<List<int>> _pumpStrip(
  WidgetTester tester,
  BookingDateFilter filter,
) async {
  final List<int> steps = <int>[];
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: BookingDateFilterStrip(
            filter: filter,
            onStep: steps.add,
            onEdit: () {},
            onClear: () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return steps;
}

void main() {
  testWidgets('the strip stays out of the way while the filter is off', (
    WidgetTester tester,
  ) async {
    await _pumpStrip(tester, const BookingDateFilter.all());

    expect(find.byKey(const Key('futsal-date-filter-label')), findsNothing);
    expect(find.byKey(const Key('futsal-date-step-previous')), findsNothing);
  });

  testWidgets('a day filter reads out the day and offers both arrows', (
    WidgetTester tester,
  ) async {
    final List<int> steps = await _pumpStrip(
      tester,
      BookingDateFilter.day(DateTime(2026, 9, 10)),
    );

    expect(find.text('Thu, 10 Sep 2026'), findsOneWidget);
    expect(find.text('DAY'), findsOneWidget);

    await tester.tap(find.byKey(const Key('futsal-date-step-next')));
    await tester.tap(find.byKey(const Key('futsal-date-step-previous')));
    expect(steps, <int>[1, -1]);
  });

  testWidgets('a month filter reads out the month and steps by month', (
    WidgetTester tester,
  ) async {
    final List<int> steps = await _pumpStrip(
      tester,
      BookingDateFilter.month(DateTime(2026, 9)),
    );

    expect(find.text('September 2026'), findsOneWidget);
    expect(find.text('MONTH'), findsOneWidget);

    await tester.tap(find.byKey(const Key('futsal-date-step-next')));
    expect(steps, <int>[1]);
  });

  // A range has no "next one", so offering arrows would promise something the
  // filter cannot do.
  testWidgets('a range filter shows its window and no arrows', (
    WidgetTester tester,
  ) async {
    await _pumpStrip(
      tester,
      BookingDateFilter.range(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 7),
      ),
    );

    expect(find.text('1 Sep – 7 Sep 2026'), findsOneWidget);
    expect(find.text('RANGE'), findsOneWidget);
    expect(find.byKey(const Key('futsal-date-step-previous')), findsNothing);
    expect(find.byKey(const Key('futsal-date-step-next')), findsNothing);
    // Clearing is always available.
    expect(find.byKey(const Key('futsal-date-filter-clear')), findsOneWidget);
  });
}
