import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Shaped like one item of `GET /futsal-bookings`.
BookingModel booking({
  required int id,
  required int courtId,
  String date = '2026-09-26',
  required String start,
  required String end,
  String status = 'confirmed',
  double total = 1200,
  double paid = 0,
  List<Map<String, dynamic>>? slots,
}) {
  return BookingModel.fromJson(<String, dynamic>{
    'id': id,
    'venue_id': 1,
    'booking_code': 'BK-$id',
    'booking_date': date,
    'start_time': start,
    'end_time': end,
    'booking_status': status,
    'status': status,
    'total_amount': total,
    'paid_amount': paid,
    'balance_due': total - paid,
    'payment_status': paid <= 0
        ? 'unpaid'
        : (paid >= total ? 'paid' : 'partial'),
    'customer_name': 'Customer $id',
    'customer_phone': '98000000$id',
    'venue': <String, dynamic>{'id': 1, 'name': 'Venue A'},
    'court': <String, dynamic>{'id': courtId, 'name': 'Court $courtId'},
    'booking_slots':
        slots ??
        <Map<String, dynamic>>[
          <String, dynamic>{
            'id': id * 10,
            'slot_date': date,
            'slot_start': start,
            'slot_end': end,
            'slot_price': total,
            'status': status,
          },
        ],
  });
}

OpsCourt court({
  int id = 1,
  int venueId = 1,
  String venueName = 'Venue A',
  int slot = 60,
  int open = 6 * 60,
  int close = 22 * 60,
  double price = 1000,
  List<OpsPriceBand> bands = const <OpsPriceBand>[],
  List<OpsClosure> closures = const <OpsClosure>[],
  Set<String> weekendDays = const <String>{},
}) => OpsCourt(
  id: id,
  venueId: venueId,
  venueName: venueName,
  name: 'Court $id',
  slotMinutes: slot,
  openMinute: open,
  closeMinute: close,
  basePrice: price,
  bands: bands,
  closures: closures,
  weekendDays: weekendDays,
);

final DateTime day = DateTime(2026, 9, 26); // a Saturday
final DateTime today = DateTime(2026, 9, 26);

