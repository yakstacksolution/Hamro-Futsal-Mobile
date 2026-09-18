import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';

void main() {
  const String pendingBooking =
      'This court cannot be closed on 2026-09-18 because it has 1 pending '
      'booking on that date. Cancel or reject them first.';

  ValidationException parse(Map<String, dynamic> body) {
    final AppException failure = ResponseHelper.error(
      DataError('Http status error [422]', 422, body),
    );
    return failure as ValidationException;
  }

  test('update-court 422 keeps the field keys and the server message', () {
    final ValidationException failure = parse(<String, dynamic>{
      'message': 'Validation failed.',
      'errors': <String, dynamic>{
        'closed_dates.1.date': <String>[pendingBooking],
      },
    });

    expect(failure.statusCode, 422);
    expect(failure.errorMessage, pendingBooking);
    expect(failure.fieldErrors['closed_dates.1.date'], <String>[
      pendingBooking,
    ]);
    expect(failure.messagesFor('closed_dates'), <String>[pendingBooking]);
  });

  test('every validation message survives, not just the first', () {
    final ValidationException failure = parse(<String, dynamic>{
      'message': 'Validation failed.',
      'errors': <String, dynamic>{
        'closed_dates.1.date': <String>[pendingBooking],
        'court_name': <String>['The court name has already been taken.'],
      },
    });

    expect(failure.allMessages.length, 2);
    expect(failure.errorMessage, contains(pendingBooking));
    expect(
      failure.errorMessage,
      contains('The court name has already been taken.'),
    );
    expect(failure.messagesFor('court_name').single, contains('already'));
  });

  test('a 422 with no errors bag falls back to the message', () {
    final ValidationException failure = parse(<String, dynamic>{
      'message': 'Validation failed.',
    });

    expect(failure.errorMessage, 'Validation failed.');
    expect(failure.fieldErrors, isEmpty);
  });
}
