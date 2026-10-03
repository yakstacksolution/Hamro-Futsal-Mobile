import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_quote_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/manual_group_booking_service.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Whether the vendor dashboard starts on demo data.
///
/// Off by default, so the dashboard loads the vendor's own venues and courts
/// (`/auth/get-venue-courts?purpose=booking`) and their bookings. Build with
/// `--dart-define=VENDOR_OPS_DEMO=true` to start on demo data instead.
const bool kVendorOpsDemoByDefault = bool.fromEnvironment('VENDOR_OPS_DEMO');

/// Two venues: Dhananjay Sports Arena and Dhanawantary Sports.
///
/// Demo court ids chosen to trigger each booking outcome.
abstract final class VendorOpsDemoCourts {
  /// Holds from 7 PM on are refused — "just booked online".
  static const int conflictAfter7pm = 9201;

  /// The server quotes NPR 100 more per range than the board shows.
  static const int priceChanges = 9202;

  /// The first booking attempt fails; retrying succeeds.
  static const int failsFirstTime = 9103;
}

/// In-memory venues, courts and bookings that exercise every state the
/// dashboard can show. Bookings are generated for whichever date is asked
/// for, relative to Kathmandu today, and bookings made in demo mode are kept
/// for the session so they appear on the board.
class VendorOpsDemoStore {
  VendorOpsDemoStore();

  final Map<String, List<BookingModel>> _created =
      <String, List<BookingModel>>{};
  int _nextId = 70000;
  bool _failedOnce = false;

  static const Duration latency = Duration(milliseconds: 450);

  // ───────────────────────────── Courts ─────────────────────────────

  List<OpsCourt> courts() {
    final DateTime today = KathmanduClock.today();
    final String todayKey = isoDate(today);
    final String inTwoDays = isoDate(today.add(const Duration(days: 2)));
    final String tomorrow = isoDate(today.add(const Duration(days: 1)));
    return <OpsCourt>[
      // Dhananjay Sports Arena — pricing bands, 90- and 30-minute slots,
      // a maintenance window.
      OpsCourt(
        id: 9101,
        venueId: 901,
        venueName: 'Dhananjay Sports Arena',
        name: 'Court 1 · Peak pricing',
        slotMinutes: 60,
        weekendDays: const <String>{'sat'},
        holidayDates: <String>{tomorrow},
        bands: <OpsPriceBand>[
          const OpsPriceBand(start: 6 * 60, end: 16 * 60, price: 1000),
          OpsPriceBand(
            start: 16 * 60,
            end: 22 * 60,
            price: 1500,
            weekendPrice: 1800,
            holidayPrice: 1700,
            customDatePrices: <String, double>{inTwoDays: 2000},
          ),
        ],
      ),
      const OpsCourt(
        id: 9102,
        venueId: 901,
        venueName: 'Dhananjay Sports Arena',
        name: 'Court 2 · 90-min slots',
        slotMinutes: 90,
        openMinute: 6 * 60,
        closeMinute: 21 * 60,
        basePrice: 1800,
      ),
      OpsCourt(
        id: VendorOpsDemoCourts.failsFirstTime,
        venueId: 901,
        venueName: 'Dhananjay Sports Arena',
        name: 'Court 3 · 30-min slots',
        slotMinutes: 30,
        openMinute: 7 * 60,
        closeMinute: 21 * 60,
        basePrice: 600,
        closures: <OpsClosure>[
          OpsClosure(
            date: todayKey,
            fullDay: false,
            start: 12 * 60,
            end: 14 * 60,
          ),
        ],
      ),
      // Dhanawantary Sports — outcomes for the booking flow.
      const OpsCourt(
        id: VendorOpsDemoCourts.conflictAfter7pm,
        venueId: 902,
        venueName: 'Dhanawantary Sports',
        name: 'Court A · Busy after 7 PM',
        openMinute: 5 * 60,
        closeMinute: 23 * 60,
        basePrice: 1200,
      ),
      const OpsCourt(
        id: VendorOpsDemoCourts.priceChanges,
        venueId: 902,
        venueName: 'Dhanawantary Sports',
        name: 'Court B · Server re-prices',
        openMinute: 6 * 60,
        closeMinute: 22 * 60,
        basePrice: 1300,
      ),
      OpsCourt(
        id: 9203,
        venueId: 902,
        venueName: 'Dhanawantary Sports',
        name: 'Court C · Closed today',
        openMinute: 6 * 60,
        closeMinute: 22 * 60,
        basePrice: 1100,
        closures: <OpsClosure>[OpsClosure(date: todayKey)],
      ),
    ];
  }

