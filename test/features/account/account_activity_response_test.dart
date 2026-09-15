import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/utils/account_ui_utils.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';

/// The live `/auth/settlement-recent-activity?page=1&per_page=10` response,
/// verbatim.
const String _responseJson = '''
{
  "status": "success",
  "message": "Recent activity fetched successfully.",
  "data": {
    "venue_id": null,
    "items": [
      {"type":"booking_payment","title":"Venue booking payment","reference":"BK-TRJSQE1T","date":"2026-09-14 06:00:00","created_at":"2026-09-12 19:57:03","amount":1200,"direction":"credit","venue_name":"Dhanawantary Sports"},
      {"type":"platform_commission","title":"Platform commission","reference":"BK-TRJSQE1T","date":"2026-09-14 06:00:00","created_at":"2026-09-12 19:57:03","amount":36,"direction":"debit","venue_name":"Dhanawantary Sports"},
      {"type":"booking_payment","title":"Venue booking payment","reference":"BK-BFLEUQZX","date":"2026-09-13 06:00:00","created_at":"2026-09-12 19:52:12","amount":250,"direction":"credit","venue_name":"Dhanawantary Sports"},
      {"type":"platform_commission","title":"Platform commission","reference":"BK-BFLEUQZX","date":"2026-09-13 06:00:00","created_at":"2026-09-12 19:52:12","amount":7.5,"direction":"debit","venue_name":"Dhanawantary Sports"},
      {"type":"booking_payment","title":"Venue booking payment","reference":"BK-BHYNBEAG","date":"2026-09-13 06:00:00","created_at":"2026-09-12 19:42:21","amount":2500,"direction":"credit","venue_name":"Dhananjay sport"},
      {"type":"platform_commission","title":"Platform commission","reference":"BK-BHYNBEAG","date":"2026-09-13 06:00:00","created_at":"2026-09-12 19:42:21","amount":125,"direction":"debit","venue_name":"Dhananjay sport"},
      {"type":"booking_payment","title":"Venue booking payment","reference":"BK-KMOEIWNT","date":"2026-09-12 20:33:00","created_at":"2026-09-12 19:07:03","amount":2500,"direction":"credit","venue_name":"Dhananjay sport"},
      {"type":"platform_commission","title":"Platform commission","reference":"BK-KMOEIWNT","date":"2026-09-12 20:33:00","created_at":"2026-09-12 19:07:03","amount":125,"direction":"debit","venue_name":"Dhananjay sport"},
      {"type":"booking_payment","title":"Venue booking payment","reference":"BK-R5T3LBHA","date":"2026-09-13 06:00:00","created_at":"2026-09-12 19:02:43","amount":1200,"direction":"credit","venue_name":"Dhanawantary Sports"},
      {"type":"platform_commission","title":"Platform commission","reference":"BK-R5T3LBHA","date":"2026-09-13 06:00:00","created_at":"2026-09-12 19:02:43","amount":36,"direction":"debit","venue_name":"Dhanawantary Sports"}
    ],
    "pagination": {"current_page":1,"last_page":2,"per_page":10,"total":18,"from":1,"to":10,"has_more_pages":true}
  }
}
''';

AccountActivityPageModel _page() => AccountActivityPageModel.fromResponse(
  jsonDecode(_responseJson),
  requestedPage: 1,
  requestedPerPage: 10,
);

void main() {
  group('the live response', () {
    test('parses all ten rows with both timestamps', () {
      final page = _page();
      expect(page.items, hasLength(10));
      expect(page.total, 18);
      expect(page.lastPage, 2);
      expect(page.hasMorePages, isTrue);

      for (final entry in page.items) {
        expect(entry.title, isNotEmpty);
        expect(entry.reference, isNotEmpty);
        expect(entry.venueName, isNotEmpty);
        expect(entry.date, isNotNull);
        expect(entry.createdAt, isNotNull);
        expect(entry.amount, greaterThan(0));
      }
    });

    test('every row is uniquely identified despite having no id', () {
      final page = _page();
      expect(page.items.map((e) => e.identity).toSet(), hasLength(10));
    });

    test('credits and debits split five and five', () {
      final page = _page();
      expect(page.items.where((e) => e.isCredit).length, 5);
      expect(page.items.where((e) => !e.isCredit).length, 5);
      expect(
        page.items.where((e) => e.isCredit).fold<double>(
          0,
          (sum, e) => sum + e.amount,
        ),
        7650,
      );
      expect(
        page.items.where((e) => !e.isCredit).fold<double>(
          0,
          (sum, e) => sum + e.amount,
        ),
        329.5,
      );
    });

    testWidgets('renders as cards under one day heading without overflow', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 1400);
      addTearDown(tester.view.reset);

      final page = _page();
      // Every row was recorded on 12 Sep, so the list is one section.
      final Set<DateTime> days = page.items
          .map((e) => AccountFmt.dayOf(e.createdAt!))
          .toSet();
      expect(days, hasLength(1));

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) => MaterialApp(
            home: Scaffold(
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  AccountActivityDateHeader(day: days.single, dense: true),
                  for (final entry in page.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: AccountEntryTile(
                        key: ValueKey<String>(entry.identity),
                        entry: entry,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      // The pair of one booking: same reference, opposite directions, and
      // both the slot date and the recorded date on each card.
      expect(find.text('BK-TRJSQE1T'), findsNWidgets(2));
      expect(find.text('Booking date'), findsWidgets);
      expect(find.text('Recorded'), findsWidgets);
      expect(find.text('− NPR 7.50'), findsOneWidget);
      expect(find.text('+ NPR 2,500'), findsNWidgets(2));
    });
  });
}
