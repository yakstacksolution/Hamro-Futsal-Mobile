import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/currency.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/widgets/ops_style.dart';
import 'package:shimmer/shimmer.dart';

class OpsCourtCardsView extends StatelessWidget {
  const OpsCourtCardsView({super.key, required this.onBookingTap});

  final OpsBookingTap onBookingTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          // Not the selection: each slot chip watches its own, so a tap
          // redraws one chip instead of the whole board.
          a.board != b.board ||
          a.bookingsLoading != b.bookingsLoading ||
          a.weekSlots != b.weekSlots ||
          a.weekSlotsLoading != b.weekSlotsLoading ||
          a.weekSlotsError != b.weekSlotsError,
      builder: (BuildContext context, VendorOpsState state) {
        final OpsBoard? board = state.board;
        if (board == null) return const SizedBox.shrink();
        if (board.isEmpty) {
          return const _Empty(text: 'No courts match these filters.');
        }
        // Until the server answers for every court shown, a court listed
        // without a schedule would read as closed — so wait for them. A
        // failed call falls back to the schedules, with a notice.
        final bool awaitingLive = board.venues.any(
          (OpsVenueRow v) => v.courts.any(
            (OpsCourtRow r) =>
                state.daySlotsFor(r.court.id, state.date) == null,
          ),
        );
        // The date failed to load: the error above offers the retry, and
        // there are no slots to draw.
        if (awaitingLive && state.bookingsError) {
          return const _Empty(text: 'This date\'s slots could not be loaded.');
        }
        if (awaitingLive) return const _CardsSkeleton();
        final DateTime today = KathmanduClock.today();
        final bool isPast =
            board.date.isBefore(today) && !isSameDay(board.date, today);
        return Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (state.weekSlotsError != null) ...<Widget>[
                  OpsLiveSlotsNotice(
                    onRetry: () => context.read<VendorOpsBloc>().add(
                      const VendorOpsRefreshed(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                for (final OpsVenueRow venue in board.venues) ...<Widget>[
                  _VenueSection(
                    venue: venue,
                    nowMinute: board.nowMinute,
                    isPastDate: isPast,
                    onBookingTap: onBookingTap,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
            if (state.bookingsLoading || state.weekSlotsLoading)
              const Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        );
      },
    );
  }
}

class OpsCourtCardsSliver extends StatelessWidget {
  const OpsCourtCardsSliver({super.key, required this.onBookingTap});

  final OpsBookingTap onBookingTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOpsBloc, VendorOpsState>(
      buildWhen: (VendorOpsState a, VendorOpsState b) =>
          a.board != b.board ||
          a.bookingsLoading != b.bookingsLoading ||
          a.weekSlots != b.weekSlots ||
          a.weekSlotsLoading != b.weekSlotsLoading ||
          a.weekSlotsError != b.weekSlotsError,
      builder: (BuildContext context, VendorOpsState state) {
        final OpsBoard? board = state.board;
        if (board == null) return const SliverToBoxAdapter();
        if (board.isEmpty) {
          return const SliverToBoxAdapter(
            child: _Empty(text: 'No courts match these filters.'),
          );
        }
        final bool awaitingLive = board.venues.any(
          (OpsVenueRow v) => v.courts.any(
            (OpsCourtRow r) =>
                state.daySlotsFor(r.court.id, state.date) == null,
          ),
        );
        if (awaitingLive && state.bookingsError) {
          return const SliverToBoxAdapter(
            child: _Empty(text: 'This date\'s slots could not be loaded.'),
          );
        }
        if (awaitingLive) {
          return const SliverToBoxAdapter(child: _CardsSkeleton());
        }

        final DateTime today = KathmanduClock.today();
        final bool isPast =
            board.date.isBefore(today) && !isSameDay(board.date, today);
        return SliverMainAxisGroup(
          slivers: <Widget>[
            if (state.bookingsLoading || state.weekSlotsLoading)
              const SliverToBoxAdapter(
                child: LinearProgressIndicator(minHeight: 2),
              ),
            if (state.weekSlotsError != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: OpsLiveSlotsNotice(
                    onRetry: () => context.read<VendorOpsBloc>().add(
                      const VendorOpsRefreshed(),
                    ),
                  ),
                ),
              ),
            SliverLayoutBuilder(
              builder: (BuildContext context, SliverConstraints constraints) {
                // Tablet / desktop: venues share one grid instead of each
                // starting a new row, so a one-court venue does not leave the
                // rest of its row empty.
                if (constraints.crossAxisExtent >= AppBreakpoints.tablet) {
                  return SliverToBoxAdapter(
                    child: _PackedVenueBoard(
                      venues: board.venues,
                      nowMinute: board.nowMinute,
                      isPastDate: isPast,
                      onBookingTap: onBookingTap,
                    ),
                  );
                }
                return SliverList.builder(
                  itemCount: board.venues.length,
                  itemBuilder: (BuildContext context, int index) {
                    final OpsVenueRow venue = board.venues[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == board.venues.length - 1 ? 0 : 16,
                      ),
                      child: _VenueSection(
                        venue: venue,
                        nowMinute: board.nowMinute,
                        isPastDate: isPast,
                        onBookingTap: onBookingTap,
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _PackedVenueBoard extends StatelessWidget {
  const _PackedVenueBoard({
    required this.venues,
    required this.nowMinute,
    required this.isPastDate,
    required this.onBookingTap,
  });

  final List<OpsVenueRow> venues;
  final int? nowMinute;
  final bool isPastDate;
  final OpsBookingTap onBookingTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final double gap = context.responsive<double>(mobile: 12, desktop: 16);
        final int columns = columnsFor(
          availableWidth: c.maxWidth,
          minItemWidth: context.responsive<double>(
            mobile: 300,
            tablet: 300,
            desktop: 320,
            large: 340,
          ),
          spacing: gap,
          maxColumns: context.isLarge ? 4 : 3,
        );
        final double cardWidth = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: 20,
          children: <Widget>[
            for (final OpsVenueRow venue in venues)
              Builder(
                builder: (BuildContext context) {
                  final int span = venue.courts.length.clamp(1, columns);
                  return SizedBox(
                    width: cardWidth * span + gap * (span - 1),
                    child: _VenueSection(
                      venue: venue,
                      nowMinute: nowMinute,
                      isPastDate: isPastDate,
                      onBookingTap: onBookingTap,
                      cardWidth: cardWidth,
                      cardGap: gap,
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _VenueSection extends StatelessWidget {
  const _VenueSection({
    required this.venue,
    required this.nowMinute,
    required this.isPastDate,
    required this.onBookingTap,
    this.cardWidth,
    this.cardGap,
  });

  final OpsVenueRow venue;
  final int? nowMinute;
  final bool isPastDate;
  final OpsBookingTap onBookingTap;

  final double? cardWidth;
  final double? cardGap;

  @override
  Widget build(BuildContext context) {
    final List<OpsCourtDaySummary> summaries = <OpsCourtDaySummary>[
      for (final OpsCourtRow row in venue.courts)
        summarizeCourtDay(row, nowMinute: nowMinute, isPastDate: isPastDate),
    ];
    final int free = summaries.fold<int>(
      0,
      (int s, OpsCourtDaySummary c) => s + c.freeSlots,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(
              Icons.stadium_rounded,
              size: 16,
              color: LightColor.brandTextColor,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                venue.venueName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: LightColor.primaryTextColor,
                ),
              ),
            ),
            Text(
              '${summaries.length} '
              '${summaries.length == 1 ? 'court' : 'courts'} · $free free',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: LightColor.secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints c) {
            if (cardWidth != null) {
              return Wrap(
                spacing: cardGap ?? 12,
                runSpacing: cardGap ?? 12,
                children: <Widget>[
                  for (int i = 0; i < venue.courts.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: RepaintBoundary(
                        child: _CourtCard(
                          row: venue.courts[i],
                          summary: summaries[i],
                          onBookingTap: onBookingTap,
                        ),
                      ),
                    ),
                ],
              );
            }
            final bool mobile = c.maxWidth < AppBreakpoints.tablet;
            final double gap = mobile ? 10 : 12;
            final int columns = mobile
                ? 1
                : columnsFor(
                    availableWidth: c.maxWidth,
                    minItemWidth: context.responsive<double>(
                      mobile: 320,
                      tablet: 330,
                      desktop: 360,
                      large: 380,
                    ),
                    spacing: gap,
                    maxColumns: context.isLarge ? 4 : 3,
                  );
            final double width = (c.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: <Widget>[
                for (int i = 0; i < venue.courts.length; i++)
                  SizedBox(
                    width: width,
                    // Painted once and reused while the page scrolls.
                    child: RepaintBoundary(
                      child: _CourtCard(
                        row: venue.courts[i],
                        summary: summaries[i],
                        onBookingTap: onBookingTap,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _CourtCard extends StatefulWidget {
  const _CourtCard({
    required this.row,
    required this.summary,
    required this.onBookingTap,
  });

  final OpsCourtRow row;
  final OpsCourtDaySummary summary;
  final OpsBookingTap onBookingTap;

  @override
  State<_CourtCard> createState() => _CourtCardState();
}

class _CourtCardState extends State<_CourtCard> {
  bool _showPast = false;

  void _openWeek() {
    context.read<VendorOpsBloc>()
      ..add(VendorOpsWeekCourtChanged(widget.summary.court.id))
      ..add(const VendorOpsViewChanged(OpsAvailabilityView.week));
  }

  void _onSlotTap(OpsCell cell) {
    switch (cell.kind) {
      case OpsCellKind.available:
        context.read<VendorOpsBloc>().add(VendorOpsSlotToggled(cell));
      case OpsCellKind.booked:
        widget.onBookingTap(cell.booking!);
      case OpsCellKind.closed:
      case OpsCellKind.past:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final OpsCourtDaySummary s = widget.summary;
    final int percent = (s.occupancy * 100).round();
    final List<OpsCell> past = widget.row.cells
        .where((OpsCell c) => c.kind == OpsCellKind.past)
        .toList();
    final List<OpsCell> shown = _showPast
        ? widget.row.cells
        : widget.row.cells
              .where((OpsCell c) => c.kind != OpsCellKind.past)
              .toList();

    final (String badge, Color badgeFg, Color badgeBg) = s.isClosed
        ? ('Closed', LightColor.secondaryTextColor, LightColor.sunkenColor)
        : s.isFull
        ? ('Full', LightColor.onWarningLightColor, LightColor.warningLightColor)
        : (
            '${s.freeSlots} free',
            LightColor.brandTextColor,
            LightColor.secondaryColor.withValues(alpha: 0.10),
          );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Header: name, slot length, status badge, link to the week.
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      s.court.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: s.isClosed
                            ? LightColor.secondaryTextColor
                            : LightColor.primaryTextColor,
                      ),
                    ),
                    Text(
                      '${formatDuration(s.court.slotMinutes)} slots',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: LightColor.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: badgeFg,
                  ),
                ),
              ),
              TextButton(
                onPressed: _openWeek,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  minimumSize: const Size(0, 32),
                  foregroundColor: LightColor.brandTextColor,
                ),
                child: const Text(
                  'Week ›',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (s.isClosed) ...<Widget>[
            const SizedBox(height: 8),
            _Fact(label: 'Status', value: s.closedReason!, muted: true),
          ] else ...<Widget>[
            const SizedBox(height: 8),
            _OccupancyBar(value: s.occupancy, percent: percent),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: _Fact(
                    label: 'Next free',
                    value: s.nextFree == null
                        ? 'None left'
                        : '${formatMinuteOfDay(s.nextFree!.start)}'
                              '${s.nextFree!.price == null ? '' : ' · ${_rs(s.nextFree!.price!)}'}',
                    muted: s.nextFree == null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: _bookingFact(s)),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: LightColor.dividerColor),
            if (past.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => setState(() => _showPast = !_showPast),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    foregroundColor: LightColor.secondaryTextColor,
                  ),
                  icon: Icon(
                    _showPast
                        ? Icons.expand_less_rounded
                        : Icons.history_rounded,
                    size: 15,
                  ),
                  label: Text(
                    _showPast
                        ? 'Hide earlier'
                        : 'Show earlier (${past.length})',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                ),
              )
            else
              const SizedBox(height: 10),
            if (shown.isEmpty)
              Text(
                'No slots left on this day.',
                style: TextStyle(
                  fontSize: 12,
                  color: LightColor.secondaryTextColor,
                ),
              )
            else
              _SlotGrid(cells: shown, court: s.court, onTap: _onSlotTap),
          ],
        ],
      ),
    );
  }

  Widget _bookingFact(OpsCourtDaySummary s) {
    String name(BookingModel b) => (b.playerName?.trim().isNotEmpty ?? false)
        ? b.playerName!.trim().split(' ').first
        : 'Booked';
    if (s.current != null) {
      return _Fact(
        label: 'On court now',
        value:
            '${name(s.current!.booking!)} · till '
            '${formatMinuteOfDay(s.current!.end)}',
        highlight: true,
      );
    }
    if (s.next != null) {
      return _Fact(
        label: 'Next booking',
        value:
            '${name(s.next!.booking!)} · '
            '${formatMinuteOfDay(s.next!.start)}',
      );
    }
    return const _Fact(label: 'Next booking', value: 'None', muted: true);
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.cells,
    required this.court,
    required this.onTap,
  });

  final List<OpsCell> cells;
  final OpsCourt court;
  final ValueChanged<OpsCell> onTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        const double gap = 6;
        final int columns = (c.maxWidth / 96).floor().clamp(3, 8);
        final double w = (c.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: <Widget>[
            for (final OpsCell cell in cells)
              SizedBox(
                // A booking over several slots takes the room of two.
                width:
                    cell.kind == OpsCellKind.booked &&
                        cell.minutes > court.slotMinutes
                    ? w * 2 + gap
                    : w,
                child: _SlotChip(
                  cell: cell,
                  court: court,
                  onTap: () => onTap(cell),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _SlotChip extends StatelessWidget {
  const _SlotChip({
    required this.cell,
    required this.court,
    required this.onTap,
  });

  final OpsCell cell;
  final OpsCourt court;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Watches only this slot, so toggling one redraws just this chip.
    final bool selected = context.select<VendorOpsBloc, bool>(
      (VendorOpsBloc b) => b.state.selection.containsKey(cell.slotKey),
    );
    final OpsCellStyle style = opsCellStyle(cell, selected: selected);
    final bool tappable =
        cell.kind == OpsCellKind.available || cell.kind == OpsCellKind.booked;
    final bool long = cell.minutes > court.slotMinutes;
    final String time = long
        ? '${formatMinuteOfDay(cell.start)} – ${formatMinuteOfDay(cell.end)}'
        : formatMinuteOfDay(cell.start);
    final String sub = switch (cell.kind) {
      OpsCellKind.available =>
        selected
            ? 'Selected'
            : (cell.price == null ? 'Available' : _rs(cell.price!)),
      OpsCellKind.booked =>
        (cell.booking!.playerName?.trim().isNotEmpty ?? false)
            ? cell.booking!.playerName!.trim()
            : 'Booked',
      OpsCellKind.closed => cell.note ?? 'Closed',
      OpsCellKind.past => 'Past',
    };
    final String label = switch (cell.kind) {
      OpsCellKind.available =>
        '$time, ${selected ? 'selected' : 'available'}, '
            '${cell.price == null ? 'price on confirmation' : Money.npr(cell.price!)}. '
            '${selected ? 'Tap to remove.' : 'Tap to add to booking.'}',
      OpsCellKind.booked =>
        '$time, ${opsPhaseStyle(cell.phase!).label}, $sub, '
            '${opsPaymentLabel(cell.payment!)}. Tap for details.',
      OpsCellKind.closed => '$time, closed',
      OpsCellKind.past => '$time, past',
    };

    return Semantics(
      button: tappable,
      selected: selected,
      label: '${court.name}, $label',
      child: ExcludeSemantics(
        child: Material(
          color: style.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(color: style.border, width: selected ? 1.5 : 1),
          ),
          // The splash is kept to the corners by [customBorder] rather than
          // clipping every chip, which is costly while the page scrolls.
          child: InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onTap: tappable ? onTap : null,
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            time,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: style.foreground,
                            ),
                          ),
                        ),
                        if (cell.kind == OpsCellKind.booked)
                          OpsPaymentBadge(
                            state: cell.payment!,
                            compact: true,
                            onSolid: style.solid,
                          )
                        else if (selected)
                          Icon(
                            Icons.check_rounded,
                            size: 12,
                            color: style.foreground,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: style.foreground.withValues(alpha: 0.85),
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

class _OccupancyBar extends StatelessWidget {
  const _OccupancyBar({required this.value, required this.percent});

  final double value;
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 5,
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2B9E82)
                  : const Color(0xFF1A8C74),
              backgroundColor: LightColor.sunkenColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$percent% booked',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: LightColor.secondaryTextColor,
            fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.muted = false,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool muted;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            letterSpacing: 0.4,
            fontWeight: FontWeight.w700,
            color: highlight
                ? LightColor.purpleColor
                : LightColor.hintTextColor,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: muted
                ? LightColor.hintTextColor
                : LightColor.primaryTextColor,
          ),
        ),
      ],
    );
  }
}

class _CardsSkeleton extends StatelessWidget {
  const _CardsSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget bone(double h, {double? w, double r = 8}) => Container(
      height: h,
      width: w,
      decoration: BoxDecoration(
        color: LightColor.skeletonBaseColor,
        borderRadius: BorderRadius.circular(r),
      ),
    );
    return Semantics(
      label: 'Loading courts\' slots',
      child: ExcludeSemantics(
        child: Shimmer.fromColors(
          baseColor: LightColor.skeletonBaseColor,
          highlightColor: LightColor.skeletonHighlightColor,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints c) {
              final int columns = c.maxWidth >= 1100
                  ? 3
                  : c.maxWidth >= 700
                  ? 2
                  : 1;
              const double gap = 10;
              final double width = (c.maxWidth - gap * (columns - 1)) / columns;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  bone(40, r: 6),
                  const SizedBox(height: 16),
                  bone(16, w: 160, r: 6),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: <Widget>[
                      for (int i = 0; i < columns.clamp(2, 3); i++)
                        SizedBox(width: width, child: bone(220)),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: LightColor.dividerColor),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(color: LightColor.secondaryTextColor),
      ),
    );
  }
}

String _rs(num amount) => Money.npr(amount).replaceFirst('NPR', 'Rs');
