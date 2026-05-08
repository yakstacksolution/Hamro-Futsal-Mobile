import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

Future<TimeOfDay?> showCustomTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  return showDialog<TimeOfDay>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => _CustomTimePickerDialog(
      initialTime: initialTime,
    ),
  );
}

class _CustomTimePickerDialog extends StatefulWidget {
  const _CustomTimePickerDialog({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_CustomTimePickerDialog> createState() =>
      _CustomTimePickerDialogState();
}

class _CustomTimePickerDialogState extends State<_CustomTimePickerDialog> {
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX20),
      ),
      backgroundColor: LightColor.whiteColor,
      child: Container(
        padding: AppUtils().getPadding(all: AppDimens.paddingX24),
        decoration: BoxDecoration(
          color: LightColor.whiteColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Select Time',
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimens.sizeX24),
            Container(
              padding: AppUtils().getPadding(all: AppDimens.paddingX20),
              decoration: BoxDecoration(
                color: LightColor.background,
                borderRadius: BorderRadius.circular(AppDimens.radiusX16),
                border: Border.all(color: LightColor.greyBorderColor),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _TimeSelector(
                        value: _selectedHour,
                        maxValue: 23,
                        onChanged: (int value) =>
                            setState(() => _selectedHour = value),
                      ),
                      Padding(
                        padding: AppUtils().getPadding(
                          horizontal: AppDimens.paddingX12,
                        ),
                        child: Text(
                          ':',
                          style: textTheme.bodyTextLarge?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: FontWeight.w800,
                            fontSize: AppDimens.fontHeadingXXSmall,
                          ),
                        ),
                      ),
                      _TimeSelector(
                        value: _selectedMinute,
                        maxValue: 59,
                        onChanged: (int value) =>
                            setState(() => _selectedMinute = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.sizeX20),
                  _TimeSlider(
                    label: 'Hour',
                    value: _selectedHour,
                    maxValue: 23,
                    onChanged: (double value) =>
                        setState(() => _selectedHour = value.toInt()),
                  ),
                  const SizedBox(height: AppDimens.sizeX16),
                  _TimeSlider(
                    label: 'Minute',
                    value: _selectedMinute,
                    maxValue: 59,
                    onChanged: (double value) =>
                        setState(() => _selectedMinute = value.toInt()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimens.sizeX24),
            Row(
              children: <Widget>[
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    isOutlined: true,
                    foregroundColor: LightColor.secondaryColor,
                    borderColor: LightColor.secondaryColor,
                    minHeight: AppDimens.sizeX46,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX12),
                Expanded(
                  child: CustomButton(
                    text: 'Confirm',
                    backgroundColor: LightColor.secondaryColor,
                    foregroundColor: LightColor.whiteColor,
                    minHeight: AppDimens.sizeX46,
                    onPressed: () => Navigator.of(context).pop(
                      TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  const _TimeSelector({
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  final int value;
  final int maxValue;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            final int newValue = (value + 1) % (maxValue + 1);
            onChanged(newValue);
          },
          child: Container(
            padding: AppUtils().getPadding(all: AppDimens.paddingX8),
            decoration: BoxDecoration(
              color: LightColor.secondaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: const Icon(
              Icons.keyboard_arrow_up_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX20,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sizeX8),
        Container(
          width: AppDimens.sizeX60,
          padding: AppUtils().getPadding(all: AppDimens.paddingX12),
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: LightColor.secondaryColor,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.secondaryColor,
                fontWeight: FontWeight.w800,
                fontSize: AppDimens.fontHeadingXXSmall,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sizeX8),
        GestureDetector(
          onTap: () {
            final int newValue = value == 0 ? maxValue : value - 1;
            onChanged(newValue);
          },
          child: Container(
            padding: AppUtils().getPadding(all: AppDimens.paddingX8),
            decoration: BoxDecoration(
              color: LightColor.secondaryLight.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX20,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimeSlider extends StatelessWidget {
  const _TimeSlider({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int maxValue;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX8),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: AppDimens.sizeX6,
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: AppDimens.sizeX12,
              elevation: 4,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: AppDimens.sizeX18,
            ),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: maxValue.toDouble(),
            divisions: maxValue,
            activeColor: LightColor.secondaryColor,
            inactiveColor: LightColor.greyBorderColor,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
