/// Match format offered when challenging an opponent.
enum MatchFormat { fiveASide, sixASide, sevenASide }

extension MatchFormatX on MatchFormat {
  String get label => switch (this) {
    MatchFormat.fiveASide => '5v5',
    MatchFormat.sixASide => '6v6',
    MatchFormat.sevenASide => '7v7',
  };

  /// Court fee tier per format until the backend provides real pricing.
  int get courtFee => switch (this) {
    MatchFormat.fiveASide => 1200,
    MatchFormat.sixASide => 1500,
    MatchFormat.sevenASide => 1800,
  };
}

enum OpponentLevel { beginner, intermediate, advanced }

extension OpponentLevelX on OpponentLevel {
  String get label => switch (this) {
    OpponentLevel.beginner => 'Beginner',
    OpponentLevel.intermediate => 'Intermediate',
    OpponentLevel.advanced => 'Advanced',
  };
}

enum PlayerPosition { goalkeeper, defender, midfielder, forward }

extension PlayerPositionX on PlayerPosition {
  String get label => switch (this) {
    PlayerPosition.goalkeeper => 'Goalkeeper',
    PlayerPosition.defender => 'Defender',
    PlayerPosition.midfielder => 'Midfielder',
    PlayerPosition.forward => 'Forward',
  };

  String get abbr => switch (this) {
    PlayerPosition.goalkeeper => 'GK',
    PlayerPosition.defender => 'DF',
    PlayerPosition.midfielder => 'MF',
    PlayerPosition.forward => 'FW',
  };

  /// Resolves a position from whatever the backend sends — a label
  /// (`Goalkeeper`), an abbreviation (`GK`) or a numeric/string id
  /// (`1`..`4`). Falls back to [PlayerPosition.midfielder] when unknown.
  static PlayerPosition fromAny(dynamic value) {
    if (value == null) return PlayerPosition.midfielder;
    final raw = value.toString().trim().toLowerCase();
    if (raw.isEmpty) return PlayerPosition.midfielder;
    for (final p in PlayerPosition.values) {
      if (raw == p.label.toLowerCase() ||
          raw == p.abbr.toLowerCase() ||
          raw == p.name.toLowerCase()) {
        return p;
      }
    }
    // Numeric ids, mirroring the label order: 1=GK, 2=DF, 3=MF, 4=FW.
    return switch (raw) {
      '1' => PlayerPosition.goalkeeper,
      '2' => PlayerPosition.defender,
      '3' => PlayerPosition.midfielder,
      '4' => PlayerPosition.forward,
      _ => PlayerPosition.midfielder,
    };
  }
}

/// A player position as served by `GET /positions`:
/// `{id: 1, title: Goalkeeper, slug: goalkeeper}` under `data.positions`.
class PlayerPositionModel {
  const PlayerPositionModel({
    required this.id,
    required this.name,
    this.slug = '',
  });

  final String id;

  /// Display name — the API's `title`.
  final String name;

  /// Stable machine key — the API's `slug` (e.g. `goalkeeper`).
  final String slug;

  factory PlayerPositionModel.fromJson(Map<String, dynamic> json) {
    return PlayerPositionModel(
      id: (json['id'] ?? json['position_id'] ?? '').toString(),
      name: (json['title'] ?? json['name'] ?? json['label'] ?? '')
          .toString()
          .trim(),
      slug: (json['slug'] ?? '').toString().trim(),
    );
  }

  /// Static fallback mirroring [PlayerPosition], used until (or in case)
  /// the API list arrives.
  static List<PlayerPositionModel> get defaults => PlayerPosition.values
      .map((p) => PlayerPositionModel(id: '', name: p.label, slug: p.name))
      .toList(growable: false);

  /// Name-based equality so a default selection still matches the API row
  /// that replaces it.
  @override
  bool operator ==(Object other) =>
      other is PlayerPositionModel &&
      other.name.toLowerCase() == name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}

/// An opponent level as served by `GET /opponent-levels` — same shape as
/// positions: `{id, title, slug}` under `data.opponent_levels`.
class OpponentLevelModel {
  const OpponentLevelModel({
    required this.id,
    required this.name,
    this.slug = '',
  });

  final String id;

  /// Display name — the API's `title`.
  final String name;

  /// Stable machine key — the API's `slug`.
  final String slug;

