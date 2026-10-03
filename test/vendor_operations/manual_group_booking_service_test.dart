import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_result_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/manual_group_booking_service.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Records holds, releases and creates; refuses what it is told to.
class _FakeRepository implements FutsalDetailsRepository {
  _FakeRepository({this.refuseHoldOnCourt, this.skipHoldOnCourt});

  /// A list with this court in it is refused as a whole.
  final int? refuseHoldOnCourt;

  /// Answered, but with no hold for this court.
  final int? skipHoldOnCourt;

  /// Each `POST /booking-holds` list, as sent.
  final List<List<Map<String, dynamic>>> holdCalls =
      <List<Map<String, dynamic>>>[];

  /// Each `DELETE /booking-holds` list of ids, as sent.
  final List<List<String>> releaseCalls = <List<String>>[];

  final List<String> held = <String>[];
  List<String> get released => <String>[
    for (final List<String> ids in releaseCalls) ...ids,
  ];
  final List<CreateBookingRequest> created = <CreateBookingRequest>[];
  int _nextId = 100;

  @override
  Future<Either<AppException, List<BookingHoldModel>>> createBookingHolds({
    required List<BookingHoldRequest> holds,
  }) async {
    holdCalls.add(<Map<String, dynamic>>[
      for (final BookingHoldRequest h in holds) h.toJson(),
    ]);
    if (holds.any((BookingHoldRequest h) => h.courtId == refuseHoldOnCourt)) {
      return left(
        DefaultException(errorMessage: 'Slot already booked.', statusCode: 409),
      );
    }
    return right(<BookingHoldModel>[
      for (final BookingHoldRequest h in holds)
        if (h.courtId != skipHoldOnCourt)
          () {
            final String id = 'hold-${h.courtId}-${h.startTime}';
            held.add(id);
            return BookingHoldModel(
              id: id,
              holdToken: 'token-$id',
              courtId: h.courtId,
              bookingDate: h.bookingDate,
              startTime: '${h.startTime}:00',
            );
          }(),
    ]);
  }

  @override
  Future<Either<AppException, Unit>> releaseBookingHolds({
    required List<String> holdIds,
  }) async {
    releaseCalls.add(holdIds);
    return right(unit);
  }

