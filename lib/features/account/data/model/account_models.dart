library;

import 'package:hamro_futsal/core/api/api_client/api_constants.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';

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

PaymentQrModel? _parsePaymentQr(Map<String, dynamic> data) {
  final List<dynamic> candidates = <dynamic>[
    data['payment_qr'] ?? data['paymentQr'] ?? data['qr'],
    data['recipient'],
    data,
  ];
  for (final dynamic candidate in candidates) {
    if (candidate == null) continue;
    final PaymentQrModel parsed = PaymentQrModel.fromResponse(candidate);
    if (parsed.hasQr) return parsed;
  }
  return null;
}

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

  final double availableBalance;

  final double pendingClearance;
  final double reservedBalance;

  final double totalEarned;
  final double totalCommission;
  final double totalRefunded;
  final double totalSettled;

  final double commissionRate;

  final double minSettlementAmount;
  final double? maxSettlementAmount;

  final double requestableAmount;
  final bool settlementEligible;
  final String settlementBlockingReason;
  final String processingEstimate;
  final List<VenueAccountModel> venues;

  final List<AccountSectionModel> sections;

  int? sectionCount(String key) {
    for (final section in sections) {
      if (section.key == key) return section.count;
    }
    return null;
  }

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
      // `/auth/settlement-breakdown` names this plain `commission`. Without it
      // the per-futsal commission read as 0 and the settlement form fell back
      // to the venue's balance — several times what is actually owed.
      totalCommission: _asDouble(
        json['commission'] ??
            json['total_commission'] ??
            json['commission_due'] ??
            json['commission_payable'],
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

class SettlementBreakdownModel {
  const SettlementBreakdownModel({
    this.venues = const <VenueAccountModel>[],
    this.entries = const <AccountEntryModel>[],
    this.count = 0,
  });

  final List<VenueAccountModel> venues;
  final List<AccountEntryModel> entries;

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

class SettlementQrCodeModel {
  const SettlementQrCodeModel({
    this.id = 0,
    this.title = '',
    this.sortOrder = 0,
    this.qr = const PaymentQrModel(),
  });

  final int id;

  final String title;

  final int sortOrder;

  final PaymentQrModel qr;

  bool get hasQr => qr.hasQr;

  factory SettlementQrCodeModel.fromJson(Map<String, dynamic> json) {
    final String title = _asString(
      json['title'] ??
          json['label'] ??
          json['name'] ??
          json['bank_name'] ??
          json['payment_method'],
    );
    final PaymentQrModel qr = PaymentQrModel.fromResponse(json);
    return SettlementQrCodeModel(
      id: _asInt(json['id'] ?? json['qr_id']),
      title: title.isEmpty ? _asString(qr.payeeName) : title,
      sortOrder: _asInt(json['sort_order'] ?? json['sortOrder']),
      qr: qr,
    );
  }

  static List<SettlementQrCodeModel> listFromResponse(dynamic payload) {
    final List<dynamic> raw = _qrNodes(payload);
    final List<SettlementQrCodeModel> parsed = raw
        .whereType<Map>()
        .map((Map e) => Map<String, dynamic>.from(e))
        .where((Map<String, dynamic> e) => e['status'] != false)
        .map(SettlementQrCodeModel.fromJson)
        .where((SettlementQrCodeModel e) => e.hasQr)
        .toList();
    parsed.sort(
      (SettlementQrCodeModel a, SettlementQrCodeModel b) =>
          a.sortOrder.compareTo(b.sortOrder),
    );
    return List<SettlementQrCodeModel>.unmodifiable(parsed);
  }

  static List<dynamic> _qrNodes(dynamic payload) {
    if (payload is List) return payload;
    if (payload is! Map) return const <dynamic>[];
    final Map<String, dynamic> root = Map<String, dynamic>.from(payload);
    final dynamic data = root['data'] ?? root;
    if (data is List) return data;
    if (data is! Map) return const <dynamic>[];
    final Map<String, dynamic> map = Map<String, dynamic>.from(data);
    final dynamic node =
        map['qr_codes'] ??
        map['qrCodes'] ??
        map['items'] ??
        map['data'] ??
        map['results'];
    return node is List ? node : const <dynamic>[];
  }
}

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
    this.paymentQr,
  });

  final String scope;

  final String title;

  final String subtitle;
  final SettlementRecipientModel recipient;

  final SettlementPreviewVenue? venue;

  final double maximumPayable;

  final double defaultAmount;
  final double pendingClearance;

  final bool exactAmountRequired;

  final List<String> acceptedProofTypes;
  final int proofMaxSizeMb;
  final String blockingReason;

  final PaymentQrModel? paymentQr;

  bool get isVenueScoped => venue != null || scope == 'venue';

  bool get eligible => maximumPayable > 0;

  int get proofMaxBytes => proofMaxSizeMb * 1024 * 1024;

  factory SettlementPreviewModel.fromResponse(dynamic payload) {
    final root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    // A settlement pays the commission the venue owes Hamro Futsal, so the
    // commission keys are read first. `maximum_payable` trails them on purpose:
    // the endpoint fills it with the vendor's cleared balance — the pot the
    // commission came out of — which is several times the debt. It is a
    // last-resort figure here, not the preferred one.
    final maximumPayable = _asDouble(
      data['commission_payable'] ??
          data['commission_due'] ??
          data['total_commission'] ??
          data['maximum_payable'] ??
          data['payable_amount'],
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
      paymentQr: _parsePaymentQr(data),
      blockingReason: _asString(
        data['blocking_reason'] ?? data['settlement_blocking_reason'],
      ),
    );
  }
}

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
    this.createdAt,
  });

  final String id;
  final AccountEntryType type;
  final String title;

  final double amount;
  final bool isCredit;
  final String note;

  final String venueName;

  final String reference;

  final DateTime? date;

  final DateTime? createdAt;

  DateTime? get occurredAt => date ?? createdAt;

  bool get recordedApartFromDate =>
      date != null && createdAt != null && date != createdAt;

  String get identity => id.isNotEmpty
      ? id
      : <String>[
          type.name,
          reference,
          venueName,
          isCredit ? 'cr' : 'dr',
          amount.toStringAsFixed(2),
          createdAt?.toIso8601String() ?? '',
          date?.toIso8601String() ?? '',
        ].join('|');

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
      date: _asDate(json['date']),
      createdAt: _asDate(json['created_at'] ?? json['createdAt']),
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
    this.venueAddress = '',
    this.requestedAt,
    this.resolvedAt,
    this.scope = '',
    this.maximumPayable = 0,
    this.pendingClearanceAmount = 0,
    this.itemCount = 0,
    this.proofPath = '',
    this.proofUrl = '',
  });

  final String id;

  final double amount;

  final SettlementStatus status;
  final String note;
  final String rejectedReason;

  final String reference;

  final String transactionReference;

  final int? venueId;
  final String venueName;
  final String venueAddress;
  final DateTime? requestedAt;
  final DateTime? resolvedAt;

  final String scope;

  final double maximumPayable;
  final double pendingClearanceAmount;

  final int itemCount;

  final String proofPath;
  final String proofUrl;

  bool get hasProof => proofImageUrl != null;

  String? get proofImageUrl {
    final String direct = proofUrl.trim();
    if (direct.isNotEmpty) {
      final Uri? parsed = Uri.tryParse(direct);
      if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
        return parsed.replace(path: _collapse(parsed.path)).toString();
      }
    }
    final String raw = direct.isNotEmpty ? direct : proofPath.trim();
    if (raw.isEmpty) return null;
    final String path = raw.startsWith('/') ? raw : '/$raw';
    final String storagePath = path.startsWith('/storage/')
        ? path
        : '/storage$path';
    return Uri.parse(APIEndpoint.baseUrl)
        .replace(path: _collapse(storagePath), query: null, fragment: null)
        .toString();
  }

  static String _collapse(String path) =>
      path.replaceAll(RegExp(r'/{2,}'), '/');

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> venue = json['venue'] is Map
        ? Map<String, dynamic>.from(json['venue'] as Map)
        : const <String, dynamic>{};
    return SettlementModel(
      id: _asString(json['id'] ?? json['settlement_id']),
      // `/auth/settlements` names the figure `requested_amount`; older
      // payloads (and the create response) call it `amount`.
      amount: _asDouble(
        json['requested_amount'] ?? json['amount'] ?? json['maximum_payable'],
      ).abs(),
      status: SettlementStatus.parse(_asString(json['status'])),
      note: _asString(json['note'] ?? json['remarks']),
      rejectedReason: _asString(
        json['rejected_reason'] ?? json['rejection_reason'] ?? json['reason'],
      ),
      reference: _asString(
        json['settlement_code'] ??
            json['reference'] ??
            json['ref'] ??
            json['code'],
      ),
      transactionReference: _asString(
        json['transaction_reference'] ?? json['txn_reference'],
      ),
      venueId: (json['venue_id'] ?? venue['id']) == null
          ? null
          : _asInt(json['venue_id'] ?? venue['id']),
      venueName: _asString(
        json['venue_name'] ?? json['futsal_name'] ?? venue['name'],
      ),
      venueAddress: _asString(venue['address']),
      requestedAt: _asDate(
        json['requested_at'] ?? json['created_at'] ?? json['createdAt'],
      ),
      resolvedAt: _asDate(
        json['resolved_at'] ?? json['paid_at'] ?? json['updated_at'],
      ),
      scope: _asString(json['scope']),
      maximumPayable: _asDouble(json['maximum_payable']).abs(),
      pendingClearanceAmount: _asDouble(json['pending_clearance_amount']).abs(),
      itemCount: _asInt(json['item_count'] ?? json['items_count']),
      proofPath: _asString(json['proof_path']),
      proofUrl: _asString(json['proof_url']),
    );
  }
}

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

  int get inProgress => pending + approved;

  factory SettlementStatusCounts.fromJson(Map<String, dynamic> json) =>
      SettlementStatusCounts(
        pending: _asInt(json['pending']),
        approved: _asInt(json['approved']),
        paid: _asInt(json['paid']),
        rejected: _asInt(json['rejected']),
      );
}

