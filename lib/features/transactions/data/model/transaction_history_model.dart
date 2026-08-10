import 'package:equatable/equatable.dart';

/// Direction of money movement relative to the signed-in vendor.
///
/// The API calls these `incoming` / `outgoing`.
enum TransactionDirection { incoming, outgoing }

/// Values accepted by the `direction` query parameter.
enum TransactionDirectionFilter { all, incoming, outgoing }

extension TransactionDirectionFilterQuery on TransactionDirectionFilter {
  String get query => switch (this) {
    TransactionDirectionFilter.all => 'all',
    TransactionDirectionFilter.incoming => 'incoming',
    TransactionDirectionFilter.outgoing => 'outgoing',
  };
}

/// `source` values the endpoint is known to serve, used to seed the type chips
/// so the row is complete before every kind has appeared in a loaded page.
const List<String> kKnownTransactionSources = <String>[
  'booking',
  'expense',
  'settlement',
];

/// Preset windows for the `date_from` / `date_to` query parameters.
enum TransactionRangeFilter { all, today, week, month, year, custom }

/// A resolved `date_from` / `date_to` window.
///
/// Presets are resolved against a caller-supplied "now" so the arithmetic stays
/// pure and testable; `custom` carries the two dates the user picked. Both
/// bounds are inclusive whole days — the endpoint takes `Y-m-d`, not timestamps.
class TransactionDateRange extends Equatable {
  const TransactionDateRange({
    this.filter = TransactionRangeFilter.all,
    this.from,
    this.to,
  });

  final TransactionRangeFilter filter;
  final DateTime? from;
  final DateTime? to;

  static const TransactionDateRange allTime = TransactionDateRange();

  /// Resolves [filter] into concrete bounds.
  ///
  /// `week` runs from Monday of the current week, `month` from the 1st, and
  /// `year` from January 1st — each through [now]. A `custom` range keeps the
  /// dates as given, swapped into order when picked backwards.
  factory TransactionDateRange.of(
    TransactionRangeFilter filter, {
    DateTime? now,
    DateTime? from,
    DateTime? to,
  }) {
    final DateTime today = _dayOf(now ?? DateTime.now());

    switch (filter) {
      case TransactionRangeFilter.all:
        return TransactionDateRange.allTime;
      case TransactionRangeFilter.today:
        return TransactionDateRange(filter: filter, from: today, to: today);
      case TransactionRangeFilter.week:
        return TransactionDateRange(
          filter: filter,
          from: today.subtract(Duration(days: today.weekday - 1)),
          to: today,
        );
      case TransactionRangeFilter.month:
        return TransactionDateRange(
          filter: filter,
          from: DateTime(today.year, today.month),
          to: today,
        );
      case TransactionRangeFilter.year:
        return TransactionDateRange(
          filter: filter,
          from: DateTime(today.year),
          to: today,
        );
      case TransactionRangeFilter.custom:
        if (from == null && to == null) return TransactionDateRange.allTime;
        final DateTime? start = from == null ? null : _dayOf(from);
        final DateTime? end = to == null ? null : _dayOf(to);
        // Tolerate a backwards pick rather than sending an empty window.
        final bool swap = start != null && end != null && end.isBefore(start);
        return TransactionDateRange(
          filter: filter,
          from: swap ? end : start,
          to: swap ? start : end,
        );
    }
  }

  bool get isActive => filter != TransactionRangeFilter.all;

  /// `Y-m-d`, or null when that bound is open.
  String? get queryFrom => _format(from);

  String? get queryTo => _format(to);

  static DateTime _dayOf(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static String? _format(DateTime? value) {
    if (value == null) return null;
    final String month = value.month.toString().padLeft(2, '0');
    final String day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  @override
  List<Object?> get props => <Object?>[filter, from, to];
}

/// Parsing helpers shared by the transaction-history models.
///
/// Values are read tolerantly — amounts arrive as both numbers and strings, and
/// several fields are nullable per `source` — so a missing key degrades to null
/// instead of throwing mid-list.
class TxnParse {
  TxnParse._();

  /// First non-null value among [keys].
  static dynamic pick(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value != null) return value;
    }
    return null;
  }

