import 'package:equatable/equatable.dart';

/// Parsing helpers shared by every reward model.
///
/// The reward endpoints wrap their payload in a `data` envelope, but which keys
/// carry the numbers varies (`points` / `points_balance` / `available_points`).
/// Every model reads through these tolerant helpers so a key rename on the
/// backend degrades to a zero instead of a thrown parse error.
class RewardParse {
  RewardParse._();

  /// Unwraps nested `data` envelopes until a map without one is reached.
  static Map<String, dynamic> unwrap(dynamic payload) {
    dynamic current = payload;
    for (int depth = 0; depth < 5; depth++) {
      if (current is! Map) return <String, dynamic>{};
      final Map<String, dynamic> map = Map<String, dynamic>.from(current);
      final dynamic nested = map['data'];
      // A `data` list means we already reached the paginated envelope.
      if (nested is! Map) return map;
      current = nested;
    }
    return <String, dynamic>{};
  }

  /// First non-null value among [keys], looked up in [map].
  static dynamic pick(Map<String, dynamic> map, List<String> keys) {
    for (final String key in keys) {
      final dynamic value = map[key];
      if (value != null) return value;
    }
    return null;
  }

  static int intOf(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString().trim() ?? '') ??
        double.tryParse(value?.toString().trim() ?? '')?.round() ??
        fallback;
  }

  static int? intOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    final String text = value.toString().trim();
    return int.tryParse(text) ?? double.tryParse(text)?.round();
  }

  static double doubleOf(dynamic value, {double fallback = 0}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString().trim() ?? '') ?? fallback;
  }

  static double? doubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  static String stringOf(dynamic value) => value?.toString().trim() ?? '';

  static DateTime? dateOf(dynamic value) {
    if (value is DateTime) return value;
    final String text = stringOf(value);
    if (text.isEmpty) return null;
    return DateTime.tryParse(text)?.toLocal();
  }

  static bool? boolOrNull(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final String text = value.toString().trim().toLowerCase();
    if (const <String>{'true', '1', 'yes'}.contains(text)) return true;
    if (const <String>{'false', '0', 'no'}.contains(text)) return false;
    return null;
  }
}

/// The reward wallet, from `GET /customer/rewards`.
class RewardsSummaryModel extends Equatable {
  const RewardsSummaryModel({
    this.availablePoints = 0,
    this.totalEarnedPoints = 0,
    this.totalRedeemedPoints = 0,
    this.pointsPerCoupon = 0,
    this.couponValue = 0,
    this.tier = '',
    this.currency = 'NPR',
    this.expiringPoints = 0,
    this.expiresAt,
    this.canGenerateCoupon,
    this.note = '',
  });

  /// Points the customer can spend right now.
  final int availablePoints;
  final int totalEarnedPoints;
  final int totalRedeemedPoints;

  /// Points consumed by one generated coupon. `0` when the server does not
  /// publish a threshold, in which case redemption is offered unconditionally
  /// and the server decides.
  final int pointsPerCoupon;

  /// Money value of one generated coupon, in [currency].
  final double couponValue;

  final String tier;
  final String currency;

  /// Points that lapse on [expiresAt]; both are optional.
  final int expiringPoints;
  final DateTime? expiresAt;

  /// Server-side eligibility flag when present; [canRedeem] falls back to
  /// comparing [availablePoints] against [pointsPerCoupon].
  final bool? canGenerateCoupon;

  /// Free-text programme note shown under the balance.
  final String note;

  static const RewardsSummaryModel empty = RewardsSummaryModel();

  /// Whether a coupon can be generated from the current balance.
  bool get canRedeem =>
      canGenerateCoupon ??
      (pointsPerCoupon > 0
          ? availablePoints >= pointsPerCoupon
          : availablePoints > 0);

  /// Points still needed for the next coupon; `0` once redeemable.
  int get pointsToNextCoupon {
    if (pointsPerCoupon <= 0) return 0;
    final int remaining = pointsPerCoupon - (availablePoints % pointsPerCoupon);
    if (availablePoints >= pointsPerCoupon) return 0;
    return remaining.clamp(0, pointsPerCoupon);
  }