  OpsCourt? _court(int id) =>
      courts().where((OpsCourt c) => c.id == id).firstOrNull;

  /// What the schedule says [range] costs — the "server" price in demo.
  double? _priceOf(int courtId, String date, int start, int end) {
    final OpsCourt? court = _court(courtId);
    final DateTime? day = DateTime.tryParse(date);
    if (court == null || day == null) return null;
    double total = 0;
    for (final OpsSlot s in court.scheduleFor(day).slots) {
      if (overlaps(s.start, s.end, start, end)) total += s.price ?? 0;
    }
    return total;
  }

  // ───────────────────────────── Bookings ─────────────────────────────

  static const List<(String, String)> _customers = <(String, String)>[
    ('Aarav Shrestha', '9841000001'),
    ('Sujata Karki', '9851000002'),
    ('Bikash Thapa', '9861000003'),
    ('Nisha Gurung', '9801000004'),
    ('Roshan Maharjan', '9811000005'),
    ('Pratik Adhikari', '9821000006'),
    ('Anjali Rai', '9841000007'),
    ('Suman Tamang', '9851000008'),
    ('Kiran Bhandari', '9861000009'),
    ('Dipesh KC', '9801000010'),
    ('Sabina Magar', '9811000011'),
    ('Ujjwal Poudel', '9821000012'),
  ];

