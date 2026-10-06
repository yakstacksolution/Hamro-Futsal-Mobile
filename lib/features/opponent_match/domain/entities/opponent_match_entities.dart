import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';

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
    this.bookingId,
    this.venueId,
    this.courtId,
  });

  final String team;
  final DateTime dateTime;
  final String summary;
  final String venue;
  final String slot;
  final int totalFee;
  final int yourShare;
  final String message;

  final int? myPct;

  final String teamId;

  final String formatLabel;

  final String levelSlug;

  final String splitMode;

  final int? loserPct;

  final String? endTime;

  final int? claimedTotalFee;

  final int? bookingId;
  final int? venueId;
  final int? courtId;

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
    'booking_id': bookingId,
    'venue_id': venueId,
    'court_id': courtId,
  };

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