void main() {
  group('time parsing', () {
    test('reads every format the API and the app use', () {
      expect(parseMinuteOfDay('18:00'), 1080);
      expect(parseMinuteOfDay('18:00:00'), 1080);
      expect(parseMinuteOfDay('6:00 PM'), 1080);
      expect(parseMinuteOfDay('06 : 00 PM'), 1080);
      expect(parseMinuteOfDay('12 : 00 AM'), 0);
      expect(parseMinuteOfDay('12:30 PM'), 750);
      expect(parseMinuteOfDay('24:00'), 1440);
      expect(parseMinuteOfDay('nope'), isNull);
      expect(apiTimeOf(1080), '18:00');
      expect(formatMinuteOfDay(1080), '6:00 PM');
    });

    test('intervals are start-inclusive, end-exclusive', () {
      expect(overlaps(1080, 1140, 1140, 1200), isFalse, reason: 'adjacent');
      expect(overlaps(1080, 1140, 1110, 1170), isTrue, reason: 'overlap');
      expect(overlaps(1080, 1200, 1110, 1140), isTrue, reason: 'contains');
    });
  });

  group('court schedule', () {
    test('uses the court\'s own slot length, never assuming an hour', () {
      final OpsDaySchedule s = court(
        slot: 90,
        open: 6 * 60,
        close: 12 * 60,
      ).scheduleFor(day);
      expect(s.slots.map((OpsSlot x) => x.start), <int>[360, 450, 540, 630]);
      expect(s.slots.every((OpsSlot x) => x.minutes == 90), isTrue);
    });

    test('prices each band, weekend and special dates', () {
      final OpsCourt c = court(
        weekendDays: const <String>{'sat'},
        bands: const <OpsPriceBand>[
          OpsPriceBand(start: 360, end: 1080, price: 1000, weekendPrice: 1100),
          OpsPriceBand(
            start: 1080,
            end: 1320,
            price: 1500,
            customDatePrices: <String, double>{'2026-09-26': 2000},
          ),
        ],
      );
      final List<OpsSlot> slots = c.scheduleFor(day).slots;
      expect(slots.firstWhere((OpsSlot s) => s.start == 360).price, 1100);
      expect(slots.firstWhere((OpsSlot s) => s.start == 1080).price, 2000);
      // Sunday: no weekend price, no special date.
      final List<OpsSlot> sunday = c.scheduleFor(DateTime(2026, 9, 27)).slots;
      expect(sunday.firstWhere((OpsSlot s) => s.start == 360).price, 1000);
      expect(sunday.firstWhere((OpsSlot s) => s.start == 1080).price, 1500);
    });

    test('a slot never crosses a pricing band boundary', () {
      final OpsCourt c = court(
        slot: 90,
        bands: const <OpsPriceBand>[
          OpsPriceBand(start: 360, end: 540, price: 1000), // 06:00–09:00
          OpsPriceBand(start: 540, end: 720, price: 1500), // 09:00–12:00
        ],
      );
      final List<OpsSlot> slots = c.scheduleFor(day).slots;
      expect(slots.map((OpsSlot s) => (s.start, s.price)), <(int, double?)>[
        (360, 1000),
        (450, 1000),
        (540, 1500),
        (630, 1500),
      ]);
    });

    test('full-day and hourly closures', () {
      expect(
        court(
          closures: const <OpsClosure>[OpsClosure(date: '2026-09-26')],
        ).scheduleFor(day).closedReason,
        'Closed all day',
      );
      final OpsDaySchedule s = court(
        closures: const <OpsClosure>[
          OpsClosure(date: '2026-09-26', fullDay: false, start: 600, end: 720),
        ],
      ).scheduleFor(day);
      expect(
        s.slots.any((OpsSlot x) => overlaps(x.start, x.end, 600, 720)),
        isFalse,
      );
      expect(s.slots.any((OpsSlot x) => x.end == 600), isTrue);
      expect(s.slots.any((OpsSlot x) => x.start == 720), isTrue);
    });
  });

  group('board', () {
    test('booked, available and past cells', () {
      final OpsBoard board = buildOpsBoard(
        courts: <OpsCourt>[court(open: 1020, close: 1260)], // 17:00–21:00
        bookings: <BookingModel>[
          booking(id: 1, courtId: 1, start: '18:00:00', end: '19:00:00'),
        ],
        date: day,
        today: today,
        nowMinute: 1050, // 17:30
      );
      final List<OpsCell> cells = board.venues.single.courts.single.cells;
      expect(cells.map((OpsCell c) => (c.start, c.kind)), <(int, OpsCellKind)>[
        (1020, OpsCellKind.past),
        (1080, OpsCellKind.booked),
        (1140, OpsCellKind.available),
        (1200, OpsCellKind.available),
      ]);
    });

    test('an off-grid walk-in blocks every slot it touches', () {
      final OpsBoard board = buildOpsBoard(
        courts: <OpsCourt>[court(open: 1200, close: 1320)], // 20:00–22:00
        bookings: <BookingModel>[
          booking(id: 1, courtId: 1, start: '20:33:00', end: '21:33:00'),
        ],
        date: day,
        today: DateTime(2026, 9, 1),
        nowMinute: 0,
      );
      final List<OpsCell> cells = board.venues.single.courts.single.cells;
      expect(cells.single.kind, OpsCellKind.booked);
      expect((cells.single.start, cells.single.end), (1233, 1293));
    });

    test('cancelled bookings free their slots', () {
      final OpsBoard board = buildOpsBoard(
        courts: <OpsCourt>[court(open: 1080, close: 1140)],
        bookings: <BookingModel>[
          booking(
            id: 1,
            courtId: 1,
            start: '18:00:00',
            end: '19:00:00',
            status: 'cancelled',
          ),
        ],
        date: day,
        today: DateTime(2026, 9, 1),
        nowMinute: 0,
      );
      expect(
        board.venues.single.courts.single.cells.single.kind,
        OpsCellKind.available,
      );
    });

    test('in progress only on today, during the booking', () {
      OpsCell cellAt(int now) => buildOpsBoard(
        courts: <OpsCourt>[court(open: 1080, close: 1140)],
        bookings: <BookingModel>[
          booking(id: 1, courtId: 1, start: '18:00:00', end: '19:00:00'),
        ],
        date: day,
        today: today,
        nowMinute: now,
      ).venues.single.courts.single.cells.single;
      expect(cellAt(1100).phase, OpsBookingPhase.inProgress);
      expect(cellAt(1000).phase, OpsBookingPhase.confirmed);
      expect(cellAt(1140).phase, OpsBookingPhase.confirmed);
    });
  });

  group('summary', () {
    test('counts bookings, not slots, and separates payment from status', () {
      final OpsBoard board = buildOpsBoard(
        courts: <OpsCourt>[
          court(id: 1, open: 1080, close: 1260),
          court(id: 2, open: 1080, close: 1260),
        ],
        bookings: <BookingModel>[
          // One booking, two non-consecutive slots on court 1.
          booking(
            id: 1,
            courtId: 1,
            start: '18:00:00',
            end: '21:00:00',
            total: 2400,
            paid: 600,
            slots: <Map<String, dynamic>>[
              <String, dynamic>{
                'id': 1,
                'slot_date': '2026-09-26',
                'slot_start': '18:00:00',
                'slot_end': '19:00:00',
                'slot_price': 1200,
              },
              <String, dynamic>{
                'id': 2,
                'slot_date': '2026-09-26',
                'slot_start': '20:00:00',
                'slot_end': '21:00:00',
                'slot_price': 1200,
              },
            ],
          ),
          booking(
            id: 2,
            courtId: 2,
            start: '19:00:00',
            end: '20:00:00',
            total: 1200,
            paid: 1200,
          ),
        ],
        date: day,
        today: DateTime(2026, 9, 1),
        nowMinute: 0,
      );
      final OpsSummary s = summarizeBoard(board);
      expect(s.bookingCount, 2);
      expect(s.bookedMinutes, 180);
      expect(s.sellableMinutes, 360);
      expect(s.occupancy, 0.5);
      expect(s.availableMinutes, 180);
      expect(s.bookingValue, 3600);
      expect(s.outstanding, 1800);
      expect(s.outstandingCount, 1);
      // Chart figures: paid share, bookings by status, per-court occupancy.
      expect(s.paidValue, 1800);
      expect(s.pastUnbookedMinutes, 0);
      expect(s.phaseCounts, <OpsBookingPhase, int>{
        OpsBookingPhase.confirmed: 2,
      });
      expect(
        s.courts.map((OpsCourtOccupancy o) => (o.courtId, o.occupancy)),
        <(int, double)>[(1, 2 / 3), (2, 1 / 3)],
      );
      final OpsCell paidCell = board.venues.single.courts[1].cells.firstWhere(
        (OpsCell c) => c.kind == OpsCellKind.booked,
      );
      expect(paidCell.payment, OpsPaymentState.paid);
      expect(paidCell.phase, OpsBookingPhase.confirmed);
    });
  });

  group('selection', () {
    OpsSelectionItem item(int courtId, int start, {double price = 1000}) =>
        OpsSelectionItem(
          venueId: 1,
          venueName: 'Venue A',
          courtId: courtId,
          courtName: 'Court $courtId',
          date: '2026-09-26',
          start: start,
          end: start + 60,
          price: price,
        );

    test('merges touching slots, never fills a gap', () {
      final List<OpsBookingRange> ranges = mergeSelection(<OpsSelectionItem>[
        item(1, 1080),
        item(1, 1140, price: 1500),
        item(1, 1260), // gap at 20:00
        item(2, 1080),
      ]);
      expect(
        ranges.map((OpsBookingRange r) => (r.courtId, r.start, r.end)),
        <(int, int, int)>[(1, 1080, 1200), (1, 1260, 1320), (2, 1080, 1140)],
      );
      expect(ranges.first.estimate, 2500);
      expect(ranges.first.minutes, 120);
    });
  });

  test('Kathmandu clock is UTC+05:45 whatever the device zone', () {
    KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 26, 18, 20));
    expect(KathmanduClock.today(), DateTime(2026, 9, 27));
    expect(KathmanduClock.minuteOfDay(), 5); // 00:05
    KathmanduClock.debugSetUtcNow(null);
  });

  test('unbooked time that has passed is counted apart from available', () {
    final OpsSummary s = summarizeBoard(
      buildOpsBoard(
        courts: <OpsCourt>[
          court(open: 1020, close: 1260), // 17:00–21:00
          court(
            id: 2,
            closures: const <OpsClosure>[OpsClosure(date: '2026-09-26')],
          ),
        ],
        bookings: <BookingModel>[
          booking(id: 1, courtId: 1, start: '18:00:00', end: '19:00:00'),
        ],
        date: day,
        today: today,
        nowMinute: 1150, // 19:10 — 17:00 and 19:00 have started
      ),
    );
    expect(s.pastUnbookedMinutes, 120);
    expect(s.availableMinutes, 60);
    expect(s.bookedMinutes, 60);
    expect(s.sellableMinutes, 240);
    expect(s.courts.last.closedReason, 'Closed all day');
  });

  group('week table', () {
    test('runs Sunday to Saturday around any date', () {
      expect(weekStartOf(DateTime(2026, 9, 26)), DateTime(2026, 9, 20));
      expect(weekStartOf(DateTime(2026, 9, 20)), DateTime(2026, 9, 20));
      expect(weekStartOf(DateTime(2026, 9, 21)), DateTime(2026, 9, 20));
    });

    test('a week from today starts today and pages in sevens', () {
      final DateTime today = DateTime(2026, 9, 24); // Thursday
      DateTime start(DateTime d) =>
          weekStartFor(d, OpsWeekStart.today, today: today);
      expect(start(today), today);
      expect(start(DateTime(2026, 9, 30)), today); // 6 days on: same week
      expect(start(DateTime(2026, 10, 1)), DateTime(2026, 10, 1));
      expect(start(DateTime(2026, 9, 23)), DateTime(2026, 9, 17));
      expect(start(DateTime(2026, 9, 17)), DateTime(2026, 9, 17));
      // Across a month and a year end.
      expect(
        weekStartFor(
          DateTime(2027, 1, 2),
          OpsWeekStart.today,
          today: DateTime(2026, 12, 30),
        ),
        DateTime(2026, 12, 30),
      );
      // Sunday mode is the calendar week, whatever today is.
      expect(
        weekStartFor(DateTime(2026, 9, 24), OpsWeekStart.sunday, today: today),
        DateTime(2026, 9, 20),
      );
    });

    test('the stored week start reads back, unknown as Sunday', () {
      expect(OpsWeekStart.fromKey('today'), OpsWeekStart.today);
      expect(OpsWeekStart.fromKey('sunday'), OpsWeekStart.sunday);
      expect(OpsWeekStart.fromKey(null), OpsWeekStart.sunday);
      expect(OpsWeekStart.fromKey('monday'), OpsWeekStart.sunday);
    });

    test('rows are slot times, columns are days, cells carry status', () {
      final OpsCourt c = court(
        open: 1080,
        close: 1260, // 18:00–21:00
        weekendDays: const <String>{'sat'},
        bands: const <OpsPriceBand>[
          OpsPriceBand(start: 1080, end: 1260, price: 1000, weekendPrice: 1500),
        ],
        closures: const <OpsClosure>[OpsClosure(date: '2026-09-23')], // Wed
      );
      final OpsWeekTable t = buildWeekTable(
        court: c,
        bookings: <BookingModel>[
          // Two rows long, on Monday.
          booking(
            id: 1,
            courtId: 1,
            date: '2026-09-21',
            start: '18:00:00',
            end: '20:00:00',
          ),
          // Off the slot grid, on Thursday.
          booking(
            id: 2,
            courtId: 1,
            date: '2026-09-24',
            start: '19:30:00',
            end: '20:30:00',
          ),
          // Another court: ignored.
          booking(
            id: 3,
            courtId: 9,
            date: '2026-09-22',
            start: '18:00:00',
            end: '19:00:00',
          ),
        ],
        weekStart: DateTime(2026, 9, 20),
        today: DateTime(2026, 9, 22), // Tuesday
        nowMinute: 1150, // 19:10
      );

      expect(t.days.first, DateTime(2026, 9, 20));
      expect(t.days.last, DateTime(2026, 9, 26));
      expect(t.rows, <int>[1080, 1140, 1200]);
      expect(t.todayIndex, 2);

      OpsWeekCell at(int row, int day) => t.cells[row][day];

      // Monday: one booking over two rows, the second a continuation.
      expect(at(0, 1).kind, OpsCellKind.booked);
      expect(at(0, 1).continuation, isFalse);
      expect(at(1, 1).kind, OpsCellKind.booked);
      expect(at(1, 1).continuation, isTrue);
      // Monday is before today, so its free slot is past.
      expect(at(2, 1).kind, OpsCellKind.past);

      // Tuesday (today, 19:10): started slots are past.
      expect(at(0, 2).kind, OpsCellKind.past);
      expect(at(1, 2).kind, OpsCellKind.past);
      expect(at(2, 2).kind, OpsCellKind.available);

      // Wednesday: closed all day.
      expect(t.closedDays[3], 'Closed all day');
      expect(at(0, 3).kind, OpsCellKind.closed);

      // Thursday: the 19:30 walk-in shows in both rows it touches.
      expect(at(1, 4).kind, OpsCellKind.booked);
      expect(at(1, 4).continuation, isFalse);
      expect(at(2, 4).kind, OpsCellKind.booked);
      expect(at(2, 4).continuation, isTrue);

      // Saturday takes the weekend price; the other court's booking is not
      // on this table.
      expect(at(0, 6).cell!.price, 1500);
      expect(at(0, 5).cell!.price, 1000);
      expect(at(0, 2).kind, isNot(OpsCellKind.booked));
    });
  });

  group('court day summary', () {
    OpsCourtRow rowFor(List<BookingModel> bookings, {int now = 1150}) =>
        buildOpsBoard(
          courts: <OpsCourt>[court(open: 1020, close: 1320)], // 17:00–22:00
          bookings: bookings,
          date: day,
          today: today,
          nowMinute: now,
        ).venues.single.courts.single;

    test('next free, booking on court now, and the next one', () {
      final OpsCourtDaySummary s = summarizeCourtDay(
        rowFor(<BookingModel>[
          booking(id: 1, courtId: 1, start: '19:00:00', end: '20:00:00'),
          booking(id: 2, courtId: 1, start: '21:00:00', end: '22:00:00'),
        ]),
        nowMinute: 1150, // 19:10
      );
      expect(s.current?.booking?.id, 1);
      expect(s.next?.booking?.id, 2);
      expect(s.nextFree?.start, 1200); // 20:00
      expect(s.freeSlots, 1);
      expect(s.occupancy, 120 / 300);
      expect(s.isFull, isFalse);
    });

    test('full and closed courts', () {
      final OpsCourtDaySummary full = summarizeCourtDay(
        rowFor(<BookingModel>[
          booking(id: 1, courtId: 1, start: '17:00:00', end: '22:00:00'),
        ], now: 0),
        nowMinute: 0,
      );
      expect(full.isFull, isTrue);
      expect(full.nextFree, isNull);

      final OpsCourtDaySummary closed = summarizeCourtDay(
        buildOpsBoard(
          courts: <OpsCourt>[
            court(closures: const <OpsClosure>[OpsClosure(date: '2026-09-26')]),
          ],
          bookings: const <BookingModel>[],
          date: day,
          today: today,
          nowMinute: 0,
        ).venues.single.courts.single,
      );
      expect(closed.isClosed, isTrue);
      expect(closed.isFull, isFalse);
    });
  });
}
