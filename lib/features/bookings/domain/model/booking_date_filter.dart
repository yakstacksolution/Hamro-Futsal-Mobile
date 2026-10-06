import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/date_time/app_date_format.dart';
import 'package:intl/intl.dart';

enum BookingDateMode {
  all('all'),

  day('day'),

  month('month'),

  range('range');

  const BookingDateMode(this.query);

  final String query;
}

final class BookingDateFilter extends Equatable {
  const BookingDateFilter._({required this.mode, this.from, this.to});

  const BookingDateFilter.all() : this._(mode: BookingDateMode.all);

  factory BookingDateFilter.day(DateTime day) {
    final DateTime start = _startOfDay(day);
    return BookingDateFilter._(
      mode: BookingDateMode.day,
      from: start,
      to: start,
    );
  }

  factory BookingDateFilter.month(DateTime anchor) {
    return BookingDateFilter._(
      mode: BookingDateMode.month,
      from: DateTime(anchor.year, anchor.month),
      // Day 0 of the next month is the last day of this one, so this is right
      // for February and for a leap year without a table of month lengths.
      to: DateTime(anchor.year, anchor.month + 1, 0),
    );
  }

  factory BookingDateFilter.range({DateTime? from, DateTime? to}) {
    final DateTime? start = from == null ? null : _startOfDay(from);
    final DateTime? end = to == null ? null : _startOfDay(to);
    if (start == null && end == null) return const BookingDateFilter.all();
    if (start != null && end != null && end.isBefore(start)) {
      return BookingDateFilter._(
        mode: BookingDateMode.range,
        from: end,
        to: start,
      );
    }
    return BookingDateFilter._(
      mode: BookingDateMode.range,
      from: start,
      to: end,
    );
  }

  final BookingDateMode mode;

  final DateTime? from;

  final DateTime? to;

  DateTime? get fromDate => from;
  DateTime? get toDate => to;

  bool get isActive => mode != BookingDateMode.all;

  DateTime get anchor => from ?? to ?? _startOfDay(DateTime.now());

  bool get canStep =>
      mode == BookingDateMode.day || mode == BookingDateMode.month;

  BookingDateFilter stepped(int steps) => switch (mode) {
    BookingDateMode.day => BookingDateFilter.day(
      DateTime(anchor.year, anchor.month, anchor.day + steps),
    ),
    BookingDateMode.month => BookingDateFilter.month(
      DateTime(anchor.year, anchor.month + steps),
    ),
    BookingDateMode.all || BookingDateMode.range => this,
  };

  String get label => switch (mode) {
    BookingDateMode.all => 'All dates',
    BookingDateMode.day => AppDateFormat.format(anchor, _dayPattern),
    BookingDateMode.month => _monthFormat.format(anchor),
    BookingDateMode.range => _rangeLabel,
  };

  String get modeLabel => switch (mode) {
    BookingDateMode.all => 'All dates',
    BookingDateMode.day => 'Day',
    BookingDateMode.month => 'Month',
    BookingDateMode.range => 'Range',
  };

  String get _rangeLabel {
    if (from != null && to != null) {
      // A window inside one year does not need the year said twice.
      final bool sameYear =
          AppDateFormat.year(from!) == AppDateFormat.year(to!);
      final String start = sameYear
          ? AppDateFormat.format(from!, _dayNoYearPattern)
          : AppDateFormat.format(from!, _shortDayPattern);
      return '$start – ${AppDateFormat.format(to!, _shortDayPattern)}';
    }
    if (from != null) {
      return 'From ${AppDateFormat.format(from!, _shortDayPattern)}';
    }
    return 'Until ${AppDateFormat.format(to!, _shortDayPattern)}';
  }

  Map<String, dynamic> toQueryParameters() => <String, dynamic>{
    'date_filter': mode.query,
    if (mode == BookingDateMode.day) 'date': _ymd(anchor),
    if (mode == BookingDateMode.month) 'month': _ym(anchor),
    if (from != null) 'from_date': _ymd(from!),
    if (to != null) 'to_date': _ymd(to!),
  };

  static String _ymd(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  static String _ym(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}';

  static DateTime _startOfDay(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static const String _dayPattern = 'EEE, d MMM yyyy';
  static const String _shortDayPattern = 'd MMM yyyy';
  static const String _dayNoYearPattern = 'd MMM';
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  @override
  List<Object?> get props => <Object?>[mode, from, to];
}
