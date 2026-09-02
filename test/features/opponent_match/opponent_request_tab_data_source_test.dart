import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/opponent_match/data/data_source/opponent_match_data_source.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_tab.dart';

void main() {
  group('Opponent request tab data source', () {
    test('uses the backend tab query values', () {
      expect(OpponentRequestTab.needOpponent.query, 'need_opponent');
      expect(OpponentRequestTab.myRequests.query, 'my_requests');
      expect(OpponentRequestTab.invitations.query, 'invitation');
      expect(OpponentRequestTab.settled.query, 'settled');
    });

    test(
      'returns the requested server tab instead of an all-requests list',
      () async {
        final OpponentRequestMockDataSourceImpl source =
            OpponentRequestMockDataSourceImpl();

        final settled = await source.fetchRequests(
          tab: OpponentRequestTab.settled,
          page: 1,
          perPage: 15,
        );
        final needOpponent = await source.fetchRequests(
          tab: OpponentRequestTab.needOpponent,
          page: 1,
          perPage: 15,
        );
        final myRequests = await source.fetchRequests(
          tab: OpponentRequestTab.myRequests,
          page: 1,
          perPage: 15,
        );

        expect(settled.isError(), isFalse);
        expect(_ids(settled.getValue()), <int>[45]);
        expect(_ids(needOpponent.getValue()), <int>[41, 409, 42, 46]);
        expect(_ids(myRequests.getValue()), <int>[43, 47]);
      },
    );

    test('honours the page and per-page contract', () async {
      final result = await OpponentRequestMockDataSourceImpl().fetchRequests(
        tab: OpponentRequestTab.needOpponent,
        page: 2,
        perPage: 2,
      );

      final Map<String, dynamic> data = Map<String, dynamic>.from(
        (result.getValue() as Map)['data'] as Map,
      );
      final Map<String, dynamic> pagination = Map<String, dynamic>.from(
        data['pagination'] as Map,
      );

      expect(_ids(result.getValue()), <int>[42, 46]);
      expect(pagination['current_page'], 2);
      expect(pagination['per_page'], 2);
      expect(pagination['total'], 4);
      expect(pagination['has_more_pages'], isFalse);
    });
  });
}

List<int> _ids(dynamic response) {
  final Map<String, dynamic> data = Map<String, dynamic>.from(
    (response as Map)['data'] as Map,
  );
  return (data['requests'] as List<dynamic>)
      .map((dynamic row) => (row as Map)['id'] as int)
      .toList(growable: false);
}