  @override
  Future<Either<AppException, BookingResultModel>> createBooking(
    CreateBookingRequest request,
  ) async {
    created.add(request);
    return right(BookingResultModel(id: _nextId++));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

OpsBookingRange range(int courtId, int start, {int venueId = 1}) =>
    OpsBookingRange(
      items: <OpsSelectionItem>[
        OpsSelectionItem(
          venueId: venueId,
          venueName: 'Venue $venueId',
          courtId: courtId,
          courtName: 'Court $courtId',
          date: '2026-09-26',
          start: start,
          end: start + 60,
          price: 1000,
        ),
      ],
    );

OpsSelectionItem item(
  int courtId,
  int start, {
  int venueId = 1,
  String date = '2026-09-26',
}) => OpsSelectionItem(
  venueId: venueId,
  venueName: 'Venue $venueId',
  courtId: courtId,
  courtName: 'Court $courtId',
  date: date,
  start: start,
  end: start + 60,
  price: 1000,
);

const OpsCustomer customer = OpsCustomer(name: 'Dibya', phone: '9800000000');

void main() {
  test('a refused hold releases every hold taken and books nothing', () async {
    final _FakeRepository repo = _FakeRepository(refuseHoldOnCourt: 3);
    final ManualGroupBookingService service = ManualGroupBookingService(
      repository: repo,
    );

    final OpsPrepareOutcome outcome = await service.prepare(<OpsBookingRange>[
      range(1, 1080),
      range(2, 1080, venueId: 2),
      range(3, 1080),
    ]);

    // One request holds the whole selection, as a list.
    expect(repo.holdCalls, hasLength(1));
    expect(
      repo.holdCalls.single.map((Map<String, dynamic> h) => h['court_id']),
      <int>[1, 2, 3],
    );
    expect(repo.holdCalls.single.first, <String, dynamic>{
      'venue_id': 1,
      'court_id': 1,
      'booking_date': '2026-09-26',
      'start_time': '18:00',
      'end_time': '19:00',
    });
    // Refused as a whole: nothing held, nothing to release, nothing booked.
    expect(outcome.isConflict, isTrue);
    expect(outcome.conflict, isNull);
    expect(outcome.message, 'Slot already booked.');
    expect(repo.held, isEmpty);
    expect(repo.releaseCalls, isEmpty);
    expect(repo.created, isEmpty);
  });

  test(
    'a range the server did not hold gives back the others at once',
    () async {
      final _FakeRepository repo = _FakeRepository(skipHoldOnCourt: 2);
      final ManualGroupBookingService service = ManualGroupBookingService(
        repository: repo,
      );

      final OpsPrepareOutcome outcome = await service.prepare(<OpsBookingRange>[
        range(1, 1080),
        range(2, 1080, venueId: 2),
        range(3, 1080),
      ]);

      expect(outcome.isConflict, isTrue);
      expect(outcome.conflict!.courtId, 2);
      expect(repo.releaseCalls, hasLength(1));
      expect(repo.released, unorderedEquals(repo.held));
      expect(repo.created, isEmpty);
    },
  );

  test('never sends a payment status the API rejects', () {
    // The API answers 422 "The selected payment status is invalid." to
    // anything but these; `unpaid` in particular is not one of them.
    for (final OpsPaymentPlan plan in OpsPaymentPlan.values) {
      expect(<String>{'paid', 'partial', 'pending'}, contains(plan.apiStatus));
    }
  });

  test('the whole selection is one manual booking payload', () async {
    final _FakeRepository repo = _FakeRepository();
    final List<Map<String, dynamic>> sent = <Map<String, dynamic>>[];
    final ManualGroupBookingService service = ManualGroupBookingService(
      repository: repo,
      submit: (Map<String, dynamic> payload) async {
        sent.add(payload);
        return right(<String, dynamic>{'status': 'success'});
      },
    );
    // Two back-to-back hours on court 5 (venue 1), one on court 8 (venue 2),
    // same day — the two hours arrive as one range.
    final OpsPrepareOutcome held = await service.prepare(<OpsBookingRange>[
      OpsBookingRange(
        items: <OpsSelectionItem>[
          item(5, 600, venueId: 1, date: '2026-09-29'),
          item(5, 660, venueId: 1, date: '2026-09-29'),
        ],
      ),
      OpsBookingRange(
        items: <OpsSelectionItem>[item(8, 840, venueId: 2, date: '2026-09-29')],
      ),
    ]);
    await service.confirm(
      tickets: held.tickets,
      customer: const OpsCustomer(
        name: 'Walk In Customer',
        phone: '9800000000',
      ),
      payment: const OpsPayment(
        lines: <OpsPaymentLine>[
          OpsPaymentLine(method: 'cash', amount: 2000),
          OpsPaymentLine(method: 'online', amount: 200),
        ],
        note: 'Bulk manual booking',
      ),
    );

    expect(repo.created, isEmpty, reason: 'no per-slot /bookings calls');
    expect(sent.single, <String, dynamic>{
      'customer_name': 'Walk In Customer',
      'customer_phone': '9800000000',
      'payment': <Map<String, dynamic>>[
        <String, dynamic>{'payment_type': 'cash', 'value': 2000},
        <String, dynamic>{'payment_type': 'online', 'value': 200},
      ],
      // 2,200 of 3,000.
      'payment_status': 'partial',
      'booking_status': 'confirmed',
      'notes': 'Bulk manual booking',
      'bookings': <Map<String, dynamic>>[
        <String, dynamic>{
          'venue_id': 1,
          'court_id': 5,
          'booking_date': '2026-09-29',
          'slots': <Map<String, String>>[
            <String, String>{'start_time': '10:00', 'end_time': '11:00'},
            <String, String>{'start_time': '11:00', 'end_time': '12:00'},
          ],
        },
        <String, dynamic>{
          'venue_id': 2,
          'court_id': 8,
          'booking_date': '2026-09-29',
          'slots': <Map<String, String>>[
            <String, String>{'start_time': '14:00', 'end_time': '15:00'},
          ],
        },
      ],
    });
  });

  test('one entry per venue, court and date', () async {
    final List<Map<String, dynamic>> sent = <Map<String, dynamic>>[];
    final ManualGroupBookingService service = ManualGroupBookingService(
      repository: _FakeRepository(),
      submit: (Map<String, dynamic> payload) async {
        sent.add(payload);
        return right(null);
      },
    );
    // Court 1 on two dates, and a later range on the same court and date.
    final OpsPrepareOutcome held = await service.prepare(<OpsBookingRange>[
      OpsBookingRange(items: <OpsSelectionItem>[item(1, 1080)]),
      OpsBookingRange(
        items: <OpsSelectionItem>[item(1, 1080, date: '2026-09-27')],
      ),
      OpsBookingRange(items: <OpsSelectionItem>[item(1, 1260)]),
    ]);
    await service.confirm(
      tickets: held.tickets,
      customer: customer,
      payment: const OpsPayment(),
    );
    final List<dynamic> bookings = sent.single['bookings'] as List<dynamic>;
    expect(
      bookings.map((dynamic b) => (b['booking_date'], b['slots'].length)),
      <(String, int)>[('2026-09-26', 2), ('2026-09-27', 1)],
    );
  });

  test('payment status and method follow the payments', () async {
    Future<Map<String, dynamic>> send(OpsPayment payment) async {
      Map<String, dynamic>? sent;
      final ManualGroupBookingService service = ManualGroupBookingService(
        repository: _FakeRepository(),
        submit: (Map<String, dynamic> p) async {
          sent = p;
          return right(null);
        },
      );
      final OpsPrepareOutcome held = await service.prepare(<OpsBookingRange>[
        range(1, 1080),
      ]);
      await service.confirm(
        tickets: held.tickets,
        customer: customer,
        payment: payment,
      );
      return sent!;
    }

    final Map<String, dynamic> nothing = await send(
      const OpsPayment(bookingStatus: OpsBookingStatus.completed),
    );
    expect(nothing['payment_status'], 'pending');
    expect(nothing['payment'], isEmpty);
    // No top-level `payment_method`: the `payment` list says how.
    expect(nothing.containsKey('payment_method'), isFalse);
    expect(nothing['booking_status'], 'completed');
    expect(nothing.containsKey('notes'), isFalse);

    final Map<String, dynamic> online = await send(
      const OpsPayment(
        lines: <OpsPaymentLine>[OpsPaymentLine(method: 'online', amount: 1000)],
      ),
    );
    expect(online['payment_status'], 'paid');
    expect(online.containsKey('payment_method'), isFalse);
    expect(online['payment'], <Map<String, dynamic>>[
      <String, dynamic>{'payment_type': 'online', 'value': 1000},
    ]);

    final Map<String, dynamic> split = await send(
      const OpsPayment(
        lines: <OpsPaymentLine>[
          OpsPaymentLine(method: 'online', amount: 400),
          OpsPaymentLine(method: 'cash', amount: 600.5),
        ],
      ),
    );
    expect(split['payment_status'], 'paid');
    expect(split['payment'], <Map<String, dynamic>>[
      <String, dynamic>{'payment_type': 'online', 'value': 400},
      <String, dynamic>{'payment_type': 'cash', 'value': 600.5},
    ]);
  });

  test('never sends a booking status but confirmed or completed', () {
    expect(
      OpsBookingStatus.values.map((OpsBookingStatus b) => b.apiValue),
      <String>['confirmed', 'completed'],
    );
  });

  test('booked ranges take the ids the server sends back', () async {
    final ManualGroupBookingService service = ManualGroupBookingService(
      repository: _FakeRepository(),
      submit: (_) async => right(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'bookings': <dynamic>[
            <String, dynamic>{
              'id': 901,
              'court_id': 2,
              'booking_date': '2026-09-26',
              'start_time': '18:00:00',
              'end_time': '19:00:00',
            },
            <String, dynamic>{
              'id': 900,
              'court': <String, dynamic>{'id': 1},
              'booking_date': '2026-09-26',
              'start_time': '18:00:00',
              'end_time': '19:00:00',
            },
          ],
        },
      }),
    );
    final OpsPrepareOutcome held = await service.prepare(<OpsBookingRange>[
      range(1, 1080),
      range(2, 1080),
    ]);
    final List<OpsRangeTicket> result = await service.confirm(
      tickets: held.tickets,
      customer: customer,
      payment: const OpsPayment(
        lines: <OpsPaymentLine>[OpsPaymentLine(method: 'cash', amount: 1500)],
      ),
    );
    expect(result.map((OpsRangeTicket t) => t.bookingId), <int>[900, 901]);
    expect(result.map((OpsRangeTicket t) => t.paidNow), <double>[1000, 500]);
  });

