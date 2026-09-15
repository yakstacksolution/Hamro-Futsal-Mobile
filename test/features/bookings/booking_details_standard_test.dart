import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/widgets/data_card.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_review_model.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/bookings/presentation/pages/booking_details_page.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_shared_widgets.dart';

/// A booking whose payment summary exercises every row: a discount, products
/// on top, a part payment and an outstanding balance.
BookingModel _billed() => BookingModel.fromJson(<String, dynamic>{
  'id': 420,
  'booking_code': 'BK-BILLED',
  'booking_date': '2026-09-15',
  'start_time': '07:00:00',
  'end_time': '08:00:00',
  'slot_count': 1,
  'price_per_slot': 1400,
  'subtotal': 1400,
  'discount_amount': 500,
  'extra_amount': 100,
  'payable_now': 180,
  'balance_due_later': 720,
  'total_amount': 900,
  'paid_amount': 180,
  'balance_due': 720,
  'payment_status': 'partial',
  'booking_status': 'confirmed',
  'created_at': '2026-09-12 19:20:52',
  'venue': <String, dynamic>{'id': 40, 'name': 'Harisiddhi futsal'},
  'court': <String, dynamic>{'id': 41, 'name': 'Court 1'},
  'payment': <String, dynamic>{
    'id': 9,
    'payment_method': 'cash',
    'amount': 180,
    'verification_status': 'verified',
  },
  'extra_items': <Map<String, dynamic>>[
    <String, dynamic>{
      'id': 57,
      'product_id': 25,
      'name': 'Water',
      'quantity': 4,
      'unit_price': 25,
      'total_amount': 100,
    },
  ],
});

/// Booking 419 of the live list response.
BookingModel _booking() => BookingModel.fromJson(<String, dynamic>{
  'id': 419,
  'booking_code': 'BK-RQOFZJPT',
  'booking_type': 'regular',
  'booking_date': '2026-09-15',
  'start_time': '07:00:00',
  'end_time': '08:00:00',
  'total_amount': 1150,
  'paid_amount': 1150,
  'balance_due': 0,
  'payment_status': 'paid',
  'booking_status': 'completed',
  'created_at': '2026-09-12 19:20:52',
  'venue': <String, dynamic>{'id': 40, 'name': 'Harisiddhi futsal'},
  'court': <String, dynamic>{'id': 41, 'name': 'Court 1'},
  'customer_name': 'Dilli Bhandari',
  'customer_phone': '985655336655',
});

Set<String> _texts(WidgetTester tester) => tester
    .widgetList<Text>(find.byType(Text))
    .map((Text t) => t.data ?? '')
    .where((String s) => s.isNotEmpty)
    .toSet();

