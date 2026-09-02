import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_amenities_facilities_model.dart';

void main() {
  test('parses rich amenities and facilities response data', () {
    final VenueAmenitiesFacilitiesModel model =
        VenueAmenitiesFacilitiesModel.fromJson(<String, dynamic>{
          'amenities': <dynamic>[
            <String, dynamic>{
              'id': 4,
              'name': 'CCTV Security',
              'slug': 'cctv-security',
              'status': true,
              'icon': <String, dynamic>{
                'id': 264,
                'full_url': 'https://example.com/cctv.png',
                'media': <String, dynamic>{'status': 'active'},
              },
              'description': '24/7 monitored security cameras.',
              'is_active': true,
              'sort_order': null,
            },
          ],
          'facilities': <dynamic>[
            <String, dynamic>{
              'id': 2,
              'name': 'Drinking Water',
              'title': 'Drinking Water',
              'image': <String, dynamic>{
                'media': <String, dynamic>{
                  'full_url': 'https://example.com/water.png',
                },
              },
              'description': null,
            },
          ],
        });

    expect(model.hasData, isTrue);
    expect(model.amenities.single.id, 4);
    expect(model.amenities.single.slug, 'cctv-security');
    expect(
      model.amenities.single.description,
      '24/7 monitored security cameras.',
    );
    expect(
      model.amenities.single.displayIconUrl,
      'https://example.com/cctv.png',
    );
    expect(
      model.facilities.single.displayIconUrl,
      'https://example.com/water.png',
    );
  });

  test('keeps backward compatibility with string lists', () {
    final VenueAmenitiesFacilitiesModel model =
        VenueAmenitiesFacilitiesModel.fromJson(<String, dynamic>{
          'amenities': <String>['WiFi'],
          'facilities': <String>['First Aid'],
        });

    expect(model.amenities.single.name, 'WiFi');
    expect(model.facilities.single.name, 'First Aid');
  });
}