  factory OpponentLevelModel.fromJson(Map<String, dynamic> json) {
    return OpponentLevelModel(
      id: (json['id'] ?? json['level_id'] ?? '').toString(),
      name: (json['title'] ?? json['name'] ?? json['label'] ?? '')
          .toString()
          .trim(),
      slug: (json['slug'] ?? '').toString().trim(),
    );
  }

  /// Static fallback mirroring [OpponentLevel], used until (or in case)
  /// the API list arrives.
  static List<OpponentLevelModel> get defaults => OpponentLevel.values
      .map((l) => OpponentLevelModel(id: '', name: l.label, slug: l.name))
      .toList(growable: false);

  /// Name-based equality so a default selection still matches the API row
  /// that replaces it.
  @override
  bool operator ==(Object other) =>
      other is OpponentLevelModel &&
      other.name.toLowerCase() == name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}

/// Lifecycle of an opponent request.
enum RequestStatus {
  /// Started in the wizard but never published — the request only exists for
  /// its owner, who still has steps to finish.
  draft,

  /// Published by its owner and waiting on an admin review before it becomes
  /// visible to other teams.
  pendingApproval,
  fresh,
  pending,
  invitationSent,
  accepted,
  rejected,
  sent,
  expired,
  cancelled,
}

extension RequestStatusX on RequestStatus {
  String get label => switch (this) {
    RequestStatus.draft => 'Draft',
    RequestStatus.pendingApproval => 'Pending approval',
    RequestStatus.fresh => 'New',
    RequestStatus.pending => 'Pending',
    RequestStatus.invitationSent => 'Invitation sent',
    RequestStatus.accepted => 'Accepted',
    RequestStatus.rejected => 'Rejected',
    RequestStatus.sent => 'Sent',
    RequestStatus.expired => 'Expired',
    RequestStatus.cancelled => 'Cancelled',
  };

  /// Still actionable (can be accepted / rejected).
  bool get isOpen =>
      this == RequestStatus.fresh || this == RequestStatus.pending;

  /// A draft is neither actionable nor finished — it is still being written.
  bool get isDraft => this == RequestStatus.draft;

  /// Submitted and out of the owner's hands, but not live yet either.
  bool get isAwaitingApproval => this == RequestStatus.pendingApproval;

  /// Only a request that reached a final state is settled — a draft and a
  /// request under review are both still in flight.
  bool get isSettled => !isOpen && !isDraft && !isAwaitingApproval;

  /// Maps a wire status (`open | invitation_sent | accepted | declined |
  /// expired | cancelled`) onto the UI lifecycle. An `open`
  /// request is [sent] when it's mine, [fresh] while its accept deadline is
  /// still running, [pending] when the server gave no deadline, and shows as
  /// [expired] once the deadline has passed (until the server sweep catches
  /// up).
  static RequestStatus fromApi(
    dynamic raw, {
    required bool isMine,
    DateTime? acceptDeadline,
  }) {
    switch (raw?.toString().trim().toLowerCase() ?? '') {
      // Wizard-in-progress: `/auth/opponent-requests` returns these to their
      // owner only, and no other team can see or accept them.
      case 'draft':
        return RequestStatus.draft;
      // Published, waiting on the admin review that makes it public.
      case 'pending_approval':
      case 'under_review':
      case 'pending_review':
        return RequestStatus.pendingApproval;
      case 'open':
      case 'published':
        if (isMine) return RequestStatus.sent;
        if (acceptDeadline == null) return RequestStatus.pending;
        return acceptDeadline.isAfter(DateTime.now())
            ? RequestStatus.fresh
            : RequestStatus.expired;
      // An acceptance is in — the requester still has to pick an opponent.
      // The legacy payment-hold statuses map here too.
      case 'invitation_sent':
      case 'accept_pending_selection':
      case 'accept_pending_payment':
      case 'payment_pending':
        return RequestStatus.invitationSent;
      case 'accepted':
        return RequestStatus.accepted;
      case 'declined':
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
      case 'canceled':
        return RequestStatus.cancelled;
      case 'expired':
        return RequestStatus.expired;
      default:
        return isMine ? RequestStatus.sent : RequestStatus.pending;
    }
  }
}

/// Where an invitation (an opponent team's acceptance) stands while the
/// requester decides between the teams that replied.
enum InvitationStatus { pending, selected, rejected }

