import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/core/widgets/custom_time_picker_bottom_sheet.dart';

class CustomTimeField extends StatefulWidget {
  const CustomTimeField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.initialFallback,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TimeOfDay? initialFallback;

  @override
  State<CustomTimeField> createState() => _CustomTimeFieldState();
}

class _CustomTimeFieldState extends State<CustomTimeField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant CustomTimeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The field is read-only and fully driven by [value]; keep the controller
    // in sync so a newly picked time is reflected on the next rebuild.
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      labelText: widget.label,
      controller: _controller,
      readOnly: true,
      suffixIcon: const Icon(
        Icons.schedule_rounded,
        color: LightColor.secondaryColor,
      ),
      onTap: () => _pickTime(context),
      onChanged: (_) {},
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay initial =
        timeOfDayFromString(widget.value) ??
        widget.initialFallback ??
        TimeOfDay.now();
    final TimeOfDay? picked = await customCupertinoTimePicker(
      context,
      'Select Time',
      initialTime: initial,
    );
    if (picked == null) return;
    widget.onChanged(formatTimeOfDay(picked));
  }
}

TimeOfDay? timeOfDayFromString(String value) {
  final RegExpMatch? twelveHourMatch = RegExp(
    r'^\s*(\d{1,2})\s*:\s*(\d{2})\s*(AM|PM)\s*$',
    caseSensitive: false,
  ).firstMatch(value);
  if (twelveHourMatch != null) {
    final int? hourValue = int.tryParse(twelveHourMatch.group(1)!);
    final int? minute = int.tryParse(twelveHourMatch.group(2)!);
    if (hourValue == null || minute == null) return null;
    if (hourValue < 1 || hourValue > 12 || minute < 0 || minute > 59) {
      return null;
    }
    final String meridiem = twelveHourMatch.group(3)!.toUpperCase();
    final int hour = meridiem == 'AM'
        ? hourValue % 12
        : hourValue == 12
        ? 12
        : hourValue + 12;
    return TimeOfDay(hour: hour, minute: minute);
  }

  final List<String> parts = value.split(':');
  if (parts.length != 2) return null;
  final int? hour = int.tryParse(parts.first.trim());
  final int? minute = int.tryParse(parts.last.trim());
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String formatTimeOfDay(TimeOfDay time) {
  final int twelveHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final String hour = twelveHour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  final String meridiem = time.period == DayPeriod.am ? 'AM' : 'PM';
  return '$hour : $minute $meridiem';
}

int minutesFromTimeOfDay(TimeOfDay time) {
  return (time.hour * 60) + time.minute;
}
