import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/widgets/account_widgets.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_shared_widgets.dart';

BookingModel _booking({
  String status = 'confirmed',
  num amount = 1200,
  String ref = 'BK-TRJSQE1T',
  String futsal = 'Dhanawantary Sports',
  String court = 'Court A',
  String? player = 'Ram Thapa',
  String? phone = '9800000000',
  String? createdAt = '2026-09-12 19:20:52',
  String? type = 'regular',
}) => BookingModel.fromJson(<String, dynamic>{
  if (createdAt != null) 'created_at': createdAt,
  if (type != null) 'booking_type': type,
  'id': 424,
  'booking_ref': ref,
  'court_name': court,
  'futsal_name': futsal,
  'date': '2026-09-14 06:00:00',
  'start_time': '06:00',
  'end_time': '07:00',
  'status': status,
  'amount': amount,
  'player_name': player,
  'player_phone': phone,
  'paid_amount': amount,
});

AccountEntryModel _entry() => AccountEntryModel.fromJson(<String, dynamic>{
  'type': 'booking_payment',
  'title': 'Venue booking payment',
  'reference': 'BK-TRJSQE1T',
  'date': '2026-09-14 06:00:00',
  'created_at': '2026-09-12 19:57:03',
  'amount': 1200,
  'direction': 'credit',
  'venue_name': 'Dhanawantary Sports',
});

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  double width = 411,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = Size(width, 900);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(padding: const EdgeInsets.all(16), child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

String _text(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text t) => t.data ?? '')
    .join(' | ');

