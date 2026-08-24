/// The confirmed match behind a settled request, as served by
/// `GET /auth/opponent-requests/{id}/match-details`.
///
/// This endpoint answers in its own shape — sections built for the screen
/// (`match_summary`, `kickoff`, `linked_venue_booking`, `cost_split`,
/// `match_chat`) rather than the request row the list endpoints send. It also
/// carries the copy: headlines, `date_label`, `Your share (60%)`,
/// `Paid at the venue`, the chat CTA. That copy is used as sent, so the two
/// sides of a match always read the same wording and a server-side change does
/// not need an app release. Every label still falls back to something the app
/// can build itself, so a section that arrives bare still renders.
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

/// One side of the fixture.
class MatchTeamRef {
  const MatchTeamRef({
    required this.id,
    required this.name,
    required this.initials,
  });

  final String id;
  final String name;

  /// The server builds these ("Rajendra Teams" → "RT"); derived on-device only
  /// when it sent none.
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

/// `match_summary` — the fixture header and its confirmation line.
class MatchSummary {
  const MatchSummary({
    required this.requestingTeam,
    required this.opponentTeam,
    required this.headline,
    required this.subheadline,
  });

  final MatchTeamRef requestingTeam;
  final MatchTeamRef opponentTeam;

  /// "Match created" / "chat room opened" — shown as one line.
  final String headline;
  final String subheadline;

  static MatchSummary fromJson(Map<String, dynamic> json) => MatchSummary(
    requestingTeam: MatchTeamRef.fromJson(_asMap(json['requesting_team'])),
    opponentTeam: MatchTeamRef.fromJson(_asMap(json['opponent_team'])),
    headline: _asText(json['headline']),
    subheadline: _asText(json['subheadline']),
  );

  /// The two halves joined the way the screen shows them.
  String get statusLine => <String>[
    headline,
    subheadline,
  ].where((s) => s.isNotEmpty).join(' · ');
}

/// `kickoff` — when the match is played, pre-formatted.
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

  /// Raw `YYYY-MM-DD`, kept for anything that needs a real date rather than a
  /// label; the screen prefers the labels beside it.
  final String date;
  final String dateLabel;
  final String dayLabel;
  final String time;
  final String timeRange;

  /// "5v5".
  final String formatName;

  /// "Beginner · 5v5" — the level and format the request was opened with.
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

  /// "Sun, Aug 23" — falls back to whichever half the server sent.
  String get whenLabel => <String>[
    dayLabel,
    dateLabel,
  ].where((s) => s.isNotEmpty).join(', ');

  /// The window if there is one, otherwise the start time alone.
  String get slotLabel => timeRange.isNotEmpty ? timeRange : time;
}

/// `linked_venue_booking` — the court, and whether it is a booking on this
/// platform or one arranged elsewhere.
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

  /// `booking` when the court was booked through the app, `external` when the
  /// teams arranged it themselves.
  final String source;

  /// True only for a court booked on this platform — the one case with a
  /// booking to link.
  final bool isLinked;
  final String bookingId;
  final String venueName;
  final String venueAddress;
  final String courtName;

  /// The server's own one-liner about the link state, e.g. "External venue
  /// selected for this match".
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

  /// "Green Turf Arena · Court 2", or just the venue when it has no court.
  String get displayName => <String>[
    venueName,
    courtName,
  ].where((s) => s.isNotEmpty).join(' · ');

  bool get isEmpty => venueName.isEmpty && courtName.isEmpty;
}

/// One side's part of the bill.
class MatchShare {
  const MatchShare({
    required this.team,
    required this.amount,
    required this.percent,
    required this.label,
  });

  final String team;

  /// Null when the split is keyed to the result, so nothing is owed yet.
  final int? amount;
  final int? percent;

  /// "Your share (60%)" / "Opponent share (40%)".
  final String label;

  static MatchShare fromJson(Map<String, dynamic> json) => MatchShare(
    team: _asText(json['team']),
    amount: _asIntOrNull(json['amount']),
    percent: _asIntOrNull(json['percent']),
    label: _asText(json['label']),
  );

  bool get isEmpty => label.isEmpty && amount == null && percent == null;
}

/// `cost_split` — the agreed rule, already resolved into two amounts.
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

  /// "Paid at the venue".
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

/// `match_chat` — the room the server opened when the match was created.
class MatchChat {
  const MatchChat({
    required this.conversationId,
    required this.isOpen,
    required this.title,
    required this.description,
    required this.ctaLabel,
  });

  /// The thread both teams share. Null until the server has created it.
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

  /// Openable only once the room exists and the server says it is open.
  bool get canOpen => isOpen && (conversationId ?? 0) > 0;
}

/// `GET /auth/opponent-requests/{id}/match-details`.
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

  /// The display bucket (`settled`) and the lifecycle (`matched`) — the same
  /// pair the tabbed list sends.
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

  /// The match is locked in. `matched` is the lifecycle word; `settled` is the
  /// display bucket for the same thing.
  bool get isConfirmed =>
      rawStatus.toLowerCase() == 'matched' ||
      rawStatus.toLowerCase() == 'accepted' ||
      status.toLowerCase() == 'settled';
}
