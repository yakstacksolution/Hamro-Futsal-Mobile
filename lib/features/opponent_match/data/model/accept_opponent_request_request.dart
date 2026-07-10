/// Everything sent to `POST /opponent-requests/{id}/accept` (multipart).
///
/// Deliberately carries NO amount fields — the advance is bound server-side
/// to [holdToken], so a tampered client cannot change what it owes.
class AcceptOpponentRequestRequest {
  const AcceptOpponentRequestRequest({
    required this.requestId,
    required this.teamId,
    required this.holdToken,
    required this.paymentProofPath,
    this.paymentMethod = 'qr',
    this.paymentNote,
  });

  final String requestId;

  /// The accepter's team confirmed on the team-confirmation step.
  final String teamId;

  /// Single-use accept-hold token from the accept quote.
  final String holdToken;
  final String paymentMethod;
  final String? paymentNote;

  /// Local file path of the payment-proof screenshot; attached as the
  /// `payment_proof` multipart file in the data source.
  final String paymentProofPath;

  Map<String, dynamic> toFields() => {
    'accept_hold_token': holdToken,
    'team_id': teamId,
    'payment_method': paymentMethod,
    'payment_note': paymentNote,
  };
}
