import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/opponent_match/data/data_source/opponent_match_data_source.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_match_model.dart';
import 'package:hamro_futsal/features/opponent_match/data/repositories/opponent_match_repository_impl.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/widgets/opponent_sheets.dart';

void main() {
  group('AddPlayerSheet email field', () {
    const List<PlayerPositionModel> positions = <PlayerPositionModel>[
      PlayerPositionModel(id: '1', name: 'Goalkeeper'),
      PlayerPositionModel(id: '2', name: 'Defender'),
    ];

    Widget host({
      PlayerModel? initialPlayer,
      required ValueChanged<PlayerModel> onAdd,
    }) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: AddPlayerSheet(
            teamName: 'Yak FC',
            positions: positions,
            initialPlayer: initialPlayer,
            onAdd: onAdd,
          ),
        ),
      ),
    );

    testWidgets('sits below the player name field', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(host(onAdd: (_) {}));
      await tester.pumpAndSettle();

      expect(find.text('Player name'), findsWidgets);
      expect(find.text('Player email'), findsWidgets);

      final double nameY = tester.getTopLeft(find.text('Player name').first).dy;
      final double emailY = tester
          .getTopLeft(find.text('Player email').first)
          .dy;
      expect(emailY, greaterThan(nameY));
    });

    testWidgets('carries the typed address into the player', (
      WidgetTester tester,
    ) async {
      PlayerModel? added;
      await tester.pumpWidget(host(onAdd: (PlayerModel p) => added = p));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Ramesh');
      await tester.enterText(
        find.byType(TextField).at(1),
        'ramesh@example.com',
      );
      await tester.tap(find.text('Goalkeeper'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.text('Add Player'),
        ),
      );
      await tester.pumpAndSettle();

      expect(added?.name, 'Ramesh');
      expect(added?.email, 'ramesh@example.com');
    });

    testWidgets('blocks submission on a malformed address', (
      WidgetTester tester,
    ) async {
      PlayerModel? added;
      await tester.pumpWidget(host(onAdd: (PlayerModel p) => added = p));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Ramesh');
      await tester.enterText(find.byType(TextField).at(1), 'not-an-email');
      await tester.tap(find.text('Goalkeeper'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);

      await tester.tap(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.text('Add Player'),
        ),
      );
      await tester.pumpAndSettle();

      expect(added, isNull);
    });

    testWidgets('stays optional — a player can be added without one', (
      WidgetTester tester,
    ) async {
      PlayerModel? added;
      await tester.pumpWidget(host(onAdd: (PlayerModel p) => added = p));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Ramesh');
      await tester.tap(find.text('Goalkeeper'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(CustomButton),
          matching: find.text('Add Player'),
        ),
      );
      await tester.pumpAndSettle();

      expect(added?.email, isEmpty);
    });

    testWidgets('prefills when editing an existing member', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        host(
          initialPlayer: const PlayerModel(
            id: '7',
            name: 'Ramesh',
            email: 'ramesh@example.com',
            position: PlayerPosition.goalkeeper,
            positionName: 'Goalkeeper',
            positionId: '1',
          ),
          onAdd: (_) {},
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ramesh@example.com'), findsOneWidget);
    });
  });

  group('member payload', () {
    final PlayerModel player = const PlayerModel(
      name: 'Ramesh',
      email: 'ramesh@example.com',
      position: PlayerPosition.goalkeeper,
      positionId: '1',
    );

    test('addMember sends email alongside name and position', () async {
      final _FakeTeamDataSource ds = _FakeTeamDataSource();
      final OpponentMatchRepositoryImpl repo = OpponentMatchRepositoryImpl(
        teamDataSource: ds,
      );

      await repo.addMember('3', player);

      expect(ds.lastPayload, <String, dynamic>{
        'name': 'Ramesh',
        'position_id': 1,
        'email': 'ramesh@example.com',
      });
    });

    test('updateMember sends email too', () async {
      final _FakeTeamDataSource ds = _FakeTeamDataSource();
      final OpponentMatchRepositoryImpl repo = OpponentMatchRepositoryImpl(
        teamDataSource: ds,
      );

      await repo.updateMember(
        '3',
        const PlayerModel(
          id: '9',
          name: 'Ramesh',
          email: 'ramesh@example.com',
          position: PlayerPosition.goalkeeper,
          positionId: '1',
        ),
      );

      expect(ds.lastPayload?['email'], 'ramesh@example.com');
    });

    test('the key is omitted rather than sent blank when unset', () async {
      final _FakeTeamDataSource ds = _FakeTeamDataSource();
      final OpponentMatchRepositoryImpl repo = OpponentMatchRepositoryImpl(
        teamDataSource: ds,
      );

      await repo.addMember(
        '3',
        const PlayerModel(
          name: 'Ramesh',
          position: PlayerPosition.goalkeeper,
          positionId: '1',
        ),
      );

      expect(ds.lastPayload?.containsKey('email'), isFalse);
    });

    test('surrounding whitespace is trimmed off', () async {
      final _FakeTeamDataSource ds = _FakeTeamDataSource();
      final OpponentMatchRepositoryImpl repo = OpponentMatchRepositoryImpl(
        teamDataSource: ds,
      );

      await repo.addMember(
        '3',
        const PlayerModel(
          name: 'Ramesh',
          email: '  ramesh@example.com  ',
          position: PlayerPosition.goalkeeper,
          positionId: '1',
        ),
      );

      expect(ds.lastPayload?['email'], 'ramesh@example.com');
    });
  });

  group('PlayerModel.fromJson', () {
    test('reads email from the row', () {
      final PlayerModel player = PlayerModel.fromJson(<String, dynamic>{
        'id': 7,
        'name': 'Ramesh',
        'email': 'ramesh@example.com',
        'position_id': 1,
      });
      expect(player.email, 'ramesh@example.com');
    });

    test('falls back to the linked user', () {
      final PlayerModel player = PlayerModel.fromJson(<String, dynamic>{
        'id': 7,
        'user': <String, dynamic>{
          'name': 'Ramesh',
          'email': 'ramesh@example.com',
        },
      });
      expect(player.email, 'ramesh@example.com');
    });

    test('degrades to empty when absent', () {
      final PlayerModel player = PlayerModel.fromJson(<String, dynamic>{
        'id': 7,
        'name': 'Ramesh',
      });
      expect(player.email, isEmpty);
    });
  });
}

