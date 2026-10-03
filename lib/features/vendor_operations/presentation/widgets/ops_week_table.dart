import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_style.dart';
import 'package:shimmer/shimmer.dart';

/// One court's whole week as a table: a row per slot time, a column per day,
/// each cell showing the slot's status and price.
///
/// Free cells add to the manual booking (any day of the week); booked cells
/// open the booking's details.
class OpsWeekTableView extends StatelessWidget {
  const OpsWeekTableView({
    super.key,
    required this.onBookingTap,
    this.rightInset = 0,
  });

  final OpsBookingTap onBookingTap;

  /// The page margin this view is laid out without on the right. The table
  /// and court picker run to the edge; the week controls and messages keep
  /// the margin.
  final double rightInset;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.weekCourtId != b.weekCourtId ||
          // Back to a week already loaded changes nothing else.
          a.weekStartMode != b.weekStartMode ||
          a.weekBookings != b.weekBookings ||
          a.weekSlots != b.weekSlots ||
          a.weekSlotsLoading != b.weekSlotsLoading ||
          a.weekSlotsError != b.weekSlotsError ||
          // Not the selection: each cell watches its own.
          a.date != b.date ||
          a.courts != b.courts ||
          a.venueIds != b.venueIds ||
          a.board?.nowMinute != b.board?.nowMinute,
      builder: (BuildContext context, VendorOpsState state) {
        final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
        final List<OpsCourt> courts = state.filterableCourts;
        final OpsCourt? court = state.tableCourt;
        if (court == null) {
          return const _Message(
            icon: Icons.filter_alt_off_rounded,
            text: 'No courts match the venue filter.',
          );
        }
        // The server's week is the table: its slots carry their bookings.
        // Until it answers the table waits; if it fails, it offers a retry
        // rather than guessing from the court's schedule, which knows no
        // bookings.
        final OpsCourtWeekAvailability? live = state.weekSlotsFor(
          court.id,
          state.weekStart,
        );

        final EdgeInsets margin = EdgeInsets.only(right: rightInset);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // A picker only when there is a choice: with a single court
            // (one venue, one court — or a filter down to one) the table is
            // simply that court's.
            if (courts.length > 1) ...<Widget>[
              _CourtPicker(
                courts: courts,
                selected: court,
                // Free slots per court this week, for courts whose week the
                // server has sent. Others show no count rather than "full".
                freeThisWeek: <int, int>{
                  for (final OpsCourt c in courts)
                    if (state.weekSlotsFor(c.id, state.weekStart)
                        case final OpsCourtWeekAvailability server)
                      c.id: buildWeekTable(
                        court: c,
                        bookings: const <BookingModel>[],
                        weekStart: state.weekStart,
                        today: KathmanduClock.today(),
                        nowMinute: KathmanduClock.minuteOfDay(),
                        server: server,
                      ).freeCount,
                },
              ),
              const SizedBox(height: 10),
            ],
            Padding(
              padding: margin,
              child: _WeekNavigator(
                weekStart: state.weekStart,
                mode: state.weekStartMode,
              ),
            ),
            const SizedBox(height: 10),
            if (live == null && state.weekSlotsError != null)
              Padding(
                padding: margin,
                child: _Message(
                  icon: Icons.cloud_off_rounded,
                  text: state.weekSlotsError!,
                  actionLabel: 'Retry',
                  onAction: () => bloc.add(const VendorOpsRefreshed()),
                ),
              )
            else if (live == null)
              _TableSkeleton(
                edgeToEdge: rightInset > 0,
                rowCount: _skeletonRows(court, state.weekStart),
                todayIndex: KathmanduClock.today()
                    .difference(state.weekStart)
                    .inDays,
              )
            else ...<Widget>[
              Stack(
                children: <Widget>[
                  RepaintBoundary(
                    child: _Table(
                      edgeToEdge: rightInset > 0,
                      // Opens on the selected date's column when the week is
                      // wider than the screen.
                      focusDay: state.date.difference(state.weekStart).inDays,
                      table: buildWeekTable(
                        court: court,
                        bookings: state.weekBookings,
                        weekStart: state.weekStart,
                        today: KathmanduClock.today(),
                        nowMinute: KathmanduClock.minuteOfDay(),
                        server: live,
                      ),
                      onBookingTap: onBookingTap,
                    ),
                  ),
                  if (state.weekSlotsLoading)
                    const Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// How many rows the court's week will have, from its own schedule, so the
/// skeleton is as tall as the table that replaces it. Courts without a
/// schedule (their slots come only from the server) get a typical day.
int _skeletonRows(OpsCourt court, DateTime weekStart) {
  final int rows = buildWeekTable(
    court: court,
    bookings: const <BookingModel>[],
    weekStart: weekStart,
    today: KathmanduClock.today(),
    nowMinute: KathmanduClock.minuteOfDay(),
  ).rows.length;
  return rows > 0 ? rows : 8;
}

// ───────────────────────────── Controls ─────────────────────────────

class _CourtPicker extends StatelessWidget {
  const _CourtPicker({
    required this.courts,
    required this.selected,
    required this.freeThisWeek,
  });

  final List<OpsCourt> courts;
  final OpsCourt selected;

  /// Court id → free slots this week; empty while the week loads.
  final Map<int, int> freeThisWeek;

  @override
  Widget build(BuildContext context) {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final OpsCourt c in courts) ...<Widget>[
            _CourtChip(
              court: c,
              selected: c.id == selected.id,
              freeThisWeek: freeThisWeek[c.id],
              onTap: () => bloc.add(VendorOpsWeekCourtChanged(c.id)),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

/// A court to show in the table: name, venue, slot length and how much of
/// its week is still free. The selected one is outlined and ticked rather
/// than filled, so it stays easy to read.
class _CourtChip extends StatelessWidget {
  const _CourtChip({
    required this.court,
    required this.selected,
    required this.onTap,
    this.freeThisWeek,
  });

  final OpsCourt court;
  final bool selected;
  final VoidCallback onTap;
  final int? freeThisWeek;

  static const double width = 184;

  @override
  Widget build(BuildContext context) {
    final Color accent = LightColor.secondaryColor;
    final String meta = <String>[
      formatDuration(court.slotMinutes),
      if (freeThisWeek != null)
        freeThisWeek == 0 ? 'full this week' : '$freeThisWeek free',
    ].join(' · ');

    return Semantics(
      button: true,
      selected: selected,
      label: '${court.name}, ${court.venueName}, $meta',
      child: ExcludeSemantics(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: width,
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.08)
                : LightColor.cardColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: selected ? accent : LightColor.dividerColor,
              width: 0.5,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 5, 6, 5),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            court.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                              color: LightColor.primaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            court.venueName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              height: 1.2,
                              color: LightColor.secondaryTextColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                              color: freeThisWeek == 0
                                  ? LightColor.warningColor
                                  : LightColor.brandTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 2),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 160),
                      opacity: selected ? 1 : 0,
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 13,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekNavigator extends StatelessWidget {
  const _WeekNavigator({required this.weekStart, required this.mode});

  final DateTime weekStart;
  final OpsWeekStart mode;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _range() {
    final DateTime end = weekStart.add(const Duration(days: 6));
    final String a = '${_months[weekStart.month - 1]} ${weekStart.day}';
    final String b = end.month == weekStart.month
        ? '${end.day}'
        : '${_months[end.month - 1]} ${end.day}';
    return '$a – $b, ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final VendorOpsBloc bloc = context.read<VendorOpsBloc>();
    final DateTime date = bloc.state.date;
    // Grouped on the right, under the Day/Week switch: the dates with their
    // arrows, then where the week begins.
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        IconButton(
          tooltip: 'Previous week',
          visualDensity: VisualDensity.compact,
          onPressed: () => bloc.add(
            VendorOpsDateChanged(date.subtract(const Duration(days: 7))),
          ),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Flexible(
          child: Text(
            _range(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: LightColor.primaryTextColor,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next week',
          visualDensity: VisualDensity.compact,
          onPressed: () =>
              bloc.add(VendorOpsDateChanged(date.add(const Duration(days: 7)))),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
        const SizedBox(width: 4),
        _WeekStartPicker(
          mode: mode,
          onChanged: (OpsWeekStart m) => bloc.add(VendorOpsWeekStartChanged(m)),
        ),
      ],
    );
  }
}

/// Where the week begins, as a pill beside the week's dates. It opens a menu
/// that shows each choice's own week — its dates and the order of its days —
/// so the vendor sees what they are picking before they pick it.
class _WeekStartPicker extends StatefulWidget {
  const _WeekStartPicker({required this.mode, required this.onChanged});

  final OpsWeekStart mode;
  final ValueChanged<OpsWeekStart> onChanged;

  static IconData iconOf(OpsWeekStart mode) => switch (mode) {
    OpsWeekStart.sunday => Icons.calendar_view_week_rounded,
    OpsWeekStart.today => Icons.today_rounded,
  };

  @override
  State<_WeekStartPicker> createState() => _WeekStartPickerState();
}

class _WeekStartPickerState extends State<_WeekStartPicker> {
  bool _open = false;

  void _setOpen(bool open) {
    if (mounted && _open != open) setState(() => _open = open);
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = LightColor.secondaryColor;
    final DateTime today = KathmanduClock.today();
    return PopupMenuButton<OpsWeekStart>(
      key: const Key('ops-week-start'),
      tooltip: 'Week starts from',
      initialValue: widget.mode,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      color: LightColor.cardColor,
      surfaceTintColor: Colors.transparent,
      elevation: 6,
      shadowColor: LightColor.shadowOf(0.10),
      constraints: const BoxConstraints(minWidth: 272, maxWidth: 296),
      menuPadding: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: LightColor.dividerColor),
      ),
      onOpened: () => _setOpen(true),
      onCanceled: () => _setOpen(false),
      onSelected: (OpsWeekStart m) {
        _setOpen(false);
        widget.onChanged(m);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<OpsWeekStart>>[
        PopupMenuItem<OpsWeekStart>(
          enabled: false,
          height: 34,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
          child: Text(
            'WEEK STARTS FROM',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
              color: LightColor.hintTextColor,
            ),
          ),
        ),
        for (final OpsWeekStart m in OpsWeekStart.values)
          PopupMenuItem<OpsWeekStart>(
            value: m,
            height: 0,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: _WeekStartOption(
              mode: m,
              selected: m == widget.mode,
              today: today,
            ),
          ),
      ],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: 32,
        padding: const EdgeInsets.only(left: 10, right: 6),
        decoration: BoxDecoration(
          color: _open ? accent.withValues(alpha: 0.08) : LightColor.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _open ? accent : LightColor.dividerColor,
            width: _open ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _WeekStartPicker.iconOf(widget.mode),
              size: 15,
              color: LightColor.brandTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              widget.mode.label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: LightColor.primaryTextColor,
              ),
            ),
            const SizedBox(width: 2),
            AnimatedRotation(
              turns: _open ? 0.5 : 0,
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              child: Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One choice in the week-start menu: what it is, the week it gives today,
/// and its seven days in order with the first one lit.
class _WeekStartOption extends StatelessWidget {
  const _WeekStartOption({
    required this.mode,
    required this.selected,
    required this.today,
  });

  final OpsWeekStart mode;
  final bool selected;
  final DateTime today;

  static const List<String> _months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const List<String> _letters = <String>[
    'S',
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
  ];

  String get _title => switch (mode) {
    OpsWeekStart.sunday => 'Calendar week',
    OpsWeekStart.today => 'Starting today',
  };

  String get _subtitle => switch (mode) {
    OpsWeekStart.sunday => 'Sunday to Saturday',
    OpsWeekStart.today => 'Today and the next 6 days',
  };

  String _range(DateTime start) {
    final DateTime end = start.add(const Duration(days: 6));
    final String a = '${_months[start.month - 1]} ${start.day}';
    final String b = end.month == start.month
        ? '${end.day}'
        : '${_months[end.month - 1]} ${end.day}';
    return '$a – $b';
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = LightColor.secondaryColor;
    final DateTime start = weekStartFor(today, mode, today: today);
    final int todayIndex = today.difference(start).inDays;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: selected ? accent.withValues(alpha: 0.07) : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? accent.withValues(alpha: 0.35) : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? accent : LightColor.sunkenColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              _WeekStartPicker.iconOf(mode),
              size: 18,
              color: selected
                  ? LightColor.onBrandSurface
                  : LightColor.secondaryTextColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  _title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: LightColor.primaryTextColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'This week · ${_range(start)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? LightColor.brandTextColor
                        : LightColor.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                // Its days in order: the first filled, today ringed.
                Row(
                  children: <Widget>[
                    for (int i = 0; i < 7; i++) ...<Widget>[
                      if (i > 0) const SizedBox(width: 4),
                      _DayDot(
                        letter:
                            _letters[start.add(Duration(days: i)).weekday % 7],
                        first: i == 0,
                        today: i == todayIndex,
                        accent: selected ? accent : LightColor.iconGrey,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 160),
            child: Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              key: ValueKey<bool>(selected),
              size: 20,
              color: selected ? accent : LightColor.dividerColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A weekday letter in the week-start preview.
class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.letter,
    required this.first,
    required this.today,
    required this.accent,
  });

  final String letter;
  final bool first;
  final bool today;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: first ? accent : LightColor.sunkenColor,
        border: today && !first ? Border.all(color: accent, width: 1.2) : null,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: first
              ? LightColor.onBrandSurface
              : LightColor.secondaryTextColor,
        ),
      ),
    );
  }
}

// ───────────────────────────── Table ─────────────────────────────

class _Table extends StatefulWidget {
  const _Table({
    required this.table,
    required this.onBookingTap,
    required this.focusDay,
    this.edgeToEdge = false,
  });

  final OpsWeekTable table;
  final OpsBookingTap onBookingTap;

  /// Day column to bring into view (0 = the week's first day).
  final int focusDay;

  /// Runs to the screen's right edge: no right border or rounded corners
  /// there.
  final bool edgeToEdge;

  @override
  State<_Table> createState() => _TableState();
}

class _TableState extends State<_Table> {
  final ScrollController _h = ScrollController();
  double _dayWidth = _minDayWidth;

  /// The focus day and column width last scrolled for. Width is part of it:
  /// rotating the phone or resizing the window re-lays the columns out.
  (int, double)? _scrolledFor;

  OpsWeekTable get table => widget.table;
  OpsBookingTap get onBookingTap => widget.onBookingTap;

  @override
  void dispose() {
    _h.dispose();
    super.dispose();
  }

  /// Scrolls the focused day into view whenever the focus or the column width
  /// changes, leaving the day before it partly visible for context.
  void _scrollToFocus() {
    final (int, double) key = (widget.focusDay, _dayWidth);
    if (_scrolledFor == key) return;
    _scrolledFor = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_h.hasClients) return;
      final double target = ((widget.focusDay - 0.5) * _dayWidth).clamp(
        0,
        _h.position.maxScrollExtent,
      );
      _h.jumpTo(target);
    });
  }

  /// Time column: wide enough for "6:00 AM – 7:00 AM" on one line on wide
  /// screens; narrower on phones, where the range stacks on two lines.
  static const double _timeWidthWide = 160;
  static const double _timeWidthNarrow = 84;
  static const double _oneLineFrom = 900;
  static const double _minDayWidth = 104;

  /// Desktop-width tables get taller rows, a taller header and larger text
  /// ([_largeTextScale]) so the grid reads comfortably on a big screen.
  static double _headerHeightFor(bool large) => large ? 58 : 48;
  static double _rowHeightFor(bool large) => large ? 66 : 54;
  static const double _largeTextScale = 1.18;

  /// Current sizes, set from the table's width on every layout.
  double _headerHeight = _headerHeightFor(false);
  double _rowHeight = _rowHeightFor(false);

  static const List<String> _weekdays = <String>[
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];

  @override
  Widget build(BuildContext context) {
    if (table.rows.isEmpty) {
      return _Message(
        icon: Icons.event_busy_rounded,
        text: table.closedDays.length == 7
            ? '${table.court.name} is closed all week.'
            : '${table.court.name} has no slots set for this week.',
      );
    }
    final bool edge = widget.edgeToEdge;
    final BorderSide line = BorderSide(color: LightColor.dividerColor);
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: edge
            ? const BorderRadius.horizontal(left: Radius.circular(8))
            : BorderRadius.circular(8),
        border: edge
            ? Border(left: line, top: line, bottom: line)
            : Border.all(color: LightColor.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints c) {
          final bool oneLine = c.maxWidth >= _oneLineFrom;
          _headerHeight = _headerHeightFor(oneLine);
          _rowHeight = _rowHeightFor(oneLine);
          final double timeWidth = oneLine ? _timeWidthWide : _timeWidthNarrow;
          final double dayWidth = ((c.maxWidth - timeWidth) / 7).clamp(
            _minDayWidth,
            double.infinity,
          );
          _dayWidth = dayWidth;
          _scrollToFocus();
          final Widget grid = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Times stay put while the days scroll sideways.
              SizedBox(
                width: timeWidth,
                child: Column(
                  children: <Widget>[
                    _headerCell(
                      Text(
                        'Time slot',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: LightColor.hintTextColor,
                        ),
                      ),
                    ),
                    for (final int t in table.rows) _timeCell(t, oneLine),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _h,
                  scrollDirection: Axis.horizontal,
                  // The days are painted once and slid sideways, not
                  // repainted on every frame of the scroll.
                  child: RepaintBoundary(
                    child: SizedBox(
                      width: dayWidth * 7,
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              for (int d = 0; d < 7; d++)
                                SizedBox(width: dayWidth, child: _dayHeader(d)),
                            ],
                          ),
                          for (int r = 0; r < table.rows.length; r++)
                            Row(
                              children: <Widget>[
                                for (int d = 0; d < 7; d++)
                                  SizedBox(
                                    width: dayWidth,
                                    height: _rowHeight,
                                    child: _cell(context, r, d),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
          if (!oneLine) return grid;
          // Every label in the grid grows together, on top of the user's own
          // text size rather than replacing it.
          final MediaQueryData media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(
                media.textScaler.scale(1) * _largeTextScale,
              ),
            ),
            child: grid,
          );
        },
      ),
    );
  }

  Widget _headerCell(Widget child, {Color? color}) => Container(
    height: _headerHeight,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color ?? LightColor.background,
      border: Border(bottom: BorderSide(color: LightColor.dividerColor)),
    ),
    child: child,
  );

  /// The slot as a range — "6:00 AM – 7:00 AM" — on one line, or stacked
  /// start over end where the column is narrow.
  Widget _timeCell(int t, bool oneLine) {
    final String start = formatMinuteOfDay(t);
    final String end = formatMinuteOfDay(table.endOf(t));
    final TextStyle strong = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w800,
      color: LightColor.primaryTextColor,
    );
    final TextStyle soft = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w600,
      color: LightColor.secondaryTextColor,
    );
    Widget line(String text, TextStyle style) => FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text, maxLines: 1, style: style),
    );
    return Semantics(
      label: '$start to $end',
      child: ExcludeSemantics(
        child: Container(
          height: _rowHeight,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: LightColor.dividerColor),
              right: BorderSide(color: LightColor.dividerColor),
            ),
          ),
          child: oneLine
              ? line('$start – $end', strong)
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[line(start, strong), line('– $end', soft)],
                ),
        ),
      ),
    );
  }

  Widget _dayHeader(int d) {
    final DateTime day = table.days[d];
    final bool today = table.todayIndex == d;
    final String? closed = table.closedDays[d];
    return _headerCell(
      color: today ? LightColor.secondaryColor.withValues(alpha: 0.10) : null,
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            today ? 'Today' : _weekdays[day.weekday % 7],
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: today
                  ? LightColor.brandTextColor
                  : LightColor.secondaryTextColor,
            ),
          ),
          Text(
            closed != null ? 'Closed' : '${day.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: closed != null
                  ? LightColor.hintTextColor
                  : (today
                        ? LightColor.brandTextColor
                        : LightColor.primaryTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, int r, int d) {
    final OpsWeekCell wc = table.cells[r][d];
    final OpsCell? cell = wc.cell;
    final bool today = table.todayIndex == d;

    final Widget content;
    if (wc.kind == null) {
      content = Center(
        child: Text(
          '—',
          style: TextStyle(
            color: LightColor.hintTextColor.withValues(alpha: 0.6),
          ),
        ),
      );
    } else {
      // Watches only this cell, so toggling a slot redraws just this cell.
      content = Builder(
        builder: (BuildContext context) {
          final bool selected = context.select<VendorOpsBloc, bool>(
            (VendorOpsBloc b) =>
                cell != null &&
                cell.kind == OpsCellKind.available &&
                b.state.selection.containsKey(cell.slotKey),
          );
          return _CellBody(
            cell: wc,
            selected: selected,
            onTap: switch (wc.kind) {
              OpsCellKind.available => () => context.read<VendorOpsBloc>().add(
                VendorOpsSlotToggled(cell!),
              ),
              OpsCellKind.booked => () => onBookingTap(cell!.booking!),
              _ => null,
            },
            semantics: _semantics(r, d, wc, selected),
          );
        },
      );
    }
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: today ? LightColor.secondaryColor.withValues(alpha: 0.04) : null,
        border: Border(
          bottom: BorderSide(color: LightColor.dividerColor),
          right: d < 6
              ? BorderSide(
                  color: LightColor.dividerColor.withValues(alpha: 0.6),
                )
              : BorderSide.none,
        ),
      ),
      child: content,
    );
  }

  String _semantics(int r, int d, OpsWeekCell wc, bool selected) {
    final DateTime day = table.days[d];
    final String when =
        '${_weekdays[day.weekday % 7]} ${day.day}, '
        '${formatMinuteOfDay(table.rows[r])}';
    switch (wc.kind) {
      case OpsCellKind.available:
        return '$when, ${selected ? 'selected' : 'available'}, '
            '${wc.cell!.price == null ? 'price on confirmation' : Money.npr(wc.cell!.price!)}';
      case OpsCellKind.booked:
        final BookingModel b = wc.cell!.booking!;
        return '$when, ${opsPhaseStyle(wc.cell!.phase!).label}, '
            '${b.playerName ?? 'customer'}, ${opsPaymentLabel(wc.cell!.payment!)}';
      case OpsCellKind.closed:
        return '$when, ${wc.note ?? 'closed'}';
      case OpsCellKind.past:
        return '$when, past';
      case null:
        return '$when, no slot';
    }
  }
}

