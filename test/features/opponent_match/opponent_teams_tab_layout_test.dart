// ignore_for_file: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_details_widgets.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/repositories/opponent_match_repository_impl.dart';
import 'package:hamro_futsal/features/opponent_match/domain/usecase/opponent_match_usecase.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/bloc/opponent_match_bloc/opponent_match_bloc.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/pages/opponent_match_screen.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_team_card.dart';

TeamModel _team(String id, String name) => TeamModel(
  id: id,
  name: name,
  players: List<PlayerModel>.generate(
    3,
    (int i) => PlayerModel(
      id: '$id$i',
      name: 'Player $i',
      position: PlayerPosition.values[i % PlayerPosition.values.length],
    ),
  ),
);

/// Phone, tablet and desktop windows.
const List<Size> _sizes = <Size>[Size(400, 900), Size(800, 1000), Size(1300, 900)];

void main() {
  // The New Team bottom bar once wrapped its button in a plain Center, which
  // filled the whole height a bottom bar is allowed and covered the list.
  for (final Size size in _sizes) {
    testWidgets('My Teams lists every team at $size', (WidgetTester tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final OpponentMatchBloc bloc = OpponentMatchBloc(
        OpponentMatchUseCase(OpponentMatchRepositoryImpl()),
      );
      addTearDown(bloc.close);
      bloc.emit(
        OpponentMatchState(
          teamsStatus: OpponentMatchStatus.success,
          teams: <TeamModel>[
            _team('1', 'Velox FC'),
            _team('2', 'Kings'),
            _team('3', 'Rangers'),
          ],
        ),
      );
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (BuildContext context, Widget? _) =>
              MaterialApp(home: OpponentMatchScreen(bloc: bloc)),
        ),
      );
      await tester.pump();
      tester.takeException();
      await tester.tap(find.text(StringConstants.myTeams));
      await tester.pumpAndSettle();

      expect(find.byType(OpponentTeamCard, skipOffstage: false), findsNWidgets(3));
      // Visible, not merely built behind the bar.
      expect(find.text('Velox FC').hitTestable(), findsOneWidget);
      expect(
        tester.getSize(find.byType(BottomAppBar).evaluate().isEmpty
                ? find.text(StringConstants.newTeam).first
                : find.byType(BottomAppBar))
            .height,
        lessThan(120),
      );
    });
  }

  testWidgets('booking action bar stays bar-height on desktop', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1400, 900);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (BuildContext context, Widget? _) => const MaterialApp(
          home: Scaffold(
            body: SizedBox.expand(),
            bottomNavigationBar: BookingActionBar(
              alignToDetailsContent: true,
              child: SizedBox(height: 42, child: Placeholder()),
            ),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(BookingActionBar)).height, lessThan(120));
  });
}
