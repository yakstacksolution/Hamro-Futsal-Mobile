import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/api_constants.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';

void main() {
  group('VenueFilter.toVenueListPayload', () {
    test('always carries page and per_page', () {
      final Map<String, dynamic> payload = VenueFilter.empty
          .toVenueListPayload();

      expect(payload['page'], 1);
      expect(payload['per_page'], kVenueListPerPage);
      expect(kVenueListPerPage, 5);
    });

    test('sends the origin passed by the caller', () {
      final Map<String, dynamic> payload = VenueFilter.empty.toVenueListPayload(
        page: 2,
        perPage: 5,
        latitude: 27.7172,
        longitude: 85.3240,
      );

      expect(payload['latitude'], 27.7172);
      expect(payload['longitude'], 85.3240);
      expect(payload['page'], 2);
      expect(payload['per_page'], 5);
    });

    test("falls back to the filter's own coordinates", () {
      final Map<String, dynamic> payload = const VenueFilter(
        latitude: 26.6440,
        longitude: 88.0071,
      ).toVenueListPayload();

      expect(payload['latitude'], 26.6440);
      expect(payload['longitude'], 88.0071);
    });

    test('caller coordinates win over the filter', () {
      final Map<String, dynamic> payload = const VenueFilter(
        latitude: 26.6440,
        longitude: 88.0071,
      ).toVenueListPayload(latitude: 27.7172, longitude: 85.3240);

      expect(payload['latitude'], 27.7172);
      expect(payload['longitude'], 85.3240);
    });

    test('omits a half-known origin', () {
      final Map<String, dynamic> payload = VenueFilter.empty.toVenueListPayload(
        latitude: 27.7172,
      );

      expect(payload.containsKey('latitude'), isFalse);
      expect(payload.containsKey('longitude'), isFalse);
    });
  });
}
