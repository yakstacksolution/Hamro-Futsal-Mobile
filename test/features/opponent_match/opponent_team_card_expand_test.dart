import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_team_card.dart';

TeamModel _team({int players = 5}) => TeamModel(
  id: 't1',
  name: 'Velox FC',
  players: List<PlayerModel>.generate(
    players,
    (int i) => PlayerModel(
      id: 'p$i',
      name: 'Player $i',
      position: PlayerPosition.values[i % PlayerPosition.values.length],
    ),
  ),
);

Widget _host(TeamModel team, {bool initiallyExpanded = true}) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(
      child: OpponentTeamCard(
        team: team,
        initiallyExpanded: initiallyExpanded,
        onAddPlayer: () {},
        onDelPlayer: (_) {},
        onEditPlayer: (_) {},
        onEditTeam: () {},
        onDeleteTeam: () {},
      ),
    ),
  ),
);

void main() {
  testWidgets('a collapsed roster hides its players, header still reads', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_team(), initiallyExpanded: false));

    expect(find.text('Velox FC'), findsOneWidget);
    expect(find.text('Player 0'), findsNothing);
    expect(find.text('Player 4'), findsNothing);
  });

  testWidgets('tapping the header opens and closes the roster', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_team(), initiallyExpanded: false));

    await tester.tap(find.text('Velox FC'));
    await tester.pumpAndSettle();
    expect(find.text('Player 0'), findsOneWidget);
    expect(find.text('Player 4'), findsOneWidget);

    await tester.tap(find.text('Velox FC'));
    await tester.pumpAndSettle();
    expect(find.text('Player 0'), findsNothing);
  });

  testWidgets('an expanded card lists every player', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_team(players: 3)));

    expect(find.text('Player 0'), findsOneWidget);
    expect(find.text('Player 1'), findsOneWidget);
    expect(find.text('Player 2'), findsOneWidget);
  });

  // An empty team has nothing to collapse: the chevron would be a control that
  // does nothing, so the hint shows instead.
  testWidgets('a team with no players shows no chevron', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(_team(players: 0)));

    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);
  });
}
