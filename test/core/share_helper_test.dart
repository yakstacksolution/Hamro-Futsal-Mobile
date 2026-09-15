import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/share_helper.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  group('ShareHelper.buildParams', () {
    test('sends a bare link as a uri so targets can preview it', () {
      final ShareParams? params = ShareHelper.buildParams(
        link: 'https://hamrofutsal.com/venues/un-park-futsal',
        subject: 'UN park futsal',
      );

      expect(params, isNotNull);
      expect(
        params!.uri,
        Uri.parse('https://hamrofutsal.com/venues/un-park-futsal'),
      );
      // share_plus throws if both are set.
      expect(params.text, isNull);
      expect(params.subject, 'UN park futsal');
    });

    test('folds the link into text once there is a message', () {
      final ShareParams? params = ShareHelper.buildParams(
        message: 'Book a court at UN park futsal.',
        link: 'https://hamrofutsal.com/venues/un-park-futsal',
      );

      expect(params, isNotNull);
      expect(params!.uri, isNull);
      expect(
        params.text,
        'Book a court at UN park futsal.\n'
        'https://hamrofutsal.com/venues/un-park-futsal',
      );
    });

    test('does not repeat a link the message already quotes', () {
      const String link = 'https://hamrofutsal.com/venues/un-park-futsal';
      final ShareParams? params = ShareHelper.buildParams(
        message: 'Book a court: $link',
        link: link,
      );

      expect(params!.text, 'Book a court: $link');
    });

    test('shares a message on its own when there is no link', () {
      final ShareParams? params = ShareHelper.buildParams(
        message: 'Check out UN park futsal.',
      );

      expect(params!.text, 'Check out UN park futsal.');
      expect(params.uri, isNull);
    });

    test('sends a schemeless link as text, since a Uri needs a scheme', () {
      final ShareParams? params = ShareHelper.buildParams(
        link: 'hamrofutsal.com/venues/un-park-futsal',
      );

      expect(params!.uri, isNull);
      expect(params.text, 'hamrofutsal.com/venues/un-park-futsal');
    });

    test('keeps the app scheme shareable when it is all the backend gave', () {
      final ShareParams? params = ShareHelper.buildParams(
        link: 'hamrofutsal://venues/un-park-futsal',
      );

      expect(params!.uri, Uri.parse('hamrofutsal://venues/un-park-futsal'));
    });

    test('returns null when there is nothing to share', () {
      expect(ShareHelper.buildParams(), isNull);
      expect(ShareHelper.buildParams(message: '   ', link: '  '), isNull);
    });

    test('passes the origin rect through for the iPad popover', () {
      const Rect origin = Rect.fromLTWH(10, 20, 44, 44);
      final ShareParams? params = ShareHelper.buildParams(
        link: 'https://hamrofutsal.com',
        origin: origin,
      );

      expect(params!.sharePositionOrigin, origin);
    });
  });
}