class _CellBody extends StatelessWidget {
  const _CellBody({
    required this.cell,
    required this.selected,
    required this.onTap,
    required this.semantics,
  });

  final OpsWeekCell cell;
  final bool selected;
  final VoidCallback? onTap;
  final String semantics;

  @override
  Widget build(BuildContext context) {
    final OpsCell? c = cell.cell;
    final OpsCellStyle style = c == null
        ? opsClosedStyle()
        : opsCellStyle(c, selected: selected);
    final bool quiet = cell.continuation;
    final bool centred = cell.kind == OpsCellKind.available;

    final (String top, String? bottom) = switch (cell.kind) {
      OpsCellKind.available => (
        selected ? 'Selected' : 'Available',
        opsCompactPrice(c!.price),
      ),
      OpsCellKind.booked => (
        quiet
            ? 'Same booking'
            : ((c!.booking!.playerName?.trim().isNotEmpty ?? false)
                  ? c.booking!.playerName!.trim()
                  : 'Booked'),
        quiet ? null : opsPhaseStyle(c!.phase!).label,
      ),
      OpsCellKind.closed => (c?.note ?? 'Closed', null),
      OpsCellKind.past => ('Past', null),
      null => ('', null),
    };

    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semantics,
      child: ExcludeSemantics(
        child: Material(
          // A booking's later rows, quieter — but a filled box keeps enough
          // colour for its light text.
          color: quiet
              ? style.background.withValues(alpha: style.solid ? 0.72 : 0.5)
              : style.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(color: style.border, width: selected ? 1.5 : 1),
          ),
          // The splash is kept to the corners by [customBorder] rather than
          // clipping every cell of the table, which is costly while it
          // scrolls.
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                // Available slots are centred — label over price — so the
                // open cells read as a clean column of prices.
                crossAxisAlignment: centred
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: centred
                        ? MainAxisAlignment.center
                        : MainAxisAlignment.start,
                    children: <Widget>[
                      // Booked cells lead with the customer's name; the
                      // status is spelled out on the line below.
                      if (cell.kind != OpsCellKind.booked) ...<Widget>[
                        Icon(style.icon, size: 11, color: style.foreground),
                        const SizedBox(width: 3),
                      ],
                      Flexible(
                        fit: centred ? FlexFit.loose : FlexFit.tight,
                        child: Text(
                          top,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: quiet
                                ? FontWeight.w500
                                : FontWeight.w800,
                            color: style.foreground,
                          ),
                        ),
                      ),
                      if (cell.kind == OpsCellKind.booked && !quiet)
                        OpsPaymentBadge(
                          state: c!.payment!,
                          compact: true,
                          onSolid: style.solid,
                        ),
                    ],
                  ),
                  if (bottom != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      bottom,
                      textAlign: centred ? TextAlign.center : TextAlign.start,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: cell.kind == OpsCellKind.available ? 10.5 : 9,
                        fontWeight: cell.kind == OpsCellKind.available
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: style.foreground.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Stands in for the table while the court's week loads. It is laid out
/// with the table's own measurements — frame, time column, day widths,
/// header and row heights, grid lines, today's tint — so nothing moves when
/// the table lands. Only the placeholders shimmer; the grid stays still.
class _TableSkeleton extends StatelessWidget {
  const _TableSkeleton({
    required this.rowCount,
    required this.todayIndex,
    this.edgeToEdge = false,
  });

  final int rowCount;

  /// Today's column in this week (0 = its first day); outside 0–6 when the
  /// week is another one.
  final int todayIndex;
  final bool edgeToEdge;

  @override
  Widget build(BuildContext context) {
    final BorderSide line = BorderSide(color: LightColor.dividerColor);
    return Semantics(
      label: 'Loading this court\'s week',
      child: ExcludeSemantics(
        child: Container(
          decoration: BoxDecoration(
            color: LightColor.cardColor,
            borderRadius: edgeToEdge
                ? const BorderRadius.horizontal(left: Radius.circular(8))
                : BorderRadius.circular(8),
            border: edgeToEdge
                ? Border(left: line, top: line, bottom: line)
                : Border.all(color: LightColor.dividerColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final bool oneLine = c.maxWidth >= _TableState._oneLineFrom;
              final double headerHeight = _TableState._headerHeightFor(oneLine);
              final double rowHeight = _TableState._rowHeightFor(oneLine);
              final double timeWidth = oneLine
                  ? _TableState._timeWidthWide
                  : _TableState._timeWidthNarrow;
              final double dayWidth = ((c.maxWidth - timeWidth) / 7).clamp(
                _TableState._minDayWidth,
                double.infinity,
              );
              // The grid and the placeholders are the same layout drawn
              // twice: lines below, shimmering placeholders on top.
              return Stack(
                children: <Widget>[
                  _grid(
                    timeWidth,
                    dayWidth,
                    oneLine,
                    headerHeight: headerHeight,
                    rowHeight: rowHeight,
                    bones: false,
                  ),
                  Shimmer.fromColors(
                    baseColor: LightColor.skeletonBaseColor,
                    highlightColor: LightColor.skeletonHighlightColor,
                    child: _grid(
                      timeWidth,
                      dayWidth,
                      oneLine,
                      headerHeight: headerHeight,
                      rowHeight: rowHeight,
                      bones: true,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _grid(
    double timeWidth,
    double dayWidth,
    bool oneLine, {
    required double headerHeight,
    required double rowHeight,
    required bool bones,
  }) {
    final BorderSide line = BorderSide(color: LightColor.dividerColor);
    final BorderSide softLine = BorderSide(
      color: LightColor.dividerColor.withValues(alpha: 0.6),
    );
    Widget bone({double? width, double? height}) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: LightColor.skeletonBaseColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
    // In the placeholder layer cells paint nothing but their placeholder.
    BoxDecoration? frame(BoxDecoration decoration) => bones ? null : decoration;

    Widget header({required Widget child, Color? color}) => Container(
      height: headerHeight,
      alignment: Alignment.center,
      decoration: frame(
        BoxDecoration(
          color: color ?? LightColor.background,
          border: Border(bottom: line),
        ),
      ),
      child: bones ? child : null,
    );

    final Widget timeColumn = SizedBox(
      width: timeWidth,
      child: Column(
        children: <Widget>[
          header(child: bone(width: 44, height: 10)),
          for (int r = 0; r < rowCount; r++)
            Container(
              height: rowHeight,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: frame(
                BoxDecoration(
                  border: Border(bottom: line, right: line),
                ),
              ),
              child: !bones
                  ? null
                  : oneLine
                  ? bone(width: timeWidth * 0.7, height: 11)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        bone(width: timeWidth * 0.62, height: 10),
                        const SizedBox(height: 4),
                        bone(width: timeWidth * 0.5, height: 9),
                      ],
                    ),
            ),
        ],
      ),
    );

    Color? todayTint(int d, double alpha) => d == todayIndex
        ? LightColor.secondaryColor.withValues(alpha: alpha)
        : null;

    final Widget days = SizedBox(
      width: dayWidth * 7,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              for (int d = 0; d < 7; d++)
                SizedBox(
                  width: dayWidth,
                  child: header(
                    color: todayTint(d, 0.10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        bone(width: 24, height: 9),
                        const SizedBox(height: 4),
                        bone(width: 16, height: 11),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          for (int r = 0; r < rowCount; r++)
            Row(
              children: <Widget>[
                for (int d = 0; d < 7; d++)
                  Container(
                    width: dayWidth,
                    height: rowHeight,
                    padding: const EdgeInsets.all(3),
                    decoration: frame(
                      BoxDecoration(
                        color: todayTint(d, 0.04),
                        border: Border(
                          bottom: line,
                          right: d < 6 ? softLine : BorderSide.none,
                        ),
                      ),
                    ),
                    child: bones ? bone() : null,
                  ),
              ],
            ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        timeColumn,
        // The days overflow sideways on narrow screens, as in the table;
        // the skeleton just clips them.
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: days,
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 30, color: LightColor.iconGrey),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(color: LightColor.secondaryTextColor),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}
