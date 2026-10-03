import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Books a vendor's multi-venue, multi-court, multi-date selection for one
/// customer, with however it was paid.
///
/// 1. [prepare] holds every range. If any hold is refused, every hold already
///    taken is released and nothing is booked — the vendor sees exactly which
///    slot conflicted. The holds also bring the server's prices to review.
/// 2. [confirm] books the whole selection in one
///    `POST /futsal-bookings/manual` ([buildManualBookingPayload]): the
///    customer, every payment line (part in cash, the rest online), and one
///    entry per venue, court and date with its slots. The server books all of
///    it or none of it, so a retry after a failure sends the same request
///    again, and once booked nothing is sent twice.
/// Sends a manual booking payload; the decoded response on success.
typedef OpsSubmitManualBooking =
    Future<Either<AppException, dynamic>> Function(
      Map<String, dynamic> payload,
    );

class ManualGroupBookingService {
  ManualGroupBookingService({
    FutsalDetailsRepository? repository,
    OpsSubmitManualBooking? submit,
  }) : _repository = repository ?? FutsalDetailsRepositoryImpl(),
       _submit = submit ?? _submitViaApi;

  final FutsalDetailsRepository _repository;
  final OpsSubmitManualBooking _submit;

  static Future<Either<AppException, dynamic>> _submitViaApi(
    Map<String, dynamic> payload,
  ) async {
    final Result response = await Client.instance()
        .getAuthManager()
        .createManualBooking(payload);
    if (response.isError()) return left(ResponseHelper.error(response));
    return right(response.getValue());
  }

  /// Holds every range in one `POST /booking-holds` — a list, one item per
  /// range. Returns the held ranges, or a conflict with every hold taken
  /// released.
  Future<OpsPrepareOutcome> prepare(List<OpsBookingRange> ranges) async {
    if (ranges.isEmpty) return const OpsPrepareOutcome.held(<OpsRangeTicket>[]);
    final Either<AppException, List<BookingHoldModel>> result =
        await _repository.createBookingHolds(
          holds: <BookingHoldRequest>[
            for (final OpsBookingRange range in ranges)
              BookingHoldRequest(
                venueId: range.venueId,
                courtId: range.courtId,
                bookingDate: range.date,
                startTime: apiTimeOf(range.start),
                endTime: apiTimeOf(range.end),
              ),
          ],
        );
    const String refused =
        'This slot could not be held. It may have just been booked.';
    final AppException? failure = result.fold((AppException e) => e, (_) {
      return null;
    });
    if (failure != null) {
      // Refused as a whole: nothing was held. Only a lone range can be named.
      return OpsPrepareOutcome.conflict(
        range: ranges.length == 1 ? ranges.single : null,
        message: failure.errorMessage.isEmpty ? refused : failure.errorMessage,
      );
    }
    final List<BookingHoldModel> holds = result.getOrElse(
      () => const <BookingHoldModel>[],
    );
    final List<OpsRangeTicket> held = <OpsRangeTicket>[];
    final Set<BookingHoldModel> unmatched = holds.toSet();
    for (int i = 0; i < ranges.length; i++) {
      final OpsBookingRange range = ranges[i];
      final BookingHoldModel? hold = _holdFor(range, i, holds, unmatched);
      if (hold == null || !hold.hasId) {
        // A range left unheld: give back every hold taken, in one call, and
        // book nothing.
        await _releaseHolds(holds);
        return OpsPrepareOutcome.conflict(range: range, message: refused);
      }
      unmatched.remove(hold);
      held.add(
        OpsRangeTicket(
          range: range,
          holdId: hold.id!,
          holdToken: hold.holdToken ?? '',
          holdExpiresAt: DateTime.tryParse(hold.expiresAt ?? '')?.toLocal(),
          serverTotal:
              hold.quote?.priceDetails?.bookingTotal ??
              hold.quote?.priceDetails?.subtotal,
        ),
      );
    }
    return OpsPrepareOutcome.held(held);
  }

  /// [range]'s hold: the one for its court, date and start time, else — for
  /// a hold that does not say which court it is — the one sent back at its
  /// place in the list.
  static BookingHoldModel? _holdFor(
    OpsBookingRange range,
    int index,
    List<BookingHoldModel> holds,
    Set<BookingHoldModel> unmatched,
  ) {
    final String start = apiTimeOf(range.start);
    for (final BookingHoldModel h in unmatched) {
      if (h.courtId == range.courtId &&
          (h.bookingDate == null || h.bookingDate == range.date) &&
          (h.startTime == null || h.startTime!.startsWith(start))) {
        return h;
      }
    }
    if (index < holds.length &&
        holds[index].courtId == null &&
        unmatched.contains(holds[index])) {
      return holds[index];
    }
    return null;
  }