/// Records the member payloads the repository builds.
final class _FakeTeamDataSource implements TeamRemoteDataSource {
  Map<String, dynamic>? lastPayload;

  @override
  Future<Result> addMember(int teamId, Map<String, dynamic> data) async {
    lastPayload = data;
    return Result<dynamic, dynamic>.success(<String, dynamic>{'data': true});
  }

  @override
  Future<Result> updateMember(
    int teamId,
    int memberId,
    Map<String, dynamic> data,
  ) async {
    lastPayload = data;
    return Result<dynamic, dynamic>.success(<String, dynamic>{'data': true});
  }

  // The repository reloads the roster after every mutation; an empty list is
  // enough for these assertions.
  @override
  Future<Result> getTeams() async =>
      Result<dynamic, dynamic>.success(<String, dynamic>{'data': <dynamic>[]});

  @override
  Future<Result> getTeam(int teamId) async => Result<dynamic, dynamic>.success(
    <String, dynamic>{'data': <String, dynamic>{}},
  );

  @override
  Future<Result> createTeam(Map<String, dynamic> data) async =>
      Result<dynamic, dynamic>.error(AppException);

  @override
  Future<Result> updateTeam(int teamId, Map<String, dynamic> data) async =>
      Result<dynamic, dynamic>.error(AppException);

  @override
  Future<Result> deleteTeam(int teamId) async =>
      Result<dynamic, dynamic>.error(AppException);

  @override
  Future<Result> removeMember(int teamId, int memberId) async =>
      Result<dynamic, dynamic>.error(AppException);

  @override
  Future<Result> getPositions() async =>
      Result<dynamic, dynamic>.success(<String, dynamic>{'data': <dynamic>[]});

  @override
  Future<Result> getOpponentLevels() async =>
      Result<dynamic, dynamic>.success(<String, dynamic>{'data': <dynamic>[]});
}