  /// Progress towards the next coupon, in `0..1`. Full bar when no threshold is
  /// published but points exist, so the meter never looks broken.
  double get progressToNextCoupon {
    if (pointsPerCoupon <= 0) return availablePoints > 0 ? 1 : 0;
    if (availablePoints >= pointsPerCoupon) return 1;
    return (availablePoints / pointsPerCoupon).clamp(0, 1).toDouble();
  }

  /// How many coupons the balance covers right now.
  int get redeemableCoupons =>
      pointsPerCoupon <= 0 ? 0 : availablePoints ~/ pointsPerCoupon;

  bool get hasPoints => availablePoints > 0;

  factory RewardsSummaryModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> root = RewardParse.unwrap(payload);

    // Some deployments nest the wallet one level deeper.
    final dynamic walletRaw = RewardParse.pick(root, <String>[
      'reward',
      'rewards',
      'wallet',
      'summary',
    ]);
    final Map<String, dynamic> map = walletRaw is Map
        ? <String, dynamic>{...root, ...Map<String, dynamic>.from(walletRaw)}
        : root;

    final int perCoupon = RewardParse.intOf(
      RewardParse.pick(map, <String>[
        'points_per_coupon',
        'points_required',
        'required_points',
        'min_points',
        'minimum_points',
        'redeem_threshold',
        'threshold',
      ]),
    );

    return RewardsSummaryModel(
      availablePoints: RewardParse.intOf(
        RewardParse.pick(map, <String>[
          'available_points',
          'points_balance',
          'balance',
          'points',
          'total_points',
        ]),
      ),
      totalEarnedPoints: RewardParse.intOf(
        RewardParse.pick(map, <String>[
          'total_earned_points',
          'total_earned',
          'earned_points',
          'lifetime_points',
        ]),
      ),
      totalRedeemedPoints: RewardParse.intOf(
        RewardParse.pick(map, <String>[
          'total_redeemed_points',
          'total_redeemed',
          'redeemed_points',
          'used_points',
        ]),
      ),
      pointsPerCoupon: perCoupon,
      couponValue: RewardParse.doubleOf(
        RewardParse.pick(map, <String>[
          'coupon_value',
          'coupon_amount',
          'discount_amount',
          'reward_value',
          'value',
        ]),
      ),
      tier: RewardParse.stringOf(
        RewardParse.pick(map, <String>['tier', 'level', 'tier_name']),
      ),
      currency: () {
        final String currency = RewardParse.stringOf(
          RewardParse.pick(map, <String>['currency', 'currency_code']),
        );
        return currency.isEmpty ? 'NPR' : currency;
      }(),
      expiringPoints: RewardParse.intOf(
        RewardParse.pick(map, <String>['expiring_points', 'points_expiring']),
      ),
      expiresAt: RewardParse.dateOf(
        RewardParse.pick(map, <String>[
          'expires_at',
          'expiry_date',
          'points_expire_at',
        ]),
      ),
      canGenerateCoupon: RewardParse.boolOrNull(
        RewardParse.pick(map, <String>[
          'can_generate_coupon',
          'can_redeem',
          'is_eligible',
          'eligible',
        ]),
      ),
      note: RewardParse.stringOf(
        RewardParse.pick(map, <String>['note', 'description', 'message']),
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    availablePoints,
    totalEarnedPoints,
    totalRedeemedPoints,
    pointsPerCoupon,
    couponValue,
    tier,
    currency,
    expiringPoints,
    expiresAt,
    canGenerateCoupon,
    note,
  ];
}

/// What a history entry did to the balance.
enum RewardEntryType { earned, redeemed, expired, adjusted }

/// One row of `GET /customer/rewards/history`.
class RewardHistoryEntryModel extends Equatable {
  const RewardHistoryEntryModel({
    required this.id,
    required this.type,
    required this.points,
    this.title = '',
    this.description = '',
    this.couponCode = '',
    this.reference = '',
    this.balanceAfter,
    this.createdAt,
  });

  final String id;
  final RewardEntryType type;

  /// Always positive; [type] carries the direction.
  final int points;

  final String title;
  final String description;

