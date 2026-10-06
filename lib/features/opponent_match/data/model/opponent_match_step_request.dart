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

enum OpponentVenueSource {
  booking('booking'),

  external('external');

  const OpponentVenueSource(this.wireValue);

  final String wireValue;
}

class OpponentVenueStepRequest {
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

  final int bookingId;

  final String venueName;
  final String courtName;
  final String address;
  final DateTime? date;
  final ({int hour, int minute})? startTime;
  final ({int hour, int minute})? endTime;
  final int feeAmount;

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

enum OpponentSplitType {
  even('even'),

  custom('custom');

  const OpponentSplitType(this.wireValue);

  final String wireValue;
}

enum OpponentSplitBasis {
  team('team'),

  result('result');

  const OpponentSplitBasis(this.wireValue);

  final String wireValue;
}

class OpponentCostStepRequest {
  const OpponentCostStepRequest.even()
    : splitType = OpponentSplitType.even,
      basis = null,
      requestingTeamPercent = 0;

  const OpponentCostStepRequest.custom({
    required OpponentSplitBasis this.basis,
    required this.requestingTeamPercent,
  }) : splitType = OpponentSplitType.custom;

  final OpponentSplitType splitType;

  final OpponentSplitBasis? basis;

  final int requestingTeamPercent;

  int get loserPayPercent => requestingTeamPercent;

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

class OpponentRequestRefModel {
  const OpponentRequestRefModel({required this.id, this.status = ''});

  final String id;
  final String status;

  bool get isValid => id.isNotEmpty;

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
