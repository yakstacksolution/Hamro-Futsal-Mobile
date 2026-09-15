import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';

AccountEntryModel _entry({
  String type = 'booking_payment',
  String title = 'Venue booking payment',
  String venue = 'Dhanawantary Sports',
  num amount = 1200,
  String direction = 'credit',
  String? date = '2026-09-14 06:00:00',
  String? createdAt = '2026-09-12 19:57:03',
}) => AccountEntryModel.fromJson(<String, dynamic>{
  'type': type,
  'title': title,
  'reference': 'BK-TRJSQE1T',
  if (date != null) 'date': date,
  if (createdAt != null) 'created_at': createdAt,
  'amount': amount,
  'direction': direction,
  'venue_name': venue,
});

Future<void> _pumpTile(
  WidgetTester tester,
  AccountEntryModel entry, {
  double width = 411,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AccountEntryTile(entry: entry),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

/// Any text in the widget tree, joined — the meta line is assembled from
/// several Text widgets, so a substring match needs the whole row.
String _renderedText(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text t) => t.data ?? '')
    .join(' | ');

void main() {
  group('AccountEntryTile', () {
    testWidgets('carries every field the endpoint sends', (tester) async {
      await _pumpTile(tester, _entry());
      final String text = _renderedText(tester);

      expect(text, contains('Venue booking payment'), reason: 'title');
      expect(text, contains('BK-TRJSQE1T'), reason: 'reference');
      expect(text, contains('Dhanawantary Sports'), reason: 'venue_name');
      expect(text, contains('+ NPR 1,200'), reason: 'amount + direction');
      expect(text, contains('CREDIT'), reason: 'direction in words');
      // Both timestamps, named, in full.
      expect(find.text('Booking date'), findsOneWidget);
      expect(text, contains('Sep 14, 2026 · 6:00 AM'), reason: 'date');
      expect(find.text('Recorded'), findsOneWidget);
      expect(text, contains('Sep 12, 2026 · 7:57 PM'), reason: 'created_at');
    });

    testWidgets('the two dates are shown apart, not collapsed into one', (
      tester,
    ) async {
      await _pumpTile(tester, _entry());
      final String text = _renderedText(tester);
      // The slot is 14 Sep while the row was written on the 12th: showing
      // only one of them is what made this screen misleading.
      expect(text, contains('Sep 14, 2026'));
      expect(text, contains('Sep 12, 2026'));
    });

    testWidgets('a field the payload omits takes its row away', (tester) async {
      await _pumpTile(tester, _entry(date: null, venue: ''));
      final String text = _renderedText(tester);
      expect(find.text('Booking date'), findsNothing);
      expect(find.text('Venue'), findsNothing);
      // What is there still shows.
      expect(find.text('Recorded'), findsOneWidget);
      expect(text, contains('BK-TRJSQE1T'));
    });

    testWidgets('amounts use tabular figures so the column aligns', (
      tester,
    ) async {
      await _pumpTile(tester, _entry());
      final Text amount = tester.widget<Text>(find.text('+ NPR 1,200'));
      expect(
        amount.style?.fontFeatures,
        contains(const FontFeature.tabularFigures()),
      );
      expect(amount.textAlign, TextAlign.right);
    });

    testWidgets('a debit row reads as negative', (tester) async {
      await _pumpTile(
        tester,
        _entry(
          type: 'platform_commission',
          title: 'Platform commission',
          amount: 7.5,
          direction: 'debit',
        ),
      );
      final String text = _renderedText(tester);
      expect(text, contains('− NPR 7.50'));
    });

    testWidgets('a credit row reads as positive and whole', (tester) async {
      await _pumpTile(tester, _entry());
      expect(_renderedText(tester), contains('+ NPR 1,200'));
    });

    testWidgets('shows the booking date when there is no created_at', (
      tester,
    ) async {
      await _pumpTile(tester, _entry(createdAt: null));
      expect(find.text('Recorded'), findsNothing);
      expect(_renderedText(tester), contains('Sep 14, 2026 · 6:00 AM'));
    });

    testWidgets('a row with no timestamp at all still renders', (tester) async {
      await _pumpTile(tester, _entry(date: null, createdAt: null));
      expect(tester.takeException(), isNull);
      expect(_renderedText(tester), contains('BK-TRJSQE1T'));
    });

    testWidgets('a long title and venue do not overflow a narrow screen', (
      tester,
    ) async {
      await _pumpTile(
        tester,
        _entry(
          title: 'Venue booking payment for a recurring weekend fixture',
          venue: 'Dhanawantary Sports and Recreation Centre, Lalitpur Branch',
          amount: 1234567.89,
        ),
        width: 320,
      );
      // Any overflow would have been recorded as an exception by now.
      expect(tester.takeException(), isNull);
      expect(_renderedText(tester), contains('NPR 1,234,567.89'));
    });

    testWidgets('survives a very narrow screen', (tester) async {
      await _pumpTile(
        tester,
        _entry(
          title: 'Venue booking payment for a recurring weekend fixture',
          venue: 'Dhanawantary Sports and Recreation Centre, Lalitpur Branch',
          amount: 9876543.21,
        ),
        width: 280,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a debit card is chipped DEBIT', (tester) async {
      await _pumpTile(
        tester,
        _entry(
          type: 'platform_commission',
          title: 'Platform commission',
          amount: 36,
          direction: 'debit',
        ),
      );
      expect(_renderedText(tester), contains('DEBIT'));
    });

    testWidgets('the pair differs where it matters, not in its repeats', (
      tester,
    ) async {
      await _pumpTile(tester, _entry());
      final String credit = _renderedText(tester);
      await _pumpTile(
        tester,
        _entry(
          type: 'platform_commission',
          title: 'Platform commission',
          amount: 36,
          direction: 'debit',
        ),
      );
      final String debit = _renderedText(tester);

      // Same booking on both lines …
      expect(credit, contains('BK-TRJSQE1T'));
      expect(debit, contains('BK-TRJSQE1T'));
      // … and the description and figure are what separate them.
      expect(credit, contains('Venue booking payment'));
      expect(debit, contains('Platform commission'));
      expect(credit, contains('+ NPR 1,200'));
      expect(debit, contains('− NPR 36'));
    });
  });
}
