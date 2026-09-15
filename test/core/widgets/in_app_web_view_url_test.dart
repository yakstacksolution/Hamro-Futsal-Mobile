import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/in_app_web_view_page.dart';

void main() {
  group('InAppWebViewPage.resolveUrl', () {
    test('asks the site for its mobile rendering', () {
      expect(
        InAppWebViewPage.resolveUrl(
          'https://hamrofutsal.com/terms-and-conditions',
        ).toString(),
        'https://hamrofutsal.com/terms-and-conditions?type=mobile',
      );
    });

    test('keeps a query the URL already carries', () {
      final Uri resolved = InAppWebViewPage.resolveUrl(
        'https://hamrofutsal.com/privacy-policy?lang=np',
      );

      expect(resolved.queryParameters['lang'], 'np');
      expect(resolved.queryParameters['type'], 'mobile');
    });

    test('does not override an explicit type', () {
      expect(
        InAppWebViewPage.resolveUrl(
          'https://hamrofutsal.com/terms-and-conditions?type=print',
        ).queryParameters['type'],
        'print',
      );
    });

    test('leaves the URL alone when the variant is not wanted', () {
      expect(
        InAppWebViewPage.resolveUrl(
          'https://example.com/page',
          mobileVariant: false,
        ).toString(),
        'https://example.com/page',
      );
    });
  });
}
