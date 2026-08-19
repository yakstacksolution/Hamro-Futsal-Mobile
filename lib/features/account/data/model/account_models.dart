/// Models for the vendor ↔ Hamro Futsal (super admin) financial account:
/// the running balance the platform owes the vendor, the commission it
/// retains, ledger entries, and settlement (payout) requests.
library;

import 'package:hamro_footsall/features/futsal_details/data/model/payment_qr_model.dart';

int _asInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v?.toString() ?? '') ??
      double.tryParse(v?.toString() ?? '')?.round() ??
      0;
}

double _asDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0;
}

DateTime? _asDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

String _asString(dynamic v) => (v ?? '').toString().trim();

/// One entry of `data.sections` — the server tells the UI which sub-sections
/// exist and how many rows each holds, so shortcut tiles never guess.
class AccountSectionModel {
  const AccountSectionModel({
    required this.key,
    required this.label,
    this.count = 0,
  });

  final String key;
  final String label;
  final int count;

  factory AccountSectionModel.fromJson(Map<String, dynamic> json) =>
      AccountSectionModel(
        key: _asString(json['key']),
        label: _asString(json['label']),
        count: _asInt(json['count']),
      );
}

/// Headline numbers of the vendor's platform account.
class AccountSummaryModel {
  const AccountSummaryModel({
    this.currency = 'NPR',
    this.availableBalance = 0,
    this.pendingClearance = 0,
    this.reservedBalance = 0,
    this.totalEarned = 0,
    this.totalCommission = 0,
    this.totalRefunded = 0,
    this.totalSettled = 0,
    this.commissionRate = 0,
    this.minSettlementAmount = 0,
    this.maxSettlementAmount,
    this.requestableAmount = 0,
    this.settlementEligible = false,
    this.settlementBlockingReason = '',
    this.processingEstimate = '',
    this.venues = const <VenueAccountModel>[],
    this.sections = const <AccountSectionModel>[],
    this.recentActivity = const <AccountEntryModel>[],
    this.settlementQr,
    this.updatedAt,
  });

  final String currency;

  /// Cleared earnings the vendor can request a settlement for. Money is
  /// carried as `double` throughout — the server reports paisa (e.g.
  /// 11711.99) and `exact_amount_required` means a rounded figure would be
  /// rejected.
  final double availableBalance;

  /// Verified-but-not-yet-cleared income (e.g. advances under review).
  final double pendingClearance;
  final double reservedBalance;

  final double totalEarned;
  final double totalCommission;
  final double totalRefunded;
  final double totalSettled;

  /// Platform commission in percent (e.g. 10 = 10%).
  final double commissionRate;

  /// Server-enforced floor for a settlement request; 0 = no floor.
  final double minSettlementAmount;
  final double? maxSettlementAmount;

  /// `actions.requestable_amount` — what the server will accept right now.
  final double requestableAmount;
  final bool settlementEligible;
  final String settlementBlockingReason;
  final String processingEstimate;
  final List<VenueAccountModel> venues;

  /// `data.sections` — which sub-sections the server exposes, with counts.
  final List<AccountSectionModel> sections;

  /// Row count the server reports for one section key, or null when it does
  /// not mention that section at all.
  int? sectionCount(String key) {
    for (final section in sections) {
      if (section.key == key) return section.count;
    }
    return null;
  }

  /// Ledger entries shipped inline with the settlement account.
  final List<AccountEntryModel> recentActivity;
  final PaymentQrModel? settlementQr;

  final DateTime? updatedAt;