  Future<void> _releaseHolds(Iterable<BookingHoldModel> holds) async {
    final List<String> ids = <String>[
      for (final BookingHoldModel h in holds)
        if (h.hasId) h.id!,
    ];
    if (ids.isNotEmpty) await _repository.releaseBookingHolds(holdIds: ids);
  }

  /// Releases holds that were not turned into bookings, in one
  /// `DELETE /booking-holds` with their ids.
  Future<void> release(Iterable<OpsRangeTicket> tickets) async {
    final List<String> ids = <String>[
      for (final OpsRangeTicket t in tickets)
        if (t.bookingId == null && t.holdId.isNotEmpty) t.holdId,
    ];
    if (ids.isEmpty) return;
    await _repository.releaseBookingHolds(holdIds: ids);
  }

  /// Books every held range in one request, with [payment]. Returns the
  /// tickets marked booked — or, when the server refused, unbooked with its
  /// message, ready to send again.
  Future<List<OpsRangeTicket>> confirm({
    required List<OpsRangeTicket> tickets,
    required OpsCustomer customer,
    required OpsPayment payment,
  }) async {
    if (tickets.isEmpty || tickets.every((OpsRangeTicket t) => t.isCreated)) {
      return tickets;
    }
    final double payable = tickets.fold<double>(
      0,
      (double sum, OpsRangeTicket t) => sum + (t.effectiveTotal ?? 0),
    );
    final Either<AppException, dynamic> result = await _submit(
      buildManualBookingPayload(
        tickets: tickets,
        customer: customer,
        payment: payment,
        payable: payable,
      ),
    );
    return result.fold(
      (AppException e) => <OpsRangeTicket>[
        for (final OpsRangeTicket t in tickets)
          t.isCreated ? t : t.copyWith(error: e.errorMessage),
      ],
      (dynamic response) {
        final List<Map<String, dynamic>> created = _createdBookings(response);
        final List<double> paid = _paidPerTicket(tickets, payment.received);
        return <OpsRangeTicket>[
          for (int i = 0; i < tickets.length; i++)
            tickets[i].copyWith(
              bookingId: _bookingIdFor(tickets[i].range, created) ?? -1,
              paymentRecorded: true,
              paidNow: paid[i],
              clearError: true,
            ),
        ];
      },
    );
  }
}

/// The `POST /futsal-bookings/manual` body for [tickets]:
///
/// ```json
/// {
///   "customer_name": "Walk In Customer", "customer_phone": "9800000000",
///   "payment": [{"payment_type": "cash", "value": 2000},
///               {"payment_type": "online", "value": 200}],
///   "payment_status": "partial", "booking_status": "confirmed",
///   "notes": "Bulk manual booking",
///   "bookings": [{"venue_id": 1, "court_id": 5, "booking_date": "2026-09-29",
///                 "slots": [{"start_time": "10:00", "end_time": "11:00"}]}]
/// }
/// ```
///
/// One `bookings` entry per venue, court and date, in the order first
/// picked, each with its slots in time order. `payment_status` is what the
/// payments add up to against [payable]. Empty optional fields are left out.
Map<String, dynamic> buildManualBookingPayload({
  required List<OpsRangeTicket> tickets,
  required OpsCustomer customer,
  required OpsPayment payment,
  required double payable,
}) {
  final Map<String, List<OpsSelectionItem>> groups =
      <String, List<OpsSelectionItem>>{};
  for (final OpsRangeTicket t in tickets) {
    for (final OpsSelectionItem item in t.range.items) {
      groups
          .putIfAbsent(
            '${item.venueId}|${item.courtId}|${item.date}',
            () => <OpsSelectionItem>[],
          )
          .add(item);
    }
  }
  final String? notes = payment.note ?? customer.note;
  return <String, dynamic>{
    'customer_name': customer.name,
    'customer_phone': customer.phone,
    if (customer.email case final String email when email.trim().isNotEmpty)
      'customer_email': email.trim(),
    // How it was paid is the `payment` list alone — no top-level
    // `payment_method`.
    'payment': <Map<String, dynamic>>[
      for (final OpsPaymentLine line in payment.lines)
        if (line.amount > 0)
          <String, dynamic>{
            'payment_type': line.method,
            'value': _wholeOrDecimal(line.amount),
          },
    ],
    'payment_status': payment.planFor(payable).apiStatus,
    'booking_status': payment.bookingStatus.apiValue,
    if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    'bookings': <Map<String, dynamic>>[
      for (final List<OpsSelectionItem> items in groups.values)
        <String, dynamic>{
          'venue_id': items.first.venueId,
          'court_id': items.first.courtId,
          'booking_date': items.first.date,
          'slots': <Map<String, String>>[
            for (final OpsSelectionItem i
                in items.toList()..sort(
                  (OpsSelectionItem a, OpsSelectionItem b) =>
                      a.start.compareTo(b.start),
                ))
              <String, String>{
                'start_time': apiTimeOf(i.start),
                'end_time': apiTimeOf(i.end),
              },
          ],
        },
    ],
  };
}

