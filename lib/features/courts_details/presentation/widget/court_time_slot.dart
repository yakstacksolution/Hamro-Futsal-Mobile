import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/courts_details/presentation/model/time_slot_model.dart';

typedef TimeSelectionChanged = void Function(int dateIndex, int slotIndex);

class CourtTimeSlotSection extends StatefulWidget {
  const CourtTimeSlotSection({
    super.key,
    required this.dates,
    required this.timeSlotsByDate,
    required this.openTime,
    required this.closeTime,
    this.initialDateIndex = 0,
    this.initialSlotIndex = -1,
    this.onSelectionChanged,
  });

  final List<DateTime> dates;
  final List<List<TimeSlotModel>> timeSlotsByDate;
  final String openTime;
  final String closeTime;
  final int initialDateIndex;
  final int initialSlotIndex;
  final TimeSelectionChanged? onSelectionChanged;

  @override
  State<CourtTimeSlotSection> createState() => _CourtTimeSlotSectionState();
}

class _CourtTimeSlotSectionState extends State<CourtTimeSlotSection> {
  late int _selectedDateIndex;
  late int _selectedSlotIndex;

  @override
  void initState() {
    super.initState();
    _selectedDateIndex = widget.initialDateIndex.clamp(
      0,
      widget.dates.isEmpty ? 0 : widget.dates.length - 1,
    );
    _selectedSlotIndex = widget.initialSlotIndex;
  }

  @override
  void didUpdateWidget(covariant CourtTimeSlotSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDateIndex != widget.initialDateIndex ||
        oldWidget.initialSlotIndex != widget.initialSlotIndex) {
      _selectedDateIndex = widget.initialDateIndex.clamp(
        0,
        widget.dates.isEmpty ? 0 : widget.dates.length - 1,
      );
      _selectedSlotIndex = widget.initialSlotIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.dates.isEmpty) {
      return const SizedBox.shrink();
    }

    final slots = _slotsForSelectedDate();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LightColor.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: LightColor.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadow.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Select Date & Time',
                  style: TextStyle(
                    color: LightColor.titleText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: LightColor.primaryLight,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 14,
                        color: LightColor.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.openTime} - ${widget.closeTime}',
                        style: const TextStyle(
                          color: LightColor.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateSelector(),
            const SizedBox(height: 16),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _SlotLegend(bg: LightColor.primaryLight, label: 'Available'),
                SizedBox(width: 14),
                _SlotLegend(bg: LightColor.secondaryGreen, label: 'Selected'),
                SizedBox(width: 14),
                _SlotLegend(bg: LightColor.borderLight, label: 'Booked'),
              ],
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 14,
                crossAxisSpacing: 10,
                childAspectRatio: 2,
              ),
              itemCount: slots.length,
              itemBuilder: (context, i) {
                final slot = slots[i];
                final selected = _selectedSlotIndex == i;

                return GestureDetector(
                  onTap: slot.isAvailable
                      ? () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedSlotIndex = selected ? -1 : i;
                          });
                          widget.onSelectionChanged?.call(
                            _selectedDateIndex,
                            _selectedSlotIndex,
                          );
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: selected ? LightColor.primaryGradient : null,
                      color: selected
                          ? null
                          : slot.isAvailable
                          ? LightColor.primaryLight
                          : LightColor.borderLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? Colors.transparent
                            : slot.isAvailable
                            ? LightColor.secondary.withValues(alpha: 0.25)
                            : LightColor.border.withValues(alpha: 0.8),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.time,
                            style: TextStyle(
                              color: selected
                                  ? LightColor.white
                                  : slot.isAvailable
                                  ? LightColor.titleText
                                  : LightColor.hintText,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              decoration: slot.isAvailable
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            "Rs. 1200",
                            style: TextStyle(
                              color: selected
                                  ? LightColor.white
                                  : slot.isAvailable
                                  ? LightColor.titleText
                                  : LightColor.hintText,
                              fontSize: 8,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.dates.length,
        itemBuilder: (context, i) {
          final date = widget.dates[i];
          final selected = _selectedDateIndex == i;
          final today = _isToday(date);

          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _selectedDateIndex = i;
                _selectedSlotIndex = -1;
              });
              widget.onSelectionChanged?.call(_selectedDateIndex, -1);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 60,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: selected ? LightColor.primaryGradient : null,
                color: selected ? null : LightColor.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? Colors.transparent
                      : today
                      ? LightColor.secondary.withValues(alpha: 0.35)
                      : LightColor.border.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date),
                    style: TextStyle(
                      color: selected ? Colors.white70 : LightColor.hintText,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      color: selected ? Colors.white : LightColor.titleText,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    today ? 'Today' : _monthName(date),
                    style: TextStyle(
                      color: selected
                          ? Colors.white70
                          : today
                          ? LightColor.primary
                          : LightColor.hintText,
                      fontSize: 10,
                      fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<TimeSlotModel> _slotsForSelectedDate() {
    if (_selectedDateIndex < 0 ||
        _selectedDateIndex >= widget.timeSlotsByDate.length) {
      return const [];
    }
    return widget.timeSlotsByDate[_selectedDateIndex];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  String _dayName(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _monthName(DateTime date) {
    const months = [
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
    return months[date.month - 1];
  }
}

class _SlotLegend extends StatelessWidget {
  const _SlotLegend({required this.bg, required this.label});

  final Color bg;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: LightColor.border.withValues(alpha: 0.7)),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: LightColor.hintText,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
