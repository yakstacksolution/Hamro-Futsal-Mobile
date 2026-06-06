import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';

abstract class OpponentMatchDataSource {
  Future<List<TeamModel>> fetchTeams();
  Future<List<String>> fetchVenues();
  Future<List<OpponentRequestModel>> fetchRequests();
}

/// Local demo data source.
///
/// Swap this with an API-backed implementation (mirroring
/// `ExpensesRemoteDataSourceImpl`) once the backend endpoints are available —
/// the repository and everything above it stay untouched.
final class OpponentMatchLocalDataSourceImpl implements OpponentMatchDataSource {
  @override
  Future<List<TeamModel>> fetchTeams() async => const [
    TeamModel(
      id: 't1',
      name: 'Kathmandu Strikers',
      players: [
        PlayerModel(name: 'Aayush Karki', position: PlayerPosition.forward),
        PlayerModel(name: 'Niraj Shrestha', position: PlayerPosition.midfielder),
        PlayerModel(name: 'Samir Tamang', position: PlayerPosition.defender),
      ],
    ),
    TeamModel(
      id: 't2',
      name: 'Valley Five',
      players: [
        PlayerModel(name: 'Rohit Rai', position: PlayerPosition.goalkeeper),
        PlayerModel(name: 'Bishal Maharjan', position: PlayerPosition.forward),
      ],
    ),
  ];

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
