import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/routers/deep_link_target.dart';

void main() {
  group('DeepLinkTarget.parse', () {
    test('reads the shared https URL, id and all', () {
      final DeepLinkTarget? target = DeepLinkTarget.parse(
        Uri.parse('https://hamrofutsal.com/venues/un-park-futsal?venue=38'),
      );

      expect(target, isA<VenueDeepLink>());
      final VenueDeepLink venue = target! as VenueDeepLink;
      expect(venue.id, 38);
      expect(venue.slug, 'un-park-futsal');
    });

    test('reads the app scheme, whose slug sits in the authority', () {
      final DeepLinkTarget? target = DeepLinkTarget.parse(
        Uri.parse('hamrofutsal://venues/un-park-futsal'),
      );

      final VenueDeepLink venue = target! as VenueDeepLink;
      expect(venue.slug, 'un-park-futsal');
      expect(venue.id, isNull);
    });

    test('accepts www and staging hosts', () {
      expect(
        DeepLinkTarget.parse(
          Uri.parse('https://www.hamrofutsal.com/venues/goal-zone-futsal'),
        ),
        isA<VenueDeepLink>(),
      );
      expect(
        DeepLinkTarget.parse(
          Uri.parse('https://staging.hamrofutsal.com/venues/goal-zone-futsal'),
        ),
        isA<VenueDeepLink>(),
      );
    });

    test('turns the slug into a search term the listing can match', () {
      final VenueDeepLink venue =
          DeepLinkTarget.parse(
                Uri.parse('hamrofutsal://venues/three-star-futsal'),
              )!
              as VenueDeepLink;

      // `GET /venues?search=` matches names, and the slug is the hyphenated
      // name.
      expect(venue.searchTerm, 'three star futsal');
    });

    test('takes an id-only link, since a slug can be renamed', () {
      final VenueDeepLink venue =
          DeepLinkTarget.parse(
                Uri.parse('https://hamrofutsal.com/venues?venue=38'),
              )!
              as VenueDeepLink;

      expect(venue.id, 38);
      expect(venue.slug, isNull);
      expect(venue.searchTerm, isNull);
    });

    test('leaves links the app does not own alone', () {
      expect(
        DeepLinkTarget.parse(Uri.parse('https://example.com/venues/whatever')),
        isNull,
      );
      expect(
        DeepLinkTarget.parse(Uri.parse('https://hamrofutsal.com/')),
        isNull,
      );
      expect(
        DeepLinkTarget.parse(Uri.parse('https://hamrofutsal.com/about-us')),
        isNull,
      );
      expect(DeepLinkTarget.parse(Uri.parse('hamrofutsal://venues')), isNull);
      // Another app's scheme on a path that looks like ours.
      expect(
        DeepLinkTarget.parse(Uri.parse('otherapp://venues/un-park-futsal')),
        isNull,
      );
    });
  });
}