  List<BookingModel> bookingsOn(DateTime date) {
    final String key = isoDate(date);
    final DateTime today = KathmanduClock.today();
    final int offset = date.difference(today).inDays;
    final bool past = offset < 0;
    final bool isToday = offset == 0;
    // Rotates names so neighbouring days do not look identical.
    int n = offset.abs() * 3;
    (String, String) next() => _customers[n++ % _customers.length];

    // Today's bookings are marked completed only once their time is over.
    String statusFor(int endMinute, {String upcoming = 'confirmed'}) {
      if (past) return 'completed';
      if (isToday && endMinute <= KathmanduClock.minuteOfDay()) {
        return 'completed';
      }
      return upcoming;
    }

    final List<BookingModel> out = <BookingModel>[];
    int id = 50000 + (offset + 400) * 100;

    void add({
      required int courtId,
      required int venueId,
      required String venueName,
      required String courtName,
      required List<(int, int)> slots,
      required double total,
      required double paid,
      String? status,
      String type = 'regular',
      String? note,
    }) {
      final (String name, String phone) = next();
      final int end = slots.last.$2;
      out.add(
        _booking(
          id: id++,
          date: key,
          courtId: courtId,
          venueId: venueId,
          venueName: venueName,
          courtName: courtName,
          slots: slots,
          total: total,
          paid: paid,
          status: status ?? statusFor(end),
          customer: name,
          phone: phone,
          type: type,
          note: note,
        ),
      );
    }

    const String arena = 'Dhananjay Sports Arena';
    const String dhanawantary = 'Dhanawantary Sports';

    // Court 1 — every payment state, and one booking with two separate slots.
    add(
      courtId: 9101,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 1 · Peak pricing',
      slots: <(int, int)>[(360, 420)],
      total: 1000,
      paid: 1000,
    );
    add(
      courtId: 9101,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 1 · Peak pricing',
      slots: <(int, int)>[(420, 480)],
      total: 1000,
      paid: 0,
      note: 'Pays at the end of the month',
    );
    add(
      courtId: 9101,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 1 · Peak pricing',
      slots: <(int, int)>[(540, 600)],
      total: 1000,
      paid: 500,
    );
    add(
      courtId: 9101,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 1 · Peak pricing',
      slots: <(int, int)>[(840, 900), (1200, 1260)],
      total: 2500,
      paid: 1000,
      note: 'Two separate slots, one booking',
    );
    add(
      courtId: 9101,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 1 · Peak pricing',
      slots: <(int, int)>[(960, 1080)],
      total: 3000,
      paid: 3000,
    );
    add(
      courtId: 9101,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 1 · Peak pricing',
      slots: <(int, int)>[(1080, 1140)],
      total: 1500,
      paid: 0,
      status: past ? 'completed' : 'pending',
      note: 'Waiting for payment proof',
    );

    // Court 2 — 90-minute slots.
    add(
      courtId: 9102,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 2 · 90-min slots',
      slots: <(int, int)>[(450, 540)],
      total: 1800,
      paid: 1800,
    );
    add(
      courtId: 9102,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 2 · 90-min slots',
      slots: <(int, int)>[(990, 1080)],
      total: 1800,
      paid: 0,
    );
    add(
      courtId: 9102,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 2 · 90-min slots',
      slots: <(int, int)>[(1170, 1260)],
      total: 1800,
      paid: 900,
      type: 'manual',
    );

    // Court 3 — 30-minute slots.
    add(
      courtId: VendorOpsDemoCourts.failsFirstTime,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 3 · 30-min slots',
      slots: <(int, int)>[(480, 510), (510, 540)],
      total: 1200,
      paid: 1200,
    );
    add(
      courtId: VendorOpsDemoCourts.failsFirstTime,
      venueId: 901,
      venueName: arena,
      courtName: 'Court 3 · 30-min slots',
      slots: <(int, int)>[(1020, 1050)],
      total: 600,
      paid: 0,
      status: past ? 'completed' : 'pending',
    );

    // Court A — the booking running now, and an off-grid walk-in.
    final int nowHour = (KathmanduClock.minuteOfDay() ~/ 60) * 60;
    final int liveStart = isToday ? nowHour.clamp(5 * 60, 21 * 60) : 15 * 60;
    add(
      courtId: VendorOpsDemoCourts.conflictAfter7pm,
      venueId: 902,
      venueName: dhanawantary,
      courtName: 'Court A · Busy after 7 PM',
      slots: <(int, int)>[(liveStart, liveStart + 60)],
      total: 1200,
      paid: 600,
      status: past ? 'completed' : 'confirmed',
    );
    if (liveStart != 20 * 60) {
      add(
        courtId: VendorOpsDemoCourts.conflictAfter7pm,
        venueId: 902,
        venueName: dhanawantary,
        courtName: 'Court A · Busy after 7 PM',
        slots: <(int, int)>[(1233, 1293)],
        total: 1200,
        paid: 1200,
        type: 'manual',
        note: 'Walk-in at 8:33 PM',
      );
    }

    // Court B — a cancelled booking leaves its slot free.
    add(
      courtId: VendorOpsDemoCourts.priceChanges,
      venueId: 902,
      venueName: dhanawantary,
      courtName: 'Court B · Server re-prices',
      slots: <(int, int)>[(600, 660)],
      total: 1300,
      paid: 0,
      status: 'cancelled',
    );
    add(
      courtId: VendorOpsDemoCourts.priceChanges,
      venueId: 902,
      venueName: dhanawantary,
      courtName: 'Court B · Server re-prices',
      slots: <(int, int)>[(1140, 1260)],
      total: 2600,
      paid: 1300,
    );

    return <BookingModel>[...out, ...?_created[key]];
  }

  // ───────────────────────────── Booking flow ─────────────────────────────