extension InvitationStatusX on InvitationStatus {
  String get label => switch (this) {
    InvitationStatus.pending => 'Awaiting your pick',
    InvitationStatus.selected => 'Selected',
    InvitationStatus.rejected => 'Auto-rejected',
  };

  static InvitationStatus fromApi(dynamic raw) =>
      switch (raw?.toString().trim().toLowerCase() ?? '') {
        'selected' || 'confirmed' || 'accepted' => InvitationStatus.selected,
        'rejected' ||
        'declined' ||
        'auto_rejected' => InvitationStatus.rejected,
        _ => InvitationStatus.pending,
      };
}

/// One opponent team's acceptance of my request. The requester reviews every
/// invitation and picks a single opponent; the rest are rejected by the server.
class OpponentInvitationModel {
  const OpponentInvitationModel({
    required this.id,
    required this.teamId,
    required this.teamName,
    this.status = InvitationStatus.pending,
    this.captainName = '',
    this.captainUserId = 0,
    this.playerCount = 0,
    this.share = 0,
    this.message = '',
    this.acceptedAt,
  });

  final String id;
  final String teamId;
  final String teamName;
  final InvitationStatus status;

  /// The accepting captain — chat target for the requester.
  final String captainName;
  final int captainUserId;

  /// Size of the accepting roster, when the API reports it.
  final int playerCount;

  /// What this team owes of the court fee.
  final int share;

  /// Optional note the accepting captain attached.
  final String message;
  final DateTime? acceptedAt;

  factory OpponentInvitationModel.fromJson(Map<String, dynamic> json) {
    final team = _asMap(json['team'] ?? json['accepted_by']);
    final captain = _asMap(json['captain'] ?? json['user']);
    return OpponentInvitationModel(
      id: (json['id'] ?? json['invitation_id'] ?? '').toString(),
      teamId: (json['team_id'] ?? team['id'] ?? team['team_id'] ?? '')
          .toString(),
      teamName: (json['team_name'] ?? team['name'] ?? team['team_name'] ?? '')
          .toString()
          .trim(),
      status: InvitationStatusX.fromApi(json['status']),
      captainName:
          (json['captain_name'] ??
                  captain['name'] ??
                  team['captain_name'] ??
                  '')
              .toString()
              .trim(),
      captainUserId: _asInt(
        json['user_id'] ??
            captain['id'] ??
            captain['user_id'] ??
            team['user_id'],
      ),
      playerCount: _asInt(
        json['player_count'] ?? json['members_count'] ?? team['player_count'],
      ),
      share: _asInt(json['share'] ?? json['accepter_share'] ?? json['amount']),
      message: (json['message'] ?? json['note'] ?? '').toString().trim(),
      acceptedAt: _asDate(json['accepted_at'] ?? json['created_at']),
    );
  }

  String get initials {
    final parts = teamName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }
}

/// How the court fee is divided between the two teams.
enum SplitMode { even, custom }

extension SplitModeX on SplitMode {
  String get label => switch (this) {
    SplitMode.even => 'Even',
    SplitMode.custom => 'Custom %',
  };
}

/// Basis for a custom split: a fixed team percentage or the match result.
enum SplitBasis { teams, result }

extension SplitBasisX on SplitBasis {
  String get label => switch (this) {
    SplitBasis.teams => 'By team',
    SplitBasis.result => 'By result',
  };
}

class PlayerModel {
  const PlayerModel({
    required this.name,
    required this.position,
    this.id = '',
    this.email = '',
    this.positionName = '',
    this.positionId = '',
  });

  /// Server-side team-member id (`teams/{team}/members/{member}`). Empty for
  /// players built locally before they round-trip through the backend.
  final String id;
  final String name;

  /// Contact address for the member, sent as `email`. Empty when the roster
  /// entry has none — the field is optional.
  final String email;

  final PlayerPosition position;

  /// Raw position name from the `/positions` API — this exact value is sent
  /// back when storing/updating the player. Falls back to [position]'s label
  /// when empty.
  final String positionName;

  /// The `/positions` row id, sent to the API as `position_id` when storing
  /// the player. Falls back to [position]'s 1-based id (1=GK … 4=FW) when
  /// empty.
  final String positionId;

