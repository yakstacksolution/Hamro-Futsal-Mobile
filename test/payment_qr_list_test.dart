import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/payment_qr_model.dart';

void main() {
  test('parses every active QR from payment_qr_media_list', () {
    final PaymentQrModel qr = PaymentQrModel.fromResponse(<String, dynamic>{
      'status': 'success',
      'data': <String, dynamic>{
        'court_id': 14,
        'court_name': 'Court 1',
        'venue': <String, dynamic>{'id': 2, 'name': 'Dhanawantary Sports'},
        'payment_qr_media': null,
        'payment_qr_media_list': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 682,
            'name': 'camera_1',
            'full_url':
                'https://staging.hamrofutsal.com//storage/court/14/payment_qr/682/a.jpg',
            'status': 'active',
          },
          <String, dynamic>{
            'id': 683,
            'name': 'camera_2',
            'full_url':
                'https://staging.hamrofutsal.com//storage/court/14/payment_qr/683/b.jpg',
            'status': 'active',
          },
          <String, dynamic>{
            'id': 684,
            'full_url': 'https://staging.hamrofutsal.com/storage/c.jpg',
            'status': 'inactive',
          },
        ],
      },
    });

    expect(qr.hasQr, isTrue);
    expect(qr.payeeName, 'Dhanawantary Sports');
    expect(qr.images.map((PaymentQrImage i) => i.id), <int>[682, 683]);
    expect(
      qr.images.first.url,
      'https://staging.hamrofutsal.com/storage/court/14/payment_qr/682/a.jpg',
    );
    expect(qr.qrImageUrl, qr.images.first.url);
  });

  test('falls back to the single payment_qr_media', () {
    final PaymentQrModel qr = PaymentQrModel.fromResponse(<String, dynamic>{
      'data': <String, dynamic>{
        'payment_qr_media': <String, dynamic>{
          'full_url': 'https://example.com/storage/qr.png',
        },
        'payment_qr_media_list': <dynamic>[],
      },
    });

    expect(qr.images, hasLength(1));
    expect(qr.qrImageUrl, 'https://example.com/storage/qr.png');
  });

  test('no QR yields an empty list', () {
    final PaymentQrModel qr = PaymentQrModel.fromResponse(<String, dynamic>{
      'data': <String, dynamic>{'payment_qr_media': null},
    });
    expect(qr.hasQr, isFalse);
    expect(qr.images, isEmpty);
  });
}