  static Map<String, dynamic> mapOf(dynamic value) =>
      value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    final String text = value.toString().trim();
    return int.tryParse(text) ?? double.tryParse(text)?.round();
  }

  static double doubleOf(dynamic value, {double fallback = 0}) {
    if (value is num) return value.toDouble();
    final String text = value?.toString().trim().replaceAll(',', '') ?? '';
    return double.tryParse(text) ?? fallback;
  }

  static double? doubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim().replaceAll(',', ''));
  }

  static String stringOf(dynamic value) =>
      value == null ? '' : value.toString().trim();

  static String? stringOrNull(dynamic value) {
    final String text = stringOf(value);
    return text.isEmpty ? null : text;
  }

  /// Parses `2026-10-02`, `2026-07-16 19:24:06` and epoch seconds/millis.
  static DateTime? dateOrNull(dynamic value) {
    if (value is DateTime) return value;
    if (value is num) return _fromEpoch(value.round());
    final String text = stringOf(value);
    if (text.isEmpty) return null;
    final int? epoch = int.tryParse(text);
    if (epoch != null) return _fromEpoch(epoch);
    return DateTime.tryParse(text) ??
        DateTime.tryParse(text.replaceFirst(' ', 'T'));
  }

  static DateTime _fromEpoch(int value) => DateTime.fromMillisecondsSinceEpoch(
    value.abs() > 100000000000 ? value : value * 1000,
  );

  /// Reads a label out of either a bare string or a `{id, name}` object.
  static String? labelOf(dynamic value) {
    if (value is Map) {
      return stringOrNull(
        pick(Map<String, dynamic>.from(value), <String>[
          'name',
          'full_name',
          'title',
        ]),
      );
    }
    return stringOrNull(value);
  }

  /// Turns `pending_clearance` into `Pending Clearance`.
  static String humanize(String raw) {
    final String normalized = raw.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    if (normalized.isEmpty) return '';
    return normalized
        .split(RegExp(r'\s+'))
        .map(
          (String word) => word.length == 1
              ? word.toUpperCase()
              : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

/// One row of `data.items`.
///
/// Rows are heterogeneous: a `booking` carries commission and payment/booking
/// statuses, an `expense` carries a payment method and a note. Everything that
/// varies by `source` is nullable, and the UI renders only what is present.
class TransactionHistoryItemModel extends Equatable {
  const TransactionHistoryItemModel({
    this.id = '',
    this.source,
    this.direction = TransactionDirection.outgoing,
    this.title,
    this.reference,
    this.amount = 0,
    this.grossAmount,
    this.commissionAmount,
    this.status,
    this.paymentStatus,
    this.bookingStatus,
    this.paymentMethod,
    this.venueName,
    this.venueAddress,
    this.courtName,
    this.note,
    this.bookingId,
    this.expenseId,
    this.date,
  });

  /// Composite key such as `booking-26` — unique across sources, not numeric.
  final String id;

  /// `booking`, `expense`, `settlement`, … — the `type` filter's vocabulary.
  final String? source;

  final TransactionDirection direction;
  final String? title;
  final String? reference;

  /// Net amount credited/debited (`gross_amount` minus commission for bookings).
  final double amount;
  final double? grossAmount;
  final double? commissionAmount;

  /// Ledger status: `pending_clearance`, `cleared`, `recorded`, …
  final String? status;
  final String? paymentStatus;
  final String? bookingStatus;
  final String? paymentMethod;
  final String? venueName;
  final String? venueAddress;
  final String? courtName;
  final String? note;

  /// Set on `booking` rows — lets the tile deep-link to the booking.
  final int? bookingId;
  final int? expenseId;

  /// `transaction_date` when present, otherwise `created_at`.
  final DateTime? date;

  bool get isIncoming => direction == TransactionDirection.incoming;

  String get sourceLabel => TxnParse.humanize(source ?? '');

  String get statusLabel => TxnParse.humanize(status ?? '');

  String get paymentStatusLabel => TxnParse.humanize(paymentStatus ?? '');

  /// Commission is only worth showing when the server actually withheld some.
  bool get hasCommission => commissionAmount != null && commissionAmount! > 0;

  /// Primary line of the tile.
  String get displayTitle {
    for (final String? candidate in <String?>[
      title,
      sourceLabel.isEmpty ? null : sourceLabel,
      reference,
    ]) {
      if (candidate != null && candidate.isNotEmpty) return candidate;
    }
    return id;
  }

  /// Secondary line: reference, then where it happened.
  String get subtitle => <String>[
    if (reference != null && reference!.isNotEmpty) reference!,
    if (courtName != null && courtName!.isNotEmpty) courtName!,
    if (venueName != null && venueName!.isNotEmpty) venueName!,
  ].join(' · ');

  factory TransactionHistoryItemModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> meta = TxnParse.mapOf(json['meta']);
    final Map<String, dynamic> venue = TxnParse.mapOf(json['venue']);

    return TransactionHistoryItemModel(
      id: TxnParse.stringOf(TxnParse.pick(json, <String>['id', 'key'])),
      source: TxnParse.stringOrNull(
        TxnParse.pick(json, <String>['source', 'type', 'transaction_type']),
      ),
      direction: _directionOf(json),
      title: TxnParse.stringOrNull(
        TxnParse.pick(json, <String>['title', 'description', 'purpose']),
      ),
      reference: TxnParse.stringOrNull(
        TxnParse.pick(json, <String>['reference', 'ref', 'code']),
      ),
      // `amount` is the net figure; keep it positive and let `direction` sign it.
      amount: TxnParse.doubleOf(
        TxnParse.pick(json, <String>['amount', 'net_amount']),
      ).abs(),
      grossAmount: TxnParse.doubleOrNull(
        TxnParse.pick(json, <String>['gross_amount', 'total_amount']),
      ),
      commissionAmount: TxnParse.doubleOrNull(
        TxnParse.pick(json, <String>['commission_amount', 'commission']),
      ),
      status: TxnParse.stringOrNull(json['status']),
      paymentStatus: TxnParse.stringOrNull(json['payment_status']),
      bookingStatus: TxnParse.stringOrNull(json['booking_status']),
      paymentMethod: TxnParse.stringOrNull(
        TxnParse.pick(json, <String>['payment_method', 'method']),
      ),
      venueName: TxnParse.labelOf(
        venue.isNotEmpty ? venue : TxnParse.pick(json, <String>['venue_name']),
      ),
      venueAddress: TxnParse.stringOrNull(venue['address']),
      // Court and note live inside `meta`, and may be null there.
      courtName: TxnParse.stringOrNull(
        TxnParse.pick(meta, <String>['court_name', 'court']),
      ),
      note: TxnParse.stringOrNull(meta['note']),
      bookingId: TxnParse.intOrNull(meta['booking_id']),
      expenseId: TxnParse.intOrNull(meta['expense_id']),
      date:
          TxnParse.dateOrNull(json['transaction_date']) ??
          TxnParse.dateOrNull(json['created_at']) ??
          TxnParse.dateOrNull(json['sort_at']),
    );
  }

  /// `incoming` / `outgoing`, with `credit` / `debit` wording and a signed
  /// amount both accepted as fallbacks.
  static TransactionDirection _directionOf(Map<String, dynamic> json) {
    final String flag = TxnParse.stringOf(
      TxnParse.pick(json, <String>['direction', 'flow', 'entry_type']),
    ).toLowerCase();

    if (<String>[
      'incoming',
      'in',
      'inflow',
      'credit',
      'cr',
      'received',
      'income',
    ].contains(flag)) {
      return TransactionDirection.incoming;
    }
    if (<String>[
      'outgoing',
      'out',
      'outflow',
      'debit',
      'dr',
      'paid',
      'expense',
    ].contains(flag)) {
      return TransactionDirection.outgoing;
    }

    return TxnParse.doubleOf(json['amount']) < 0
        ? TransactionDirection.outgoing
        : TransactionDirection.incoming;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    source,
    direction,
    title,
    reference,
    amount,
    grossAmount,
    commissionAmount,
    status,
    paymentStatus,
    bookingStatus,
    paymentMethod,
    venueName,
    venueAddress,
    courtName,
    note,
    bookingId,
    expenseId,
    date,
  ];
}

/// `data.summary` — totals for the whole filtered set, not just the loaded
/// page, so the card stays correct while paginating.
class TransactionHistorySummaryModel extends Equatable {
  const TransactionHistorySummaryModel({
    this.incomingTotal,
    this.outgoingTotal,
    this.netTotal,
    this.transactionCount,
  });

  final double? incomingTotal;
  final double? outgoingTotal;
  final double? netTotal;
  final int? transactionCount;

  bool get isEmpty =>
      incomingTotal == null &&
      outgoingTotal == null &&
      netTotal == null &&
      transactionCount == null;

  factory TransactionHistorySummaryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistorySummaryModel(
      incomingTotal: TxnParse.doubleOrNull(
        TxnParse.pick(json, <String>[
          'incoming_total',
          'total_incoming',
          'total_credit',
        ]),
      ),
      outgoingTotal: TxnParse.doubleOrNull(
        TxnParse.pick(json, <String>[
          'outgoing_total',
          'total_outgoing',
          'total_debit',
        ]),
      ),
      netTotal: TxnParse.doubleOrNull(
        TxnParse.pick(json, <String>['net_total', 'net', 'net_amount']),
      ),
      transactionCount: TxnParse.intOrNull(
        TxnParse.pick(json, <String>[
          'transaction_count',
          'total_transactions',
          'count',
        ]),
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    incomingTotal,
    outgoingTotal,
    netTotal,
    transactionCount,
  ];
}

/// `data.pagination`.
class TransactionPaginationModel extends Equatable {
  const TransactionPaginationModel({
    this.currentPage = 1,
    this.lastPage,
    this.perPage = 20,
    this.total = 0,
    this.hasMorePages,
  });

  final int currentPage;
  final int? lastPage;
  final int perPage;
  final int total;

  /// The server's explicit signal; preferred over deriving from page numbers.
  final bool? hasMorePages;

  bool get hasMore {
    if (hasMorePages != null) return hasMorePages!;
    if (lastPage != null) return currentPage < lastPage!;
    if (total > 0) return currentPage * perPage < total;
    return false;
  }

  factory TransactionPaginationModel.fromJson(
    Map<String, dynamic> json, {
    required int itemCount,
  }) {
    return TransactionPaginationModel(
      currentPage:
          TxnParse.intOrNull(
            TxnParse.pick(json, <String>['current_page', 'page']),
          ) ??
          1,
      lastPage: TxnParse.intOrNull(
        TxnParse.pick(json, <String>['last_page', 'total_pages']),
      ),
      perPage:
          TxnParse.intOrNull(TxnParse.pick(json, <String>['per_page'])) ??
          (itemCount == 0 ? 20 : itemCount),
      total:
          TxnParse.intOrNull(TxnParse.pick(json, <String>['total'])) ??
          itemCount,
      hasMorePages: switch (TxnParse.pick(json, <String>[
        'has_more_pages',
        'has_more',
      ])) {
        final bool value => value,
        final String value => value == 'true' || value == '1',
        _ => null,
      },
    );
  }

  @override
  List<Object?> get props => <Object?>[
    currentPage,
    lastPage,
    perPage,
    total,
    hasMorePages,
  ];
}

/// One page of `GET /auth/transaction-history`.
class TransactionHistoryPageModel extends Equatable {
  const TransactionHistoryPageModel({
    this.items = const <TransactionHistoryItemModel>[],
    this.summary,
    this.pagination = const TransactionPaginationModel(),
  });

  final List<TransactionHistoryItemModel> items;
  final TransactionHistorySummaryModel? summary;
  final TransactionPaginationModel pagination;

  int get page => pagination.currentPage;

  int get total => pagination.total;

  bool get hasMore => pagination.hasMore;

  factory TransactionHistoryPageModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> root = TxnParse.mapOf(payload);
    final Map<String, dynamic> envelope = root['data'] is Map
        ? TxnParse.mapOf(root['data'])
        : root;

    final dynamic itemsRaw = TxnParse.pick(envelope, <String>[
      'items',
      'data',
      'transactions',
      'records',
    ]);
    final List<TransactionHistoryItemModel> items = itemsRaw is List
        ? itemsRaw
              .whereType<Map>()
              .map(
                (Map item) => TransactionHistoryItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
        : const <TransactionHistoryItemModel>[];

    final TransactionHistorySummaryModel summary =
        TransactionHistorySummaryModel.fromJson(
          TxnParse.mapOf(
            TxnParse.pick(envelope, <String>['summary', 'totals']),
          ),
        );

    return TransactionHistoryPageModel(
      items: items,
      summary: summary.isEmpty ? null : summary,
      pagination: TransactionPaginationModel.fromJson(
        TxnParse.mapOf(
          TxnParse.pick(envelope, <String>['pagination', 'meta']) ?? envelope,
        ),
        itemCount: items.length,
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[items, summary, pagination];
}
