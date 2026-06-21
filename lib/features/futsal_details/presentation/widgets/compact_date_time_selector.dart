import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';

class CompactDateTimeSelector extends StatelessWidget {
  const CompactDateTimeSelector({
    super.key,
    required this.dates,
    required this.timeSlots,
    required this.selectedDateIndex,
    required this.selectedSlotIndex,
    required this.onDateSelected,
    required this.onSlotSelected,
  });

  final List<DateTime> dates;
  final List<TimeSlotModel> timeSlots;
  final int selectedDateIndex;
  final int selectedSlotIndex;
  final ValueChanged<int> onDateSelected;
  final ValueChanged<int> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    if (dates.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(context, Icons.calendar_today_rounded, 'Select date'),
        const SizedBox(height: AppDimens.sizeX12),
        SizedBox(height: AppDimens.sizeX56, child: _buildDateStrip(context)),
        const SizedBox(height: AppDimens.sizeX18),
        _sectionLabel(context, Icons.schedule_rounded, 'Choose Preferred Time'),
        const SizedBox(height: AppDimens.sizeX12),
        _buildTimeSlots(context),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, IconData icon, String label) {
    return Row(
      children: <Widget>[
        Icon(icon, size: AppDimens.sizeX16, color: LightColor.secondaryColor),
        const SizedBox(width: AppDimens.sizeX6),
        Text(
          label,
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDateStrip(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: dates.length,
      itemBuilder: (BuildContext context, int i) {
        final DateTime date = dates[i];
        final bool selected = selectedDateIndex == i;
        final bool today = _isToday(date);
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onDateSelected(i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: AppDimens.sizeX50,
            margin: AppUtils().getMargin(right: AppDimens.marginX10),
            decoration: BoxDecoration(
              color: selected
                  ? LightColor.secondaryColor
                  : LightColor.inputFillColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  today ? 'Today' : _dayName(date),
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: selected
                        ? Colors.white70
                        : today
                        ? LightColor.secondaryColor
                        : LightColor.hintTextColor,
                    fontWeight: today ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX2),
                Text(
                  '${date.day}',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: selected
                        ? Colors.white
                        : LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeSlots(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool hasTimeRanges = timeSlots.any(_hasTimeRange);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppDimens.sizeX8,
        crossAxisSpacing: AppDimens.sizeX4,
        mainAxisExtent: hasTimeRanges ? AppDimens.sizeX30 : AppDimens.sizeX32,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (BuildContext context, int i) {
        final TimeSlotModel slot = timeSlots[i];
        final bool selected = selectedSlotIndex == i;
        final TextStyle? labelStyle = textTheme.bodyMiniSubTitle?.copyWith(
          color: selected
              ? LightColor.whiteColor
              : slot.isAvailable
              ? LightColor.primaryTextColor
              : LightColor.hintTextColor,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          decoration: slot.isAvailable ? null : TextDecoration.lineThrough,
        );

        return GestureDetector(
          onTap: slot.isAvailable
              ? () {
                  HapticFeedback.selectionClick();
                  onSlotSelected(selected ? -1 : i);
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? LightColor.secondaryColor
                  : slot.isAvailable
                  ? LightColor.secondaryLightMedium.withValues(alpha: 0.5)
                  : LightColor.dividerColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX50),
            ),
            child: Center(
              child: Padding(
                padding: AppUtils().getPadding(horizontal: AppDimens.paddingX6),
                child: Text(
                  _timeRangeLabel(slot),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: labelStyle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final DateTime now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  String _dayName(DateTime date) {
    const List<String> days = <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];
    return days[date.weekday - 1];
  }

  bool _hasTimeRange(TimeSlotModel slot) {
    return slot.endTime != null || RegExp(r'\s+[-–]\s+').hasMatch(slot.time);
  }

  String _timeRangeLabel(TimeSlotModel slot) {
    final List<String> parts = slot.time
        .split(RegExp(r'\s+[-–]\s+'))
        .map((String part) => part.trim())
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.length >= 2) {
      return '${_formatMeridiem(parts.first)} - ${_formatMeridiem(parts.sublist(1).join(' - '))}';
    }
    final String? endTime = slot.endTime?.trim();
    if (endTime != null && endTime.isNotEmpty && endTime != slot.time.trim()) {
      return '${_formatMeridiem(slot.time.trim())} - ${_formatMeridiem(endTime)}';
    }
    return _formatMeridiem(slot.time.trim());
  }

  String _formatMeridiem(String value) {
    return value
        .replaceAll(RegExp(r'\bAM\b', caseSensitive: false), 'Am')
        .replaceAll(RegExp(r'\bPM\b', caseSensitive: false), 'Pm');
  }
}
