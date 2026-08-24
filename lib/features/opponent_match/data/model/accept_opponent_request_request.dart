/// Everything sent when my team accepts a request from the `need_opponent`
/// section: `POST /auth/opponent-requests/{requestId}/invitations`.
///
/// The accept creates an invitation on the request — my team applying to play
/// it — so the request id is the listed row's id and the team travels in the
/// body.
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

  /// The `need_opponent` row being accepted.
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
