import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';

void main() {
  test('HTTP 413 explains that the selected file is too large', () {
    final error = ResponseHelper.error(
      DataError('Request entity too large', 413, null),
    );
    expect(error.statusCode, 413);
    expect(error.errorMessage.toLowerCase(), contains('too large'));
    expect(error.errorMessage.toLowerCase(), contains('smaller'));
  });

  test('zero-byte upload validation becomes an actionable reattach error', () {
    final error = ResponseHelper.error(
      DataError('validation failed', 422, <String, dynamic>{
        'errors': <String, dynamic>{
          'payment_proof': <String>[
            'The payment proof failed to upload because its size is 0.',
          ],
        },
      }),
    );
    expect(error.statusCode, 422);
    expect(error.errorMessage.toLowerCase(), contains('reattach'));
    expect(error.errorMessage.toLowerCase(), contains('smaller'));
  });

  test('ordinary 422 validation messages remain unchanged', () {
    final error = ResponseHelper.error(
      DataError('validation failed', 422, <String, dynamic>{
        'message': 'The transaction reference has already been used.',
      }),
    );
    expect(
      error.errorMessage,
      'The transaction reference has already been used.',
    );
  });
}
