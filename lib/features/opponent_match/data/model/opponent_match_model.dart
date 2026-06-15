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
  const OpponentLevelModel({required this.id, required this.name, this.slug = ''});

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
enum RequestStatus { fresh, pending, accepted, rejected, sent, expired }

extension RequestStatusX on RequestStatus {
  String get label => switch (this) {
    RequestStatus.fresh => 'New',
    RequestStatus.pending => 'Pending',
    RequestStatus.accepted => 'Accepted',
    RequestStatus.rejected => 'Rejected',
    RequestStatus.sent => 'Sent',
    RequestStatus.expired => 'Expired',
  };

  /// Still actionable (can be accepted / rejected).
  bool get isOpen => this == RequestStatus.fresh || this == RequestStatus.pending;

  bool get isSettled => !isOpen;
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
    this.positionName = '',
    this.positionId = '',
  });

  /// Server-side team-member id (`teams/{team}/members/{member}`). Empty for
  /// players built locally before they round-trip through the backend.
  final String id;
  final String name;
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

  /// When set on a `fresh` request, drives the accept-window countdown.
  final DateTime? createdAt;

  OpponentRequestModel copyWith({RequestStatus? status}) =>
      OpponentRequestModel(
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