  static const AccountSummaryModel empty = AccountSummaryModel();

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    // Lifetime totals and the settlement CTA arrive in nested objects.
    final cards = json['cards'] is Map
        ? Map<String, dynamic>.from(json['cards'] as Map)
        : const <String, dynamic>{};
    final actions = json['actions'] is Map
        ? Map<String, dynamic>.from(json['actions'] as Map)
        : const <String, dynamic>{};
    return AccountSummaryModel(
      currency: _asString(json['currency']).isEmpty
          ? 'NPR'
          : _asString(json['currency']),
      availableBalance: _asDouble(
        json['available_balance'] ??
            json['balance'] ??
            json['availableBalance'],
      ),
      pendingClearance: _asDouble(
        json['pending_clearance'] ??
            json['pending_balance'] ??
            json['pendingClearance'],
      ),
      reservedBalance: _asDouble(
        json['reserved_balance'] ?? json['settlement_reserved'],
      ),
      totalEarned: _asDouble(
        json['total_earned'] ??
            json['lifetime_earned'] ??
            cards['total_earned'],
      ),
      totalCommission: _asDouble(
        json['total_commission'] ??
            json['commission_paid'] ??
            cards['commission'],
      ),
      totalRefunded: _asDouble(json['total_refunded'] ?? json['refunds_total']),
      totalSettled: _asDouble(
        json['total_settled'] ?? json['paid_out'] ?? cards['settled'],
      ),
      commissionRate: _asDouble(
        json['commission_rate'] ??
            json['commission_pct'] ??
            json['commissionRate'],
      ),
      minSettlementAmount: _asDouble(
        json['min_settlement_amount'] ?? json['minSettlementAmount'],
      ),
      maxSettlementAmount: json['max_settlement_amount'] == null
          ? null
          : _asDouble(json['max_settlement_amount']),
      requestableAmount: _asDouble(
        actions['requestable_amount'] ?? json['requestable_amount'],
      ),
      settlementEligible:
          json['settlement_eligible'] == true ||
          json['can_request_settlement'] == true ||
          actions['can_request_settlement'] == true,
      settlementBlockingReason: _asString(
        json['settlement_blocking_reason'] ?? json['blocking_reason'],
      ),
      processingEstimate: _asString(
        json['processing_estimate'] ?? json['settlement_processing_estimate'],
      ),
      venues: _mapList(
        json['venues'] ?? json['futsals'] ?? json['venue_accounts'],
      ).map(VenueAccountModel.fromJson).toList(growable: false),
      sections: _mapList(
        json['sections'],
      ).map(AccountSectionModel.fromJson).toList(growable: false),
      recentActivity: _mapList(
        json['recent_activity'] ?? json['recent_entries'],
      ).map(AccountEntryModel.fromJson).toList(growable: false),
      settlementQr: _paymentQr(json['settlement_qr'] ?? json['payment_qr']),
      updatedAt: _asDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  AccountSummaryModel copyWith({List<VenueAccountModel>? venues}) {
    return AccountSummaryModel(
      currency: currency,
      availableBalance: availableBalance,
      pendingClearance: pendingClearance,
      reservedBalance: reservedBalance,
      totalEarned: totalEarned,
      totalCommission: totalCommission,
      totalRefunded: totalRefunded,
      totalSettled: totalSettled,
      commissionRate: commissionRate,
      minSettlementAmount: minSettlementAmount,
      maxSettlementAmount: maxSettlementAmount,
      requestableAmount: requestableAmount,
      settlementEligible: settlementEligible,
      settlementBlockingReason: settlementBlockingReason,
      processingEstimate: processingEstimate,
      venues: venues ?? this.venues,
      sections: sections,
      recentActivity: recentActivity,
      settlementQr: settlementQr,
      updatedAt: updatedAt,
    );
  }
}

class VenueAccountModel {
  const VenueAccountModel({
    required this.id,
    required this.name,
    this.location = '',
    this.availableBalance = 0,
    this.pendingClearance = 0,
    this.totalEarned = 0,
    this.totalCommission = 0,
    this.settlementEligible = true,
  });

  final int id;
  final String name;
  final String location;
  final double availableBalance;
  final double pendingClearance;
  final double totalEarned;
  final double totalCommission;

  /// `can_request_settlement` for this futsal alone.
  final bool settlementEligible;

