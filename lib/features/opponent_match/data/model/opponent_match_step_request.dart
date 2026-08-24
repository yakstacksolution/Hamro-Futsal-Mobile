/// The match section of an opponent request — what step one of the wizard
/// sends, both when opening the request and when the user comes back and
/// edits it.
///
/// `POST /auth/opponent-requests` opens the request with this body;
/// `PATCH /auth/opponent-requests/{id}/match` re-sends the same body against
/// the id that came back.
class OpponentMatchStepRequest {
  const OpponentMatchStepRequest({
    required this.teamId,
    required this.matchFormatId,
    required this.opponentLevelId,
  });

  final int teamId;
  final int matchFormatId;
  final int opponentLevelId;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'team_id': teamId,
    'match_format_id': matchFormatId,
    'opponent_level_id': opponentLevelId,
  };
}

/// Where the court behind an opponent request comes from. The server switches
/// on this, so the wire values are fixed.
enum OpponentVenueSource {
  /// Already booked through this platform — the booking carries the court,
  /// date, time and fee, so only its id is sent.
  booking('booking'),

  /// Booked somewhere outside this platform: the requester describes the court
  /// themselves, so every field travels in the body.
  external('external');

  const OpponentVenueSource(this.wireValue);

  final String wireValue;
}

/// The venue section of an opponent request — what step two of the wizard
/// sends against the id step one opened.
///
/// `PUT /auth/opponent-requests/{id}/venue`.
class OpponentVenueStepRequest {
  /// The "my bookings" branch: the match is hosted by an existing platform
  /// booking, identified by [bookingId].
  const OpponentVenueStepRequest.existingBooking(this.bookingId)
    : source = OpponentVenueSource.booking,
      venueName = '',
      courtName = '',
      address = '',
      date = null,
      startTime = null,
      endTime = null,
      preferredDate = null,
      feeAmount = 0;

  /// The "booked elsewhere" branch: the court is described by hand. [endTime]
  /// is optional — the server derives one when it is absent.
  ///
  /// [preferredDate] is the match day. Step one no longer asks for a date, so
  /// this branch is where it is stated and it travels as `preferred_date`
  /// alongside the booked window.
  const OpponentVenueStepRequest.external({
    required this.venueName,
    required this.courtName,
    required this.address,
    required this.date,
    required this.startTime,
    required this.feeAmount,
    this.endTime,
    this.preferredDate,
  }) : source = OpponentVenueSource.external,
       bookingId = 0;

  final OpponentVenueSource source;

  /// Set for [OpponentVenueSource.booking].
  final int bookingId;

  /// Set for [OpponentVenueSource.external].
  final String venueName;
  final String courtName;
  final String address;
  final DateTime? date;
  final ({int hour, int minute})? startTime;
  final ({int hour, int minute})? endTime;
  final int feeAmount;

  /// The match day, sent as `preferred_date`. Defaults to [date] when the
  /// caller leaves it out, since for an external court the booked day *is* the
  /// match day.
  final DateTime? preferredDate;

  Map<String, dynamic> toJson() => switch (source) {
    OpponentVenueSource.booking => <String, dynamic>{
      'venue_source': source.wireValue,
      'booking_id': bookingId,
    },
    OpponentVenueSource.external => <String, dynamic>{
      'venue_source': source.wireValue,
      'external_venue_name': venueName,
      // Omitted rather than sent blank: the manual form has no court field, so
      // an empty value here means "not supplied", not "named empty".
      if (courtName.isNotEmpty) 'external_court_name': courtName,
      if (address.isNotEmpty) 'external_address': address,
      if (date != null) 'external_date': _date(date!),
      if ((preferredDate ?? date) != null)
        'preferred_date': _date((preferredDate ?? date)!),
      if (startTime != null) 'external_start_time': _time(startTime!),
      if (endTime != null) 'external_end_time': _time(endTime!),
      'external_fee_amount': feeAmount,
    },
  };

