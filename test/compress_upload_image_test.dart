import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/utils/compress_upload_image.dart';

void main() {
  test('leaves an already-small image alone', () async {
    final small = Uint8List.fromList(List<int>.filled(1000, 1));
    expect(
      await compressUploadImage(small, filename: 'a.jpg'),
      same(small),
      reason: 'nothing to gain, and re-encoding costs quality',
    );
  });

  test('leaves non-images alone whatever their size', () async {
    final pdf = Uint8List.fromList(List<int>.filled(5 * 1024 * 1024, 1));
    expect(
      await compressUploadImage(pdf, filename: 'receipt.pdf'),
      same(pdf),
      reason: 'an image codec would corrupt a PDF',
    );
    expect(await compressUploadImage(pdf, filename: 'notes.doc'), same(pdf));
    expect(await compressUploadImage(pdf), same(pdf));
  });

  test('falls back to the original when compression cannot run', () async {
    // Not a decodable image, so the plugin fails: the original must still be
    // returned. A slightly-too-large upload beats no upload.
    final junk = Uint8List.fromList(List<int>.filled(4 * 1024 * 1024, 9));
    expect(await compressUploadImage(junk, filename: 'shot.jpg'), same(junk));
  });

  group('filename', () {
    test('switches to .jpg when the bytes were recompressed', () {
      expect(
        compressedUploadName('Screenshot_20260818.png', wasCompressed: true),
        'Screenshot_20260818.jpg',
      );
    });

    test('is left untouched when nothing was recompressed', () {
      expect(
        compressedUploadName('receipt.pdf', wasCompressed: false),
        'receipt.pdf',
      );
    });

    test('handles a missing name', () {
      expect(
        compressedUploadName(null, wasCompressed: false),
        'attachment.jpg',
      );
    });
  });
}
