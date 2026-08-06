import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';

/// Everything needed to create (send) an opponent request.
class CreateOpponentRequestEntity {
  const CreateOpponentRequestEntity({
    required this.team,
    required this.dateTime,
    required this.summary,
    required this.venue,
    required this.slot,
    required this.totalFee,
    required this.yourShare,
    required this.message,
    this.myPct,
    this.teamId = '',
    this.formatLabel = '',
    this.levelSlug = '',
    this.splitMode = 'even',
    this.loserPct,
    this.endTime,
    this.claimedTotalFee,
  });

  final String team;
  final DateTime dateTime;
  final String summary;
  final String venue;
  final String slot;
  final int totalFee;
  final int yourShare;
  final String message;

  /// Your side's percentage; null when the split is result-based.
  final int? myPct;

  /// Server id of the requesting team.
  final String teamId;

  /// Wire format label, e.g. `5v5`.
  final String formatLabel;

  /// Wire level slug, e.g. `intermediate`.
  final String levelSlug;

  /// Wire split mode: `even | custom_team | custom_result`.
  final String splitMode;

  /// Loser's percentage — only for result-based splits.
  final int? loserPct;

  /// `HH:mm` end time when a booked slot supplied one.
  final String? endTime;

  /// What the requester says they paid for an externally-booked court.
  /// Only sent for the already-booked path — for platform venues the server
  /// computes the fee itself and ignores this.
  final int? claimedTotalFee;

  /// Body for `POST /opponent-requests`. Platform-venue fees are intentionally
  /// NOT serialized — the server computes the total fee and both shares;
  /// only [claimedTotalFee] travels, for externally-booked courts.
  Map<String, dynamic> toJson() => {
    'team_id': teamId,
    'date':
        '${dateTime.year.toString().padLeft(4, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}',
    'start_time':
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}',
    'end_time': endTime,
    'venue_name': venue,
    'format': formatLabel,
    'level_slug': levelSlug,
    'split_mode': splitMode,
    'requester_pct': myPct,
    'loser_pct': loserPct,
    'message': message,
    'claimed_total_fee': claimedTotalFee,
  };

  /// Local model used only by the mock fallback (`OPPONENT_MOCK`).
  OpponentRequestModel toModel(String id) => OpponentRequestModel(
    id: id,
    team: team,
    dateTime: dateTime,
    summary: summary,
    status: RequestStatus.sent,
    venue: venue,
    slot: slot,
    totalFee: totalFee,
    yourShare: yourShare,
    myPct: myPct,
    isMine: true,
  );
}
