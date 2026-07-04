import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';

/// Team CRUD + member management, backed by the `/api/teams` endpoints.
/// Also serves the `/positions` and `/opponent-levels` lookups.
abstract class TeamRemoteDataSource {
  Future<Result> getTeams();
  Future<Result> getTeam(int teamId);
  Future<Result> createTeam(Map<String, dynamic> data);
  Future<Result> updateTeam(int teamId, Map<String, dynamic> data);
  Future<Result> deleteTeam(int teamId);
  Future<Result> addMember(int teamId, Map<String, dynamic> data);
  Future<Result> updateMember(
    int teamId,
    int memberId,
    Map<String, dynamic> data,
  );
  Future<Result> removeMember(int teamId, int memberId);
  Future<Result> getPositions();
  Future<Result> getOpponentLevels();
}

final class TeamRemoteDataSourceImpl extends TeamRemoteDataSource {
  @override
  Future<Result> getTeams() async =>
      await Client.instance().getAuthManager().getTeams();

  @override
  Future<Result> getPositions() async =>
      await Client.instance().getAuthManager().getPlayerPositions();

  @override
  Future<Result> getOpponentLevels() async =>
      await Client.instance().getAuthManager().getOpponentLevels();

  @override
  Future<Result> getTeam(int teamId) async =>
      await Client.instance().getAuthManager().getTeam(teamId);

  @override
  Future<Result> createTeam(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().createTeam(data);

  @override
  Future<Result> updateTeam(int teamId, Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().updateTeam(teamId, data);

  @override
  Future<Result> deleteTeam(int teamId) async =>
      await Client.instance().getAuthManager().deleteTeam(teamId);

  @override
  Future<Result> addMember(int teamId, Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().addTeamMember(teamId, data);

  @override
  Future<Result> updateMember(
    int teamId,
    int memberId,
    Map<String, dynamic> data,
  ) async => await Client.instance().getAuthManager().updateTeamMember(
    teamId,
    memberId,
    data,
  );

  @override
  Future<Result> removeMember(int teamId, int memberId) async =>
      await Client.instance().getAuthManager().removeTeamMember(
        teamId,
        memberId,
      );
}

/// Local demo source for the parts of the feature without a backend yet —
/// venues and opponent requests.
abstract class OpponentMatchDataSource {
  Future<List<String>> fetchVenues();
  Future<List<OpponentRequestModel>> fetchRequests();
}

final class OpponentMatchLocalDataSourceImpl
    implements OpponentMatchDataSource {
  @override
  Future<List<String>> fetchVenues() async => const [
    'Green Turf Arena, Kathmandu',
    'Capital Futsal, Lalitpur',
    'Champions Court, Bhaktapur',
    'Soccer Pro Arena, Pulchowk',
  ];

  @override
  Future<List<OpponentRequestModel>> fetchRequests() async {
    final now = DateTime.now();
    return [
      OpponentRequestModel(
        id: 'r1',
        team: 'Royal Futsal Club',
        dateTime: DateTime(now.year, now.month, now.day, 18, 30),
        summary: 'Intermediate · 5v5',
        status: RequestStatus.fresh,
        venue: 'Green Turf Arena, Kathmandu',
        slot: '6:00 AM – 7:00 AM',
        totalFee: 1200,
        yourShare: 600,
        myPct: 50,
        createdAt: now.subtract(const Duration(minutes: 4)),
      ),
      OpponentRequestModel(
        id: 'r2',
        team: 'Bhaktapur Warriors',
        dateTime: DateTime(now.year, now.month, now.day + 1, 17),
        summary: 'Advanced · 6v6',
        status: RequestStatus.pending,
        venue: 'Champions Court, Bhaktapur',
        slot: '5:00 PM – 6:00 PM',
        totalFee: 1500,
        yourShare: 900,
        myPct: 60,
      ),
    ];
  }
}
