import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_recurrence.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';

void main() {
  // Sunday 16 Aug 2026.
  final DateTime sunday = DateTime(2026, 8, 16);

  String iso(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  group('datesFrom', () {
    test('with no weekdays repeats on the start date\'s own weekday', () {
      final List<DateTime> dates = BookingRecurrence.twoWeeks.datesFrom(sunday);

      // The historical behaviour: one session per week, starting on the day
      // the user picked.
      expect(dates.map(iso), <String>['2026-08-16', '2026-08-23']);
    });

    test('books every selected weekday in each week of the horizon', () {
      final List<DateTime> dates = BookingRecurrence.twoWeeks.datesFrom(
        sunday,
        weekdays: <int>{DateTime.sunday, DateTime.monday},
      );

      expect(dates.map(iso), <String>[
        '2026-08-16', // Sun
        '2026-08-17', // Mon
        '2026-08-23',
        '2026-08-24',
      ]);
    });

    test('is chronological regardless of the order days were picked', () {
      final List<DateTime> dates = BookingRecurrence.twoWeeks.datesFrom(
        sunday,
        weekdays: <int>{DateTime.wednesday, DateTime.monday},
      );

      expect(dates.map(iso), <String>[
        '2026-08-17', // Mon
        '2026-08-19', // Wed
        '2026-08-24',
        '2026-08-26',
      ]);
    });

    test('a weekday earlier in the week lands after the start date', () {
      // Start Wednesday, repeat on Monday: the first Monday is the next one,
      // never the one before the user's date.
      final DateTime wednesday = DateTime(2026, 8, 19);
      final List<DateTime> dates = BookingRecurrence.twoWeeks.datesFrom(
        wednesday,
        weekdays: <int>{DateTime.monday},
      );

      expect(dates.first.isAfter(wednesday), isTrue);
      expect(dates.map(iso), <String>['2026-08-24', '2026-08-31']);
    });

    test('session count is weeks × days', () {
      expect(
        BookingRecurrence.oneMonth
            .datesFrom(
              sunday,
              weekdays: <int>{
                DateTime.sunday,
                DateTime.monday,
                DateTime.friday,
              },
            )
            .length,
        4 * 3,
      );
      expect(
        BookingRecurrence.oneMonth.sessionCount(<int>{
          DateTime.sunday,
          DateTime.monday,
        }),
        8,
      );
      // An empty set still means one day a week.
      expect(BookingRecurrence.oneMonth.sessionCount(const <int>{}), 4);
    });
  });

  group('weekday labels', () {
    test('the picker runs Sunday first', () {
      expect(RecurringWeekdays.displayOrder.first, DateTime.sunday);
      expect(RecurringWeekdays.displayOrder.last, DateTime.saturday);
      expect(RecurringWeekdays.displayOrder.length, 7);
    });

    test('summary reads in week order, not selection order', () {
      expect(
        RecurringWeekdays.summary(<int>{DateTime.monday, DateTime.sunday}),
        'Sun & Mon',
      );
      expect(
        RecurringWeekdays.summary(<int>{
          DateTime.wednesday,
          DateTime.sunday,
          DateTime.monday,
        }),
        'Sun, Mon & Wed',
      );
      expect(RecurringWeekdays.summary(<int>{DateTime.friday}), 'Fri');
    });
  });

  group('create payload', () {
    CreateBookingRequest requestWith({
      int? repeatWeeks,
      List<String> bookingDates = const <String>[],
    }) => CreateBookingRequest(
      venueId: 1,
      courtId: 2,
      bookingDate: '2026-08-16',
      startTime: '07:00',
      paymentMethod: 'cash',
      repeatWeeks: repeatWeeks,
      bookingDates: bookingDates,
    );

    test('sends every session date under an array key', () {
      final Map<String, dynamic> fields = requestWith(
        bookingDates: <String>['2026-08-16', '2026-08-17'],
      ).toFields();

      // The `[]` suffix matters: these go out as multipart fields, where a
      // repeated bare key would collapse to its last value.
      expect(fields['booking_dates[]'], <String>['2026-08-16', '2026-08-17']);
    });

    test('omits the key entirely for a single-session booking', () {
      expect(requestWith().toFields().containsKey('booking_dates[]'), isFalse);
    });

    test('repeat_weeks still rides along for a single-weekday recurrence', () {
      final Map<String, dynamic> fields = requestWith(
        repeatWeeks: 4,
        bookingDates: <String>['2026-08-16'],
      ).toFields();

      expect(fields['repeat_weeks'], 4);
    });
  });
}
