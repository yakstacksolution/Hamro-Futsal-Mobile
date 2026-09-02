import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';

void main() {
  Map<String, dynamic> response({
    int currentPage = 1,
    int lastPage = 3,
    int total = 24,
  }) => <String, dynamic>{
    'status': 'success',
    'data': <String, dynamic>{
      'items': <dynamic>[
        <String, dynamic>{
          'id': 'a1',
          'type': 'booking_income',
          'title': 'Booking income',
          'amount': 1200,
          'venue_name': 'Dhananjay sport',
          'created_at': '2026-08-18T10:00:00Z',
        },
        <String, dynamic>{
          'id': 'a2',
          'type': 'commission',
          'title': 'Platform commission',
          'amount': 120,
          'created_at': '2026-08-17T10:00:00Z',
        },
      ],
      'pagination': <String, dynamic>{
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': 10,
        'total': total,
      },
    },
  };

  test('parses a page of ledger rows', () {
    final page = AccountActivityPageModel.fromResponse(
      response(),
      requestedPage: 1,
      requestedPerPage: 10,
    );
    expect(page.items.length, 2);
    expect(page.items.first.title, 'Booking income');
    expect(page.items.first.venueName, 'Dhananjay sport');
    expect(page.total, 24);
    expect(page.hasMorePages, isTrue);
  });

  test('knows the last page', () {
    final page = AccountActivityPageModel.fromResponse(
      response(currentPage: 3, lastPage: 3),
      requestedPage: 3,
      requestedPerPage: 10,
    );
    expect(page.hasMorePages, isFalse);
  });

  test(
    'infers another page when pagination is absent and the page is full',
    () {
      final page = AccountActivityPageModel.fromResponse(
        <String, dynamic>{
          'data': <String, dynamic>{
            'items': List<dynamic>.generate(
              10,
              (int i) => <String, dynamic>{'id': 'x$i', 'amount': 10},
            ),
          },
        },
        requestedPage: 1,
        requestedPerPage: 10,
      );
      expect(page.hasMorePages, isTrue);
      expect(page.items.length, 10);
    },
  );

  test('survives a bare list and an empty envelope', () {
    expect(
      AccountActivityPageModel.fromResponse(
        <dynamic>[
          <String, dynamic>{'id': 'z', 'amount': 5},
        ],
        requestedPage: 1,
        requestedPerPage: 10,
      ).items.length,
      1,
    );
    expect(
      AccountActivityPageModel.fromResponse(
        null,
        requestedPage: 1,
        requestedPerPage: 10,
      ).items,
      isEmpty,
    );
  });
}
