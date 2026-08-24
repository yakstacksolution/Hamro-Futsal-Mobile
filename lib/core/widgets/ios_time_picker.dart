import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

Future<TimeOfDay?> showIOSTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) async {
  return showModalBottomSheet<TimeOfDay>(
    context: context,
    backgroundColor: Theme.of(context).cardColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimens.radiusX20),
      ),
    ),
    builder: (BuildContext context) =>
        _IOSTimePickerSheet(initialTime: initialTime),
  );
}

class _IOSTimePickerSheet extends StatefulWidget {
  const _IOSTimePickerSheet({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_IOSTimePickerSheet> createState() => _IOSTimePickerSheetState();
}

class _IOSTimePickerSheetState extends State<_IOSTimePickerSheet> {
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialTime.hour;
    _selectedMinute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: _selectedMinute,
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.radiusX20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: AppUtils().getPadding(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    StringConstants.cancel,
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  StringConstants.selectTime,
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(
                    context,
                    TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
                  ),
                  child: Text(
                    StringConstants.done,
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.secondaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: LightColor.greyBorderColor),
          Padding(
            padding: AppUtils().getPadding(vertical: AppDimens.paddingX16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _TimeScrollWheel(
                  controller: _hourController,
                  maxValue: 23,
                  onSelectedItemChanged: (int index) {
                    setState(() => _selectedHour = index);
                  },
                ),
                Padding(
                  padding: AppUtils().getPadding(
                    horizontal: AppDimens.paddingX8,
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
                _TimeScrollWheel(
                  controller: _minuteController,
                  maxValue: 59,
                  onSelectedItemChanged: (int index) {
                    setState(() => _selectedMinute = index);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: AppUtils().getPadding(
              horizontal: AppDimens.paddingX16,
              vertical: AppDimens.paddingX16,
            ),
            child: CustomButton(
              text: StringConstants.confirm,
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.inverseTextColor,
              minHeight: AppDimens.sizeX46,
              onPressed: () => Navigator.pop(
                context,
                TimeOfDay(hour: _selectedHour, minute: _selectedMinute),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeScrollWheel extends StatelessWidget {
  const _TimeScrollWheel({
    required this.controller,
    required this.maxValue,
    required this.onSelectedItemChanged,
  });

  final FixedExtentScrollController controller;
  final int maxValue;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return SizedBox(
      width: AppDimens.sizeX80,
      height: AppDimens.sizeX200,
      child: CupertinoPicker(
        scrollController: controller,
        itemExtent: AppDimens.sizeX40,
        onSelectedItemChanged: onSelectedItemChanged,
        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
          background: LightColor.secondaryLight.withValues(alpha: 0.1),
        ),
        children: List<Widget>.generate(
          maxValue + 1,
          (int index) => Center(
            child: Text(
              index.toString().padLeft(2, '0'),
              style: textTheme.bodyTextLarge?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
