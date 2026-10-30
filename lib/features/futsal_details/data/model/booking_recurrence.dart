import 'package:hamro_futsal/core/utils/string_constants.dart';

enum BookingMode { single, recurring }

enum BookingRecurrence {
  twoWeeks(2),
  oneMonth(4),
  twoMonths(8),
  threeMonths(12);

  const BookingRecurrence(this.weeks);

  String get label => switch (this) {
    BookingRecurrence.twoWeeks => StringConstants.twoWeeks,
    BookingRecurrence.oneMonth => StringConstants.oneMonth,
    BookingRecurrence.twoMonths => StringConstants.twoMonths,
    BookingRecurrence.threeMonths => StringConstants.threeMonths,
  };

  final int weeks;

  int get sessions => weeks;

  List<DateTime> datesFrom(
    DateTime start, {
    Set<int> weekdays = const <int>{},
  }) {
    final Set<int> days = weekdays.isEmpty ? <int>{start.weekday} : weekdays;
    final List<DateTime> dates = <DateTime>[];

    for (final int weekday in days) {
      // 0 when `start` is already on this weekday, so a single-day recurrence
      // still begins on the date the user picked.
      final int offset = (weekday - start.weekday + 7) % 7;
      final DateTime first = start.add(Duration(days: offset));
      for (int week = 0; week < weeks; week++) {
        dates.add(first.add(Duration(days: 7 * week)));
      }
    }

    dates.sort();
    return dates;
  }

  int sessionCount(Set<int> weekdays) =>
      weeks * (weekdays.isEmpty ? 1 : weekdays.length);
}

abstract final class RecurringWeekdays {
  static const List<int> displayOrder = <int>[
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
  ];

  static List<String> get _short => <String>[
    StringConstants.weekdayMon,
    StringConstants.weekdayTue,
    StringConstants.weekdayWed,
    StringConstants.weekdayThu,
    StringConstants.weekdayFri,
    StringConstants.weekdaySat,
    StringConstants.weekdaySun,
  ];

  static List<String> get _full => <String>[
    StringConstants.monday,
    StringConstants.tuesday,
    StringConstants.wednesday,
    StringConstants.thursday,
    StringConstants.friday,
    StringConstants.saturday,
    StringConstants.sunday,
  ];

  static String shortLabel(int weekday) => _short[weekday - 1];

  static String fullLabel(int weekday) => _full[weekday - 1];

  static String initial(int weekday) => _short[weekday - 1][0];

  static String summary(Set<int> weekdays) {
    final List<String> labels = displayOrder
        .where(weekdays.contains)
        .map(shortLabel)
        .toList(growable: false);
    if (labels.isEmpty) return '';
    if (labels.length == 1) return labels.single;
    return '${labels.sublist(0, labels.length - 1).join(', ')} & ${labels.last}';
  }
}
