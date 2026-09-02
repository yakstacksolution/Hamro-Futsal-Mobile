import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/public/data/model/public_option_model.dart';

/// A trimmed copy of `GET /amenities`, keeping the shapes that matter: the
/// nested media object under `icon`, and the doubled slash in its URL.
const String _amenitiesResponse = '''
{
  "status": "success",
  "message": "Ameneities fetched successfully.",
  "data": {
    "amenities": [
      {
        "id": 4,
        "name": "CCTV Security",
        "slug": "cctv-security",
        "status": true,
        "icon": {
          "id": 264,
          "name": "icon",
          "full_url": "https://hamrofutsal.com//storage/Amenity/4/icon/264/icon_1785226461.png",
          "media": {
            "id": 264,
            "name": "icon",
            "full_url": "https://hamrofutsal.com//storage/Amenity/4/icon/264/icon_1785226461.png",
            "status": "active"
          }
        },
        "description": "24/7 monitored security cameras.",
        "is_active": true,
        "sort_order": null
      },
      {
        "id": 1,
        "name": "WiFi",
        "slug": "wifi",
        "status": true,
        "icon": {
          "id": 288,
          "name": "icon",
          "media": {
            "id": 288,
            "full_url": "https://hamrofutsal.com/storage/Amenity/1/icon/288/icon.png"
          }
        },
        "description": "Free wireless internet access.",
        "is_active": true,
        "sort_order": 2
      }
    ]
  }
}
''';

void main() {
  List<Map<String, dynamic>> amenities() {
    final Map<String, dynamic> json =
        jsonDecode(_amenitiesResponse) as Map<String, dynamic>;
    final List<dynamic> list =
        (json['data'] as Map<String, dynamic>)['amenities'] as List<dynamic>;
    return list
        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  group('PublicOptionModel.fromJson', () {
    test('reads the icon URL out of the nested media object', () {
      final PublicOptionModel cctv = PublicOptionModel.fromJson(
        amenities().first,
      );

      expect(cctv.hasImage, isTrue);
      expect(cctv.image, startsWith('https://hamrofutsal.com/storage/'));
      // The whole point: the object must not be stringified into the URL.
      expect(cctv.image, isNot(contains('full_url')));
      expect(cctv.image, isNot(contains('{')));
    });

    test('collapses the doubled slash the media host emits', () {
      final PublicOptionModel cctv = PublicOptionModel.fromJson(
        amenities().first,
      );

      expect(cctv.image, isNot(contains('.com//')));
      expect(cctv.image, startsWith('https://'));
    });

    test('falls through to icon.media.full_url when the icon has no url', () {
      final PublicOptionModel wifi = PublicOptionModel.fromJson(
        amenities().last,
      );

      expect(
        wifi.image,
        'https://hamrofutsal.com/storage/Amenity/1/icon/288/icon.png',
      );
    });

    test('carries the descriptive fields through', () {
      final PublicOptionModel cctv = PublicOptionModel.fromJson(
        amenities().first,
      );

      expect(cctv.id, '4');
      expect(cctv.idAsInt, 4);
      expect(cctv.name, 'CCTV Security');
      expect(cctv.slug, 'cctv-security');
      expect(cctv.description, '24/7 monitored security cameras.');
      expect(cctv.hasDescription, isTrue);
      expect(cctv.isActive, isTrue);
      expect(cctv.sortOrder, isNull);
      expect(PublicOptionModel.fromJson(amenities().last).sortOrder, 2);
    });

    test('a plain string icon still works', () {
      final PublicOptionModel option = PublicOptionModel.fromJson(
        <String, dynamic>{
          'id': 9,
          'title': 'Parking',
          'image': ' https://example.com/parking.png ',
        },
      );

      expect(option.name, 'Parking');
      expect(option.image, 'https://example.com/parking.png');
    });

    test('an option with no icon has no image', () {
      final PublicOptionModel option = PublicOptionModel.fromJson(
        <String, dynamic>{'id': 9, 'name': 'Parking'},
      );

      expect(option.hasImage, isFalse);
      expect(option.image, isEmpty);
    });

    test('visibility flags: only an explicit false hides an option', () {
      bool activeOf(Map<String, dynamic> json) =>
          PublicOptionModel.fromJson(json).isActive;

      expect(activeOf(<String, dynamic>{'name': 'A'}), isTrue);
      expect(
        activeOf(<String, dynamic>{'name': 'A', 'is_active': false}),
        isFalse,
      );
      expect(activeOf(<String, dynamic>{'name': 'A', 'status': 0}), isFalse);
      expect(
        activeOf(<String, dynamic>{'name': 'A', 'status': 'inactive'}),
        isFalse,
      );
      expect(activeOf(<String, dynamic>{'name': 'A', 'status': true}), isTrue);
    });
  });
}