  factory VenueAccountModel.fromJson(Map<String, dynamic> json) {
    return VenueAccountModel(
      id: _asInt(json['id'] ?? json['venue_id'] ?? json['futsal_id']),
      name: _asString(
        json['name'] ?? json['venue_name'] ?? json['futsal_name'],
      ),
      location: _asString(json['location'] ?? json['address']),
      availableBalance: _asDouble(
        json['available_balance'] ?? json['balance'] ?? json['amount_due'],
      ),
      pendingClearance: _asDouble(
        json['pending_clearance'] ?? json['pending_balance'],
      ),
      totalEarned: _asDouble(json['total_earned'] ?? json['gross_earnings']),
      totalCommission: _asDouble(
        json['total_commission'] ?? json['commission_due'],
      ),
      settlementEligible:
          json['settlement_eligible'] != false &&
          json['can_request_settlement'] != false,
    );
  }
}

List<Map<String, dynamic>> _mapList(dynamic value) => value is List
    ? value.whereType<Map>().map(Map<String, dynamic>.from).toList()
    : const <Map<String, dynamic>>[];

PaymentQrModel? _paymentQr(dynamic value) {
  if (value == null) return null;
  final qr = PaymentQrModel.fromResponse(value);
  final hasDetails =
      qr.hasQr ||
      (qr.payeeName?.isNotEmpty ?? false) ||
      (qr.accountId?.isNotEmpty ?? false);
  return hasDetails ? qr : null;
}

/// `/auth/settlement-breakdown`: per-futsal balances plus the ledger entries
/// the totals are built from.
class SettlementBreakdownModel {
  const SettlementBreakdownModel({
    this.venues = const <VenueAccountModel>[],
    this.entries = const <AccountEntryModel>[],
    this.count = 0,
  });

  final List<VenueAccountModel> venues;
  final List<AccountEntryModel> entries;

  /// `data.count` — how many futsals the server counted.
  final int count;

  static const SettlementBreakdownModel empty = SettlementBreakdownModel();

  factory SettlementBreakdownModel.fromResponse(dynamic payload) {
    final root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    // The server sends the per-venue list under `data.items`.
    final venuesRaw = _mapList(
      data['items'] ??
          data['venues'] ??
          data['futsals'] ??
          data['venue_breakdown'] ??
          data['breakdown'] ??
          (root['data'] is List ? root['data'] : null),
    );
    final entriesRaw = _mapList(
      data['entries'] ?? data['statement'] ?? data['transactions'],
    );
    final venues = venuesRaw
        .map(VenueAccountModel.fromJson)
        .toList(growable: false);
    return SettlementBreakdownModel(
      venues: venues,
      entries: entriesRaw
          .map(AccountEntryModel.fromJson)
          .toList(growable: false),
      count: data['count'] == null ? venues.length : _asInt(data['count']),
    );
  }
}

/// Who the vendor pays when settling — `data.recipient`.
class SettlementRecipientModel {
  const SettlementRecipientModel({
    this.name = '',
    this.phone = '',
    this.logoUrl = '',
  });

  final String name;
  final String phone;
  final String logoUrl;

  bool get isEmpty => name.isEmpty && phone.isEmpty && logoUrl.isEmpty;

  factory SettlementRecipientModel.fromJson(Map<String, dynamic> json) =>
      SettlementRecipientModel(
        name: _asString(json['name']),
        phone: _asString(json['phone']),
        logoUrl: _asString(json['logo_url'] ?? json['logo']),
      );
}

/// `/auth/settlement-preview[?venue_id=]`: everything the request form needs,
/// as the server scopes it — the copy to show, who to pay, how much is
/// payable, and what a proof file may be.
///
/// `scope` is `consolidated` (all futsals) or `venue` (one futsal, with
/// [venue] populated).
class SettlementPreviewModel {
  const SettlementPreviewModel({
    this.scope = 'consolidated',
    this.title = '',
    this.subtitle = '',
    this.recipient = const SettlementRecipientModel(),
    this.venue,
    this.maximumPayable = 0,
    this.defaultAmount = 0,
    this.pendingClearance = 0,
    this.exactAmountRequired = false,
    this.acceptedProofTypes = const <String>['jpg', 'jpeg', 'png', 'pdf'],
    this.proofMaxSizeMb = 10,
    this.blockingReason = '',
  });