  /// A team member as returned inside a team payload. Tolerant of the member's
  /// name living either directly on the row or nested under `user`.
  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final dynamic user = json['user'];
    final userMap = user is Map ? Map<String, dynamic>.from(user) : null;
    final name =
        (json['name'] ??
                json['member_name'] ??
                userMap?['name'] ??
                userMap?['full_name'] ??
                json['user_name'] ??
                '')
            .toString()
            .trim();

    // Like the name, the address may sit on the row or under the linked user.
    final email =
        (json['email'] ??
                json['member_email'] ??
                userMap?['email'] ??
                json['user_email'] ??
                '')
            .toString()
            .trim();

    final dynamic position = json['position'];
    final positionMap = position is Map
        ? Map<String, dynamic>.from(position)
        : null;
    final positionValue =
        positionMap?['title'] ??
        positionMap?['name'] ??
        positionMap?['label'] ??
        positionMap?['slug'] ??
        positionMap?['id'] ??
        json['position_name'] ??
        json['position_id'] ??
        position;

    return PlayerModel(
      id: (json['id'] ?? json['member_id'] ?? '').toString(),
      name: name,
      email: email,
      position: PlayerPositionX.fromAny(positionValue),
      positionName: positionValue is String ? positionValue.trim() : '',
      positionId: (positionMap?['id'] ?? json['position_id'] ?? '').toString(),
    );
  }
}

class TeamModel {
  const TeamModel({
    required this.id,
    required this.name,
    this.players = const [],
  });

  final String id;
  final String name;
  final List<PlayerModel> players;

  /// A team row from `GET /teams` (list) or `GET /teams/{team}` (single).
  /// Members may arrive under `members`, `players` or `team_members`.
  factory TeamModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawMembers =
        json['members'] ?? json['players'] ?? json['team_members'];
    final players = rawMembers is List
        ? rawMembers
              .whereType<Map>()
              .map((m) => PlayerModel.fromJson(Map<String, dynamic>.from(m)))
              .where((p) => p.name.isNotEmpty)
              .toList(growable: false)
        : const <PlayerModel>[];
    return TeamModel(
      id: (json['id'] ?? json['team_id'] ?? '').toString(),
      name: (json['name'] ?? json['team_name'] ?? json['title'] ?? '')
          .toString()
          .trim(),
      players: players,
    );
  }

  TeamModel copyWith({String? name, List<PlayerModel>? players}) => TeamModel(
    id: id,
    name: name ?? this.name,
    players: players ?? this.players,
  );

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  /// `2 FW · 1 GK` — roster mix in position order, skipping empty positions.
  String get positionSummary {
    final buf = <String>[];
    for (final p in PlayerPosition.values) {
      final n = players.where((player) => player.position == p).length;
      if (n > 0) buf.add('$n ${p.abbr}');
    }
    return buf.join(' · ');
  }
}

class OpponentRequestModel {
  const OpponentRequestModel({
    required this.id,
    required this.team,
    required this.dateTime,
    required this.summary,
    required this.status,
    required this.venue,
    required this.slot,
    required this.totalFee,
    required this.yourShare,
    this.myPct,
    this.createdAt,
    this.requesterUserId = 0,
    this.requesterName = '',
    this.requesterTeamId = '',
    this.isMine = false,
    this.acceptDeadline,
    this.acceptedByTeamId = '',
    this.acceptedByTeamName = '',
    this.acceptedByUserId = 0,
    this.invitations = const <OpponentInvitationModel>[],
    this.mainStep = 0,
    this.subStep = 0,
    this.pendingInvitationCount = 0,
    this.totalInvitationCount = 0,
    this.matchFormatId = '',
    this.opponentLevelId = '',
    this.message = '',
    this.venueSource = '',
    this.venueName = '',
    this.venueCourtName = '',
    this.venueAddress = '',
    this.venueBookingId = '',
    this.venueBooking = const <String, dynamic>{},
    this.preferredDateTime,
    this.venueStartTime,
    this.venueEndTime,
    this.perPlayerAmount = 0,
    this.splitType = '',
    this.splitBasis = '',
    this.requestingTeamPercent = 0,
  });

  final String id;
  final String team;

  /// Scheduled match date + kickoff time.
  final DateTime dateTime;

  /// One-line context shown under the team name (level, format, split…).
  final String summary;
  final RequestStatus status;
  final String venue;
  final String slot;
  final int totalFee;
  final int yourShare;

