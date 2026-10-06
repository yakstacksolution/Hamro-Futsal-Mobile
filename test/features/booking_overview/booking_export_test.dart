import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/features/booking_overview/data/data_source/booking_overview_data_source.dart';
import 'package:hamro_futsal/features/booking_overview/data/repositories/booking_overview_repository_impl.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/csv_parser.dart';

final class _FakeDataSource implements BookingOverviewDataSource {
  _FakeDataSource(this.body);

  final dynamic body;
  Map<String, dynamic>? exportQuery;

  @override
  Future<Result> fetchBookingOverview({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async => Result.error(DataError('unused', 0, null));

  @override
  Future<Result> exportBookingsOverView({
    String? dateFilter,
    String? dateFrom,
    String? dateTo,
    List<String>? venueIds,
  }) async {
    exportQuery = bookingOverviewQuery(
      dateFilter: dateFilter,
      dateFrom: dateFrom,
      dateTo: dateTo,
      venueIds: venueIds,
    );
    return Result.success(body);
  }
}

void main() {
  test('export sends the same filter payload as the overview', () {
    expect(
      bookingOverviewQuery(
        dateFilter: 'custom',
        dateFrom: '2026-09-01',
        dateTo: '2026-09-30',
        venueIds: <String>['7'],
      ),
      <String, dynamic>{
        'date_filter': 'custom',
        'date_from': '2026-09-01',
        'date_to': '2026-09-30',
        'venue_ids': <String>['7'],
      },
    );
    expect(bookingOverviewQuery(dateFilter: 'week'), <String, dynamic>{
      'date_filter': 'week',
    });
    expect(bookingOverviewQuery(), isNull);
  });

  test('CSV bytes come back as a .csv file', () async {
    final source = _FakeDataSource(utf8.encode('id,customer\n1,Ram\n'));
    final result = await BookingOverviewRepositoryImpl(
      dataSource: source,
    ).exportBookingsOverView(dateFilter: 'week', venueIds: <String>['3']);

    final file = result.getOrElse(() => throw StateError('expected a file'));
    expect(file.bytes, isNotEmpty);
    expect(file.fileName, startsWith('bookings_week_'));
    expect(file.fileName, endsWith('.csv'));
    expect(source.exportQuery, <String, dynamic>{
      'date_filter': 'week',
      'venue_ids': <String>['3'],
    });
  });

  test('CSV parser handles quotes, escapes, CRLF and a BOM', () {
    const String csv =
        '﻿id,name,note\r\n'
        '1,"Ram, Shyam","said ""hi"""\r\n'
        '\r\n'
        '2,Hari,"two\nlines"\n';
    expect(parseCsv(csv), <List<String>>[
      <String>['id', 'name', 'note'],
      <String>['1', 'Ram, Shyam', 'said "hi"'],
      <String>['2', 'Hari', 'two\nlines'],
    ]);
  });

  test('an empty body is a failure', () async {
    final result = await BookingOverviewRepositoryImpl(
      dataSource: _FakeDataSource(<int>[]),
    ).exportBookingsOverView();
    expect(result.isLeft(), isTrue);
  });
}