  final String scope;

  /// Page title the server dictates, e.g. "Request Consolidated Settlement".
  final String title;

  /// Scope line under it, e.g. "All futsals" or the futsal's name.
  final String subtitle;
  final SettlementRecipientModel recipient;

  /// Present only on a venue-scoped preview.
  final SettlementPreviewVenue? venue;

  /// Ceiling the server will accept.
  final double maximumPayable;

  /// What the amount field starts on.
  final double defaultAmount;
  final double pendingClearance;

  /// When true the amount must equal [defaultAmount] exactly — a partial
  /// settlement is rejected, so the field is locked rather than validated.
  final bool exactAmountRequired;

  /// File extensions the proof upload accepts.
  final List<String> acceptedProofTypes;
  final int proofMaxSizeMb;
  final String blockingReason;

  bool get isVenueScoped => venue != null || scope == 'venue';

  /// Nothing to settle means nothing to request.
  bool get eligible => maximumPayable > 0;

  int get proofMaxBytes => proofMaxSizeMb * 1024 * 1024;

  factory SettlementPreviewModel.fromResponse(dynamic payload) {
    final root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    final maximumPayable = _asDouble(
      data['maximum_payable'] ??
          data['payable_amount'] ??
          data['available_balance'],
    );
    final proofTypes = data['accepted_proof_types'] is List
        ? (data['accepted_proof_types'] as List)
              .map(_asString)
              .where((e) => e.isNotEmpty)
              .map((e) => e.toLowerCase())
              .toList(growable: false)
        : const <String>[];
    return SettlementPreviewModel(
      scope: _asString(data['scope']).isEmpty
          ? 'consolidated'
          : _asString(data['scope']),
      title: _asString(data['title']),
      subtitle: _asString(data['subtitle']),
      recipient: data['recipient'] is Map
          ? SettlementRecipientModel.fromJson(
              Map<String, dynamic>.from(data['recipient'] as Map),
            )
          : const SettlementRecipientModel(),
      venue: data['venue'] is Map
          ? SettlementPreviewVenue.fromJson(
              Map<String, dynamic>.from(data['venue'] as Map),
            )
          : null,
      maximumPayable: maximumPayable,
      // Without an explicit default the whole payable amount is offered.
      defaultAmount: data['default_amount'] == null
          ? maximumPayable
          : _asDouble(data['default_amount']),
      pendingClearance: _asDouble(data['pending_clearance']),
      exactAmountRequired: data['exact_amount_required'] == true,
      acceptedProofTypes: proofTypes.isEmpty
          ? const <String>['jpg', 'jpeg', 'png', 'pdf']
          : proofTypes,
      proofMaxSizeMb: data['proof_max_size_mb'] == null
          ? 10
          : _asInt(data['proof_max_size_mb']),
      blockingReason: _asString(
        data['blocking_reason'] ?? data['settlement_blocking_reason'],
      ),
    );
  }
}

/// The futsal a venue-scoped preview belongs to (`data.venue`).
class SettlementPreviewVenue {
  const SettlementPreviewVenue({
    required this.id,
    this.name = '',
    this.address = '',
  });

  final int id;
  final String name;
  final String address;

  factory SettlementPreviewVenue.fromJson(Map<String, dynamic> json) =>
      SettlementPreviewVenue(
        id: _asInt(json['id'] ?? json['venue_id']),
        name: _asString(json['name'] ?? json['venue_name']),
        address: _asString(json['address']),
      );
}

/// What a ledger entry did to the vendor's balance.
enum AccountEntryType {
  bookingIncome,
  opponentMatchIncome,
  commission,
  settlement,
  refund,
  adjustment;

