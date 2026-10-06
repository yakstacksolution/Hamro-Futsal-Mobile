enum MatchFormat { fiveASide, sixASide, sevenASide }

extension MatchFormatX on MatchFormat {
  String get label => switch (this) {
    MatchFormat.fiveASide => '5v5',
    MatchFormat.sixASide => '6v6',
    MatchFormat.sevenASide => '7v7',
  };

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

class PlayerPositionModel {
  const PlayerPositionModel({
    required this.id,
    required this.name,
    this.slug = '',
  });

  final String id;

  final String name;

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

  static List<PlayerPositionModel> get defaults => PlayerPosition.values
      .map((p) => PlayerPositionModel(id: '', name: p.label, slug: p.name))
      .toList(growable: false);

  @override
  bool operator ==(Object other) =>
      other is PlayerPositionModel &&
      other.name.toLowerCase() == name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}

class OpponentLevelModel {
  const OpponentLevelModel({
    required this.id,
    required this.name,
    this.slug = '',
  });

  final String id;

  final String name;

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

  static List<OpponentLevelModel> get defaults => OpponentLevel.values
      .map((l) => OpponentLevelModel(id: '', name: l.label, slug: l.name))
      .toList(growable: false);

  @override
  bool operator ==(Object other) =>
      other is OpponentLevelModel &&
      other.name.toLowerCase() == name.toLowerCase();

  @override
  int get hashCode => name.toLowerCase().hashCode;
}

enum RequestStatus {
  draft,

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

  bool get isOpen =>
      this == RequestStatus.fresh || this == RequestStatus.pending;

  bool get isDraft => this == RequestStatus.draft;

  bool get isAwaitingApproval => this == RequestStatus.pendingApproval;

  bool get isSettled => !isOpen && !isDraft && !isAwaitingApproval;

  static RequestStatus fromApi(
    dynamic raw, {
    required bool isMine,
    DateTime? acceptDeadline,
    bool? serverExpired,
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
      // The `my_requests` display bucket for a live request: published and
      // collecting invitations. Same lifecycle position as `published`.
      case 'invite':
      case 'inviting':
        // A request of mine whose window has run out is closed, not still
        // waiting — otherwise it keeps offering "Invitations" and "Remove" on
        // a row nobody can act on any more.
        if (isMine) {
          if (serverExpired == true) return RequestStatus.expired;
          if (acceptDeadline != null &&
              !acceptDeadline.isAfter(DateTime.now())) {
            return RequestStatus.expired;
          }
          return RequestStatus.sent;
        }
        // `countdown.is_expired` is the server's own verdict — trust it over a
        // comparison against a device clock that may be minutes out.
        if (serverExpired == true) return RequestStatus.expired;
        if (acceptDeadline == null) {
          return serverExpired == false
              ? RequestStatus.fresh
              : RequestStatus.pending;
        }
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
      // The opponent is locked in and the match exists. `matched` is the
      // lifecycle name; `settled` is the display bucket the tabbed list uses
      // for the same thing.
      case 'accepted':
      case 'matched':
      case 'settled':
        return RequestStatus.accepted;
      case 'declined':
      case 'rejected':
        return RequestStatus.rejected;
      case 'cancelled':
      case 'canceled':
        return RequestStatus.cancelled;
      // `closed` is how the authenticated list reports a request that is over
      // — its window ran out or the owner shut it. Nothing can act on it, so
      // it shares the terminal state the badges render as "Closed".
      case 'closed':
      case 'completed':
        return RequestStatus.expired;
      case 'expired':
        return RequestStatus.expired;
      default:
        return isMine ? RequestStatus.sent : RequestStatus.pending;
    }
  }
}

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
    this.respondedAt,
  });

  final String id;
  final String teamId;
  final String teamName;
  final InvitationStatus status;

  final String captainName;
  final int captainUserId;

  final int playerCount;

  final int share;

  final String message;
  final DateTime? acceptedAt;

  final DateTime? respondedAt;

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
      // `/invitations` names the accepting captain `invitation_sender_id` and
      // sends no captain block — without it the requester has no one to open a
      // chat with and the message actions stay hidden.
      captainUserId: _asInt(
        json['user_id'] ??
            captain['id'] ??
            captain['user_id'] ??
            json['invitation_sender_id'] ??
            json['sender_id'] ??
            team['user_id'],
      ),
      playerCount: _asInt(
        json['player_count'] ?? json['members_count'] ?? team['player_count'],
      ),
      share: _asInt(json['share'] ?? json['accepter_share'] ?? json['amount']),
      message: (json['message'] ?? json['note'] ?? '').toString().trim(),
      acceptedAt: _asDate(json['accepted_at'] ?? json['created_at']),
      respondedAt: _asDate(json['responded_at']),
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