  /// Your side's percentage; null when the split is result-based.
  final int? myPct;

  final DateTime? createdAt;

  /// The user who posted the request — chat target for incoming requests.
  final int requesterUserId;
  final String requesterName;
  final String requesterTeamId;

  /// True when the current user posted this request.
  final bool isMine;

  /// Server-owned accept window; drives the countdown on `fresh` requests.
  final DateTime? acceptDeadline;

  /// Set once a team has accepted (before the requester picks an opponent
  /// this is simply the latest acceptance).
  final String acceptedByTeamId;
  final String acceptedByTeamName;

  /// The accepting captain's user id — chat target for the requester.
  final int acceptedByUserId;

  /// Every opponent team that accepted this request. The API sends the list
  /// once it supports competing acceptances; until then it carries the single
  /// `accepted_by` team (see [_invitationsFrom]) so the review UI works either
  /// way.
  final List<OpponentInvitationModel> invitations;

  /// How far the create wizard got on a [RequestStatus.draft] row —
  /// `main_step`/`sub_step` as the backend counts them. 0 when unknown.
  final int mainStep;
  final int subStep;

  /// Server ids behind the match section, so resuming a draft in the wizard
  /// can re-select exactly what was saved instead of guessing from labels.
  final String matchFormatId;
  final String opponentLevelId;

  /// `per_player_amount` — what each player on my side owes, as the server
  /// worked it out from the roster snapshot. 0 until the cost step has run.
  final int perPlayerAmount;

  /// The `cost` block's own fields — `split_type` (`even` | `custom`),
  /// `split_basis` (`team` | `result`) and `requesting_team_percent` — kept raw
  /// so the wizard can restore the exact rule a draft saved. Empty/0 until the
  /// cost step has run.
  final String splitType;
  final String splitBasis;
  final int requestingTeamPercent;

  /// `preferred_date` + `preferred_time` exactly as the match step saved them.
  /// Kept apart from [dateTime], which prefers the settled court's slot — the
  /// wizard's step-one pickers must show what was submitted, not the booking.
  final DateTime? preferredDateTime;

  /// The note the requester attached, as `message`. Empty when unset.
  final String message;

  /// The venue block's own fields, kept alongside the flattened [venue] label
  /// so the wizard can re-select what a draft's venue step saved:
  /// `venue_source` (`booking` | `external` | …) plus the parts an externally
  /// booked court is described by. [totalFee] carries `fee_amount`.
  final String venueSource;
  final String venueName;
  final String venueCourtName;
  final String venueAddress;

  /// The booked window the venue step saved, as the API's `HH:mm(:ss)` strings.
  /// Null when the venue step has not run.
  final String? venueStartTime;
  final String? venueEndTime;

  /// Set when the venue is a booking made on this platform.
  final String venueBookingId;

  /// The whole nested `venue.booking` payload, untouched. `booking`-sourced
  /// venues arrive as a full booking rather than an id, and it parses straight
  /// into a `BookingModel` — which is what lets the wizard re-select the
  /// booking behind a resumed draft.
  final Map<String, dynamic> venueBooking;

  /// `invitations_summary` counts. The list endpoint reports only these
  /// numbers, so they stand in for [invitations] on the cards.
  final int pendingInvitationCount;
  final int totalInvitationCount;

  /// Invitation count to show: the objects when the payload carried them,
  /// otherwise the summary the list endpoint sends.
  int get invitationCount => invitations.isNotEmpty
      ? invitations.length
      : (totalInvitationCount > 0
            ? totalInvitationCount
            : pendingInvitationCount);

  /// Invitations still waiting on the requester's pick.
  List<OpponentInvitationModel> get pendingInvitations => invitations
      .where((i) => i.status == InvitationStatus.pending)
      .toList(growable: false);

  /// The team the requester picked, when the choice has been made.
  OpponentInvitationModel? get selectedInvitation {
    for (final i in invitations) {
      if (i.status == InvitationStatus.selected) return i;
    }
    return null;
  }

  /// True once the match is locked in: an opponent is confirmed and the venue
  /// is linked to the request.
  bool get isMatchConfirmed => status == RequestStatus.accepted;