  bool get isCredit => switch (this) {
    bookingIncome || opponentMatchIncome => true,
    commission || settlement || refund => false,
    // Admin adjustments carry their own sign on the amount.
    adjustment => true,
  };

  static AccountEntryType parse(String raw) {
    final v = raw.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    if (v.contains('opponent') || v.contains('match')) {
      return AccountEntryType.opponentMatchIncome;
    }
    if (v.contains('booking') ||
        v.contains('income') ||
        v.contains('earning')) {
      return AccountEntryType.bookingIncome;
    }
    if (v.contains('commission') || v.contains('fee')) {
      return AccountEntryType.commission;
    }
    if (v.contains('settle') ||
        v.contains('payout') ||
        v.contains('withdraw')) {
      return AccountEntryType.settlement;
    }
    if (v.contains('refund')) return AccountEntryType.refund;
    return AccountEntryType.adjustment;
  }
}

/// One movement on the vendor's platform account.
class AccountEntryModel {
  const AccountEntryModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    this.isCredit = true,
    this.note = '',
    this.reference = '',
    this.venueName = '',
    this.date,
  });

  final String id;
  final AccountEntryType type;
  final String title;

  /// Always positive; [isCredit] carries the direction.
  final double amount;
  final bool isCredit;
  final String note;

  /// Futsal the movement belongs to (`venue_name`), when the server says.
  final String venueName;

  /// Booking / settlement code the entry belongs to, when the server sends
  /// one (e.g. "BK-1042").
  final String reference;
  final DateTime? date;

  factory AccountEntryModel.fromJson(Map<String, dynamic> json) {
    final type = AccountEntryType.parse(
      _asString(json['type'] ?? json['entry_type'] ?? json['category']),
    );
    final double rawAmount = _asDouble(json['amount']);
    final dynamic direction = json['direction'] ?? json['is_credit'];
    final bool isCredit = direction != null
        ? direction == true || _asString(direction).toLowerCase() == 'credit'
        : (rawAmount != 0
              ? !rawAmount.isNegative && type.isCredit
              : type.isCredit);
    return AccountEntryModel(
      id: _asString(json['id'] ?? json['entry_id']),
      type: type,
      title: _asString(json['title'] ?? json['description'] ?? json['label']),
      amount: rawAmount.abs(),
      isCredit: isCredit,
      note: _asString(json['note'] ?? json['remarks']),
      reference: _asString(json['reference'] ?? json['ref'] ?? json['code']),
      venueName: _asString(json['venue_name'] ?? json['futsal_name']),
      date: _asDate(json['date'] ?? json['created_at'] ?? json['createdAt']),
    );
  }
}

enum SettlementStatus {
  pending,
  processing,
  approved,
  paid,
  rejected,
  cancelled,
  failed;

  static SettlementStatus parse(String raw) {
    final v = raw.toLowerCase();
    if (v.contains('paid') || v.contains('complete') || v.contains('settle')) {
      return SettlementStatus.paid;
    }
    if (v.contains('approve') || v.contains('process')) {
      return v.contains('process')
          ? SettlementStatus.processing
          : SettlementStatus.approved;
    }
    if (v.contains('cancel')) return SettlementStatus.cancelled;
    if (v.contains('fail')) return SettlementStatus.failed;
    if (v.contains('reject') || v.contains('decline')) {
      return SettlementStatus.rejected;
    }
    return SettlementStatus.pending;
  }
}

/// A payout request from the vendor to the Hamro Futsal super admin.
class SettlementModel {
  const SettlementModel({
    required this.id,
    required this.amount,
    required this.status,
    this.note = '',
    this.rejectedReason = '',
    this.reference = '',
    this.transactionReference = '',
    this.venueId,
    this.venueName = '',
    this.requestedAt,
    this.resolvedAt,
  });

  final String id;
  final double amount;
  final SettlementStatus status;
  final String note;
  final String rejectedReason;
  final String reference;

  /// The vendor's own payment reference sent with the request.
  final String transactionReference;

