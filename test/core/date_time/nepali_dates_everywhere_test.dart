import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/utils/booking_ui_utils.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_details_widgets.dart';
import 'package:hamro_futsal/features/bookings/presentation/widgets/booking_shared_widgets.dart';
import 'package:hamro_futsal/features/expenses/presentation/utils/expense_ui_utils.dart';
import 'package:hamro_futsal/features/message/presentation/utils/message_fmt.dart';
import 'package:hamro_futsal/features/opponent_match/presentation/utils/opponent_ui_utils.dart';
import 'package:hamro_futsal/features/rewards/presentation/utils/rewards_ui.dart';

/// With `use_nepali_calendar` on, the app's date formatters write Bikram
/// Sambat dates — and none still prints a Gregorian month name.
void main() {
  // An old date, so "today / yesterday" shortcuts never kick in.
  // 13 Apr 2024 AD = 1 Baishakh 2081 BS (a Saturday).
  final DateTime d = DateTime(2024, 4, 13, 18, 30);

  const List<String> adMonths = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  Map<String, String Function()> formatters() => <String, String Function()>{
    'DateFmt.date': () => DateFmt.date(d),
    'DateFmt.dateTime': () => DateFmt.dateTime(d),
    'BookingFmt.shortDate': () => BookingFmt.shortDate(d),
    'bookingFormatDate': () => bookingFormatDate(d),
    'bookingDateTimeStamp': () => bookingDateTimeStamp(d),
    'formatShortDate (expenses)': () => formatShortDate(d),
    'MessageFmt.friendly': () => MessageFmt.friendly(d),
    'OpponentFmt.shortDate': () => OpponentFmt.shortDate(d),
    'RewardFmt.date': () => RewardFmt.date(d),
  };

  tearDown(() => AppCalendarController.instance.setCalendar(AppCalendar.ad));

  test('English calendar: Gregorian dates, as before', () {
    for (final MapEntry<String, String Function()> f in formatters().entries) {
      expect(f.value(), contains('Apr'), reason: f.key);
    }
  });

  test('Nepali calendar: every formatter writes the BS date', () {
    AppCalendarController.instance.setCalendar(AppCalendar.bs);
    for (final MapEntry<String, String Function()> f in formatters().entries) {
      final String text = f.value();
      for (final String month in adMonths) {
        expect(text, isNot(contains(month)), reason: '${f.key}: "$text"');
      }
      expect(text, contains('Baishakh'), reason: '${f.key}: "$text"');
    }
    // Numeric dates follow the calendar too: 01/01/2081.
    expect(bookingFormatShortDate(d), '01/01/2081');
  });
}
