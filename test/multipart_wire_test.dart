import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/utils/upload_part.dart';

Future<int> wireLength(FormData form) async {
  int total = 0;
  await for (final chunk in form.finalize()) {
    total += chunk.length;
  }
  return total;
}

UploadAttachment attachment(String name, int size) => UploadAttachment(
  filename: name,
  bytes: Uint8List.fromList(List<int>.filled(size, 7)),
);

void main() {
  test('a byte-backed proof reaches the wire with its content', () async {
    final part = buildUploadPart(attachment('Screenshot.jpg', 2048));
    final form = FormData.fromMap(<String, dynamic>{
      'amount': '1402.52',
      'venue_id': 1,
      'payment_proof': part,
    });
    expect(form.files.single.value.length, 2048);
    expect(form.files.single.value.contentType.toString(), 'image/jpeg');
    expect(await wireLength(form), greaterThan(2048));
  });

  test('all upload field names preserve their API contract', () {
    final file = attachment('proof.jpg', 10);
    final Map<String, FormData> forms = <String, FormData>{
      'booking': FormData.fromMap(<String, dynamic>{
        'payment_proof': buildUploadPart(file),
      }),
      'settlement': FormData.fromMap(<String, dynamic>{
        'payment_proof': buildUploadPart(file),
      }),
      'expense': FormData.fromMap(<String, dynamic>{
        'document': buildUploadPart(file),
      }),
      'media': FormData.fromMap(<String, dynamic>{
        'media_files': <MultipartFile>[
          buildUploadPart(file),
          buildUploadPart(file),
        ],
      }, ListFormat.multiCompatible),
    };
    final FormData chat = FormData()
      ..files.add(MapEntry('files[]', buildUploadPart(file)));
    forms['chat'] = chat;

    expect(forms['booking']!.files.single.key, 'payment_proof');
    expect(forms['settlement']!.files.single.key, 'payment_proof');
    expect(forms['expense']!.files.single.key, 'document');
    expect(forms['media']!.files, hasLength(2));
    expect(
      forms['media']!.files.every((entry) => entry.key == 'media_files[]'),
      isTrue,
    );
    expect(forms['chat']!.files.single.key, 'files[]');
    for (final FormData form in forms.values) {
      expect(form.files.every((entry) => entry.value.length == 10), isTrue);
    }
  });

  group('retry after a 401 refresh', () {
    test('re-sending the same FormData is forbidden', () async {
      final form = FormData.fromMap(<String, dynamic>{
        'payment_proof': buildUploadPart(attachment('a.jpg', 512)),
      });
      await wireLength(form);
      expect(() => wireLength(form), throwsA(isA<StateError>()));
    });

    test('a fresh clone carries the full payload on every attempt', () async {
      final form = FormData.fromMap(<String, dynamic>{
        'payment_proof': buildUploadPart(attachment('a.jpg', 512)),
      });
      for (int attempt = 0; attempt < 3; attempt++) {
        final FormData clone = form.clone();
        expect(clone.files.single.value.length, 512);
        expect(await wireLength(clone), greaterThan(512));
      }
    });
  });
}