  /// Set on a venue-scoped settlement; null on a consolidated one.
  final int? venueId;
  final String venueName;
  final DateTime? requestedAt;
  final DateTime? resolvedAt;

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: _asString(json['id'] ?? json['settlement_id']),
      amount: _asDouble(json['amount']).abs(),
      status: SettlementStatus.parse(_asString(json['status'])),
      note: _asString(json['note'] ?? json['remarks']),
      rejectedReason: _asString(
        json['rejected_reason'] ?? json['rejection_reason'] ?? json['reason'],
      ),
      reference: _asString(json['reference'] ?? json['ref'] ?? json['code']),
      transactionReference: _asString(
        json['transaction_reference'] ?? json['txn_reference'],
      ),
      venueId: json['venue_id'] == null ? null : _asInt(json['venue_id']),
      venueName: _asString(json['venue_name'] ?? json['futsal_name']),
      requestedAt: _asDate(
        json['requested_at'] ?? json['created_at'] ?? json['createdAt'],
      ),
      resolvedAt: _asDate(
        json['resolved_at'] ?? json['paid_at'] ?? json['updated_at'],
      ),
    );
  }
}

/// `data.summary` of `/auth/settlements` — how many requests sit in each
/// state, straight from the server rather than counted over the loaded page.
class SettlementStatusCounts {
  const SettlementStatusCounts({
    this.pending = 0,
    this.approved = 0,
    this.paid = 0,
    this.rejected = 0,
  });

  final int pending;
  final int approved;
  final int paid;
  final int rejected;

  int get total => pending + approved + paid + rejected;

  /// Requests still moving through review — these block a second request.
  int get inProgress => pending + approved;

  factory SettlementStatusCounts.fromJson(Map<String, dynamic> json) =>
      SettlementStatusCounts(
        pending: _asInt(json['pending']),
        approved: _asInt(json['approved']),
        paid: _asInt(json['paid']),
        rejected: _asInt(json['rejected']),
      );
}

/// One page of `/auth/settlements?page=&per_page=`.
class SettlementPageModel {
  const SettlementPageModel({
    this.items = const <SettlementModel>[],
    this.summary = const SettlementStatusCounts(),
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 20,
    this.total = 0,
    this.hasMorePages = false,
  });

  final List<SettlementModel> items;
  final SettlementStatusCounts summary;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  static const SettlementPageModel empty = SettlementPageModel();

  factory SettlementPageModel.fromResponse(
    dynamic payload, {
    required int requestedPage,
    required int requestedPerPage,
  }) {
    final root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    final pagination = data['pagination'] is Map
        ? Map<String, dynamic>.from(data['pagination'] as Map)
        : const <String, dynamic>{};
    final items =
        _mapList(
            data['items'] ??
                data['settlements'] ??
                (root['data'] is List ? root['data'] : null),
          ).map(SettlementModel.fromJson).toList()
          // Newest request first.
          ..sort(
            (a, b) => (b.requestedAt ?? DateTime(0)).compareTo(
              a.requestedAt ?? DateTime(0),
            ),
          );
    final currentPage = pagination['current_page'] == null
        ? requestedPage
        : _asInt(pagination['current_page']);
    final perPage = pagination['per_page'] == null
        ? requestedPerPage
        : _asInt(pagination['per_page']);
    // Without a `last_page`, a full page means another probably follows.
    final lastPage = pagination['last_page'] == null
        ? (items.length >= perPage ? currentPage + 1 : currentPage)
        : _asInt(pagination['last_page']);
    return SettlementPageModel(
      items: List.unmodifiable(items),
      summary: data['summary'] is Map
          ? SettlementStatusCounts.fromJson(
              Map<String, dynamic>.from(data['summary'] as Map),
            )
          : const SettlementStatusCounts(),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: pagination['total'] == null
          ? items.length
          : _asInt(pagination['total']),
      hasMorePages: pagination['has_more_pages'] == null
          ? currentPage < lastPage
          : pagination['has_more_pages'] == true,
    );
  }
}
