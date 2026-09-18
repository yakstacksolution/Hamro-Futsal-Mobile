import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/routers/deep_link_target.dart';
import 'package:hamro_futsal/features/message/domain/model/message_links.dart';

void main() {
  group('findLinkSpans', () {
    test('picks a shared venue link out of a sentence and marks it internal', () {
      const String body =
          'Booked here 👉 https://hamrofutsal.com/venues/un-park-futsal?venue=38 '
          'see you at 7';

      final List<LinkSpan> spans = findLinkSpans(body);

      expect(spans.length, 1);
      final LinkSpan link = spans.single;
      expect(body.substring(link.start, link.end), link.text);
      expect(link.isInternal, isTrue);
      expect((link.target! as VenueDeepLink).id, 38);
    });

    test('an outside link is still a link, just not an internal one', () {
      final List<LinkSpan> spans = findLinkSpans('map: https://maps.app/x/abc');

      expect(spans.single.uri.host, 'maps.app');
      expect(spans.single.isInternal, isFalse);
    });

    test('www gets the scheme it omits', () {
      final LinkSpan link = findLinkSpans(
        'www.hamrofutsal.com/venues/goal-zone',
      ).single;

      expect(link.uri.scheme, 'https');
      expect(link.text, 'www.hamrofutsal.com/venues/goal-zone');
      expect(link.isInternal, isTrue);
    });

    test('the app scheme is picked up too', () {
      final LinkSpan link = findLinkSpans(
        'open hamrofutsal://venues/un-park-futsal',
      ).single;

      expect(link.isInternal, isTrue);
    });

    test('a full stop after a URL is punctuation, not part of it', () {
      final LinkSpan link = findLinkSpans(
        'Join at https://hamrofutsal.com/venues/un-park-futsal.',
      ).single;

      expect(link.text, 'https://hamrofutsal.com/venues/un-park-futsal');
    });

    test('a link that ends in a bracket it opened keeps it', () {
      final LinkSpan link = findLinkSpans(
        'https://en.wikipedia.org/wiki/Futsal_(sport)',
      ).single;

      expect(link.text, 'https://en.wikipedia.org/wiki/Futsal_(sport)');
    });

    test('several links in one message are all found, in order', () {
      final List<LinkSpan> spans = findLinkSpans(
        'https://hamrofutsal.com/venues/a?venue=1 or https://example.com/b',
      );

      expect(spans.map((LinkSpan item) => item.uri.host), <String>[
        'hamrofutsal.com',
        'example.com',
      ]);
    });

    test('ordinary text holds no links', () {
      expect(findLinkSpans('hi.Are you coming at 7?'), isEmpty);
      expect(findLinkSpans('mail me at hello@hamrofutsal.com'), isEmpty);
      expect(findLinkSpans(''), isEmpty);
    });
  });
}
