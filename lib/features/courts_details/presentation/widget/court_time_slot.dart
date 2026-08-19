import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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
  static const LinearGradient _selectedSlotGradient = LinearGradient(
    colors: <Color>[LightColor.secondaryColor, LightColor.secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.05),
              blurRadius: AppDimens.sizeX14,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    StringConstants.selectDateAndTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextLarge?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX8),
                Container(
                  padding: AppUtils().getPadding(
                    horizontal: AppDimens.paddingX8,
                    vertical: AppDimens.paddingX4,
                  ),
                  decoration: BoxDecoration(
                    color: LightColor.secondaryLight,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: AppDimens.sizeX14,
                        color: LightColor.secondaryColor,
                      ),
                      const SizedBox(width: AppDimens.sizeX4),
                      Flexible(
                        child: Text(
                          '${widget.openTime} - ${widget.closeTime}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySubTitle?.copyWith(
                            color: LightColor.secondaryColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX16),
            _buildDateSelector(),
            const SizedBox(height: AppDimens.sizeX16),
            Wrap(
              spacing: AppDimens.sizeX14,
              runSpacing: AppDimens.sizeX8,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                _SlotLegend(
                  bg: LightColor.secondaryLight,
                  label: StringConstants.available,
                ),
                _SlotLegend(
                  bg: LightColor.secondaryColor,
                  label: StringConstants.selected,
                ),
                _SlotLegend(
                  bg: LightColor.dividerColor,
                  label: StringConstants.booked,
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppDimens.sizeX14,
                crossAxisSpacing: AppDimens.sizeX10,
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
                      gradient: selected ? _selectedSlotGradient : null,
                      color: selected
                          ? null
                          : slot.isAvailable
                          ? LightColor.secondaryLight
                          : LightColor.dividerColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            slot.time,
                            style: textTheme.bodySubTitle?.copyWith(
                              color: selected
                                  ? LightColor.inverseTextColor
                                  : slot.isAvailable
                                  ? LightColor.primaryTextColor
                                  : LightColor.hintTextColor,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              decoration: slot.isAvailable
                                  ? null
                                  : TextDecoration.lineThrough,
                            ),
                          ),
                          Text(
                            StringConstants.rs1200,
                            style: textTheme.bodyMiniSubTitle?.copyWith(
                              color: selected
                                  ? LightColor.inverseTextColor
                                  : slot.isAvailable
                                  ? LightColor.primaryTextColor
                                  : LightColor.hintTextColor,
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
      height: AppDimens.sizeX80,
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
              width: AppDimens.sizeX60,
              margin: AppUtils().getMargin(right: AppDimens.marginX10),
              decoration: BoxDecoration(
                gradient: selected ? _selectedSlotGradient : null,
                color: selected ? null : LightColor.cardColor,
                borderRadius: BorderRadius.circular(AppDimens.radiusX16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _dayName(date),
                    style: FutsalTheme.getTextTheme(context).bodySubTitle
                        ?.copyWith(
                          color: selected
                              ? LightColor.inverseTextColor.withValues(alpha: 0.7)
                              : LightColor.hintTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sizeX4),
                  Text(
                    '${date.day}',
                    style: FutsalTheme.getTextTheme(context).bodyTextLarge
                        ?.copyWith(
                          color: selected
                              ? LightColor.inverseTextColor
                              : LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: AppDimens.sizeX2),
                  Text(
                    today ? 'Today' : _monthName(date),
                    style: FutsalTheme.getTextTheme(context).bodySubTitle
                        ?.copyWith(
                          color: selected
                              ? LightColor.inverseTextColor.withValues(alpha: 0.7)
                              : today
                              ? LightColor.secondaryColor
                              : LightColor.hintTextColor,
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
          width: AppDimens.sizeX14,
          height: AppDimens.sizeX14,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusX4),
          ),
        ),
        const SizedBox(width: AppDimens.sizeX6),
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
            color: LightColor.hintTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
