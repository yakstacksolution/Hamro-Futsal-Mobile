import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_review_model.dart';

void main() {
  Map<String, dynamic> response({
    int currentPage = 1,
    int lastPage = 3,
    int total = 25,
    List<dynamic>? reviews,
  }) => <String, dynamic>{
    'status': 'success',
    'data': <String, dynamic>{
      'reviews':
          reviews ??
          <dynamic>[
            <String, dynamic>{
              'id': 1,
              'user': <String, dynamic>{'name': 'Dilli', 'avatar': ''},
              'rating': 5,
              'comment': 'Great turf.',
              'created_at': '2026-08-18T10:00:00Z',
            },
            <String, dynamic>{
              'id': 2,
              'user_name': 'Ram',
              'rating': 4,
              'review': 'Good lights.',
              'created_at': '2026-08-01T10:00:00Z',
            },
          ],
      'pagination': <String, dynamic>{
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': 10,
        'total': total,
      },
      'summary': <String, dynamic>{
        'average_rating': 4.5,
        'breakdown': <String, dynamic>{'5': 18, '4': 5, '3': 2},
      },
    },
  };

  test('parses reviews, pagination and the rating summary', () {
    final page = VenueReviewPageModel.fromResponse(
      response(),
      requestedPage: 1,
      requestedPerPage: 10,
    );
    expect(page.items.length, 2);
    expect(page.items.first.name, 'Dilli');
    expect(page.items.last.name, 'Ram', reason: 'flat user_name is read too');
    expect(page.items.last.comment, 'Good lights.');
    expect(page.averageRating, 4.5);
    expect(page.total, 25);
    expect(page.hasMorePages, isTrue);
    expect(page.breakdown.counts[5], 18);
    expect(page.breakdown.fractionFor(5), closeTo(18 / 25, 0.001));
  });

  test('knows when the last page is reached', () {
    final page = VenueReviewPageModel.fromResponse(
      response(currentPage: 3, lastPage: 3),
      requestedPage: 3,
      requestedPerPage: 10,
    );
    expect(page.hasMorePages, isFalse);
  });

  test('derives the breakdown when the server omits it', () {
    final page = VenueReviewPageModel.fromResponse(
      <String, dynamic>{
        'data': <String, dynamic>{
          'reviews': <dynamic>[
            <String, dynamic>{'id': 1, 'rating': 5},
            <String, dynamic>{'id': 2, 'rating': 5},
            <String, dynamic>{'id': 3, 'rating': 3},
          ],
        },
      },
      requestedPage: 1,
      requestedPerPage: 10,
    );
    expect(page.breakdown.counts[5], 2);
    expect(page.breakdown.counts[3], 1);
  });

  test('infers a next page when last_page is missing and the page is full', () {
    final page = VenueReviewPageModel.fromResponse(
      <String, dynamic>{
        'data': <String, dynamic>{
          'reviews': List<dynamic>.generate(
            10,
            (int i) => <String, dynamic>{'id': i, 'rating': 4},
          ),
        },
      },
      requestedPage: 1,
      requestedPerPage: 10,
    );
    expect(page.hasMorePages, isTrue);
  });

  test('survives a bare list and an unexpected envelope', () {
    expect(
      VenueReviewPageModel.fromResponse(
        <dynamic>[
          <String, dynamic>{'id': 1, 'rating': 4, 'comment': 'ok'},
        ],
        requestedPage: 1,
        requestedPerPage: 10,
      ).items.length,
      1,
    );
    expect(
      VenueReviewPageModel.fromResponse(
        null,
        requestedPage: 1,
        requestedPerPage: 10,
      ).items,
      isEmpty,
    );
  });
}