  /// Set on redemption rows that produced a coupon.
  final String couponCode;

  /// Booking/order reference the points came from, when the server sends one.
  final String reference;

  final int? balanceAfter;
  final DateTime? createdAt;

  bool get isCredit => type == RewardEntryType.earned;

  /// `+120` / `-500`, ready to render.
  String get signedPoints => '${isCredit ? '+' : '-'}$points';

  factory RewardHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final int rawPoints = RewardParse.intOf(
      RewardParse.pick(json, <String>[
        'points',
        'point',
        'amount',
        'value',
        'points_change',
      ]),
    );

    final RewardEntryType type = _resolveType(json, rawPoints);

    return RewardHistoryEntryModel(
      id: RewardParse.stringOf(
        RewardParse.pick(json, <String>['id', 'uuid', 'reference_id']),
      ),
      type: type,
      points: rawPoints.abs(),
      title: RewardParse.stringOf(
        RewardParse.pick(json, <String>['title', 'label', 'source', 'reason']),
      ),
      description: RewardParse.stringOf(
        RewardParse.pick(json, <String>['description', 'note', 'remarks']),
      ),
      couponCode: RewardParse.stringOf(
        RewardParse.pick(json, <String>['coupon_code', 'code', 'coupon']),
      ),
      reference: RewardParse.stringOf(
        RewardParse.pick(json, <String>[
          'reference',
          'booking_code',
          'booking_id',
          'order_id',
        ]),
      ),
      balanceAfter: RewardParse.intOrNull(
        RewardParse.pick(json, <String>[
          'balance_after',
          'running_balance',
          'balance',
        ]),
      ),
      createdAt: RewardParse.dateOf(
        RewardParse.pick(json, <String>['created_at', 'date', 'earned_at']),
      ),
    );
  }

  /// Reads the explicit type when the server sends one, otherwise infers the
  /// direction from the sign of the points change.
  static RewardEntryType _resolveType(Map<String, dynamic> json, int points) {
    final String raw = RewardParse.stringOf(
      RewardParse.pick(json, <String>[
        'type',
        'transaction_type',
        'entry_type',
        'action',
      ]),
    ).toLowerCase();

    if (raw.contains('expire')) return RewardEntryType.expired;
    if (raw.contains('redeem') ||
        raw.contains('debit') ||
        raw.contains('spend') ||
        raw.contains('coupon')) {
      return RewardEntryType.redeemed;
    }
    if (raw.contains('earn') || raw.contains('credit')) {
      return RewardEntryType.earned;
    }
    if (raw.contains('adjust')) return RewardEntryType.adjusted;

    return points < 0 ? RewardEntryType.redeemed : RewardEntryType.earned;
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    type,
    points,
    title,
    description,
    couponCode,
    reference,
    balanceAfter,
    createdAt,
  ];
}

/// One page of reward history, plus the pagination cursor.
class RewardHistoryPageModel extends Equatable {
  const RewardHistoryPageModel({
    this.entries = const <RewardHistoryEntryModel>[],
    this.page = 1,
    this.perPage = 20,
    this.total = 0,
    this.lastPage,
  });

  final List<RewardHistoryEntryModel> entries;
  final int page;
  final int perPage;
  final int total;
  final int? lastPage;

  /// Whether another page exists. Falls back to comparing the accumulated count
  /// with [total] when the server omits `last_page`.
  bool get hasMore {
    if (lastPage != null) return page < lastPage!;
    if (total > 0) return page * perPage < total;
    return entries.length >= perPage;
  }