/// `2000`, not `2000.0`, for whole rupees.
num _wholeOrDecimal(double v) => v == v.roundToDouble() ? v.round() : v;

/// Every booking the response describes — maps with an `id` and a court —
/// wherever it nests them (`data`, `data.bookings`, …).
List<Map<String, dynamic>> _createdBookings(dynamic node, [int depth = 0]) {
  if (depth > 5 || node == null) return const <Map<String, dynamic>>[];
  if (node is List) {
    return <Map<String, dynamic>>[
      for (final dynamic n in node) ..._createdBookings(n, depth + 1),
    ];
  }
  if (node is! Map) return const <Map<String, dynamic>>[];
  final Map<String, dynamic> map = Map<String, dynamic>.from(node);
  final dynamic court = map['court'];
  final bool isBooking =
      map['id'] != null &&
      (map['court_id'] != null || (court is Map && court['id'] != null)) &&
      (map['booking_date'] != null || map['start_time'] != null);
  if (isBooking) return <Map<String, dynamic>>[map];
  return <Map<String, dynamic>>[
    for (final dynamic v in map.values)
      if (v is Map || v is List) ..._createdBookings(v, depth + 1),
  ];
}

/// The created booking covering [range]: same court and date, and — when the
/// booking says — a time that overlaps.
int? _bookingIdFor(OpsBookingRange range, List<Map<String, dynamic>> created) {
  for (final Map<String, dynamic> b in created) {
    final dynamic court = b['court'];
    final int? courtId = int.tryParse(
      '${b['court_id'] ?? (court is Map ? court['id'] : '')}',
    );
    if (courtId != range.courtId) continue;
    final String date = '${b['booking_date'] ?? ''}';
    if (date.isNotEmpty && !date.startsWith(range.date)) continue;
    final int? start = parseMinuteOfDay('${b['start_time'] ?? ''}');
    final int? end = parseMinuteOfDay('${b['end_time'] ?? ''}');
    if (start != null &&
        end != null &&
        !(start < range.end && range.start < end)) {
      continue;
    }
    return int.tryParse('${b['id']}');
  }
  return null;
}

/// How much of [received] went to each ticket, filling them in order up to
/// what each costs — for showing what was paid on each booking.
List<double> _paidPerTicket(List<OpsRangeTicket> tickets, double received) {
  double left = received;
  return <double>[
    for (int i = 0; i < tickets.length; i++)
      () {
        final double due = tickets[i].effectiveTotal ?? left;
        final double take = i == tickets.length - 1
            ? left
            : (left < due ? left : due);
        left -= take;
        return take < 0 ? 0.0 : take;
      }(),
  ];
}

/// What has been paid, worked out from the payment lines./// What has been paid, worked out from the payment lines.
///
/// The booking API's payment statuses are `paid`, `partial` and `pending` —
/// `pending` is what it calls not paid yet, and it rejects `unpaid` with 422
/// "The selected payment status is invalid."
enum OpsPaymentPlan {
  full('Paid', 'paid'),
  partial('Partly paid', 'partial'),
  pending('Pending', 'pending');

  const OpsPaymentPlan(this.label, this.apiStatus);

  final String label;

  /// `payment_status` sent with the booking.
  final String apiStatus;
}

/// The booking's own status, apart from its payment. A booking made at the
/// counter is either confirmed, or already played (completed).
enum OpsBookingStatus {
  confirmed('Confirmed', 'confirmed'),
  completed('Completed', 'completed');

