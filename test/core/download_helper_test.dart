import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/download_helper.dart';
import 'package:hamro_futsal/core/widgets/attachment_viewer.dart';

void main() {
  group('DownloadHelper.resolveFileName', () {
    test(
      'keeps the uploaded name from the URL when it carries an extension',
      () {
        expect(
          DownloadHelper.resolveFileName(
            uri: Uri.parse(
              'https://api.example.com/storage/proofs/esewa-99.png',
            ),
          ),
          'esewa-99.png',
        );
      },
    );

    test('prefers an explicit name over the URL segment', () {
      expect(
        DownloadHelper.resolveFileName(
          uri: Uri.parse('https://api.example.com/storage/proofs/abc123.png'),
          preferredName: 'payment-proof-7.png',
        ),
        'payment-proof-7.png',
      );
    });

    test(
      'falls back to the content type when nothing carries an extension',
      () {
        expect(
          DownloadHelper.resolveFileName(
            uri: Uri.parse('https://api.example.com/proofs/9182'),
            preferredName: 'payment-proof-9182',
            contentType: 'application/pdf; charset=binary',
          ),
          'payment-proof-9182.pdf',
        );
      },
    );

    test('stamps a name when the URL is a bare id and the type is unknown', () {
      final String name = DownloadHelper.resolveFileName(
        uri: Uri.parse('https://api.example.com/proofs/9182'),
      );
      expect(name, startsWith('download_'));
      expect(name, endsWith('.jpg'));
    });

    // A server-supplied name must not be able to reach outside the directory
    // the file is written to.
    test('strips path separators out of a supplied name', () {
      final String name = DownloadHelper.resolveFileName(
        uri: Uri.parse('https://api.example.com/proofs/9182'),
        preferredName: '../../etc/passwd.png',
      );
      expect(name, isNot(contains('/')));
      expect(name, isNot(startsWith('.')));
    });
  });

  group('isViewableImageUrl', () {
    test('accepts the image types the proof field takes', () {
      for (final String extension in <String>['jpg', 'jpeg', 'png', 'webp']) {
        expect(
          isViewableImageUrl('https://api.example.com/p/proof.$extension'),
          isTrue,
          reason: extension,
        );
      }
    });

    test('rejects a PDF, so it gets the file tile instead of a preview', () {
      expect(
        isViewableImageUrl('https://api.example.com/p/proof.pdf'),
        isFalse,
      );
    });

    test('rejects nothing and nonsense', () {
      expect(isViewableImageUrl(null), isFalse);
      expect(isViewableImageUrl(''), isFalse);
    });

    test('ignores a query string after the extension', () {
      expect(
        isViewableImageUrl('https://api.example.com/p/proof.png?expires=12'),
        isTrue,
      );
    });
  });
}
