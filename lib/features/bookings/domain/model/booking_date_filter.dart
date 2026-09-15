import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

/// How the futsal bookings list is narrowed by date.
enum BookingDateMode {
  /// Every date — the date filter is off.
  all('all'),

  /// One day. The arrows step a day at a time.
  day('day'),

  /// A whole calendar month. The arrows step a month at a time.
  month('month'),

  /// An arbitrary from/to window.
  range('range');

  const BookingDateMode(this.query);

  /// The value the endpoint's `date_filter` parameter takes.
  final String query;
}

/// The date filter on the futsal bookings list.
///
/// All three modes are the same thing to whatever does the filtering — a
/// [fromDate]/[toDate] window — so the list, the summary strip and the sheet
/// all read one value instead of a mode flag plus three sets of dates that can
/// disagree with each other. The mode is kept only because the *user* means
/// something different by each: it decides what the arrows step by and how the
/// window is described.
final class BookingDateFilter extends Equatable {
  const BookingDateFilter._({required this.mode, this.from, this.to});

  /// No date filter.
  const BookingDateFilter.all() : this._(mode: BookingDateMode.all);

  /// A single day.
  factory BookingDateFilter.day(DateTime day) {
    final DateTime start = _startOfDay(day);
    return BookingDateFilter._(
      mode: BookingDateMode.day,
      from: start,
      to: start,
    );
  }

  /// The whole calendar month [anchor] falls in.
  factory BookingDateFilter.month(DateTime anchor) {
    return BookingDateFilter._(
      mode: BookingDateMode.month,
      from: DateTime(anchor.year, anchor.month),
      // Day 0 of the next month is the last day of this one, so this is right
      // for February and for a leap year without a table of month lengths.
      to: DateTime(anchor.year, anchor.month + 1, 0),
    );
  }

  /// An arbitrary window. Either end may be open.
  ///
  /// Ends given the wrong way round are swapped rather than rejected: the
  /// sheet lets them be picked in either order, and a window that excludes
  /// everything is never what was meant.
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

  /// Inclusive first day of the window, or null when it is open-ended.
  final DateTime? from;

  /// Inclusive last day of the window, or null when it is open-ended.
  final DateTime? to;

  DateTime? get fromDate => from;
  DateTime? get toDate => to;

  bool get isActive => mode != BookingDateMode.all;

  /// Which day or month the arrows move from.
  DateTime get anchor => from ?? to ?? _startOfDay(DateTime.now());

  /// True where stepping makes sense: a day and a month have a next one, an
  /// arbitrary range does not.
  bool get canStep =>
      mode == BookingDateMode.day || mode == BookingDateMode.month;

  /// The same filter moved [steps] units — days in [BookingDateMode.day],
  /// months in [BookingDateMode.month] — which is what the arrows do.
  BookingDateFilter stepped(int steps) => switch (mode) {
    BookingDateMode.day => BookingDateFilter.day(
      DateTime(anchor.year, anchor.month, anchor.day + steps),
    ),
    BookingDateMode.month => BookingDateFilter.month(
      DateTime(anchor.year, anchor.month + steps),
    ),
    BookingDateMode.all || BookingDateMode.range => this,
  };

  /// How the window reads in the summary strip.
  String get label => switch (mode) {
    BookingDateMode.all => 'All dates',
    BookingDateMode.day => _dayFormat.format(anchor),
    BookingDateMode.month => _monthFormat.format(anchor),
    BookingDateMode.range => _rangeLabel,
  };

  /// What kind of window this is, for the strip's leading pill.
  String get modeLabel => switch (mode) {
    BookingDateMode.all => 'All dates',
    BookingDateMode.day => 'Day',
    BookingDateMode.month => 'Month',
    BookingDateMode.range => 'Range',
  };

  String get _rangeLabel {
    if (from != null && to != null) {
      // A window inside one year does not need the year said twice.
      final bool sameYear = from!.year == to!.year;
      final String start = sameYear
          ? _dayNoYearFormat.format(from!)
          : _shortDayFormat.format(from!);
      return '$start – ${_shortDayFormat.format(to!)}';
    }
    if (from != null) return 'From ${_shortDayFormat.format(from!)}';
    return 'Until ${_shortDayFormat.format(to!)}';
  }

  /// The date parameters this window contributes to a booking-list request.
  ///
  /// `from_date`/`to_date` are filled in every mode, day and month included —
  /// they *are* the window, and `date`/`month` are only that mode's own
  /// shorthand for it. So the server needs one date-range implementation, not
  /// three, and reads `date_filter` only to know what it was asked for.
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

  static final DateFormat _dayFormat = DateFormat('EEE, d MMM yyyy');
  static final DateFormat _shortDayFormat = DateFormat('d MMM yyyy');
  static final DateFormat _dayNoYearFormat = DateFormat('d MMM');
  static final DateFormat _monthFormat = DateFormat('MMMM yyyy');

  @override
  List<Object?> get props => <Object?>[mode, from, to];
}