  Future<Either<AppException, BookingHoldModel>> hold({
    required int? courtId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    await Future<void>.delayed(latency);
    final int start = parseMinuteOfDay(startTime) ?? 0;
    final int end = parseMinuteOfDay(endTime) ?? 0;
    if (courtId == VendorOpsDemoCourts.conflictAfter7pm && start >= 19 * 60) {
      return left(
        DefaultException(
          errorMessage: 'Just booked online by another player (demo conflict).',
          statusCode: 409,
        ),
      );
    }
    double? price = _priceOf(courtId ?? 0, date, start, end);
    if (price != null && courtId == VendorOpsDemoCourts.priceChanges) {
      price += 100;
    }
    return right(
      BookingHoldModel(
        id: 'demo-hold-id-$courtId-$date-$startTime',
        holdToken: 'demo-hold-$courtId-$date-$startTime',
        courtId: courtId,
        bookingDate: date,
        startTime: startTime,
        endTime: endTime,
        expiresAt: DateTime.now()
            .add(const Duration(minutes: 10))
            .toIso8601String(),
        quote: BookingQuoteModel(
          priceDetails: BookingPriceDetailsModel(
            subtotal: price,
            bookingTotal: price,
          ),
        ),
      ),
    );
  }

  /// `POST /futsal-bookings/manual` in demo mode: one booking per venue,
  /// court and date, the payments filling them in order.
  Future<Either<AppException, dynamic>> createManual(
    Map<String, dynamic> payload,
  ) async {
    await Future<void>.delayed(latency);
    final List<Map<String, dynamic>> groups = <Map<String, dynamic>>[
      for (final dynamic g in payload['bookings'] as List<dynamic>)
        Map<String, dynamic>.from(g as Map),
    ];
    if (!_failedOnce &&
        groups.any(
          (Map<String, dynamic> g) =>
              g['court_id'] == VendorOpsDemoCourts.failsFirstTime,
        )) {
      _failedOnce = true;
      return left(
        DefaultException(
          errorMessage:
              'Server timed out (demo failure — retry succeeds). '
              'Nothing was booked.',
          statusCode: 504,
        ),
      );
    }
    double received = 0;
    for (final dynamic p
        in payload['payment'] as List<dynamic>? ?? <dynamic>[]) {
      received += ((p as Map)['value'] as num?)?.toDouble() ?? 0;
    }
    final List<Map<String, dynamic>> created = <Map<String, dynamic>>[];
    for (final Map<String, dynamic> g in groups) {
      final int courtId = g['court_id'] as int;
      final String date = g['booking_date'] as String;
      final List<(int, int)> slots = <(int, int)>[
        for (final dynamic slot in g['slots'] as List<dynamic>)
          (
            parseMinuteOfDay('${(slot as Map)['start_time']}') ?? 0,
            parseMinuteOfDay('${slot['end_time']}') ?? 0,
          ),
      ];
      double total = 0;
      for (final (int s, int e) in slots) {
        total += _priceOf(courtId, date, s, e) ?? 0;
      }
      if (courtId == VendorOpsDemoCourts.priceChanges) total += 100;
      final double paid = received < total ? received : total;
      received -= paid;
      final OpsCourt? court = _court(courtId);
      final int id = _nextId++;
      _created
          .putIfAbsent(date, () => <BookingModel>[])
          .add(
            _booking(
              id: id,
              date: date,
              courtId: courtId,
              venueId: g['venue_id'] as int? ?? court?.venueId ?? 0,
              venueName: court?.venueName ?? 'Venue',
              courtName: court?.name ?? 'Court',
              slots: slots,
              total: total,
              paid: paid,
              status: '${payload['booking_status'] ?? 'confirmed'}',
              customer: '${payload['customer_name'] ?? 'Customer'}',
              phone: '${payload['customer_phone'] ?? ''}',
              type: 'manual',
              note: payload['notes'] as String?,
            ),
          );
      created.add(<String, dynamic>{
        'id': id,
        'court_id': courtId,
        'booking_date': date,
        'start_time': apiTimeOf(slots.first.$1),
        'end_time': apiTimeOf(slots.last.$2),
      });
    }
    return right(<String, dynamic>{
      'status': 'success',
      'data': <String, dynamic>{'bookings': created},
    });
  }

  static BookingModel _booking({
    required int id,
    required String date,
    required int courtId,
    required int venueId,
    required String venueName,
    required String courtName,
    required List<(int, int)> slots,
    required double total,
    required double paid,
    required String status,
    required String customer,
    required String phone,
    String type = 'regular',
    String? note,
  }) {
    final double perSlot = slots.isEmpty ? total : total / slots.length;
    return BookingModel.fromJson(<String, dynamic>{
      'id': id,
      'booking_code': 'BK-DEMO$id',
      'booking_type': type,
      'booking_date': date,
      'start_time': apiTimeOf(slots.first.$1),
      'end_time': apiTimeOf(slots.last.$2),
      'slot_count': slots.length,
      'booking_status': status,
      'status': status,
      'total_amount': total,
      'paid_amount': paid,
      'balance_due': (total - paid).clamp(0, double.infinity),
      'payment_status': paid <= 0
          ? 'unpaid'
          : (paid >= total ? 'paid' : 'partial'),
      'customer_name': customer,
      'customer_phone': phone,
      'notes': note,
      'created_at': '$date 08:00:00',
      'venue_id': venueId,
      'venue': <String, dynamic>{'id': venueId, 'name': venueName},
      'court': <String, dynamic>{'id': courtId, 'name': courtName},
      'payments': <Map<String, dynamic>>[
        if (paid > 0)
          <String, dynamic>{
            'id': id * 10,
            'payment_method': 'cash',
            'amount': paid,
            'status': 'success',
            'verification_status': 'verified',
            'created_at': '$date 08:05:00',
          },
      ],
      'booking_slots': <Map<String, dynamic>>[
        for (int i = 0; i < slots.length; i++)
          <String, dynamic>{
            'id': id * 10 + i,
            'slot_date': date,
            'slot_start': apiTimeOf(slots[i].$1),
            'slot_end': apiTimeOf(slots[i].$2),
            'slot_price': perSlot,
            'status': status,
          },
      ],
    });
  }
}

// ───────────────────────────── Repositories ─────────────────────────────

class DemoVendorOpsRepository extends VendorOpsRepository {
  DemoVendorOpsRepository(this.store)
    : super(bookingRepository: _UnusedBookings());

