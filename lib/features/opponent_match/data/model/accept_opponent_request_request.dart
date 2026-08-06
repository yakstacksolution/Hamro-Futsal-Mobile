/// Everything sent to `POST /opponent-requests/{id}/accept`.
///
/// Accepting is free: it only tells the requester which of my teams wants to
/// play. No hold token, no advance, no payment proof — the court fee is
/// settled with the venue, and the requester still has to pick an opponent.
class AcceptOpponentRequestRequest {
  const AcceptOpponentRequestRequest({
    required this.requestId,
    required this.teamId,
    this.message,
  });

  final String requestId;

  /// The accepter's team confirmed on the accept screen.
  final String teamId;

  /// Optional note the accepting captain sends with the acceptance.
  final String? message;

  Map<String, dynamic> toFields() => <String, dynamic>{
    'team_id': teamId,
    'message': message,
  };
}
