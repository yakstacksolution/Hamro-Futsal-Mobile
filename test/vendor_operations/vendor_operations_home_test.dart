import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/pages/vendor_operations_home.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_style.dart';

class _NoBookings implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Two venues, three courts with different slot lengths, one booking.
class _FakeOpsRepository extends VendorOpsRepository {
  _FakeOpsRepository() : super(bookingRepository: _NoBookings());

  /// The day's one call: the courts with their schedules and the booking,
  /// no server slots — each court is drawn from its schedule.
  @override
  Future<Either<AppException, OpsDayAvailability>> loadDay(
    DateTime date,
  ) async => right(
    OpsDayAvailability(
      date: date,
      courts: _courts,
      bookings: _bookingsOn(date),
    ),
  );

  @override
  Future<Either<AppException, OpsCourtWeekAvailability>> loadCourtWeekSlots({
    required int venueId,
    required int courtId,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) async =>
      right(OpsCourtWeekAvailability(courtId: courtId, weekStart: start));

  static const List<OpsCourt> _courts = <OpsCourt>[
    OpsCourt(
      id: 1,
      venueId: 1,
      venueName: 'Dhananjay Sport',
      name: 'Court 1',
      openMinute: 6 * 60,
      closeMinute: 22 * 60,
      basePrice: 1000,
    ),
    OpsCourt(
      id: 2,
      venueId: 1,
      venueName: 'Dhananjay Sport',
      name: 'Court 2',
      slotMinutes: 90,
      openMinute: 6 * 60,
      closeMinute: 21 * 60,
      basePrice: 1500,
    ),
    OpsCourt(
      id: 3,
      venueId: 2,
      venueName: 'Dhanawantary Sports',
      name: 'Court A',
      openMinute: 7 * 60,
      closeMinute: 20 * 60,
      basePrice: 1200,
    ),
  ];

  @override
  Future<Either<AppException, List<BookingModel>>> loadBookingsBetween(
    DateTime from,
    DateTime to,
  ) async => right(_bookingsOn(DateTime(2026, 9, 26)));

  static List<BookingModel> _bookingsOn(DateTime date) => <BookingModel>[
    BookingModel.fromJson(<String, dynamic>{
      'id': 471,
      'booking_code': 'BK-3V0CRW0R',
      'booking_date': isoDate(date),
      'start_time': '18:00:00',
      'end_time': '19:00:00',
      'booking_status': 'confirmed',
      'total_amount': 1200,
      'paid_amount': 600,
      'balance_due': 600,
      'payment_status': 'partial',
      'customer_name': 'Dibya',
      'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay Sport'},
      'court': <String, dynamic>{'id': 1, 'name': 'Court 1'},
    }),
  ];
}

Future<void> pumpHome(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: FutsalTheme.lightTheme,
      home: Scaffold(
        body: VendorOperationsHome(
          repository: _FakeOpsRepository(),
          demo: false,
        ),
      ),
    ),
  );
  // The day's one call, then the first frame of the board.
  for (int i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUp(() {
    // 17:30 in Kathmandu on 26 Sep 2026.
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 11, 45));
  });
  tearDown(() => KathmanduClock.debugSetUtcNow(null));

  testWidgets('phone: court cards, then a court\'s week to book from', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpHome(tester, const Size(390, 844));
    expect(tester.takeException(), isNull);

    expect(find.textContaining('Today'), findsWidgets);
    // The day overview strip.
    expect(find.text('booked'), findsWidgets);
    expect(find.text('due'), findsOneWidget);
    // Dibya paid Rs 600 of 1,200: shown as both paid and due.
    expect(find.text('paid'), findsOneWidget);
    expect(find.text('Rs 600'), findsNWidgets(2));

    // Day view: a card per court, with the next booking on it.
    await tester.scrollUntilVisible(
      find.text('Court A'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Dibya · 6:00 PM'), findsOneWidget);
    expect(find.text('Court 2'), findsOneWidget);

    // The day's slots are on the card: Dibya's booking and free slots.
    expect(
      find.bySemanticsLabel(RegExp(r'^Court 1, 6:00 PM, Confirmed, Dibya')),
      findsOneWidget,
    );
    final Finder slot = find.bySemanticsLabel(
      RegExp(r'^Court 1, 7:00 PM, available'),
    );
    await tester.ensureVisible(slot);
    await tester.pump();
    await tester.tap(slot);
    await tester.pump();
    expect(find.textContaining('1 slot · 1 court-h'), findsOneWidget);
    expect(find.text('Review'), findsOneWidget);
    expect(find.text('1 court · Est. NPR 1,000'), findsOneWidget);

    // A 90-minute slot on a second court, then clear — quietly, no snackbar.
    final Finder other = find.bySemanticsLabel(
      RegExp(r'^Court 2, .*available'),
    );
    await tester.ensureVisible(other.first);
    await tester.pump();
    await tester.tap(other.first);
    await tester.pump();
    expect(find.textContaining('2 slots · 2.5 court-h'), findsOneWidget);
    expect(find.text('2 courts · Est. NPR 2,500'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear selection'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Review'), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Undo'), findsNothing);

    // The Week tab shows a court's whole week as a table.
    await tester.ensureVisible(find.text('Week').first);
    await tester.pump();
    await tester.tap(find.text('Week').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Time slot'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('desktop: court cards and the side booking panel', (
    tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpHome(tester, const Size(1440, 1200));
    expect(tester.takeException(), isNull);

    expect(find.text('Manual booking'), findsOneWidget);
    expect(find.text('Dibya · 6:00 PM'), findsOneWidget);

    // Picking a free slot on a court card opens the panel beside it.
    final Finder slot = find.bySemanticsLabel(
      RegExp(r'^Court 1, 8:00 PM, available'),
    );
    await tester.ensureVisible(slot);
    await tester.pump();
    await tester.tap(slot);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Continue'), findsOneWidget);
    expect(find.textContaining('1 slot · 1 court-h'), findsOneWidget);

    // A card's "Week ›" opens that court's week.
    await tester.ensureVisible(find.text('Week ›').first);
    await tester.pump();
    await tester.tap(find.text('Week ›').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Time slot'), findsOneWidget);
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  for (final Size size in const <Size>[
    Size(320, 640),
    Size(600, 960),
    Size(800, 1280),
    Size(1024, 768),
  ]) {
    testWidgets('lays out without errors at ${size.width.toInt()} px', (
      tester,
    ) async {
      await pumpHome(tester, size);
      expect(tester.takeException(), isNull);
      // The court cards can sit below the fold on short screens.
      await tester.scrollUntilVisible(
        find.text('Court 2').last,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Court 2'), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('statuses stay hidden until Status is tapped', (tester) async {
    await pumpHome(tester, const Size(360, 1400));
    expect(find.byType(OpsLegend), findsNothing);

    final Finder toggle = find.text('Status');
    await tester.ensureVisible(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(OpsLegend), findsOneWidget);

    await tester.tap(toggle);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    expect(find.byType(OpsLegend), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
