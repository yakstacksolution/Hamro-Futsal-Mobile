import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_page_model.dart';

void main() {
  test('parses venue-court items and dynamic pagination metadata', () {
    final VenueCourtPageModel page = VenueCourtPageModel.fromResponse(
      <String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 22,
              'futsal_name': 'Test Futsal',
              'status': 'inactive',
              'courts': <dynamic>[],
            },
          ],
          'pagination': <String, dynamic>{
            'current_page': 2,
            'last_page': 4,
            'per_page': 10,
            'total': 34,
            'has_more_pages': true,
          },
        },
      },
    );

    expect(page.items.single.id, 22);
    expect(page.items.single.title, 'Test Futsal');
    expect(page.currentPage, 2);
    expect(page.lastPage, 4);
    expect(page.perPage, 10);
    expect(page.total, 34);
    expect(page.hasMorePages, isTrue);
  });

  test('infers has-more from page bounds when the flag is omitted', () {
    final VenueCourtPageModel page = VenueCourtPageModel.fromResponse(
      <String, dynamic>{
        'data': <String, dynamic>{
          'items': <dynamic>[],
          'pagination': <String, dynamic>{
            'current_page': '1',
            'last_page': '2',
          },
        },
      },
    );

    expect(page.hasMorePages, isTrue);
  });
}