class AccountActivityPageModel {
  const AccountActivityPageModel({
    this.items = const <AccountEntryModel>[],
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.hasMorePages = false,
  });

  final List<AccountEntryModel> items;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final bool hasMorePages;

  static const AccountActivityPageModel empty = AccountActivityPageModel();

  factory AccountActivityPageModel.fromResponse(
    dynamic payload, {
    required int requestedPage,
    required int requestedPerPage,
  }) {
    final root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final dynamic dataNode = payload is List ? payload : (root['data'] ?? root);
    final Map<String, dynamic> data = dataNode is Map
        ? Map<String, dynamic>.from(dataNode)
        : <String, dynamic>{};

    final items = _mapList(
      dataNode is List
          ? dataNode
          : (data['items'] ??
                data['recent_activity'] ??
                data['activities'] ??
                data['entries'] ??
                data['statement'] ??
                data['transactions'] ??
                data['data'] ??
                data['results']),
    ).map(AccountEntryModel.fromJson).toList();

    final pagination = data['pagination'] is Map
        ? Map<String, dynamic>.from(data['pagination'] as Map)
        : (data['meta'] is Map
              ? Map<String, dynamic>.from(data['meta'] as Map)
              : const <String, dynamic>{});

    final currentPage = pagination['current_page'] == null
        ? requestedPage
        : _asInt(pagination['current_page']);
    final perPage = pagination['per_page'] == null
        ? requestedPerPage
        : _asInt(pagination['per_page']);
    final lastPage = pagination['last_page'] == null
        ? (items.length >= perPage ? currentPage + 1 : currentPage)
        : _asInt(pagination['last_page']);

    return AccountActivityPageModel(
      items: List.unmodifiable(items),
      currentPage: currentPage,
      lastPage: lastPage,
      perPage: perPage,
      total: pagination['total'] == null
          ? _asInt(data['count'] ?? items.length)
          : _asInt(pagination['total']),
      hasMorePages: pagination['has_more_pages'] == null
          ? currentPage < lastPage
          : pagination['has_more_pages'] == true,
    );
  }
}

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