void main() {
  group('BookingCard', () {
    testWidgets('leads with the venue and carries the slot facts', (
      tester,
    ) async {
      await _pump(tester, BookingCard(booking: _booking()));
      final String text = _text(tester);

      expect(text, contains('Dhanawantary Sports'));
      expect(text, contains('Court A'));
      expect(text, contains('NPR 1,200'));
      expect(text, contains('CONFIRMED'));
      // The facts sit in a 2x2 grid: Date | Time over Reference | Booked on.
      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
      expect(text, contains('Sep 14, 2026'));
      expect(text, contains('6:00 AM'));
      expect(find.text('REFERENCE'), findsOneWidget);
      expect(find.text('TYPE'), findsOneWidget);
      expect(text, contains('Regular'));
      expect(text, contains('BK-TRJSQE1T'));
    });

    testWidgets('a vendor list leads with the player instead', (tester) async {
      await _pump(
        tester,
        BookingCard(booking: _booking(), showPlayer: true),
      );
      final String text = _text(tester);

      expect(text, contains('Ram Thapa'));
      expect(text, contains('9800000000'));
      // The court joins the phone on the subtitle, keeping the grid even.
      expect(text, contains('Court A'));
      expect(find.text('COURT'), findsNothing);
    });

    testWidgets('a missing field takes its row away', (tester) async {
      await _pump(
        tester,
        BookingCard(booking: _booking(ref: '', amount: 0)),
      );
      expect(find.text('REFERENCE'), findsNothing);
      expect(_text(tester), isNot(contains('NPR')));
      // The status chip still identifies the row.
      expect(_text(tester), contains('CONFIRMED'));
    });

    testWidgets('is tappable and does not overflow when narrow', (
      tester,
    ) async {
      int taps = 0;
      await _pump(
        tester,
        BookingCard(
          booking: _booking(
            futsal: 'Dhanawantary Sports and Recreation Centre, Lalitpur',
            court: 'Indoor Court Number Three (Astro Turf)',
            amount: 1234567.89,
          ),
          onTap: () => taps++,
        ),
        width: 300,
      );
      expect(tester.takeException(), isNull);

      await tester.tap(find.byType(BookingCard));
      expect(taps, 1);
    });
  });

  group('the footer actions on a confirmed booking', () {
    Widget actionsFooter() => Row(
      children: <Widget>[
        Expanded(
          child: Material(
            color: Colors.green.withValues(alpha: 0.08),
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                height: 36,
                child: Center(child: Text('Add products')),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Material(
            color: Colors.green,
            child: InkWell(
              onTap: () {},
              child: const SizedBox(
                height: 36,
                child: Center(child: Text('Complete')),
              ),
            ),
          ),
        ),
      ],
    );

    testWidgets('both buttons keep their full width inside the card', (
      tester,
    ) async {
      await _pump(
        tester,
        BookingCard(
          booking: _booking(status: 'confirmed'),
          showPlayer: true,
          footer: actionsFooter(),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Add products'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);

      // The two share the card's width evenly and sit below the grid.
      final Rect add = tester.getRect(find.text('Add products'));
      final Rect complete = tester.getRect(find.text('Complete'));
      // Side by side on one row, each taking half the card.
      expect((add.center.dy - complete.center.dy).abs(), lessThan(2));
      final Rect card = tester.getRect(find.byType(BookingCard));
      expect(add.center.dx, lessThan(card.center.dx));
      expect(complete.center.dx, greaterThan(card.center.dx));

      final Rect grid = tester.getRect(find.byType(DataCardGrid));
      expect(add.top, greaterThan(grid.bottom));
    });

    testWidgets('the buttons survive a narrow card', (tester) async {
      await _pump(
        tester,
        BookingCard(
          booking: _booking(status: 'confirmed'),
          showPlayer: true,
          footer: actionsFooter(),
        ),
        width: 300,
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Add products'), findsOneWidget);
      expect(find.text('Complete'), findsOneWidget);
    });

    testWidgets('no footer means no trailing rule', (tester) async {
      await _pump(tester, BookingCard(booking: _booking()));
      // One divider only: between the header and the grid.
      expect(find.byType(DataCardDivider), findsOneWidget);
    });
  });

  group('consistency with the account ledger', () {
    testWidgets('both cards are built from the shared card language', (
      tester,
    ) async {
      await _pump(tester, BookingCard(booking: _booking()));
      expect(find.byType(DataCard), findsOneWidget);
      expect(find.byType(DataCardHeader), findsOneWidget);
      expect(find.byType(DataCardCell), findsWidgets);
      expect(find.byType(DataCardChip), findsOneWidget);

      await _pump(tester, AccountEntryTile(entry: _entry()));
      expect(find.byType(DataCard), findsOneWidget);
      expect(find.byType(DataCardHeader), findsOneWidget);
      expect(find.byType(DataCardField), findsWidgets);
      expect(find.byType(DataCardChip), findsOneWidget);
    });

    testWidgets('both spell an amount the same way', (tester) async {
      // The total in the header and the paid figure in the grid.
      await _pump(tester, BookingCard(booking: _booking()));
      expect(find.text('NPR 1,200'), findsNWidgets(2));

      await _pump(tester, AccountEntryTile(entry: _entry()));
      expect(find.text('+ NPR 1,200'), findsOneWidget);
    });

    testWidgets('the ledger keeps its fixed label column', (tester) async {
      await _pump(tester, AccountEntryTile(entry: _entry()));
      final double ledgerLabel = tester
          .widgetList<SizedBox>(
            find.descendant(
              of: find.byType(DataCardField).first,
              matching: find.byType(SizedBox),
            ),
          )
          .first
          .width!;
      expect(ledgerLabel, kDataCardLabelWidth);
    });

    testWidgets('an odd number of cells keeps the columns in place', (
      tester,
    ) async {
      // No created_at: three cells, and the last stays in the left column
      // rather than stretching across the card.
      await _pump(
        tester,
        BookingCard(
          booking: _booking(createdAt: null, type: null, amount: 0),
        ),
      );
      final List<Rect> cells = tester
          .widgetList<DataCardCell>(find.byType(DataCardCell))
          .map((DataCardCell c) => tester.getRect(find.byWidget(c)))
          .toList();

      expect(cells, hasLength(3));
      expect(cells[2].left, cells[0].left);
      expect((cells[2].width - cells[0].width).abs(), lessThan(0.5));
      expect(tester.takeException(), isNull);
    });

    testWidgets('the booking grid splits the card in equal halves', (
      tester,
    ) async {
      await _pump(tester, BookingCard(booking: _booking()));
      final List<Rect> cells = tester
          .widgetList<DataCardCell>(find.byType(DataCardCell))
          .map((DataCardCell c) => tester.getRect(find.byWidget(c)))
          .toList();

      expect(
        cells,
        hasLength(6),
        reason: 'date, time, ref, type, booked on, money',
      );
      // Left column cells share a left edge; so do the right column's.
      expect(cells[0].left, cells[2].left);
      expect(cells[1].left, cells[3].left);
      // And the two columns are the same width.
      expect((cells[0].width - cells[1].width).abs(), lessThan(0.5));
      // Paired into rows, not stacked one per line.
      expect(cells[0].top, cells[1].top);
      expect(cells[2].top, cells[3].top);
      expect(cells[2].top, greaterThan(cells[0].top));
    });
  });
}
