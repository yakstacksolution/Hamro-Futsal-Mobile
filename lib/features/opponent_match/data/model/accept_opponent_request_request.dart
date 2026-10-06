class AcceptOpponentRequestRequest {
  const AcceptOpponentRequestRequest({
    required this.requestId,
    required this.teamId,
    this.message,
  });

  final String requestId;

  final String teamId;

  final String? message;

  Map<String, dynamic> toFields() => <String, dynamic>{
    'team_id': teamId,
    'message': message,
  };
}
