import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

Future<TimeOfDay?> customCupertinoTimePicker(
  BuildContext context,
  String title, {
  TimeOfDay? initialTime,
}) async {
  final completer = Completer<TimeOfDay?>();

  final now = TimeOfDay.now();
  TimeOfDay selectedTime = initialTime ?? now;

  DateTime dateTimeFromTimeOfDay(TimeOfDay tod) {
    return DateTime(0, 1, 1, tod.hour, tod.minute);
  }

  return showModalBottomSheet<TimeOfDay?>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: LightColor.whiteColor,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimens.radiusX16),
        topRight: Radius.circular(AppDimens.radiusX16),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final textTheme = FutsalTheme.getTextTheme(context);
          return Padding(
            padding: AppUtils().getPadding(horizontal: AppDimens.paddingX16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _minimizeIndicatorWidget(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyTextMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColor.primaryTextColor,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => selectedTime = now),
                      child: Text(
                        'Reset',
                        style: textTheme.bodyTextMedium?.copyWith(
                          color: LightColor.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.sizeX12),
                IntrinsicHeight(
                  child: CupertinoTheme(
                    data: CupertinoTheme.of(context).copyWith(
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: textTheme.bodyTextLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: LightColor.primaryTextColor,
                            ),
                      ),
                    ),
                    child: SizedBox(
                      height: AppDimens.sizeX150,
                      child: CupertinoDatePicker(
                        itemExtent: 48,
                        mode: CupertinoDatePickerMode.time,
                        initialDateTime: dateTimeFromTimeOfDay(selectedTime),
                        use24hFormat: false,
                        onDateTimeChanged: (DateTime dateTime) {
                          setState(() {
                            selectedTime = TimeOfDay(
                              hour: dateTime.hour,
                              minute: dateTime.minute,
                            );
                          });
                        },
                      ),
                    ),
                  ),
                ),
                CustomButton(
                  text: 'Select',
                  backgroundColor: LightColor.secondaryColor,
                  foregroundColor: LightColor.whiteColor,
                  minHeight: AppDimens.sizeX46,
                  // margin: AppUtils().getMargin(
                  //   top: AppDimens.marginX16,
                  //   bottom: AppDimens.marginX16,
                  // ),
                  onPressed: () {
                    Navigator.pop(context);
                    completer.complete(selectedTime);
                  },
                ),
              ],
            ),
          );
        },
      );
    },
  ).then((_) => completer.future);
}

Align _minimizeIndicatorWidget() {
  return Align(
    alignment: Alignment.center,
    child: Container(
      height: AppDimens.sizeX2,
      width: AppDimens.sizeX110,
      margin: AppUtils().getMargin(
        top: AppDimens.marginX22,
        bottom: AppDimens.marginX20,
      ),
      decoration: BoxDecoration(
        color: LightColor.greyBorderColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
    ),
  );
}