  /// A request row from `GET /opponent-requests` or
  /// `GET /auth/opponent-requests?tab=all`. Tolerant of three payload shapes:
  /// flat, the public list's nested `requester`/`match`/`pricing`, and the
  /// authenticated list's `team`/`match_format`/`opponent_level`/`venue`
  /// (which carries drafts, hence `preferred_date`/`preferred_time` and
  /// `main_step`/`sub_step`).
  factory OpponentRequestModel.fromJson(Map<String, dynamic> json) {
    final requester = _asMap(json['requester']);
    final ownTeam = _asMap(json['team']);
    final matchFormat = _asMap(json['match_format']);
    final opponentLevel = _asMap(json['opponent_level']);
    final venueBlock = _asMap(json['venue']);
    // A `booking`-sourced venue describes itself through the nested booking; an
    // `external` one carries the same facts as flat keys. Read both.
    final costBlock = _asMap(json['cost']);
    final venueBooking = _asMap(venueBlock['booking']);
    final bookingVenue = _asMap(venueBooking['venue']);
    final bookingCourt = _asMap(venueBooking['court']);
    final String venueNameValue =
        (venueBlock['venue_name'] ?? bookingVenue['name'] ?? '')
            .toString()
            .trim();
    final String courtNameValue =
        (venueBlock['court_name'] ?? bookingCourt['name'] ?? '')
            .toString()
            .trim();
    final String venueAddressValue =
        (venueBlock['address'] ?? bookingVenue['address'] ?? '')
            .toString()
            .trim();
    final String venueDateValue =
        (venueBlock['date'] ?? venueBooking['booking_date'] ?? '').toString();
    final String venueStartValue =
        (venueBlock['start_time'] ?? venueBooking['start_time'] ?? '')
            .toString();
    final String venueEndValue =
        (venueBlock['end_time'] ?? venueBooking['end_time'] ?? '').toString();
    final dynamic venueFeeValue =
        venueBlock['fee_amount'] ??
        venueBooking['total_amount'] ??
        venueBooking['subtotal'];
    final acceptedBy = _asMap(json['accepted_by']);
    final invitationsSummary = _asMap(json['invitations_summary']);

    // `match`/`pricing` are the public list's nesting; the authenticated list
    // spreads the same values across the blocks read above, so each falls back
    // onto its counterpart.
    final match = _asMap(json['match']).isNotEmpty
        ? _asMap(json['match'])
        : <String, dynamic>{
            // The settled court wins over the preferred slot: once a venue is
            // attached, that booking is when the match is actually played.
            'date': venueDateValue.isNotEmpty
                ? venueDateValue
                : json['preferred_date'],
            'start_time': venueStartValue.isNotEmpty
                ? venueStartValue
                : json['preferred_time'],
            'end_time': venueEndValue,
            'venue_name': [
              venueNameValue,
              courtNameValue,
            ].where((s) => s.isNotEmpty).join(' · '),
            'format': matchFormat['name'] ?? matchFormat['title'],
            'level': opponentLevel['title'] ?? opponentLevel['name'],
          };
    // The authenticated list nests the money under `cost`, with its own key
    // names; translate them onto the public list's `pricing` shape so the share
    // maths below has one input. `court_fee_amount` is authoritative when the
    // cost step has run — it is the fee the split was actually computed from.
    final pricing = _asMap(json['pricing']).isNotEmpty
        ? _asMap(json['pricing'])
        : <String, dynamic>{
            'total_fee': costBlock['court_fee_amount'] ?? venueFeeValue,
            'split_mode': costBlock['split_type'],
            'requester_pct': costBlock['requesting_team_percent'],
            'accepter_pct': costBlock['opponent_team_percent'],
            'requester_share': costBlock['requesting_team_amount'],
            'accepter_share': costBlock['opponent_team_amount'],
          };

    final bool isMine = json['is_mine'] == true || json['isMine'] == true;
    final DateTime? acceptDeadline = _asDate(
      json['accept_deadline'] ?? json['acceptDeadline'],
    );

    final String startTime = (match['start_time'] ?? '').toString().trim();
    final String endTime = (match['end_time'] ?? '').toString().trim();
    final DateTime dateTime =
        _asDate('${match['date'] ?? ''} $startTime'.trim()) ??
        _asDate(json['date_time'] ?? json['dateTime']) ??
        DateTime.now();

    final String slot = [
      _displayTime(startTime),
      _displayTime(endTime),
    ].where((s) => s.isNotEmpty).join(' – ');

    // A result-keyed split has no fixed percentage per side. The public list
    // says so with `split_mode: custom_result`; the authenticated one with
    // `split_basis: result`.
    final String splitMode = (pricing['split_mode'] ?? '').toString();
    final bool isResultSplit =
        splitMode == 'custom_result' ||
        (costBlock['split_basis'] ?? '').toString().toLowerCase() == 'result';
    final int totalFee = _asInt(pricing['total_fee'] ?? json['total_fee']);
    final int accepterShare = _asInt(
      pricing['accepter_share'] ?? json['your_share'],
    );
    final int requesterPct = _asInt(pricing['requester_pct']);
    final int accepterPct = _asInt(pricing['accepter_pct']);

    // "Your" side of the money depends on which side of the request you're on.
    // The server's own amounts win over percentage maths when it sent them.
    final int requesterShare = _asInt(pricing['requester_share']);
    final int yourShare = isMine
        ? (isResultSplit
              ? 0
              : (requesterShare > 0
                    ? requesterShare
                    : (totalFee * requesterPct / 100).round()))
        : accepterShare;
    final int? myPct = isResultSplit
        ? null
        : (isMine ? requesterPct : accepterPct);

    final String summary = (json['summary'] ?? '').toString().trim().isNotEmpty
        ? json['summary'].toString().trim()
        : [
            (match['level'] ?? '').toString().trim(),
            (match['format'] ?? '').toString().trim(),
          ].where((s) => s.isNotEmpty).join(' · ');

    return OpponentRequestModel(
      id: (json['id'] ?? '').toString(),
      team:
          (requester['team_name'] ??
                  ownTeam['name'] ??
                  json['team_name'] ??
                  (json['team'] is String ? json['team'] : null) ??
                  '')
              .toString()
              .trim(),
      dateTime: dateTime,
      summary: summary,
      status: RequestStatusX.fromApi(
        json['status'],
        isMine: isMine,
        acceptDeadline: acceptDeadline,
      ),
      venue: (match['venue_name'] ?? json['venue'] ?? '').toString().trim(),
      slot: slot.isEmpty ? (json['slot'] ?? '').toString() : slot,
      totalFee: totalFee,
      yourShare: yourShare,
      myPct: myPct,
      createdAt: _asDate(json['created_at'] ?? json['createdAt']),
      requesterUserId: _asInt(requester['user_id']),
      requesterName: (requester['name'] ?? '').toString().trim(),
      requesterTeamId: (requester['team_id'] ?? ownTeam['id'] ?? '').toString(),
      isMine: isMine,
      acceptDeadline: acceptDeadline,
      acceptedByTeamId: (acceptedBy['team_id'] ?? '').toString(),
      acceptedByTeamName: (acceptedBy['team_name'] ?? '').toString().trim(),
      acceptedByUserId: _asInt(acceptedBy['user_id']),
      invitations: _invitationsFrom(json, acceptedBy, accepterShare),
      mainStep: _asInt(json['main_step']),
      subStep: _asInt(json['sub_step']),
      pendingInvitationCount: _asInt(invitationsSummary['pending_count']),
      totalInvitationCount: _asInt(invitationsSummary['total_count']),
      matchFormatId: (matchFormat['id'] ?? json['match_format_id'] ?? '')
          .toString(),
      opponentLevelId: (opponentLevel['id'] ?? json['opponent_level_id'] ?? '')
          .toString(),
      message: (json['message'] ?? '').toString().trim(),
      venueSource: (venueBlock['source'] ?? venueBlock['venue_source'] ?? '')
          .toString()
          .trim(),
      venueName: venueNameValue,
      venueCourtName: courtNameValue,
      venueAddress: venueAddressValue,
      venueBookingId: (venueBlock['booking_id'] ?? venueBooking['id'] ?? '')
          .toString(),
      venueBooking: venueBooking,
      preferredDateTime: _asDate(
        '${json['preferred_date'] ?? ''} ${json['preferred_time'] ?? ''}'
            .trim(),
      ),
      venueStartTime: venueStartValue.isEmpty ? null : venueStartValue,
      venueEndTime: venueEndValue.isEmpty ? null : venueEndValue,
      perPlayerAmount: _asInt(costBlock['per_player_amount']),
      splitType: (costBlock['split_type'] ?? costBlock['split_mode'] ?? '')
          .toString()
          .trim(),
      splitBasis: (costBlock['split_basis'] ?? costBlock['basis'] ?? '')
          .toString()
          .trim(),
      requestingTeamPercent: _asInt(
        costBlock['requesting_team_percent'] ?? costBlock['requester_pct'],
      ),
    );
  }

