import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/utils/upload_part.dart';

void main() {
  late Directory tmp;

  setUp(() => tmp = Directory.systemTemp.createTempSync('upload_part_test'));
  tearDown(() => tmp.deleteSync(recursive: true));

  test('captured bytes survive after the picker path becomes empty', () async {
    final File source = File('${tmp.path}/Screenshot.jpg')
      ..writeAsBytesSync(<int>[1, 2, 3, 4, 5]);
    final UploadAttachment attachment = await loadUploadAttachment(
      path: source.path,
      filename: 'Screenshot.jpg',
      policy: const UploadPolicy(imageTargetBytes: 100),
    );
    source.writeAsBytesSync(<int>[]);

    final part = buildUploadPart(attachment);
    expect(part.length, 5, reason: 'multipart uses captured bytes, not path');
    expect(part.filename, 'Screenshot.jpg');
  });

  test('rejects empty and disappeared picker files before multipart', () async {
    final File empty = File('${tmp.path}/empty.jpg')..writeAsBytesSync(<int>[]);
    await expectLater(
      loadUploadAttachment(path: empty.path, filename: 'empty.jpg'),
      throwsA(
        isA<UploadValidationException>().having(
          (error) => error.code,
          'code',
          UploadValidationCode.empty,
        ),
      ),
    );
    await expectLater(
      loadUploadAttachment(path: '${tmp.path}/gone.jpg', filename: 'gone.jpg'),
      throwsA(isA<UploadValidationException>()),
    );
  });

  test('rejects empty byte construction', () {
    expect(
      () => UploadAttachment(filename: 'x.jpg', bytes: Uint8List(0)),
      throwsA(isA<UploadValidationException>()),
    );
  });

  test('transport guard rejects a legacy zero-length multipart part', () {
    final FormData form = FormData()
      ..files.add(
        MapEntry<String, MultipartFile>(
          'payment_proof',
          MultipartFile.fromBytes(<int>[], filename: 'proof.jpg'),
        ),
      );

    expect(
      () => validateMultipartFormData(form),
      throwsA(
        isA<UploadValidationException>().having(
          (UploadValidationException error) => error.code,
          'code',
          UploadValidationCode.empty,
        ),
      ),
    );
  });

  test('captured bytes override a stale zero-byte picker size', () async {
    final Uint8List pickerBytes = Uint8List.fromList(<int>[4, 5, 6]);
    final UploadAttachment attachment = await normalizeUploadAttachment(
      bytes: pickerBytes,
      filename: 'proof.pdf',
      originalSize: 0,
      policy: const UploadPolicy(allowedExtensions: <String>{'pdf'}),
    );

    pickerBytes[0] = 99;
    expect(attachment.originalSize, 3);
    expect(attachment.bytes, <int>[4, 5, 6]);
    expect(() => attachment.bytes[0] = 1, throwsUnsupportedError);
  });

  test('optimizes a large image and corrects its extension', () async {
    final UploadAttachment attachment = await normalizeUploadAttachment(
      bytes: Uint8List.fromList(List<int>.filled(20, 1)),
      filename: 'receipt.png',
      policy: const UploadPolicy(
        allowedExtensions: <String>{'png'},
        maxInputBytes: 30,
        imageTargetBytes: 10,
      ),
      imageOptimizer:
          (
            Uint8List _, {
            String? filename,
            int targetBytes = kUploadImageTargetBytes,
          }) async => Uint8List.fromList(List<int>.filled(targetBytes, 2)),
    );

    expect(attachment.filename, 'receipt.jpg');
    expect(attachment.size, 10);
    expect(attachment.originalSize, 20);
    expect(attachment.mimeType, 'image/jpeg');
  });

  test('normalizes optimized HEIC bytes and filename to JPEG', () async {
    final UploadAttachment attachment = await normalizeUploadAttachment(
      bytes: Uint8List.fromList(List<int>.filled(20, 1)),
      filename: 'camera.heic',
      policy: const UploadPolicy(
        allowedExtensions: <String>{'heic'},
        maxInputBytes: 30,
        imageTargetBytes: 10,
      ),
      imageOptimizer:
          (
            Uint8List _, {
            String? filename,
            int targetBytes = kUploadImageTargetBytes,
          }) async => Uint8List.fromList(List<int>.filled(8, 2)),
    );

    expect(attachment.filename, 'camera.jpg');
    expect(attachment.mimeType, 'image/jpeg');
    expect(attachment.size, 8);
  });

  test('rejects an image that cannot reach the safe target', () async {
    await expectLater(
      normalizeUploadAttachment(
        bytes: Uint8List.fromList(List<int>.filled(20, 1)),
        filename: 'receipt.jpg',
        policy: const UploadPolicy(
          allowedExtensions: <String>{'jpg'},
          maxInputBytes: 30,
          imageTargetBytes: 10,
        ),
        imageOptimizer:
            (
              Uint8List bytes, {
              String? filename,
              int targetBytes = kUploadImageTargetBytes,
            }) async => bytes,
      ),
      throwsA(
        isA<UploadValidationException>().having(
          (error) => error.code,
          'code',
          UploadValidationCode.imageOptimizationFailed,
        ),
      ),
    );
  });

  test('keeps documents unchanged and enforces their input limit', () async {
    final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3]);
    final UploadAttachment document = await normalizeUploadAttachment(
      bytes: bytes,
      filename: 'receipt.pdf',
      policy: const UploadPolicy(
        allowedExtensions: <String>{'pdf'},
        maxInputBytes: 3,
      ),
    );
    expect(document.bytes, bytes);
    await expectLater(
      normalizeUploadAttachment(
        bytes: Uint8List.fromList(<int>[1, 2, 3, 4]),
        filename: 'receipt.pdf',
        policy: const UploadPolicy(
          allowedExtensions: <String>{'pdf'},
          maxInputBytes: 3,
        ),
      ),
      throwsA(
        isA<UploadValidationException>().having(
          (error) => error.code,
          'code',
          UploadValidationCode.fileTooLarge,
        ),
      ),
    );
  });

  test('enforces file-count and total-body limits', () {
    final List<UploadAttachment> files = List<UploadAttachment>.generate(
      2,
      (index) => UploadAttachment(
        filename: 'file$index.pdf',
        bytes: Uint8List.fromList(<int>[1, 2]),
      ),
    );
    expect(
      () => validateUploadBatch(files, policy: const UploadPolicy(maxFiles: 1)),
      throwsA(isA<UploadValidationException>()),
    );
    expect(
      () => validateUploadBatch(
        files,
        policy: const UploadPolicy(maxRequestBytes: 3),
      ),
      throwsA(isA<UploadValidationException>()),
    );
  });
}
