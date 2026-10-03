import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/responsive.dart';

class VendorDashboardDraft extends StatefulWidget {
  const VendorDashboardDraft({super.key, this.topInset = 0});

  final double topInset;

  @override
  State<VendorDashboardDraft> createState() => _VendorDashboardDraftState();
}

class _VendorDashboardDraftState extends State<VendorDashboardDraft> {
  late DateTime _selectedDate;
  String _selectedVenueId = _venues.first.id;
  String _searchText = '';
  final Set<String> _selectedSlotIds = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedDate = _todayKathmandu();
  }

  VenueDraft get _selectedVenue =>
      _venues.firstWhere((VenueDraft venue) => venue.id == _selectedVenueId);

  List<SlotDraft> get _allSlots =>
      _selectedVenue.courts.expand((CourtDraft court) => court.slots).toList();

  List<SlotDraft> get _selectedSlots => _allSlots
      .where((SlotDraft slot) => _selectedSlotIds.contains(slot.id))
      .toList();

  List<BookingDraft> get _visibleBookings {
    final String query = _searchText.trim().toLowerCase();
    return _bookings.where((BookingDraft booking) {
      if (booking.venueId != _selectedVenueId) return false;
      if (query.isEmpty) return true;
      return '${booking.name} ${booking.phone} ${booking.reference}'
          .toLowerCase()
          .contains(query);
    }).toList();
  }

  DateTime _todayKathmandu() {
    final DateTime now = DateTime.now().toUtc().add(
      const Duration(hours: 5, minutes: 45),
    );
    return DateTime(now.year, now.month, now.day);
  }

  bool get _isToday {
    final DateTime today = _todayKathmandu();
    return today.year == _selectedDate.year &&
        today.month == _selectedDate.month &&
        today.day == _selectedDate.day;
  }

  void _changeDate(int days) {
    setState(() => _selectedDate = _selectedDate.add(Duration(days: days)));
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2028),
    );
    if (picked == null) return;
    setState(
      () => _selectedDate = DateTime(picked.year, picked.month, picked.day),
    );
  }

  void _toggleSlot(SlotDraft slot) {
    if (!slot.isFree) {
      _showBookingInfo(slot);
      return;
    }
    setState(() {
      if (!_selectedSlotIds.add(slot.id)) {
        _selectedSlotIds.remove(slot.id);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedSlotIds.clear);
  }

  void _confirmBooking() {
    final String reference =
        'HF-${DateTime.now().millisecondsSinceEpoch.remainder(100000)}';
    setState(_selectedSlotIds.clear);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Booking saved. Reference: $reference')),
    );
  }

  void _showBookingInfo(SlotDraft slot) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppDimens.paddingX20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  slot.customer ?? slot.statusText,
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).headingSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppDimens.sizeX8),
                Text('${slot.courtName} · ${slot.timeRange}'),
                Text('Payment: ${slot.paymentText}'),
                if (slot.reference != null)
                  Text('Reference: ${slot.reference}'),
                const SizedBox(height: AppDimens.sizeX16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.receipt_long_rounded),
                        label: const Text('Receipt'),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.payments_rounded),
                        label: const Text('Payment'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool wide = context.isDesktop;
    return Scaffold(
      backgroundColor: LightColor.background,
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            context.responsive<double>(
              mobile: AppDimens.paddingX16,
              tablet: AppDimens.paddingX24,
            ),
            widget.topInset + AppDimens.paddingX16,
            context.responsive<double>(
              mobile: AppDimens.paddingX16,
              tablet: AppDimens.paddingX24,
            ),
            AppDimens.paddingX28,
          ),
          children: <Widget>[
            _TopBar(
              date: _selectedDate,
              isToday: _isToday,
              selectedVenueId: _selectedVenueId,
              onVenueChanged: (String id) {
                setState(() {
                  _selectedVenueId = id;
                  _selectedSlotIds.clear();
                });
              },
              onPrevious: () => _changeDate(-1),
              onNext: () => _changeDate(1),
              onToday: () => setState(() => _selectedDate = _todayKathmandu()),
              onPickDate: _pickDate,
            ),
            const SizedBox(height: AppDimens.sizeX16),
            _GreetingCard(venue: _selectedVenue, date: _selectedDate),
            const SizedBox(height: AppDimens.sizeX14),
            _SummaryCards(slots: _allSlots),
            const SizedBox(height: AppDimens.sizeX14),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: _ScheduleSection(
                      venue: _selectedVenue,
                      selectedSlotIds: _selectedSlotIds,
                      onSlotTap: _toggleSlot,
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX16),
                  Expanded(
                    flex: 4,
                    child: _BookingBox(
                      slots: _selectedSlots,
                      onRemove: (String id) => setState(() {
                        _selectedSlotIds.remove(id);
                      }),
                      onClear: _clearSelection,
                      onConfirm: _confirmBooking,
                    ),
                  ),
                ],
              )
            else ...<Widget>[
              _ScheduleSection(
                venue: _selectedVenue,
                selectedSlotIds: _selectedSlotIds,
                onSlotTap: _toggleSlot,
              ),
              const SizedBox(height: AppDimens.sizeX14),
              _BookingBox(
                slots: _selectedSlots,
                onRemove: (String id) => setState(() {
                  _selectedSlotIds.remove(id);
                }),
                onClear: _clearSelection,
                onConfirm: _confirmBooking,
              ),
            ],
            const SizedBox(height: AppDimens.sizeX14),
            _TodayBookings(
              bookings: _visibleBookings,
              onSearchChanged: (String value) => setState(() {
                _searchText = value;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.date,
    required this.isToday,
    required this.selectedVenueId,
    required this.onVenueChanged,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onPickDate,
  });

  final DateTime date;
  final bool isToday;
  final String selectedVenueId;
  final ValueChanged<String> onVenueChanged;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimens.sizeX8,
      runSpacing: AppDimens.sizeX8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _IconAction(icon: Icons.chevron_left_rounded, onTap: onPrevious),
        _SimpleButton(
          icon: Icons.calendar_month_rounded,
          label: _formatDate(date),
          onTap: onPickDate,
        ),
        _IconAction(icon: Icons.chevron_right_rounded, onTap: onNext),
        _SimpleButton(
          icon: Icons.today_rounded,
          label: isToday ? 'Today' : 'Go to today',
          filled: true,
          onTap: onToday,
        ),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX12),
          decoration: _fieldDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedVenueId,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: _venues
                  .map(
                    (VenueDraft venue) => DropdownMenuItem<String>(
                      value: venue.id,
                      child: Text(venue.name),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) {
                if (value != null) onVenueChanged(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({required this.venue, required this.date});

  final VenueDraft venue;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: LightColor.secondarySoft,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: LightColor.brandTextColor,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Good day, vendor',
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).headingSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: AppDimens.sizeX4),
                Text(
                  '${venue.name} · ${_formatDate(date)}',
                  style: TextStyle(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.slots});

  final List<SlotDraft> slots;

  @override
  Widget build(BuildContext context) {
    final int booked = slots.where((SlotDraft slot) => !slot.isFree).length;
    final int free = slots.where((SlotDraft slot) => slot.isFree).length;
    final int due = slots.fold(
      0,
      (int total, SlotDraft slot) => total + slot.due,
    );
    final int earned = slots.fold(
      0,
      (int total, SlotDraft slot) => total + slot.paid,
    );
    final List<_SummaryValue> items = <_SummaryValue>[
      _SummaryValue('Booked', '$booked', Icons.event_busy_rounded),
      _SummaryValue('Free slots', '$free', Icons.event_available_rounded),
      _SummaryValue('Collected', 'Rs. $earned', Icons.payments_rounded),
      _SummaryValue('Due', 'Rs. $due', Icons.account_balance_wallet_rounded),
    ];
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int columns = columnsFor(
          availableWidth: constraints.maxWidth,
          minItemWidth: 150,
          spacing: AppDimens.sizeX10,
          maxColumns: 4,
        );
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppDimens.sizeX10,
            mainAxisSpacing: AppDimens.sizeX10,
            mainAxisExtent: 96,
          ),
          itemBuilder: (_, int index) => _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(items[index].icon, color: LightColor.brandTextColor),
                Text(
                  items[index].value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppDimens.fontHeadingSubTitle,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  items[index].label,
                  style: TextStyle(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  const _ScheduleSection({
    required this.venue,
    required this.selectedSlotIds,
    required this.onSlotTap,
  });

  final VenueDraft venue;
  final Set<String> selectedSlotIds;
  final ValueChanged<SlotDraft> onSlotTap;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(
            title: 'Today schedule',
            subtitle: 'Tap a free time to add it to a booking.',
          ),
          const SizedBox(height: AppDimens.sizeX12),
          ...venue.courts.map(
            (CourtDraft court) => Padding(
              padding: const EdgeInsets.only(bottom: AppDimens.paddingX14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    court.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: AppDimens.sizeX8),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final int columns = columnsFor(
                            availableWidth: constraints.maxWidth,
                            minItemWidth: 118,
                            spacing: AppDimens.sizeX8,
                            maxColumns: context.isDesktop ? 5 : 3,
                          );
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: court.slots.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: AppDimens.sizeX8,
                                  mainAxisSpacing: AppDimens.sizeX8,
                                  mainAxisExtent: 86,
                                ),
                            itemBuilder: (_, int index) {
                              final SlotDraft slot = court.slots[index];
                              return _SlotButton(
                                slot: slot,
                                selected: selectedSlotIds.contains(slot.id),
                                onTap: () => onSlotTap(slot),
                              );
                            },
                          );
                        },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final SlotDraft slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color borderColor = selected
        ? LightColor.yellowColor
        : slot.isFree
        ? LightColor.successColor
        : LightColor.greyBorderColor;
    final Color fillColor = selected
        ? LightColor.warningLightColor
        : slot.isFree
        ? LightColor.greenLightColor
        : LightColor.inputFillColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        padding: const EdgeInsets.all(AppDimens.paddingX10),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              slot.timeRange,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              selected ? 'Selected' : slot.statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: LightColor.secondaryTextColor),
            ),
            Text(
              slot.isFree ? 'Rs. ${slot.price}' : slot.paymentText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingBox extends StatelessWidget {
  const _BookingBox({
    required this.slots,
    required this.onRemove,
    required this.onClear,
    required this.onConfirm,
  });

  final List<SlotDraft> slots;
  final ValueChanged<String> onRemove;
  final VoidCallback onClear;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final int total = slots.fold(
      0,
      (int sum, SlotDraft slot) => sum + slot.price,
    );
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(
            title: 'New booking',
            subtitle: slots.isEmpty
                ? 'Select free times first.'
                : '${slots.length} time selected',
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (slots.isEmpty)
            _EmptyHint()
          else ...<Widget>[
            ...slots.map(
              (SlotDraft slot) => Container(
                margin: const EdgeInsets.only(bottom: AppDimens.marginX8),
                padding: const EdgeInsets.all(AppDimens.paddingX10),
                decoration: BoxDecoration(
                  color: LightColor.sunkenColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            slot.courtName,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${slot.timeRange} · Rs. ${slot.price}',
                            style: TextStyle(
                              color: LightColor.secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => onRemove(slot.id),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX8),
            const TextField(
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Customer phone',
                prefixIcon: Icon(Icons.phone_rounded),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX10),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Customer name',
                prefixIcon: Icon(Icons.person_rounded),
              ),
            ),
            const SizedBox(height: AppDimens.sizeX10),
            Container(
              padding: const EdgeInsets.all(AppDimens.paddingX12),
              decoration: BoxDecoration(
                color: LightColor.secondarySoft,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              ),
              child: Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Total amount',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    'Rs. $total',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.sizeX12),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    child: const Text('Save booking'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayBookings extends StatelessWidget {
  const _TodayBookings({required this.bookings, required this.onSearchChanged});

  final List<BookingDraft> bookings;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SectionTitle(
            title: "Today's bookings",
            subtitle: 'Search by name, phone, or reference.',
          ),
          const SizedBox(height: AppDimens.sizeX12),
          TextField(
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'Search booking',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (bookings.isEmpty)
            Text(
              'No bookings found.',
              style: TextStyle(color: LightColor.secondaryTextColor),
            )
          else
            ...bookings.map(
              (BookingDraft booking) => _BookingTile(booking: booking),
            ),
        ],
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  const _BookingTile({required this.booking});

  final BookingDraft booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimens.marginX8),
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.sunkenColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  booking.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${booking.time} · ${booking.court}',
                  style: TextStyle(color: LightColor.secondaryTextColor),
                ),
                Text(
                  '${booking.phone} · ${booking.reference}',
                  style: TextStyle(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _SmallBadge(text: booking.paymentText),
              const SizedBox(height: AppDimens.sizeX6),
              Text(
                'Rs. ${booking.amount}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              if (booking.due > 0)
                Text(
                  'Due Rs. ${booking.due}',
                  style: TextStyle(color: LightColor.warningColor),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: FutsalTheme.getTextTheme(
            context,
          ).headingSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: AppDimens.sizeX4),
        Text(subtitle, style: TextStyle(color: LightColor.secondaryTextColor)),
      ],
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: LightColor.secondarySoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: LightColor.brandTextColor,
          fontSize: AppDimens.fontBodyTextSmall,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.sunkenColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Column(
        children: <Widget>[
          Icon(Icons.touch_app_rounded, color: LightColor.brandTextColor),
          const SizedBox(height: AppDimens.sizeX8),
          const Text(
            'Tap a free time',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          Text(
            'Selected times will appear here.',
            style: TextStyle(color: LightColor.secondaryTextColor),
          ),
        ],
      ),
    );
  }
}

class _SimpleButton extends StatelessWidget {
  const _SimpleButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingX12),
        decoration: filled
            ? BoxDecoration(
                color: LightColor.secondaryColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX8),
              )
            : _fieldDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 18,
              color: filled
                  ? LightColor.inverseTextColor
                  : LightColor.brandTextColor,
            ),
            const SizedBox(width: AppDimens.sizeX6),
            Text(
              label,
              style: TextStyle(
                color: filled
                    ? LightColor.inverseTextColor
                    : LightColor.primaryTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        width: 44,
        height: 44,
        decoration: _fieldDecoration(),
        child: Icon(icon, color: LightColor.brandTextColor),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX16),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor,
            blurRadius: AppDimens.radiusX12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

BoxDecoration _fieldDecoration() {
  return BoxDecoration(
    color: LightColor.cardColor,
    borderRadius: BorderRadius.circular(AppDimens.radiusX8),
    border: Border.all(color: LightColor.greyBorderColor),
  );
}

String _formatDate(DateTime date) {
  const List<String> months = <String>[
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
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

class _SummaryValue {
  const _SummaryValue(this.label, this.value, this.icon);

  final String label;
  final String value;
  final IconData icon;
}

class VenueDraft {
  const VenueDraft({
    required this.id,
    required this.name,
    required this.courts,
  });

  final String id;
  final String name;
  final List<CourtDraft> courts;
}

class CourtDraft {
  const CourtDraft({required this.name, required this.slots});

  final String name;
  final List<SlotDraft> slots;
}

class SlotDraft {
  const SlotDraft({
    required this.id,
    required this.courtName,
    required this.timeRange,
    required this.price,
    required this.statusText,
    required this.paymentText,
    this.customer,
    this.reference,
    this.paid = 0,
    this.due = 0,
  });

  final String id;
  final String courtName;
  final String timeRange;
  final int price;
  final String statusText;
  final String paymentText;
  final String? customer;
  final String? reference;
  final int paid;
  final int due;

  bool get isFree => statusText == 'Free';
}

class BookingDraft {
  const BookingDraft({
    required this.venueId,
    required this.reference,
    required this.name,
    required this.phone,
    required this.court,
    required this.time,
    required this.paymentText,
    required this.amount,
    required this.due,
  });

  final String venueId;
  final String reference;
  final String name;
  final String phone;
  final String court;
  final String time;
  final String paymentText;
  final int amount;
  final int due;
}

const List<VenueDraft> _venues = <VenueDraft>[
  VenueDraft(
    id: 'thamel',
    name: 'Thamel Arena Futsal',
    courts: <CourtDraft>[
      CourtDraft(
        name: 'Court A',
        slots: <SlotDraft>[
          SlotDraft(
            id: 'ta-a-08',
            courtName: 'Court A',
            timeRange: '08:00 - 09:00',
            price: 1400,
            statusText: 'Booked',
            paymentText: 'Part paid',
            customer: 'Aarav Shrestha',
            reference: 'HF-2041',
            paid: 800,
            due: 600,
          ),
          SlotDraft(
            id: 'ta-a-09',
            courtName: 'Court A',
            timeRange: '09:00 - 10:00',
            price: 1400,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
          SlotDraft(
            id: 'ta-a-10',
            courtName: 'Court A',
            timeRange: '10:00 - 11:00',
            price: 1400,
            statusText: 'Cleaning',
            paymentText: 'Not for sale',
          ),
          SlotDraft(
            id: 'ta-a-17',
            courtName: 'Court A',
            timeRange: '17:00 - 18:00',
            price: 1900,
            statusText: 'Booked',
            paymentText: 'Paid',
            customer: 'KTM Strikers',
            reference: 'HF-2049',
            paid: 1900,
          ),
          SlotDraft(
            id: 'ta-a-18',
            courtName: 'Court A',
            timeRange: '18:00 - 19:00',
            price: 2200,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
          SlotDraft(
            id: 'ta-a-19',
            courtName: 'Court A',
            timeRange: '19:00 - 20:00',
            price: 2200,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
        ],
      ),
      CourtDraft(
        name: 'Court B',
        slots: <SlotDraft>[
          SlotDraft(
            id: 'ta-b-08',
            courtName: 'Court B',
            timeRange: '08:00 - 09:00',
            price: 1400,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
          SlotDraft(
            id: 'ta-b-16',
            courtName: 'Court B',
            timeRange: '16:00 - 17:00',
            price: 1700,
            statusText: 'Booked',
            paymentText: 'Unpaid',
            customer: 'Nisha FC',
            reference: 'HF-2048',
            due: 1700,
          ),
          SlotDraft(
            id: 'ta-b-17',
            courtName: 'Court B',
            timeRange: '17:00 - 18:00',
            price: 1900,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
          SlotDraft(
            id: 'ta-b-18',
            courtName: 'Court B',
            timeRange: '18:00 - 19:00',
            price: 2200,
            statusText: 'Booked',
            paymentText: 'Paid',
            customer: 'United Boys',
            reference: 'HF-2052',
            paid: 2200,
          ),
        ],
      ),
    ],
  ),
  VenueDraft(
    id: 'lalitpur',
    name: 'Lalitpur Kickoff Hub',
    courts: <CourtDraft>[
      CourtDraft(
        name: 'Five-a-side',
        slots: <SlotDraft>[
          SlotDraft(
            id: 'lk-5-07',
            courtName: 'Five-a-side',
            timeRange: '07:00 - 08:00',
            price: 1200,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
          SlotDraft(
            id: 'lk-5-14',
            courtName: 'Five-a-side',
            timeRange: '14:00 - 15:00',
            price: 1500,
            statusText: 'Booked',
            paymentText: 'Paid',
            customer: 'Bibek Rai',
            reference: 'HF-2037',
            paid: 1500,
          ),
          SlotDraft(
            id: 'lk-5-18',
            courtName: 'Five-a-side',
            timeRange: '18:00 - 19:00',
            price: 2100,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
        ],
      ),
      CourtDraft(
        name: 'Seven-a-side',
        slots: <SlotDraft>[
          SlotDraft(
            id: 'lk-7-16',
            courtName: 'Seven-a-side',
            timeRange: '16:00 - 17:00',
            price: 1800,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
          SlotDraft(
            id: 'lk-7-17',
            courtName: 'Seven-a-side',
            timeRange: '17:00 - 18:00',
            price: 2300,
            statusText: 'Booked',
            paymentText: 'Part paid',
            customer: 'KTM Strikers',
            reference: 'HF-2054',
            paid: 1400,
            due: 900,
          ),
          SlotDraft(
            id: 'lk-7-19',
            courtName: 'Seven-a-side',
            timeRange: '19:00 - 20:00',
            price: 2400,
            statusText: 'Free',
            paymentText: 'No payment',
          ),
        ],
      ),
    ],
  ),
];

const List<BookingDraft> _bookings = <BookingDraft>[
  BookingDraft(
    venueId: 'thamel',
    reference: 'HF-2041',
    name: 'Aarav Shrestha',
    phone: '9841001111',
    court: 'Court A',
    time: '08:00 - 09:00',
    paymentText: 'Part paid',
    amount: 1400,
    due: 600,
  ),
  BookingDraft(
    venueId: 'thamel',
    reference: 'HF-2048',
    name: 'Nisha FC',
    phone: '9803002222',
    court: 'Court B',
    time: '16:00 - 17:00',
    paymentText: 'Unpaid',
    amount: 1700,
    due: 1700,
  ),
  BookingDraft(
    venueId: 'thamel',
    reference: 'HF-2052',
    name: 'United Boys',
    phone: '9817003333',
    court: 'Court B',
    time: '18:00 - 19:00',
    paymentText: 'Paid',
    amount: 2200,
    due: 0,
  ),
  BookingDraft(
    venueId: 'lalitpur',
    reference: 'HF-2037',
    name: 'Bibek Rai',
    phone: '9867004444',
    court: 'Five-a-side',
    time: '14:00 - 15:00',
    paymentText: 'Paid',
    amount: 1500,
    due: 0,
  ),
  BookingDraft(
    venueId: 'lalitpur',
    reference: 'HF-2054',
    name: 'KTM Strikers',
    phone: '9815003333',
    court: 'Seven-a-side',
    time: '17:00 - 18:00',
    paymentText: 'Part paid',
    amount: 2300,
    due: 900,
  ),
];