  /// Reads the competing acceptances. When the payload only carries a single
  /// `accepted_by` team, that team becomes the one invitation — already
  /// `selected` on an accepted request, still `pending` while the requester
  /// has not chosen yet.
  static List<OpponentInvitationModel> _invitationsFrom(
    Map<String, dynamic> json,
    Map<String, dynamic> acceptedBy,
    int accepterShare,
  ) {
    final dynamic raw =
        json['invitations'] ?? json['acceptances'] ?? json['accepted_teams'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .whereType<Map>()
          .map(
            (m) =>
                OpponentInvitationModel.fromJson(Map<String, dynamic>.from(m)),
          )
          .where((i) => i.teamName.isNotEmpty || i.teamId.isNotEmpty)
          .toList(growable: false);
    }
    if (acceptedBy.isEmpty) return const <OpponentInvitationModel>[];
    final String status = (json['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return <OpponentInvitationModel>[
      OpponentInvitationModel(
        id: (acceptedBy['team_id'] ?? '').toString(),
        teamId: (acceptedBy['team_id'] ?? '').toString(),
        teamName: (acceptedBy['team_name'] ?? '').toString().trim(),
        status: status == 'accepted'
            ? InvitationStatus.selected
            : InvitationStatus.pending,
        captainName: (acceptedBy['name'] ?? '').toString().trim(),
        captainUserId: _asInt(acceptedBy['user_id']),
        playerCount: _asInt(acceptedBy['player_count']),
        share: accepterShare,
        acceptedAt: _asDate(acceptedBy['accepted_at']),
      ),
    ];
  }

  OpponentRequestModel copyWith({
    RequestStatus? status,
    List<OpponentInvitationModel>? invitations,
  }) => OpponentRequestModel(
    id: id,
    team: team,
    dateTime: dateTime,
    summary: summary,
    status: status ?? this.status,
    venue: venue,
    slot: slot,
    totalFee: totalFee,
    yourShare: yourShare,
    myPct: myPct,
    createdAt: createdAt,
    requesterUserId: requesterUserId,
    requesterName: requesterName,
    requesterTeamId: requesterTeamId,
    isMine: isMine,
    acceptDeadline: acceptDeadline,
    acceptedByTeamId: acceptedByTeamId,
    acceptedByTeamName: acceptedByTeamName,
    acceptedByUserId: acceptedByUserId,
    invitations: invitations ?? this.invitations,
    mainStep: mainStep,
    subStep: subStep,
    pendingInvitationCount: pendingInvitationCount,
    totalInvitationCount: totalInvitationCount,
    matchFormatId: matchFormatId,
    opponentLevelId: opponentLevelId,
    message: message,
    venueSource: venueSource,
    venueName: venueName,
    venueCourtName: venueCourtName,
    venueAddress: venueAddress,
    venueBookingId: venueBookingId,
    venueBooking: venueBooking,
    preferredDateTime: preferredDateTime,
    venueStartTime: venueStartTime,
    venueEndTime: venueEndTime,
    perPlayerAmount: perPlayerAmount,
    splitType: splitType,
    splitBasis: splitBasis,
    requestingTeamPercent: requestingTeamPercent,
  );

  String get initials {
    final parts = team
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
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

DateTime? _asDate(dynamic value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toLocal();
}

/// `18:00` → `6:00 PM`; returns the input when it isn't `HH:mm`.
String _displayTime(String raw) {
  final parts = raw.split(':');
  if (parts.length < 2) return raw;
  final hour = int.tryParse(parts[0]);
  final minuteStr = parts[1].length > 2 ? parts[1].substring(0, 2) : parts[1];
  final minute = int.tryParse(minuteStr);
  if (hour == null || minute == null) return raw;
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  final period = hour < 12 ? 'AM' : 'PM';
  return '$h12:${minute.toString().padLeft(2, '0')} $period';
}