  factory RewardHistoryPageModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};

    // Laravel paginators appear either at the root or under `data`.
    final Map<String, dynamic> envelope = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;

    final dynamic itemsRaw =
        RewardParse.pick(envelope, <String>[
          'data',
          'items',
          'history',
          'records',
          'transactions',
        ]) ??
        (root['data'] is List ? root['data'] : null);

    final List<RewardHistoryEntryModel> entries = (itemsRaw is List)
        ? itemsRaw
              .whereType<Map>()
              .map(
                (Map item) => RewardHistoryEntryModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList(growable: false)
        : const <RewardHistoryEntryModel>[];

    final Map<String, dynamic> meta = root['meta'] is Map
        ? Map<String, dynamic>.from(root['meta'] as Map)
        : envelope['meta'] is Map
        ? Map<String, dynamic>.from(envelope['meta'] as Map)
        : root['pagination'] is Map
        ? Map<String, dynamic>.from(root['pagination'] as Map)
        : envelope;

    return RewardHistoryPageModel(
      entries: entries,
      page:
          RewardParse.intOrNull(
            RewardParse.pick(meta, <String>['current_page', 'page']),
          ) ??
          1,
      perPage:
          RewardParse.intOrNull(
            RewardParse.pick(meta, <String>['per_page', 'perPage']),
          ) ??
          (entries.isEmpty ? 20 : entries.length),
      total:
          RewardParse.intOrNull(
            RewardParse.pick(meta, <String>['total', 'total_count']),
          ) ??
          entries.length,
      lastPage: RewardParse.intOrNull(
        RewardParse.pick(meta, <String>[
          'last_page',
          'lastPage',
          'total_pages',
        ]),
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[entries, page, perPage, total, lastPage];
}

/// The coupon produced by `POST /customer/rewards/generate-coupon`.
class GeneratedRewardCouponModel extends Equatable {
  const GeneratedRewardCouponModel({
    this.code = '',
    this.discountAmount,
    this.discountPercent,
    this.pointsUsed = 0,
    this.remainingPoints,
    this.currency = 'NPR',
    this.expiresAt,
    this.message = '',
  });

  final String code;

  /// Flat money discount, or [discountPercent] for percentage coupons. Both may
  /// be null when the server only returns the code.
  final double? discountAmount;
  final double? discountPercent;

  final int pointsUsed;

  /// Balance left after redemption, when reported.
  final int? remainingPoints;

  final String currency;
  final DateTime? expiresAt;
  final String message;

  bool get hasCode => code.isNotEmpty;

  factory GeneratedRewardCouponModel.fromResponse(dynamic payload) {
    // `message` usually sits on the outermost envelope, which unwrap() discards.
    final Map<String, dynamic> envelope = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final Map<String, dynamic> root = RewardParse.unwrap(payload);
    final dynamic couponRaw = RewardParse.pick(root, <String>[
      'coupon',
      'reward_coupon',
      'generated_coupon',
    ]);
    final Map<String, dynamic> map = couponRaw is Map
        ? <String, dynamic>{...root, ...Map<String, dynamic>.from(couponRaw)}
        : root;

    return GeneratedRewardCouponModel(
      code: RewardParse.stringOf(
        RewardParse.pick(map, <String>['code', 'coupon_code', 'voucher_code']),
      ),
      discountAmount: RewardParse.doubleOrNull(
        RewardParse.pick(map, <String>[
          'discount_amount',
          'amount',
          'value',
          'coupon_value',
        ]),
      ),
      discountPercent: RewardParse.doubleOrNull(
        RewardParse.pick(map, <String>[
          'discount_percent',
          'percentage',
          'discount_percentage',
        ]),
      ),
      pointsUsed: RewardParse.intOf(
        RewardParse.pick(map, <String>[
          'points_used',
          'points_redeemed',
          'points',
        ]),
      ),
      remainingPoints: RewardParse.intOrNull(
        RewardParse.pick(map, <String>[
          'remaining_points',
          'available_points',
          'points_balance',
          'balance',
        ]),
      ),
      currency: () {
        final String currency = RewardParse.stringOf(
          RewardParse.pick(map, <String>['currency', 'currency_code']),
        );
        return currency.isEmpty ? 'NPR' : currency;
      }(),
      expiresAt: RewardParse.dateOf(
        RewardParse.pick(map, <String>[
          'expires_at',
          'expiry_date',
          'valid_till',
          'valid_until',
        ]),
      ),
      message: RewardParse.stringOf(
        RewardParse.pick(root, <String>['message', 'status_message']) ??
            RewardParse.pick(envelope, <String>['message', 'status_message']),
      ),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    code,
    discountAmount,
    discountPercent,
    pointsUsed,
    remainingPoints,
    currency,
    expiresAt,
    message,
  ];
}