  const OpsBookingStatus(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

class OpsCustomer extends Equatable {
  const OpsCustomer({
    required this.name,
    required this.phone,
    this.email,
    this.note,
  });

  final String name;
  final String phone;
  final String? email;
  final String? note;

  @override
  List<Object?> get props => <Object?>[name, phone, email, note];
}

/// One amount received, and how: `cash` or `online` — the methods the
/// booking API accepts.
class OpsPaymentLine extends Equatable {
  const OpsPaymentLine({required this.method, required this.amount});

  final String method;
  final double amount;

  @override
  List<Object?> get props => <Object?>[method, amount];
}

class OpsPayment extends Equatable {
  const OpsPayment({
    this.lines = const <OpsPaymentLine>[],
    this.bookingStatus = OpsBookingStatus.confirmed,
    this.note,
  });

  /// What was received, one line per method used — e.g. part in cash, the
  /// rest online. Empty when nothing has been paid yet.
  final List<OpsPaymentLine> lines;
  final OpsBookingStatus bookingStatus;

  /// Sent as the booking's `payment_note`.
  final String? note;

  /// Everything received, across the lines.
  double get received => lines.fold<double>(
    0,
    (double sum, OpsPaymentLine l) => sum + (l.amount > 0 ? l.amount : 0),
  );

  /// Paid by more than one line.
  bool get isSplit =>
      lines.where((OpsPaymentLine l) => l.amount > 0).length > 1;

  /// The method the booking is created with: the first line that paid
  /// something, else the first line, else cash.
  String get method =>
      lines.where((OpsPaymentLine l) => l.amount > 0).firstOrNull?.method ??
      lines.firstOrNull?.method ??
      'cash';

  /// Nothing received is pending, [payable] or more is paid, anything
  /// between is partly paid.
  OpsPaymentPlan planFor(double payable) {
    final double r = received;
    if (r <= 0) return OpsPaymentPlan.pending;
    if (payable > 0 && r >= payable - 0.5) return OpsPaymentPlan.full;
    return OpsPaymentPlan.partial;
  }

  @override
  List<Object?> get props => <Object?>[lines, bookingStatus, note];
}

/// One range's progress through hold → booking → payment.
class OpsRangeTicket extends Equatable {
  const OpsRangeTicket({
    required this.range,
    required this.holdId,
    this.holdToken = '',
    this.holdExpiresAt,
    this.serverTotal,
    this.bookingId,
    this.paymentRecorded = false,
    this.paidNow = 0,
    this.error,
  });

  final OpsBookingRange range;

  /// Releases the hold (`DELETE /booking-holds`).
  final String holdId;
  final String holdToken;
  final DateTime? holdExpiresAt;

  /// What the server quoted when holding. Null when it sent no quote.
  final double? serverTotal;

  /// Set once created. `-1` when the server confirmed but sent no id.
  final int? bookingId;
  final bool paymentRecorded;
  final double paidNow;

  final String? error;

  bool get isCreated => bookingId != null;

  /// The server's price differs from what the board showed.
  bool get priceChanged {
    final double? estimate = range.estimate;
    final double? server = serverTotal;
    if (estimate == null || server == null) return false;
    return (estimate - server).abs() >= 0.5;
  }

  /// The price to show and charge against: the server's when known.
  double? get effectiveTotal => serverTotal ?? range.estimate;

  OpsRangeTicket copyWith({
    int? bookingId,
    bool? paymentRecorded,
    double? paidNow,
    String? error,
    bool clearError = false,
  }) {
    return OpsRangeTicket(
      range: range,
      holdId: holdId,
      holdToken: holdToken,
      holdExpiresAt: holdExpiresAt,
      serverTotal: serverTotal,
      bookingId: bookingId ?? this.bookingId,
      paymentRecorded: paymentRecorded ?? this.paymentRecorded,
      paidNow: paidNow ?? this.paidNow,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    range,
    holdId,
    holdToken,
    holdExpiresAt,
    serverTotal,
    bookingId,
    paymentRecorded,
    paidNow,
    error,
  ];
}

class OpsPrepareOutcome extends Equatable {
  const OpsPrepareOutcome._({
    this.tickets = const <OpsRangeTicket>[],
    this.conflict,
    this.message,
    this.refused = false,
  });

  const OpsPrepareOutcome.held(List<OpsRangeTicket> tickets)
    : this._(tickets: tickets);

  /// Nothing held. [range] names the range that could not be — null when the
  /// server refused the whole list without saying which.
  const OpsPrepareOutcome.conflict({
    required OpsBookingRange? range,
    required String message,
  }) : this._(conflict: range, message: message, refused: true);

  final List<OpsRangeTicket> tickets;

  /// The range that could not be held, when known; every other hold was
  /// released.
  final OpsBookingRange? conflict;
  final String? message;
  final bool refused;

  bool get isConflict => refused;

  @override
  List<Object?> get props => <Object?>[tickets, conflict, message, refused];
}