  final VendorOpsDemoStore store;

  /// The demo courts with their own schedules and the day's demo bookings;
  /// no server slots, so each court is drawn from its schedule.
  @override
  Future<Either<AppException, OpsDayAvailability>> loadDay(
    DateTime date,
  ) async {
    await Future<void>.delayed(VendorOpsDemoStore.latency * 2);
    return right(
      OpsDayAvailability(
        date: date,
        courts: store.courts(),
        bookings: store.bookingsOn(date),
      ),
    );
  }

  @override
  Future<Either<AppException, List<BookingModel>>> loadBookingsBetween(
    DateTime from,
    DateTime to,
  ) async {
    await Future<void>.delayed(VendorOpsDemoStore.latency);
    return right(<BookingModel>[
      for (
        DateTime d = from;
        !d.isAfter(to);
        d = DateTime(d.year, d.month, d.day + 1)
      )
        ...store.bookingsOn(d),
    ]);
  }

  /// The demo week has no server slots to carry bookings: the store's.
  @override
  List<BookingModel> bookingsInWeek(OpsCourtWeekAvailability week) =>
      <BookingModel>[
        for (int i = 0; i < 7; i++)
          ...store.bookingsOn(
            DateTime(
              week.weekStart.year,
              week.weekStart.month,
              week.weekStart.day + i,
            ),
          ),
      ];

  /// No server week in the demo: the table works the week out from the demo
  /// courts' schedules.
  @override
  Future<Either<AppException, OpsCourtWeekAvailability>> loadCourtWeekSlots({
    required int venueId,
    required int courtId,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) async =>
      right(OpsCourtWeekAvailability(courtId: courtId, weekStart: start));
}

class _DemoFutsalDetailsRepository implements FutsalDetailsRepository {
  _DemoFutsalDetailsRepository(this.store);

  final VendorOpsDemoStore store;

  /// Holds each range in turn; one refused refuses the whole list, as the
  /// server does.
  @override
  Future<Either<AppException, List<BookingHoldModel>>> createBookingHolds({
    required List<BookingHoldRequest> holds,
  }) async {
    final List<BookingHoldModel> held = <BookingHoldModel>[];
    for (final BookingHoldRequest h in holds) {
      final Either<AppException, BookingHoldModel> one = await store.hold(
        courtId: h.courtId,
        date: h.bookingDate,
        startTime: h.startTime,
        endTime: h.endTime,
      );
      final AppException? failure = one.fold((AppException e) => e, (_) {
        return null;
      });
      if (failure != null) return left(failure);
      held.add(one.getOrElse(() => throw StateError('unreachable')));
    }
    return right(held);
  }

  @override
  Future<Either<AppException, Unit>> releaseBookingHolds({
    required List<String> holdIds,
  }) async => right(unit);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Not available in demo: ${invocation.memberName}');
}

/// A booking service that talks only to [store] — nothing leaves the device.
ManualGroupBookingService demoBookingService(VendorOpsDemoStore store) =>
    ManualGroupBookingService(
      repository: _DemoFutsalDetailsRepository(store),
      submit: store.createManual,
    );

/// Stand in for repositories the demo never calls.
class _UnusedBookings implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError('Not available in demo: ${invocation.memberName}');
}
