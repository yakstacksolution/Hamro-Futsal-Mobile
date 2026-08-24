import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/models/opponent_cost_split.dart';

OpponentCostSplit resultSplit(int loserPercent) => OpponentCostSplit(
  format: MatchFormat.fiveASide,
  split: SplitMode.custom,
  basis: SplitBasis.result,
  myPercent: 50,
  loserPercent: loserPercent,
  playerCount: 5,
  overrideCourtFee: 2000,
);

void main() {
  test('the loser can carry the whole fee', () {
    final cost = resultSplit(100);

    expect(cost.loserShare, 2000);
    expect(cost.winnerShare, 0);
    expect(cost.shareSummary, contains('100%'));
  });

  test('an even result split still halves the fee', () {
    final cost = resultSplit(50);

    expect(cost.loserShare, 1000);
    expect(cost.winnerShare, 1000);
  });

  test('a partial result split adds back up to the fee', () {
    final cost = resultSplit(70);

    expect(cost.loserShare + cost.winnerShare, 2000);
    expect(cost.loserShare, 1400);
  });
}
