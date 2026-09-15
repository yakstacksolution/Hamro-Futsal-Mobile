import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_list_query.dart';

/// The agreed payload for `GET /bookings` and `GET /futsal-bookings`. Both
/// endpoints take the same parameters, so one query object builds both and
/// these are the exact maps it has to produce.
void main() {
  test('all — no date window', () {
    expect(
      const BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
      ).toQueryParameters(),
      <String, dynamic>{
        'page': 1,
        'per_page': 10,
        'status': 'all',
        'date_filter': 'all',
        'sort': 'date',
        'order': 'desc',
      },
    );
  });

  test('day — the day, plus the window it means', () {
    expect(
      BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.day(DateTime(2026, 9, 10)),
      ).toQueryParameters(),
      <String, dynamic>{
        'page': 1,
        'per_page': 10,
        'status': 'all',
        'date_filter': 'day',
        'date': '2026-09-10',
        'from_date': '2026-09-10',
        'to_date': '2026-09-10',
        'sort': 'date',
        'order': 'desc',
      },
    );
  });

  test('month — the month, plus its first and last day', () {
    expect(
      BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.month(DateTime(2026, 9)),
      ).toQueryParameters(),
      <String, dynamic>{
        'page': 1,
        'per_page': 10,
        'status': 'all',
        'date_filter': 'month',
        'month': '2026-09',
        'from_date': '2026-09-01',
        'to_date': '2026-09-30',
        'sort': 'date',
        'order': 'desc',
      },
    );
  });

  test('range — both ends, ascending', () {
    expect(
      BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.range(
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 7),
        ),
        order: BookingDateOrder.ascending,
      ).toQueryParameters(),
      <String, dynamic>{
        'page': 1,
        'per_page': 10,
        'status': 'all',
        'date_filter': 'range',
        'from_date': '2026-09-01',
        'to_date': '2026-09-07',
        'sort': 'date',
        'order': 'asc',
      },
    );
  });

  test('range — open end omits to_date entirely', () {
    final Map<String, dynamic> payload = BookingListQuery(
      page: 1,
      perPage: 10,
      status: 'all',
      dateFilter: BookingDateFilter.range(from: DateTime(2026, 9, 1)),
    ).toQueryParameters();

    expect(payload, <String, dynamic>{
      'page': 1,
      'per_page': 10,
      'status': 'all',
      'date_filter': 'range',
      'from_date': '2026-09-01',
      'sort': 'date',
      'order': 'desc',
    });
    // Absent, not null — a null would be serialised as an empty parameter.
    expect(payload.containsKey('to_date'), isFalse);
  });

  group('edges', () {
    test('a status is sent as given, and a blank one is dropped', () {
      expect(
        const BookingListQuery(
          page: 3,
          perPage: 10,
          status: 'pending',
        ).toQueryParameters()['status'],
        'pending',
      );
      expect(
        const BookingListQuery(
          page: 1,
          perPage: 10,
          status: '  ',
        ).toQueryParameters().containsKey('status'),
        isFalse,
      );
    });

    test('dates are zero-padded, never single-digit', () {
      final Map<String, dynamic> payload = BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.day(DateTime(2026, 1, 5)),
      ).toQueryParameters();
      expect(payload['date'], '2026-01-05');
      expect(payload['from_date'], '2026-01-05');
    });

    test('the month shorthand carries no day', () {
      expect(
        BookingListQuery(
          page: 1,
          perPage: 10,
          status: 'all',
          dateFilter: BookingDateFilter.month(DateTime(2026, 1)),
        ).toQueryParameters()['month'],
        '2026-01',
      );
    });

    // `date` and `month` are each mode's own shorthand, so they must not leak
    // into a mode that does not mean them.
    test('mode shorthands do not leak across modes', () {
      final Map<String, dynamic> day = BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.day(DateTime(2026, 9, 10)),
      ).toQueryParameters();
      expect(day.containsKey('month'), isFalse);

      final Map<String, dynamic> month = BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.month(DateTime(2026, 9)),
      ).toQueryParameters();
      expect(month.containsKey('date'), isFalse);

      final Map<String, dynamic> range = BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'all',
        dateFilter: BookingDateFilter.range(from: DateTime(2026, 9, 1)),
      ).toQueryParameters();
      expect(range.containsKey('date'), isFalse);
      expect(range.containsKey('month'), isFalse);
    });

    test('paging keeps the window it started with', () {
      final BookingListQuery first = BookingListQuery(
        page: 1,
        perPage: 10,
        status: 'confirmed',
        dateFilter: BookingDateFilter.month(DateTime(2026, 9)),
        order: BookingDateOrder.ascending,
      );
      final Map<String, dynamic> second = first
          .copyWith(page: 2)
          .toQueryParameters();

      expect(second['page'], 2);
      expect(second['from_date'], '2026-09-01');
      expect(second['to_date'], '2026-09-30');
      expect(second['order'], 'asc');
      expect(second['status'], 'confirmed');
    });
  });
}