Future<void> _pumpDetails(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(411, 1400);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: BookingDetailsPage(
          booking: _booking(),
          repository: _FakeBookingRepository(_booking()),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpCard(WidgetTester tester) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(411, 900);
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BookingCard(booking: _booking()),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('the summary opens as the card the reader tapped', (
    tester,
  ) async {
    await _pumpCard(tester);
    final Set<String> card = _texts(tester);

    await _pumpDetails(tester);
    final Set<String> details = _texts(tester);

    // Every fact the list card showed is on the details page, spelled the
    // same way — arriving here must not restate anything differently.
    for (final String fact in <String>[
      'Harisiddhi futsal',
      'Court 1',
      'NPR 1,150',
      'DATE',
      'Sep 15, 2026',
      'TIME',
      '7:00 AM – 8:00 AM',
      'REFERENCE',
      'BK-RQOFZJPT',
      'TYPE',
      'Regular',
      'BOOKED ON',
      'Sep 12, 2026 · 7:20 PM',
      'PAID',
    ]) {
      expect(card, contains(fact), reason: '$fact missing from the list card');
      expect(details, contains(fact), reason: '$fact missing from details');
    }
  });

  testWidgets('the page is built from the shared card language', (
    tester,
  ) async {
    await _pumpDetails(tester);

    // The summary uses the same header, divider and grid as the cards.
    expect(find.byType(DataCardHeader), findsOneWidget);
    expect(find.byType(DataCardGrid), findsOneWidget);
    expect(find.byType(DataCardCell), findsNWidgets(6));
    expect(find.byType(DataCardChip), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sections are labelled and hold their own cards', (tester) async {
    await _pumpDetails(tester);

    expect(find.text('Booking information'), findsOneWidget);
    // The venue and court are named in full in their own section.
    expect(find.text('Venue'), findsOneWidget);
    expect(find.text('Court'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a booking reads at the same size, bar its heading', (
    tester,
  ) async {
    await _pumpCard(tester);
    final Map<String, double> card = <String, double>{
      'DATE': tester.widget<Text>(find.text('DATE')).style!.fontSize!,
      'value': tester
          .widget<Text>(find.text('Sep 15, 2026'))
          .style!
          .fontSize!,
      'title': tester
          .widget<Text>(find.text('Harisiddhi futsal'))
          .style!
          .fontSize!,
      // The total is in the header and again in the PAID cell; the header's
      // is the first.
      'amount': tester
          .widget<Text>(find.text('NPR 1,150').first)
          .style!
          .fontSize!,
    };

    await _pumpDetails(tester);
    // The venue is also named in the Booking information section, so the
    // summary's own title is the first of them.
    final Map<String, double> details = <String, double>{
      'DATE': tester.widget<Text>(find.text('DATE')).style!.fontSize!,
      'value': tester
          .widget<Text>(find.text('Sep 15, 2026'))
          .style!
          .fontSize!,
      'title': tester
          .widget<Text>(find.text('Harisiddhi futsal').first)
          .style!
          .fontSize!,
      'amount': tester
          .widget<Text>(find.text('NPR 1,150').first)
          .style!
          .fontSize!,
    };

    // The facts read at the same size in both places — a reader moving
    // between them should not have to adjust.
    expect(card['DATE'], details['DATE']);
    expect(card['value'], details['value']);
    expect(card['value'], DataCardDensity.detail.valueSize);

    // The venue name and the figure are the exception: they head the details
    // page, but on a list card they sit level with the facts below them so
    // the top of every card does not shout.
    expect(details['title'], DataCardDensity.detail.titleSize);
    expect(card['title'], kDataCardListTitleSize);
    expect(card['title'], lessThan(details['title']!));
    expect(card['amount'], card['title']);
    expect(details['amount'], details['title']);
  });

  testWidgets('the payment summary is one consistent type scale', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(411, 2200);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (BuildContext context, Widget? _) => MaterialApp(
          home: BookingDetailsPage(
            booking: _billed(),
            repository: _FakeBookingRepository(_billed()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    double sizeOf(String text) =>
        tester.widget<Text>(find.text(text).first).style!.fontSize!;

    await tester.scrollUntilVisible(
      find.text('Payable now'),
      200,
      scrollable: find.byType(Scrollable).last,
    );

    // ignore: avoid_print
    // Ordinary breakdown rows all sit at the page's reading size.
    final double row = sizeOf('Payable now');
    for (final String label in <String>[
      'Balance due later',
      'Paid amount',
      'Payment status',
      'Products (4 items)',
    ]) {
      expect(sizeOf(label), row, reason: '\$label is out of scale');
    }

    // The figures that settle the card take exactly one step up — no more.
    final double total = sizeOf('Grand total');
    expect(total, greaterThan(row));
    expect(total - row, lessThanOrEqualTo(2));
    expect(sizeOf('Balance due'), total);

    // And the amounts beside them match their labels rather than running
    // larger, which is what made this section look oversized.
    expect(sizeOf('NPR 900'), total, reason: 'the grand total figure');
    expect(sizeOf('NPR 180'), row, reason: 'a settlement figure');
  });

  testWidgets('it lays out on a narrow screen without overflowing', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(320, 1400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (BuildContext context, Widget? _) => MaterialApp(
          home: BookingDetailsPage(
            booking: _booking(),
            repository: _FakeBookingRepository(_booking()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('BK-RQOFZJPT'), findsOneWidget);
  });
}

/// Answers only what this page asks for; anything else would be a change in
/// what the page loads, which these tests want to hear about.
class _FakeBookingRepository extends Fake implements BookingRepository {
  _FakeBookingRepository(this.booking);

  final BookingModel booking;

  @override
  Future<Either<AppException, BookingModel>> getBookingDetails(int id) async =>
      right(booking);

  @override
  Future<Either<AppException, BookingReviewModel?>> getBookingReview(
    int bookingId,
  ) async => right(null);

  @override
  Future<Either<AppException, bool>> getCancelBoundary(int bookingId) async =>
      right(false);
}
