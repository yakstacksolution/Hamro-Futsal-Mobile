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
  );
}
