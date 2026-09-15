import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/presentation/utils/account_ui_utils.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';

void main() {
  group('AccountFmt.sectionDay', () {
    final DateTime now = DateTime(2026, 9, 12, 20, 30);

    test('names today and yesterday, and still gives the date', () {
      expect(
        AccountFmt.sectionDay(DateTime(2026, 9, 12, 19, 57), now: now),
        'TODAY  ·  12 SEP 2026',
      );
      expect(
        AccountFmt.sectionDay(DateTime(2026, 9, 11, 8, 0), now: now),
        'YESTERDAY  ·  11 SEP 2026',
      );
    });

    test('older days are just the date', () {
      expect(
        AccountFmt.sectionDay(DateTime(2026, 9, 9, 8, 0), now: now),
        '09 SEP 2026',
      );
      expect(
        AccountFmt.sectionDay(DateTime(2025, 12, 31, 8, 0), now: now),
        '31 DEC 2025',
      );
    });

    test('a late-evening row belongs to its own day, not the next', () {
      // Guards the boundary: grouping keys on the calendar day, so 11:59 PM
      // must not fall into the following section.
      expect(
        AccountFmt.dayOf(DateTime(2026, 9, 12, 23, 59)),
        DateTime(2026, 9, 12),
      );
      expect(
        AccountFmt.dayOf(DateTime(2026, 9, 13, 0, 1)),
        DateTime(2026, 9, 13),
      );
    });
  });

  group('AccountActivityDateHeader', () {
    testWidgets('renders the heading for its day', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: AccountActivityDateHeader(day: DateTime(2026, 9, 11)),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text(AccountFmt.sectionDay(DateTime(2026, 9, 11))),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