  static String _date(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${_two(date.month)}-${_two(date.day)}';

  static String _time(({int hour, int minute}) time) =>
      '${_two(time.hour)}:${_two(time.minute)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}

/// How the court fee is divided. Wire values are fixed — the server switches
/// on them.
enum OpponentSplitType {
  /// Half each; no percentage travels with it.
  even('even'),

  /// A percentage the requester sets, read together with [OpponentSplitBasis].
  custom('custom');

  const OpponentSplitType(this.wireValue);

  final String wireValue;
}

/// What a custom percentage is keyed to.
enum OpponentSplitBasis {
  /// Fixed per side: the requesting team always pays its percentage.
  team('team'),

  /// Keyed to the outcome: the percentage applies to whoever loses.
  result('result');

  const OpponentSplitBasis(this.wireValue);

  final String wireValue;
}

/// The cost section of an opponent request — what step three of the wizard
/// sends against the id step one opened.
///
/// `PUT /auth/opponent-requests/{id}/cost`.
class OpponentCostStepRequest {
  /// Half each. The server derives both shares, so nothing else is sent.
  const OpponentCostStepRequest.even()
    : splitType = OpponentSplitType.even,
      basis = null,
      requestingTeamPercent = 0;

  /// A custom percentage, read according to [basis].
  ///
  /// With [OpponentSplitBasis.team] it is the requesting team's fixed share and
  /// travels as `requesting_team_percent`. With [OpponentSplitBasis.result] it
  /// is the *loser's* share, and the pair `loser_pay_percent` /
  /// `winner_pay_percent` travels instead — neither side is fixed in advance,
  /// so naming one "the requesting team" would say the wrong thing.
  const OpponentCostStepRequest.custom({
    required OpponentSplitBasis this.basis,
    required this.requestingTeamPercent,
  }) : splitType = OpponentSplitType.custom;

  final OpponentSplitType splitType;

  /// Null for an even split, which has no percentage to key.
  final OpponentSplitBasis? basis;

  /// Percentage of the court fee carried by the side [basis] names: the
  /// requesting team for a fixed split (1–99), the loser when keyed to the
  /// result (1–100, where 100 means the loser covers the whole fee).
  final int requestingTeamPercent;

  /// The loser's share of a result-keyed split.
  int get loserPayPercent => requestingTeamPercent;

  /// What is left for the winner. 0 when the loser carries the whole fee.
  int get winnerPayPercent => 100 - requestingTeamPercent;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'split_type': splitType.wireValue,
    if (splitType == OpponentSplitType.custom) ...<String, dynamic>{
      'split_basis': basis!.wireValue,
      if (basis == OpponentSplitBasis.result) ...<String, dynamic>{
        'loser_pay_percent': loserPayPercent,
        'winner_pay_percent': winnerPayPercent,
      } else
        'requesting_team_percent': requestingTeamPercent,
    },
  };
}

/// What the server hands back when the request is opened.
///
/// Only the id is load-bearing — every later step patches against it — but the
/// status is kept so the UI can tell a draft from a published request without
/// a second fetch.
class OpponentRequestRefModel {
  const OpponentRequestRefModel({required this.id, this.status = ''});

  final String id;
  final String status;

  bool get isValid => id.isNotEmpty;

  /// The id can arrive at the top level, under `data`, or under
  /// `data.opponent_request` depending on the endpoint, so the search walks
  /// down rather than assuming one shape.
  factory OpponentRequestRefModel.fromResponse(dynamic payload) {
    final Map<String, dynamic>? node = _locate(payload, 0);
    if (node == null) return const OpponentRequestRefModel(id: '');
    return OpponentRequestRefModel(
      id: (node['id'] ?? node['request_id'] ?? node['uuid'] ?? '').toString(),
      status: (node['status'] ?? node['state'] ?? '').toString(),
    );
  }

  static Map<String, dynamic>? _locate(dynamic node, int depth) {
    if (node is! Map || depth > 3) return null;
    final Map<String, dynamic> map = Map<String, dynamic>.from(node);
    if (map['id'] != null || map['request_id'] != null) return map;
    for (final String key in const <String>[
      'data',
      'opponent_request',
      'request',
      'result',
    ]) {
      final Map<String, dynamic>? found = _locate(map[key], depth + 1);
      if (found != null) return found;
    }
    return null;
  }
}