enum SplitMode { even, custom }

extension SplitModeX on SplitMode {
  String get label => switch (this) {
    SplitMode.even => 'Even',
    SplitMode.custom => 'Custom %',
  };
}

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

  final String id;
  final String name;

  final String email;

  final PlayerPosition position;

  final String positionName;

  final String positionId;

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
    this.conversationId = '',
    this.serverStatusLabel = '',
    this.venueBooking = const <String, dynamic>{},
    this.preferredDateTime,
    this.venueStartTime,
    this.venueEndTime,
    this.perPlayerAmount = 0,
    this.splitType = '',
    this.splitBasis = '',
    this.requestingTeamPercent = 0,
    this.costType = '',
    this.acceptRemaining,
    this.acceptExpired,
    this.loserPayPercent,
    this.winnerPayPercent,
    this.loserPayAmount,
    this.winnerPayAmount,
  });

  final String id;
  final String team;

  final DateTime dateTime;

  final String summary;
  final RequestStatus status;
  final String venue;
  final String slot;
  final int totalFee;
  final int yourShare;

  final int? myPct;

  final DateTime? createdAt;

  final int requesterUserId;
  final String requesterName;
  final String requesterTeamId;

  final bool isMine;

  final DateTime? acceptDeadline;

  final String acceptedByTeamId;
  final String acceptedByTeamName;

  final int acceptedByUserId;

  final List<OpponentInvitationModel> invitations;

  final int mainStep;
  final int subStep;

  final String matchFormatId;
  final String opponentLevelId;

  final int perPlayerAmount;

  final String splitType;
  final String splitBasis;
  final int requestingTeamPercent;

  final DateTime? preferredDateTime;

  final String message;

  final String venueSource;
  final String venueName;
  final String venueCourtName;
  final String venueAddress;

  final String? venueStartTime;
  final String? venueEndTime;

  final String venueBookingId;

  final String conversationId;

  final String serverStatusLabel;

  final Map<String, dynamic> venueBooking;

  final Duration? acceptRemaining;

  final bool? acceptExpired;

  Duration get remainingToAccept {
    if (acceptExpired == true) return Duration.zero;
    final DateTime? deadline = acceptDeadline;
    if (deadline != null) {
      final Duration left = deadline.difference(DateTime.now());
      return left.isNegative ? Duration.zero : left;
    }
    return acceptRemaining ?? Duration.zero;
  }

  bool get hasAcceptWindowClosed =>
      acceptExpired ??
      ((acceptDeadline != null || acceptRemaining != null) &&
          remainingToAccept == Duration.zero);

  final String costType;

  final int? loserPayPercent;
  final int? winnerPayPercent;
  final int? loserPayAmount;
  final int? winnerPayAmount;

  bool get isResultCost =>
      costType.toLowerCase() == 'result' ||
      splitBasis.toLowerCase() == 'result';

  int? get resolvedLoserPercent {
    if (loserPayPercent != null && loserPayPercent! > 0) return loserPayPercent;
    if (!isResultCost) return null;
    return requestingTeamPercent > 0 ? requestingTeamPercent : null;
  }

  int? get resolvedWinnerPercent {
    if (winnerPayPercent != null && winnerPayPercent! > 0) {
      return winnerPayPercent;
    }
    final int? loser = resolvedLoserPercent;
    return loser == null ? null : 100 - loser;
  }

  int? get resolvedLoserAmount {
    if (loserPayAmount != null && loserPayAmount! > 0) return loserPayAmount;
    final int? pct = resolvedLoserPercent;
    if (pct == null || totalFee <= 0) return null;
    return (totalFee * pct / 100).round();
  }

  int? get resolvedWinnerAmount {
    if (winnerPayAmount != null && winnerPayAmount! > 0) return winnerPayAmount;
    final int? loser = resolvedLoserAmount;
    return loser == null ? null : totalFee - loser;
  }

  OpponentBookingPayment? get bookingPayment => venueBooking.isEmpty
      ? null
      : OpponentBookingPayment.fromBooking(venueBooking);

  final int pendingInvitationCount;
  final int totalInvitationCount;

  int get invitationCount => invitations.isNotEmpty
      ? invitations.length
      : (totalInvitationCount > 0
            ? totalInvitationCount
            : pendingInvitationCount);

  List<OpponentInvitationModel> get pendingInvitations => invitations
      .where((i) => i.status == InvitationStatus.pending)
      .toList(growable: false);

  OpponentInvitationModel? get selectedInvitation {
    for (final i in invitations) {
      if (i.status == InvitationStatus.selected) return i;
    }
    return null;
  }

  bool get isMatchConfirmed => status == RequestStatus.accepted;

  String get statusBadgeLabel {
    if (serverStatusLabel.isEmpty) return status.label;
    return serverStatusLabel[0].toUpperCase() + serverStatusLabel.substring(1);
  }

  factory OpponentRequestModel.fromJson(Map<String, dynamic> json) {
    // The authenticated list names the captain who opened the request
    // `opponent_requester` ({id, name}); the public list and the detail
    // endpoint call the same block `requester`. Read either — this is the
    // person the accepting side chats with, so losing it hides the chat action.
    final requester = _asMap(json['opponent_requester']).isNotEmpty
        ? _asMap(json['opponent_requester'])
        : _asMap(json['requester']);
    final ownTeam = _asMap(json['team']);
    final matchFormat = _asMap(json['match_format']);
    final opponentLevel = _asMap(json['opponent_level']);
    final venueBlock = _asMap(json['venue']);
    // A `booking`-sourced venue describes itself through the nested booking; an
    // `external` one carries the same facts as flat keys. Read both.
    final costBlock = _asMap(json['cost']);
    final listDisplay = _asMap(costBlock['list_display']);
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
    // The authenticated list names the winning side `accepted_team`; the
    // public list and the detail endpoint call it `accepted_by`. Read either,
    // otherwise a `settled` row loses its opponent name and chat target.
    final acceptedBy = _asMap(json['accepted_by']).isNotEmpty
        ? _asMap(json['accepted_by'])
        : _asMap(json['accepted_team']);
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
            // Before a venue is attached the request still states the window
            // it wants, so the slot line reads "6:00 PM – 7:00 PM" instead of
            // just a start time.
            'end_time': venueEndValue.isNotEmpty
                ? venueEndValue
                : json['preferred_end_time'],
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
            'total_fee':
                listDisplay['total_amount'] ??
                costBlock['court_fee_amount'] ??
                venueFeeValue,
            'split_mode': costBlock['split_type'],
            'requester_pct': costBlock['requesting_team_percent'],
            'accepter_pct': costBlock['opponent_team_percent'],
            'requester_share': costBlock['requesting_team_amount'],
            'accepter_share': costBlock['opponent_team_amount'],
          };

    final bool isMine = json['is_mine'] == true || json['isMine'] == true;
    // The authenticated list calls the accept window `expires_at`; the public
    // list calls it `accept_deadline`. Without it a live request never shows
    // its countdown and never reads as expired until the server sweeps it.
    // `countdown` is the block the server built for exactly this: the moment
    // acceptance closes, whether it already has, and how long is left by its
    // own clock. `expires_at` stays the last resort — on this payload it is the
    // kickoff, an hour past the accept window.
    final countdown = _asMap(json['countdown']);
    final DateTime? acceptDeadline = _asDate(
      countdown['accept_until_at'] ??
          json['accept_until_at'] ??
          json['accept_deadline'] ??
          json['acceptDeadline'] ??
          json['expires_at'],
    );
    final bool? serverExpired = countdown['is_expired'] is bool
        ? countdown['is_expired'] as bool
        : null;
    // Fractional seconds arrive here (60943.046504), and a negative or absent
    // value is no countdown at all rather than a zero-length one.
    final num? remainingRaw = countdown['remaining_seconds'] is num
        ? countdown['remaining_seconds'] as num
        : num.tryParse((countdown['remaining_seconds'] ?? '').toString());
    final Duration? acceptRemaining = remainingRaw == null
        ? null
        : Duration(seconds: remainingRaw.floor().clamp(0, 1 << 31));

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
        (costBlock['split_basis'] ?? '').toString().toLowerCase() == 'result' ||
        (costBlock['cost_type'] ?? '').toString().toLowerCase() == 'result' ||
        (listDisplay['type'] ?? '').toString().toLowerCase() == 'result';
    final int totalFee = _asInt(pricing['total_fee'] ?? json['total_fee']);
    final int accepterShareRaw = _asInt(
      pricing['accepter_share'] ?? json['your_share'],
    );
    final int requesterPct = _asInt(pricing['requester_pct']);
    final int accepterPct = _asInt(pricing['accepter_pct']);

    // "Your" side of the money depends on which side of the request you're on.
    // The server's own amounts win over percentage maths when it sent them.
    final int requesterShare = _asInt(pricing['requester_share']);
    // `cost.opponent_team_amount` is null until the server has a roster to
    // divide by, while the percentages are set as soon as the cost step runs.
    // Fall back to the percentage so an incoming request still shows what the
    // accepting side would owe instead of Rs 0.
    final int accepterShare = accepterShareRaw > 0
        ? accepterShareRaw
        : (isResultSplit ? 0 : (totalFee * accepterPct / 100).round());
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
      // `raw_status` is the lifecycle; `status` is the coarser display bucket
      // the tabbed list sends beside it. Read the precise one when it is there.
      status: RequestStatusX.fromApi(
        json['raw_status'] ?? json['status'],
        isMine: isMine,
        acceptDeadline: acceptDeadline,
        serverExpired: serverExpired,
      ),
      venue: (match['venue_name'] ?? json['venue'] ?? '').toString().trim(),
      slot: slot.isEmpty ? (json['slot'] ?? '').toString() : slot,
      totalFee: totalFee,
      yourShare: yourShare,
      myPct: myPct,
      createdAt: _asDate(json['created_at'] ?? json['createdAt']),
      // The authenticated list sends no `requester` block; the person who booked
      // the court is that same requester, so the linked booking identifies them
      // when nothing else does. Without this the chat action has no one to open
      // a conversation with and stays hidden.
      requesterUserId: _asInt(
        // `opponent_requester` keys the captain as `id`; the older block used
        // `user_id`. The linked booking's owner is the same person, and stays
        // the last resort for a payload that carries no requester block at all.
        requester['user_id'] ??
            requester['id'] ??
            json['user_id'] ??
            venueBooking['user_id'],
      ),
      requesterName:
          (requester['name'] ??
                  venueBooking['customer_name'] ??
                  ownTeam['name'] ??
                  '')
              .toString()
              .trim(),
      requesterTeamId: (requester['team_id'] ?? ownTeam['id'] ?? '').toString(),
      isMine: isMine,
      acceptDeadline: acceptDeadline,
      // `accepted_team` on the tabbed list keys the winning side as
      // {id, name, roster_size}; `accepted_by` elsewhere uses team_id/team_name.
      acceptedByTeamId: (acceptedBy['team_id'] ?? acceptedBy['id'] ?? '')
          .toString(),
      acceptedByTeamName: (acceptedBy['team_name'] ?? acceptedBy['name'] ?? '')
          .toString()
          .trim(),
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
      conversationId: (json['conversation_id'] ?? json['conversationId'] ?? '')
          .toString()
          .trim(),
      serverStatusLabel: (json['status_label'] ?? '').toString().trim(),
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
      // A result-keyed split reports the two sides instead of a requester
      // share, so read the loser's percentage — that is what the slider holds.
      requestingTeamPercent: _asInt(
        costBlock['loser_pay_percent'] ??
            costBlock['requesting_team_percent'] ??
            costBlock['requester_pct'],
      ),
      costType: (costBlock['cost_type'] ?? listDisplay['type'] ?? '')
          .toString()
          .trim(),
      acceptRemaining: acceptRemaining,
      acceptExpired: serverExpired,
      // `list_display` is the block the server built for exactly this — the
      // cards — so it wins over the raw cost fields beside it.
      loserPayPercent: _asIntOrNull(
        listDisplay['loser_pay_percent'] ?? costBlock['loser_pay_percent'],
      ),
      winnerPayPercent: _asIntOrNull(
        listDisplay['winner_pay_percent'] ?? costBlock['winner_pay_percent'],
      ),
      loserPayAmount: _asIntOrNull(
        listDisplay['loser_pay_amount'] ?? costBlock['loser_pay_amount'],
      ),
      winnerPayAmount: _asIntOrNull(
        listDisplay['winner_pay_amount'] ?? costBlock['winner_pay_amount'],
      ),
    );
  }

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
    final String status = (json['raw_status'] ?? json['status'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    return <OpponentInvitationModel>[
      OpponentInvitationModel(
        id: (acceptedBy['team_id'] ?? acceptedBy['id'] ?? '').toString(),
        teamId: (acceptedBy['team_id'] ?? acceptedBy['id'] ?? '').toString(),
        teamName: (acceptedBy['team_name'] ?? acceptedBy['name'] ?? '')
            .toString()
            .trim(),
        // A row that carries an `accepted_team` has had its opponent chosen,
        // whichever vocabulary said so.
        status:
            status == 'accepted' || status == 'matched' || status == 'settled'
            ? InvitationStatus.selected
            : InvitationStatus.pending,
        captainName: (acceptedBy['captain_name'] ?? '').toString().trim(),
        captainUserId: _asInt(acceptedBy['user_id']),
        playerCount: _asInt(
          acceptedBy['player_count'] ?? acceptedBy['roster_size'],
        ),
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
    conversationId: conversationId,
    serverStatusLabel: serverStatusLabel,
    venueBooking: venueBooking,
    preferredDateTime: preferredDateTime,
    venueStartTime: venueStartTime,
    venueEndTime: venueEndTime,
    perPlayerAmount: perPlayerAmount,
    splitType: splitType,
    splitBasis: splitBasis,
    requestingTeamPercent: requestingTeamPercent,
    costType: costType,
    acceptRemaining: acceptRemaining,
    acceptExpired: acceptExpired,
    loserPayPercent: loserPayPercent,
    winnerPayPercent: winnerPayPercent,
    loserPayAmount: loserPayAmount,
    winnerPayAmount: winnerPayAmount,
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

class OpponentBookingPayment {
  const OpponentBookingPayment({
    required this.bookingCode,
    required this.paymentStatus,
    required this.bookingStatus,
    required this.totalAmount,
    required this.paidAmount,
    required this.balanceDue,
    required this.advanceAmount,
    required this.payableNow,
    required this.submittedAmount,
    required this.awaitingVerification,
    required this.hasProof,
    required this.method,
  });

  factory OpponentBookingPayment.fromBooking(Map<String, dynamic> booking) {
    final List<Map<String, dynamic>> payments =
        (booking['payments'] is List
                ? (booking['payments'] as List)
                : const <dynamic>[])
            .map(_asMap)
            .where((Map<String, dynamic> p) => p.isNotEmpty)
            .toList(growable: false);

    bool isPending(Map<String, dynamic> p) {
      final String verification = (p['verification_status'] ?? '')
          .toString()
          .toLowerCase();
      final String status = (p['status'] ?? '').toString().toLowerCase();
      return verification == 'pending' ||
          (verification.isEmpty && status == 'pending');
    }

    final Iterable<Map<String, dynamic>> pending = payments.where(isPending);

    return OpponentBookingPayment(
      bookingCode: (booking['booking_code'] ?? '').toString().trim(),
      paymentStatus: (booking['payment_status'] ?? '')
          .toString()
          .trim()
          .toLowerCase(),
      bookingStatus: (booking['booking_status'] ?? booking['status'] ?? '')
          .toString()
          .trim()
          .toLowerCase(),
      totalAmount: _asInt(booking['total_amount'] ?? booking['subtotal']),
      paidAmount: _asInt(booking['paid_amount']),
      balanceDue: _asInt(
        booking['balance_due'] ?? booking['balance_due_later'],
      ),
      advanceAmount: _asInt(booking['advance_amount']),
      payableNow: _asInt(booking['payable_now']),
      // What the requester has actually handed over but nobody has confirmed.
      submittedAmount: pending.fold<int>(
        0,
        (int sum, Map<String, dynamic> p) => sum + _asInt(p['amount']),
      ),
      awaitingVerification: pending.isNotEmpty,
      hasProof: payments.any(
        (Map<String, dynamic> p) =>
            p['has_payment_proof'] == true ||
            (p['payment_proof_url'] ?? '').toString().trim().isNotEmpty,
      ),
      method: payments.isEmpty
          ? ''
          : (payments.last['payment_method'] ??
                    payments.last['payment_type'] ??
                    '')
                .toString()
                .trim(),
    );
  }

  final String bookingCode;

  final String paymentStatus;

  final String bookingStatus;

  final int totalAmount;

  final int paidAmount;
  final int balanceDue;

  final int advanceAmount;
  final int payableNow;

  final int submittedAmount;
  final bool awaitingVerification;
  final bool hasProof;

  final String method;

  bool get isFullyPaid => paymentStatus == 'paid' || balanceDue <= 0;

  String get statusLabel {
    if (isFullyPaid) return 'Paid in full';
    if (awaitingVerification) return 'Awaiting payment verification';
    return switch (paymentStatus) {
      'partial' => 'Partially paid',
      'pending' || 'unpaid' || '' => 'Payment pending',
      final String other => other,
    };
  }
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const {};

int? _asIntOrNull(dynamic value) {
  if (value == null) return null;
  final String raw = value.toString().trim();
  if (raw.isEmpty) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(raw) ?? double.tryParse(raw)?.round();
}

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
