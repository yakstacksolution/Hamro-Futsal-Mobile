import 'package:hamro_footsall/features/futsal_details/data/model/payment_qr_model.dart';

/// The authoritative accept quote from
/// `POST /opponent-requests/{id}/accept-quote` — a single-use accept hold,
/// the server-computed advance, and the payment QR to settle it with.
class OpponentAcceptQuoteModel {
  const OpponentAcceptQuoteModel({
    required this.holdToken,
    required this.paymentQr,
    this.holdExpiresAt,
    this.totalFee = 0,
    this.accepterShare = 0,
    this.advancePayableNow = 0,
    this.balanceDueLater = 0,
  });

  /// Single-use token that must accompany the accept submission.
  final String holdToken;

  /// When the hold auto-releases; the pay step counts down to this.
  final DateTime? holdExpiresAt;

  final int totalFee;
  final int accepterShare;

  /// Amount to pay right now — the only figure the proof is verified against.
  final int advancePayableNow;
  final int balanceDueLater;

  final PaymentQrModel paymentQr;

  factory OpponentAcceptQuoteModel.fromResponse(dynamic payload) {
    final Map<String, dynamic> root = _asMap(payload);
    final Map<String, dynamic> data = root.containsKey('data')
        ? _asMap(root['data'])
        : root;
    final Map<String, dynamic> hold = _asMap(data['accept_hold']);
    final Map<String, dynamic> quote = _asMap(data['quote']);

    return OpponentAcceptQuoteModel(
      holdToken: (hold['token'] ?? data['hold_token'] ?? '').toString().trim(),
      holdExpiresAt: DateTime.tryParse(
        (hold['expires_at'] ?? '').toString(),
      )?.toLocal(),
      totalFee: _asInt(quote['total_fee']),
      accepterShare: _asInt(quote['accepter_share']),
      advancePayableNow: _asInt(quote['advance_payable_now']),
      balanceDueLater: _asInt(quote['balance_due_later']),
      paymentQr: PaymentQrModel.fromResponse(data['payment_qr'] ?? data),
    );
  }
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '') ??
      double.tryParse(value?.toString() ?? '')?.round() ??
      0;
}
