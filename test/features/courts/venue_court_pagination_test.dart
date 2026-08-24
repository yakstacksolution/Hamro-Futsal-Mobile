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

  test('parses the get-venue-courts venues response and nested media', () {
    final VenueCourtPageModel page = VenueCourtPageModel.fromResponse(
      <String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'venues': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 46,
              'futsal_name': 'Three star futsal',
              'futsal_address': 'Kirtipur, Kathmandu, Nepal',
              'phone': '9898998989',
              'cover_image_media': <String, dynamic>{
                'id': 407,
                'full_url': 'https://example.com/venue.jpg',
              },
              'status': 'active',
              'courts': <Map<String, dynamic>>[
                <String, dynamic>{
                  'id': 46,
                  'venue_id': 46,
                  'court_type_id': 1,
                  'match_format_id': 1,
                  'court_name': 'Court A',
                  'base_price': '900.00',
                  'is_payment_required': true,
                  'advance_payment_required': false,
                  'court_photos': <String, dynamic>{
                    'id': 406,
                    'name': 'court-photo',
                    'full_url': 'https://example.com/court.jpg',
                  },
                  'status': 'active',
                },
              ],
            },
          ],
          'pagination': <String, dynamic>{
            'current_page': 1,
            'last_page': 1,
            'per_page': 10,
            'total': 1,
            'has_more_pages': false,
          },
        },
      },
    );

    final venue = page.items.single;
    final court = venue.courts.single;
    expect(venue.title, 'Three star futsal');
    expect(venue.imageUrl, 'https://example.com/venue.jpg');
    expect(court.venueId, 46);
    expect(court.name, 'Court A');
    expect(court.basePrice, 900);
    expect(court.courtType, 'Indoor');
    expect(court.matchFormat, '5v5');
    expect(court.photos.single.remoteUrl, 'https://example.com/court.jpg');
    expect(court.advancePaymentRequired, isFalse);
    expect(page.hasMorePages, isFalse);
  });
}
