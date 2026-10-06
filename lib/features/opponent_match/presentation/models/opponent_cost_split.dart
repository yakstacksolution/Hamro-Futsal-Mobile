import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/utils/opponent_ui_utils.dart';

class OpponentCostSplit {
  const OpponentCostSplit({
    required this.format,
    required this.split,
    required this.basis,
    required this.myPercent,
    required this.loserPercent,
    required this.playerCount,
    this.overrideCourtFee,
    this.overrideYourShare,
  });

  factory OpponentCostSplit.fromServerShare({
    required int totalFee,
    required int accepterShare,
    required int playerCount,
  }) => OpponentCostSplit(
    format: MatchFormat.fiveASide,
    split: SplitMode.even,
    basis: SplitBasis.teams,
    myPercent: 50,
    loserPercent: 70,
    playerCount: playerCount,
    overrideCourtFee: totalFee,
    overrideYourShare: accepterShare,
  );

  final MatchFormat format;
  final SplitMode split;
  final SplitBasis basis;

  final int myPercent;

  final int loserPercent;
  final int playerCount;

  final int? overrideCourtFee;
  final int? overrideYourShare;

  int get courtFee => overrideCourtFee ?? 0;

  bool get hasCourtFee => courtFee > 0;

  bool get isResultBased =>
      split == SplitMode.custom && basis == SplitBasis.result;

  bool get isCustomTeams =>
      split == SplitMode.custom && basis == SplitBasis.teams;

  int? get myPct {
    if (split == SplitMode.even) return 50;
    if (isResultBased) return null;
    return myPercent;
  }

  int get yourShare {
    if (overrideYourShare != null) return overrideYourShare!;
    if (split == SplitMode.even) return (courtFee * 0.5).round();
    if (isResultBased) return 0; // conditional on match result
    return (courtFee * myPercent / 100).round();
  }

  int get opponentShare => courtFee - yourShare;

  int get loserShare => (courtFee * loserPercent / 100).round();
  int get winnerShare => courtFee - loserShare;

  int get perPlayerShare {
    if (playerCount == 0 || yourShare == 0) return 0;
    return (yourShare / playerCount).round();
  }

  String get badgeLabel {
    if (split == SplitMode.even) return '50% my side';
    if (isResultBased) return 'Conditional';
    return '$myPercent% my side';
  }

  String get shareSummary {
    if (!hasCourtFee) return 'Court fee not set yet';
    if (split == SplitMode.even) {
      return 'Your share ${OpponentFmt.npr(yourShare)} of '
          '${OpponentFmt.npr(courtFee)} (50%)';
    }
    if (isResultBased) {
      return 'Loser ${OpponentFmt.npr(loserShare)} ($loserPercent%) · '
          'Winner ${OpponentFmt.npr(winnerShare)}';
    }
    return 'Your share ${OpponentFmt.npr(yourShare)} of '
        '${OpponentFmt.npr(courtFee)} ($myPercent%)';
  }
}
