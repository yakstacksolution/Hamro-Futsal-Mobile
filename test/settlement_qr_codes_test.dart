import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';

void main() {
  const Map<String, dynamic> response = <String, dynamic>{
    'status': 'success',
    'message': 'QR codes fetched successfully.',
    'data': <String, dynamic>{
      'qr_codes': <dynamic>[
        <String, dynamic>{
          'id': 2,
          'title': 'two',
          'image':
              'https://hamrofutsal.com//storage/qr_codes/2/image/405/b.png',
          'status': true,
          'sort_order': 2,
        },
        <String, dynamic>{
          'id': 1,
          'title': 'New',
          'image':
              'https://hamrofutsal.com//storage/qr_codes/1/image/404/a.png',
          'status': true,
          'sort_order': 1,
        },
      ],
    },
  };

  test('parses the /auth/qr-codes payload in sort_order', () {
    final codes = SettlementQrCodeModel.listFromResponse(response);
    expect(codes.length, 2);
    expect(codes.first.id, 1);
    expect(codes.first.title, 'New');
    expect(codes.first.sortOrder, 1);
    expect(codes.first.qr.qrImageUrl, contains('404/a.png'));
    expect(codes.last.title, 'two');
  });

  test('drops retired and imageless entries', () {
    final codes = SettlementQrCodeModel.listFromResponse(<String, dynamic>{
      'data': <String, dynamic>{
        'qr_codes': <dynamic>[
          <String, dynamic>{
            'id': 1,
            'title': 'off',
            'image': 'https://x/a.png',
            'status': false,
          },
          <String, dynamic>{'id': 2, 'title': 'no image', 'status': true},
          <String, dynamic>{
            'id': 3,
            'title': 'ok',
            'image': 'https://x/c.png',
            'status': true,
          },
        ],
      },
    });
    expect(codes.map((e) => e.id), <int>[3]);
  });

  test('survives an empty or unexpected envelope', () {
    expect(SettlementQrCodeModel.listFromResponse(null), isEmpty);
    expect(
      SettlementQrCodeModel.listFromResponse(<String, dynamic>{}),
      isEmpty,
    );
    expect(SettlementQrCodeModel.listFromResponse('nonsense'), isEmpty);
  });
}
