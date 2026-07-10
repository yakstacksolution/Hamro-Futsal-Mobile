import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';

/// Pure calculator for the court-fee split — derives every figure the
/// cost-split card and the outgoing request need from the form selections.
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

  /// Split with server-authoritative figures — reuses the per-player math on
  /// the accept flow where the fee and share come from the request/quote, not
  /// the local format table.
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

  /// Custom "my side pays" percentage (only meaningful for custom-by-team).
  final int myPercent;

  /// Loser's percentage (only meaningful for custom-by-result).
  final int loserPercent;
  final int playerCount;

  /// Server-quoted totals; when set they take precedence over the local
  /// format fee table and percentage math.
  final int? overrideCourtFee;
  final int? overrideYourShare;

  int get courtFee => overrideCourtFee ?? format.courtFee;

  bool get isResultBased =>
      split == SplitMode.custom && basis == SplitBasis.result;

  bool get isCustomTeams =>
      split == SplitMode.custom && basis == SplitBasis.teams;

  /// Your side's fixed percentage; null when conditional on the result.
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

  /// One-line share summary embedded in the outgoing request.
  String get shareSummary {
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
