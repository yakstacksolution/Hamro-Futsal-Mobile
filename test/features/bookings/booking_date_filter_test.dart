import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/model/booking_date_filter.dart';
import 'package:hamro_futsal/features/bookings/presentation/utils/booking_search.dart';

void main() {
  group('day mode', () {
    test('narrows to exactly that day', () {
      final BookingDateFilter filter = BookingDateFilter.day(
        DateTime(2026, 9, 10, 18, 30),
      );
      expect(filter.fromDate, DateTime(2026, 9, 10));
      expect(filter.toDate, DateTime(2026, 9, 10));
      expect(filter.isActive, isTrue);
      expect(filter.canStep, isTrue);
    });

    test('steps a day at a time, across a month boundary', () {
      final BookingDateFilter filter = BookingDateFilter.day(
        DateTime(2026, 8, 31),
      );
      expect(filter.stepped(1).fromDate, DateTime(2026, 9, 1));
      expect(filter.stepped(-1).fromDate, DateTime(2026, 8, 30));
    });
  });

  group('month mode', () {
    test('spans the whole calendar month', () {
      final BookingDateFilter filter = BookingDateFilter.month(
        DateTime(2026, 9, 17),
      );
      expect(filter.fromDate, DateTime(2026, 9, 1));
      expect(filter.toDate, DateTime(2026, 9, 30));
    });

    // The last day is computed as day 0 of the next month rather than from a
    // table of month lengths, so February and leap years come out right.
    test('gets February right, leap year included', () {
      expect(
        BookingDateFilter.month(DateTime(2026, 2)).toDate,
        DateTime(2026, 2, 28),
      );
      expect(
        BookingDateFilter.month(DateTime(2028, 2)).toDate,
        DateTime(2028, 2, 29),
      );
    });

    test('steps a month at a time, across a year boundary', () {
      final BookingDateFilter december = BookingDateFilter.month(
        DateTime(2026, 12),
      );
      final BookingDateFilter next = december.stepped(1);
      expect(next.fromDate, DateTime(2027, 1, 1));
      expect(next.toDate, DateTime(2027, 1, 31));
    });
  });

  group('range mode', () {
    test('keeps an open end open', () {
      final BookingDateFilter from = BookingDateFilter.range(
        from: DateTime(2026, 9, 1),
      );
      expect(from.fromDate, DateTime(2026, 9, 1));
      expect(from.toDate, isNull);
      expect(from.label, 'From 1 Sep 2026');

      final BookingDateFilter until = BookingDateFilter.range(
        to: DateTime(2026, 9, 30),
      );
      expect(until.fromDate, isNull);
      expect(until.label, 'Until 30 Sep 2026');
    });

    // The sheet lets the two ends be picked in either order, and a window that
    // excludes everything is never what was meant.
    test('swaps ends given the wrong way round', () {
      final BookingDateFilter filter = BookingDateFilter.range(
        from: DateTime(2026, 9, 30),
        to: DateTime(2026, 9, 1),
      );
      expect(filter.fromDate, DateTime(2026, 9, 1));
      expect(filter.toDate, DateTime(2026, 9, 30));
    });

    test('two open ends is no filter at all', () {
      expect(BookingDateFilter.range(), const BookingDateFilter.all());
    });

    test('does not step — a range has no next one', () {
      final BookingDateFilter filter = BookingDateFilter.range(
        from: DateTime(2026, 9, 1),
        to: DateTime(2026, 9, 7),
      );
      expect(filter.canStep, isFalse);
      expect(filter.stepped(1), filter);
    });

    test('says the year once when the window stays inside it', () {
      expect(
        BookingDateFilter.range(
          from: DateTime(2026, 9, 1),
          to: DateTime(2026, 9, 7),
        ).label,
        '1 Sep – 7 Sep 2026',
      );
      expect(
        BookingDateFilter.range(
          from: DateTime(2026, 12, 28),
          to: DateTime(2027, 1, 3),
        ).label,
        '28 Dec 2026 – 3 Jan 2027',
      );
    });
  });

  group('all mode', () {
    test('applies no window, so nothing is filtered out', () {
      const BookingDateFilter filter = BookingDateFilter.all();
      expect(filter.fromDate, isNull);
      expect(filter.toDate, isNull);
      expect(filter.isActive, isFalse);
      expect(filter.canStep, isFalse);
      expect(filter.label, 'All dates');
    });
  });

  // The three modes are only ever applied through this one function, so it is
  // worth pinning that the windows they produce actually select what they say.
  group('applied to bookings', () {
    bool matches(BookingDateFilter filter, DateTime bookingDate) =>
        bookingFallsWithinDateRange(
          _bookingOn(bookingDate),
          fromDate: filter.fromDate,
          toDate: filter.toDate,
        );

    test('a day filter takes that day and nothing either side', () {
      final BookingDateFilter filter = BookingDateFilter.day(
        DateTime(2026, 9, 10),
      );
      expect(matches(filter, DateTime(2026, 9, 10, 23, 59)), isTrue);
      expect(matches(filter, DateTime(2026, 9, 9)), isFalse);
      expect(matches(filter, DateTime(2026, 9, 11)), isFalse);
    });

    test('a month filter takes the first and last day of the month', () {
      final BookingDateFilter filter = BookingDateFilter.month(
        DateTime(2026, 9),
      );
      expect(matches(filter, DateTime(2026, 9, 1)), isTrue);
      expect(matches(filter, DateTime(2026, 9, 30)), isTrue);
      expect(matches(filter, DateTime(2026, 8, 31)), isFalse);
      expect(matches(filter, DateTime(2026, 10, 1)), isFalse);
    });

    test('a range filter includes both ends', () {
      final BookingDateFilter filter = BookingDateFilter.range(
        from: DateTime(2026, 9, 5),
        to: DateTime(2026, 9, 7),
      );
      expect(matches(filter, DateTime(2026, 9, 5)), isTrue);
      expect(matches(filter, DateTime(2026, 9, 7)), isTrue);
      expect(matches(filter, DateTime(2026, 9, 8)), isFalse);
    });

    test('all mode keeps everything', () {
      const BookingDateFilter filter = BookingDateFilter.all();
      expect(matches(filter, DateTime(2020, 1, 1)), isTrue);
      expect(matches(filter, DateTime(2030, 12, 31)), isTrue);
    });
  });

  test('labels name the mode for the summary strip', () {
    expect(BookingDateFilter.day(DateTime(2026, 9, 10)).modeLabel, 'Day');
    expect(BookingDateFilter.month(DateTime(2026, 9)).modeLabel, 'Month');
    expect(
      BookingDateFilter.range(from: DateTime(2026, 9, 1)).modeLabel,
      'Range',
    );
  });
}

BookingModel _bookingOn(DateTime date) => BookingModel(
  id: 1,
  bookingRef: 'HF-1',
  courtName: 'Court A',
  futsalName: 'Goal Arena',
  date: date,
  startTime: '18:00',
  endTime: '19:00',
  status: BookingStatus.confirmed,
  amount: 1800,
);
