import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/data_source/futsal_details_remote_data_source.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_hold_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';

/// Records the `POST /booking-holds` body; nothing else is called.
final class _HoldDataSource implements FutsalDetailsRemoteDataSource {
  Object? sent;

  @override
  Future<Result> createBookingHolds({required Object data}) async {
    sent = data;
    return Result.success(<String, dynamic>{
      'data': <String, dynamic>{
        'hold': <String, dynamic>{'id': 'h1', 'hold_token': 't1'},
      },
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const BookingHoldRequest _six = BookingHoldRequest(
  venueId: 1,
  courtId: 6,
  bookingDate: '2026-10-02',
  startTime: '18:00',
  endTime: '19:00',
);

/// The payload one hold has always sent.
const Map<String, dynamic> _sixJson = <String, dynamic>{
  'venue_id': 1,
  'court_id': 6,
  'booking_date': '2026-10-02',
  'start_time': '18:00',
  'end_time': '19:00',
};

void main() {
  test('times go as H:i, however the slot gave them', () {
    for (final (String given, String sent) in const <(String, String)>[
      ('18:00:00', '18:00'),
      ('18:00', '18:00'),
      ('6:00', '06:00'),
      ('06:30:00', '06:30'),
      ('6:00 PM', '18:00'),
      ('12:00 AM', '00:00'),
      ('12:30 pm', '12:30'),
    ]) {
      expect(BookingHoldRequest.apiHourMinute(given), sent, reason: given);
    }
    const BookingHoldRequest fromSlot = BookingHoldRequest(
      venueId: 1,
      courtId: 6,
      bookingDate: '2026-10-02',
      startTime: '18:00:00',
      endTime: '19:00:00',
    );
    expect(fromSlot.toJson(), _sixJson);
  });

  test('one hold goes as a list of one under `holds`', () async {
    final _HoldDataSource source = _HoldDataSource();
    final Either<AppException, List<BookingHoldModel>> result =
        await FutsalDetailsRepositoryImpl(
          remoteDataSource: source,
        ).createBookingHolds(holds: const <BookingHoldRequest>[_six]);
    expect(result.isRight(), isTrue);
    expect(source.sent, <String, dynamic>{
      'holds': <Map<String, dynamic>>[_sixJson],
    });
  });

  test('several holds go as one `holds` list', () async {
    final _HoldDataSource source = _HoldDataSource();
    await FutsalDetailsRepositoryImpl(
      remoteDataSource: source,
    ).createBookingHolds(
      holds: const <BookingHoldRequest>[
        _six,
        BookingHoldRequest(
          venueId: 1,
          courtId: 7,
          bookingDate: '2026-10-02',
          startTime: '19:00',
          endTime: '20:00',
        ),
      ],
    );
    expect(source.sent, <String, dynamic>{
      'holds': <Map<String, dynamic>>[
        _sixJson,
        <String, dynamic>{
          'venue_id': 1,
          'court_id': 7,
          'booking_date': '2026-10-02',
          'start_time': '19:00',
          'end_time': '20:00',
        },
      ],
    });
  });
}
