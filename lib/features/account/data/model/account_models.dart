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
    this.settlementEligible = false,
    this.settlementBlockingReason = '',
    this.processingEstimate = '',
    this.venues = const <VenueAccountModel>[],
    this.recentActivity = const <AccountEntryModel>[],
    this.settlementQr,
    this.updatedAt,
  });

  final String currency;

  /// Cleared earnings the vendor can request a settlement for.
  final int availableBalance;

  /// Verified-but-not-yet-cleared income (e.g. advances under review).
  final int pendingClearance;
  final int reservedBalance;

  final int totalEarned;
  final int totalCommission;
  final int totalRefunded;
  final int totalSettled;

  /// Platform commission in percent (e.g. 10 = 10%).
  final double commissionRate;

  /// Server-enforced floor for a settlement request; 0 = no floor.
  final int minSettlementAmount;
  final int? maxSettlementAmount;
  final bool settlementEligible;
  final String settlementBlockingReason;
  final String processingEstimate;
  final List<VenueAccountModel> venues;

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
      availableBalance: _asInt(
        json['available_balance'] ??
            json['balance'] ??
            json['availableBalance'],
      ),
      pendingClearance: _asInt(
        json['pending_clearance'] ??
            json['pending_balance'] ??
            json['pendingClearance'],
      ),
      reservedBalance: _asInt(
        json['reserved_balance'] ?? json['settlement_reserved'],
      ),
      totalEarned: _asInt(
        json['total_earned'] ??
            json['lifetime_earned'] ??
            cards['total_earned'],
      ),
      totalCommission: _asInt(
        json['total_commission'] ??
            json['commission_paid'] ??
            cards['commission'],
      ),
      totalRefunded: _asInt(json['total_refunded'] ?? json['refunds_total']),
      totalSettled: _asInt(
        json['total_settled'] ?? json['paid_out'] ?? cards['settled'],
      ),
      commissionRate: _asDouble(
        json['commission_rate'] ??
            json['commission_pct'] ??
            json['commissionRate'],
      ),
      minSettlementAmount: _asInt(
        json['min_settlement_amount'] ?? json['minSettlementAmount'],
      ),
      maxSettlementAmount: json['max_settlement_amount'] == null
          ? null
          : _asInt(json['max_settlement_amount']),
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
      settlementEligible: settlementEligible,
      settlementBlockingReason: settlementBlockingReason,
      processingEstimate: processingEstimate,
      venues: venues ?? this.venues,
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
  final int availableBalance;
  final int pendingClearance;
  final int totalEarned;
  final int totalCommission;
  final bool settlementEligible;

  factory VenueAccountModel.fromJson(Map<String, dynamic> json) {
    return VenueAccountModel(
      id: _asInt(json['id'] ?? json['venue_id'] ?? json['futsal_id']),
      name: _asString(
        json['name'] ?? json['venue_name'] ?? json['futsal_name'],
      ),
      location: _asString(json['location'] ?? json['address']),
      availableBalance: _asInt(
        json['available_balance'] ?? json['balance'] ?? json['amount_due'],
      ),
      pendingClearance: _asInt(
        json['pending_clearance'] ?? json['pending_balance'],
      ),
      totalEarned: _asInt(json['total_earned'] ?? json['gross_earnings']),
      totalCommission: _asInt(
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
  });

  final List<VenueAccountModel> venues;
  final List<AccountEntryModel> entries;

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
    return SettlementBreakdownModel(
      venues: venuesRaw
          .map(VenueAccountModel.fromJson)
          .toList(growable: false),
      entries: entriesRaw
          .map(AccountEntryModel.fromJson)
          .toList(growable: false),
    );
  }
}

/// `/auth/settlement-preview`: what a settlement request would look like
/// right now (overall, or for one venue when `venue_id` was sent).
class SettlementPreviewModel {
  const SettlementPreviewModel({
    this.payableAmount = 0,
    this.commissionAmount = 0,
    this.grossAmount = 0,
    this.minSettlementAmount = 0,
    this.eligible = true,
    this.blockingReason = '',
  });

  /// Net amount the vendor can settle right now.
  final int payableAmount;
  final int commissionAmount;
  final int grossAmount;
  final int minSettlementAmount;
  final bool eligible;
  final String blockingReason;

  factory SettlementPreviewModel.fromResponse(dynamic payload) {
    final root = payload is Map
        ? Map<String, dynamic>.from(payload)
        : <String, dynamic>{};
    final data = root['data'] is Map
        ? Map<String, dynamic>.from(root['data'] as Map)
        : root;
    return SettlementPreviewModel(
      payableAmount: _asInt(
        data['payable_amount'] ??
            data['net_amount'] ??
            data['settlement_amount'] ??
            data['available_balance'] ??
            data['amount'],
      ),
      commissionAmount: _asInt(
        data['commission_amount'] ?? data['commission'],
      ),
      grossAmount: _asInt(
        data['gross_amount'] ?? data['total_amount'] ?? data['total_earned'],
      ),
      minSettlementAmount: _asInt(
        data['min_settlement_amount'] ?? data['minimum_amount'],
      ),
      eligible:
          data['eligible'] != false &&
          data['settlement_eligible'] != false &&
          data['can_request_settlement'] != false,
      blockingReason: _asString(
        data['blocking_reason'] ??
            data['settlement_blocking_reason'] ??
            data['message'],
      ),
    );
  }
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
    this.date,
  });

  final String id;
  final AccountEntryType type;
  final String title;

  /// Always positive; [isCredit] carries the direction.
  final int amount;
  final bool isCredit;
  final String note;

  /// Booking / settlement code the entry belongs to, when the server sends
  /// one (e.g. "BK-1042").
  final String reference;
  final DateTime? date;

  factory AccountEntryModel.fromJson(Map<String, dynamic> json) {
    final type = AccountEntryType.parse(
      _asString(json['type'] ?? json['entry_type'] ?? json['category']),
    );
    final int rawAmount = _asInt(json['amount']);
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
    this.requestedAt,
    this.resolvedAt,
  });

  final String id;
  final int amount;
  final SettlementStatus status;
  final String note;
  final String rejectedReason;
  final String reference;
  final DateTime? requestedAt;
  final DateTime? resolvedAt;

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: _asString(json['id'] ?? json['settlement_id']),
      amount: _asInt(json['amount']).abs(),
      status: SettlementStatus.parse(_asString(json['status'])),
      note: _asString(json['note'] ?? json['remarks']),
      rejectedReason: _asString(
        json['rejected_reason'] ?? json['rejection_reason'] ?? json['reason'],
      ),
      reference: _asString(json['reference'] ?? json['ref'] ?? json['code']),
      requestedAt: _asDate(
        json['requested_at'] ?? json['created_at'] ?? json['createdAt'],
      ),
      resolvedAt: _asDate(
        json['resolved_at'] ?? json['paid_at'] ?? json['updated_at'],
      ),
    );
  }
}
