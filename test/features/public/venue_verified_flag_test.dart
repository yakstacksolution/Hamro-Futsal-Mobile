import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';

PublicListingVenueModel _venue(Map<String, dynamic> extra) =>
    PublicListingVenueModel.fromJson(<String, dynamic>{
      'id': 38,
      'name': 'UN park futsal',
      ...extra,
    });

void main() {
  group('PublicListingVenueModel.isVerified', () {
    test('is false when the payload says nothing', () {
      expect(_venue(<String, dynamic>{}).isVerified, isFalse);
    });

    test('reads a boolean flag under either key', () {
      expect(_venue(<String, dynamic>{'is_verified': true}).isVerified, isTrue);
      expect(_venue(<String, dynamic>{'verified': true}).isVerified, isTrue);
      expect(
        _venue(<String, dynamic>{'is_verified': false}).isVerified,
        isFalse,
      );
    });

    test('accepts the stringified booleans an API may send', () {
      expect(
        _venue(<String, dynamic>{'is_verified': 'true'}).isVerified,
        isTrue,
      );
      expect(_venue(<String, dynamic>{'is_verified': 1}).isVerified, isTrue);
      expect(
        _venue(<String, dynamic>{'is_verified': 'false'}).isVerified,
        isFalse,
      );
    });

    test('treats only verified/approved statuses as verified', () {
      expect(
        _venue(<String, dynamic>{'verification_status': 'verified'}).isVerified,
        isTrue,
      );
      expect(
        _venue(<String, dynamic>{'verification_status': 'approved'}).isVerified,
        isTrue,
      );
      // A venue awaiting review must not be shown as verified.
      expect(
        _venue(<String, dynamic>{'verification_status': 'pending'}).isVerified,
        isFalse,
      );
      expect(
        _venue(<String, dynamic>{'verification_status': 'rejected'}).isVerified,
        isFalse,
      );
    });

    test('survives a round trip through toJson', () {
      final PublicListingVenueModel venue = _venue(<String, dynamic>{
        'is_verified': true,
      });
      expect(
        PublicListingVenueModel.fromJson(venue.toJson()).isVerified,
        isTrue,
      );
    });
  });
}