  test(
    'a refused booking books nothing; a retry sends it again, once',
    () async {
      int calls = 0;
      bool down = true;
      final ManualGroupBookingService service = ManualGroupBookingService(
        repository: _FakeRepository(),
        submit: (_) async {
          calls++;
          return down
              ? left(
                  DefaultException(
                    errorMessage: 'Slot already booked.',
                    statusCode: 422,
                  ),
                )
              : right(null);
        },
      );
      final OpsPrepareOutcome held = await service.prepare(<OpsBookingRange>[
        range(1, 1080),
        range(2, 1080),
      ]);
      List<OpsRangeTicket> tickets = await service.confirm(
        tickets: held.tickets,
        customer: customer,
        payment: const OpsPayment(),
      );
      expect(tickets.any((OpsRangeTicket t) => t.isCreated), isFalse);
      expect(tickets.first.error, 'Slot already booked.');

      down = false;
      tickets = await service.confirm(
        tickets: tickets,
        customer: customer,
        payment: const OpsPayment(),
      );
      expect(tickets.every((OpsRangeTicket t) => t.isCreated), isTrue);
      // Booked: confirming again sends nothing.
      await service.confirm(
        tickets: tickets,
        customer: customer,
        payment: const OpsPayment(),
      );
      expect(calls, 2);
    },
  );

  test('releasing after review gives back only unbooked holds', () async {
    final _FakeRepository repo = _FakeRepository();
    final ManualGroupBookingService service = ManualGroupBookingService(
      repository: repo,
    );
    final OpsPrepareOutcome held = await service.prepare(<OpsBookingRange>[
      range(1, 1080),
      range(2, 1080),
    ]);
    final List<OpsRangeTicket> tickets = <OpsRangeTicket>[
      held.tickets.first.copyWith(bookingId: 55),
      held.tickets.last,
    ];
    await service.release(tickets);
    // One `DELETE /booking-holds`, with the hold ids.
    expect(repo.releaseCalls, <List<String>>[
      <String>[held.tickets.last.holdId],
    ]);
    expect(held.tickets.last.holdId, 'hold-2-18:00');
  });
}
