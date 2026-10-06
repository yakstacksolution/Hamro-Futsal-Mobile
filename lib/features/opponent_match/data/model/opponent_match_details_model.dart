library;

int _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString().trim() ?? '') ?? 0;
}

int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  final String raw = value.toString().trim();
  if (raw.isEmpty || raw == 'null') return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(raw) ?? double.tryParse(raw)?.round();
}

String _asText(dynamic value) {
  if (value == null) return '';
  final String raw = value.toString().trim();
  return raw == 'null' ? '' : raw;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

class MatchTeamRef {
  const MatchTeamRef({
    required this.id,
    required this.name,
    required this.initials,
  });

  final String id;
  final String name;

  final String initials;

  static MatchTeamRef fromJson(Map<String, dynamic> json) {
    final String name = _asText(json['name']);
    return MatchTeamRef(
      id: _asText(json['id']),
      name: name,
      initials: _asText(json['initials']).isNotEmpty
          ? _asText(json['initials'])
          : _initialsOf(name),
    );
  }

  static String _initialsOf(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  bool get isEmpty => name.isEmpty;
}

class MatchSummary {
  const MatchSummary({
    required this.requestingTeam,
    required this.opponentTeam,
    required this.headline,
    required this.subheadline,
  });

  final MatchTeamRef requestingTeam;
  final MatchTeamRef opponentTeam;

  final String headline;
  final String subheadline;

  static MatchSummary fromJson(Map<String, dynamic> json) => MatchSummary(
    requestingTeam: MatchTeamRef.fromJson(_asMap(json['requesting_team'])),
    opponentTeam: MatchTeamRef.fromJson(_asMap(json['opponent_team'])),
    headline: _asText(json['headline']),
    subheadline: _asText(json['subheadline']),
  );

  String get statusLine =>
      <String>[headline, subheadline].where((s) => s.isNotEmpty).join(' · ');
}

class MatchKickoff {
  const MatchKickoff({
    required this.date,
    required this.dateLabel,
    required this.dayLabel,
    required this.time,
    required this.timeRange,
    required this.formatName,
    required this.formatLabel,
    required this.playersPerTeam,
  });

  final String date;
  final String dateLabel;
  final String dayLabel;
  final String time;
  final String timeRange;

  final String formatName;

  final String formatLabel;
  final int playersPerTeam;

  static MatchKickoff fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> format = _asMap(json['match_format']);
    final String name = _asText(format['name']);
    return MatchKickoff(
      date: _asText(json['date']),
      dateLabel: _asText(json['date_label']),
      dayLabel: _asText(json['day_label']),
      time: _asText(json['time']),
      timeRange: _asText(json['time_range']),
      formatName: name,
      formatLabel: _asText(format['label']).isNotEmpty
          ? _asText(format['label'])
          : name,
      playersPerTeam: _asInt(format['players_per_team']),
    );
  }

  String get whenLabel =>
      <String>[dayLabel, dateLabel].where((s) => s.isNotEmpty).join(', ');

  String get slotLabel => timeRange.isNotEmpty ? timeRange : time;
}

class MatchVenue {
  const MatchVenue({
    required this.source,
    required this.isLinked,
    required this.bookingId,
    required this.venueName,
    required this.venueAddress,
    required this.courtName,
    required this.label,
  });

  final String source;

  final bool isLinked;
  final String bookingId;
  final String venueName;
  final String venueAddress;
  final String courtName;

  final String label;

  static MatchVenue fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> venue = _asMap(json['venue']);
    final Map<String, dynamic> court = _asMap(json['court']);
    return MatchVenue(
      source: _asText(json['source']),
      isLinked: json['is_linked'] == true,
      bookingId: _asText(json['booking_id']),
      venueName: _asText(venue['name']),
      venueAddress: _asText(venue['address']),
      courtName: _asText(court['name']),
      label: _asText(json['label']),
    );
  }

  String get displayName =>
      <String>[venueName, courtName].where((s) => s.isNotEmpty).join(' · ');

  bool get isEmpty => venueName.isEmpty && courtName.isEmpty;
}

class MatchShare {
  const MatchShare({
    required this.team,
    required this.amount,
    required this.percent,
    required this.label,
  });

  final String team;

  final int? amount;
  final int? percent;

  final String label;

  static MatchShare fromJson(Map<String, dynamic> json) => MatchShare(
    team: _asText(json['team']),
    amount: _asIntOrNull(json['amount']),
    percent: _asIntOrNull(json['percent']),
    label: _asText(json['label']),
  );

  bool get isEmpty => label.isEmpty && amount == null && percent == null;
}

class MatchCostSplit {
  const MatchCostSplit({
    required this.totalCourtFee,
    required this.requestingTeamShare,
    required this.opponentTeamShare,
    required this.settlementNote,
  });

  final int totalCourtFee;
  final MatchShare requestingTeamShare;
  final MatchShare opponentTeamShare;

  final String settlementNote;

  static MatchCostSplit fromJson(Map<String, dynamic> json) => MatchCostSplit(
    totalCourtFee: _asInt(json['total_court_fee']),
    requestingTeamShare: MatchShare.fromJson(
      _asMap(json['requesting_team_share']),
    ),
    opponentTeamShare: MatchShare.fromJson(_asMap(json['opponent_team_share'])),
    settlementNote: _asText(json['settlement_note']),
  );
}

class MatchChat {
  const MatchChat({
    required this.conversationId,
    required this.isOpen,
    required this.title,
    required this.description,
    required this.ctaLabel,
  });

  final int? conversationId;
  final bool isOpen;
  final String title;
  final String description;
  final String ctaLabel;

  static MatchChat fromJson(Map<String, dynamic> json) => MatchChat(
    conversationId: _asIntOrNull(json['conversation_id']),
    isOpen: json['is_open'] == true,
    title: _asText(json['title']),
    description: _asText(json['description']),
    ctaLabel: _asText(json['cta_label']),
  );

  bool get canOpen => isOpen && (conversationId ?? 0) > 0;
}

class OpponentMatchDetailsModel {
  const OpponentMatchDetailsModel({
    required this.id,
    required this.status,
    required this.rawStatus,
    required this.summary,
    required this.kickoff,
    required this.venue,
    required this.cost,
    required this.chat,
  });

  final String id;

  final String status;
  final String rawStatus;

  final MatchSummary summary;
  final MatchKickoff kickoff;
  final MatchVenue venue;
  final MatchCostSplit cost;
  final MatchChat chat;

  factory OpponentMatchDetailsModel.fromJson(Map<String, dynamic> json) {
    return OpponentMatchDetailsModel(
      id: _asText(json['id']),
      status: _asText(json['status']),
      rawStatus: _asText(json['raw_status']),
      summary: MatchSummary.fromJson(_asMap(json['match_summary'])),
      kickoff: MatchKickoff.fromJson(_asMap(json['kickoff'])),
      venue: MatchVenue.fromJson(_asMap(json['linked_venue_booking'])),
      cost: MatchCostSplit.fromJson(_asMap(json['cost_split'])),
      chat: MatchChat.fromJson(_asMap(json['match_chat'])),
    );
  }

  bool get isConfirmed =>
      rawStatus.toLowerCase() == 'matched' ||
      rawStatus.toLowerCase() == 'accepted' ||
      status.toLowerCase() == 'settled';
}
