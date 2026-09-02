import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

Future<TimeOfDay?> customCupertinoTimePicker(
  BuildContext context,
  String title, {
  TimeOfDay? initialTime,
}) async {
  final completer = Completer<TimeOfDay?>();

  final now = TimeOfDay.now();
  TimeOfDay selectedTime = initialTime ?? now;

  return showModalBottomSheet<TimeOfDay?>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: context.appColors.surfaceElevated,
    barrierColor: LightColor.scrimColor,
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
          final bottomInset = MediaQuery.of(context).viewPadding.bottom;
          final pickerTextStyle = textTheme.bodyTextLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: LightColor.primaryTextColor,
          );

          final hour12 = selectedTime.hourOfPeriod == 0
              ? 12
              : selectedTime.hourOfPeriod;
          final isAm = selectedTime.period == DayPeriod.am;

          void updateTime({int? hour12, int? minute, bool? am}) {
            final h12 =
                hour12 ??
                (selectedTime.hourOfPeriod == 0
                    ? 12
                    : selectedTime.hourOfPeriod);
            final m = minute ?? selectedTime.minute;
            final amNow = am ?? (selectedTime.period == DayPeriod.am);
            var h24 = h12 % 12;
            if (!amNow) h24 += 12;
            selectedTime = TimeOfDay(hour: h24, minute: m);
          }

          return Padding(
            padding: AppUtils().getPadding(
              left: AppDimens.paddingX16,
              right: AppDimens.paddingX16,
              bottom: bottomInset + AppDimens.paddingX24,
            ),
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
                        StringConstants.reset,
                        style: textTheme.bodyTextMedium?.copyWith(
                          color: LightColor.secondaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppDimens.sizeX12),
                SizedBox(
                  height: AppDimens.sizeX220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      IgnorePointer(
                        child: Container(
                          height: AppDimens.sizeX48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: LightColor.secondaryColor.withValues(
                                alpha: 0.4,
                              ),
                              width: AppDimens.sizeX1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX12,
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            width: AppDimens.sizeX60,
                            child: CupertinoPicker(
                              key: ValueKey('hour-$selectedTime'),
                              itemExtent: AppDimens.sizeX48,
                              backgroundColor: Colors.transparent,
                              selectionOverlay: const SizedBox.shrink(),
                              scrollController: FixedExtentScrollController(
                                initialItem: hour12 - 1,
                              ),
                              onSelectedItemChanged: (index) =>
                                  updateTime(hour12: index + 1),
                              children: List<Widget>.generate(
                                12,
                                (i) => Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: pickerTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimens.sizeX12),
                          SizedBox(
                            width: AppDimens.sizeX60,
                            child: CupertinoPicker(
                              key: ValueKey('minute-$selectedTime'),
                              itemExtent: AppDimens.sizeX48,
                              backgroundColor: Colors.transparent,
                              selectionOverlay: const SizedBox.shrink(),
                              scrollController: FixedExtentScrollController(
                                initialItem: selectedTime.minute,
                              ),
                              onSelectedItemChanged: (index) =>
                                  updateTime(minute: index),
                              children: List<Widget>.generate(
                                60,
                                (i) => Center(
                                  child: Text(
                                    i.toString().padLeft(2, '0'),
                                    style: pickerTextStyle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppDimens.sizeX12),
                          SizedBox(
                            width: AppDimens.sizeX60,
                            child: CupertinoPicker(
                              key: ValueKey('period-$selectedTime'),
                              itemExtent: AppDimens.sizeX48,
                              backgroundColor: Colors.transparent,
                              selectionOverlay: const SizedBox.shrink(),
                              scrollController: FixedExtentScrollController(
                                initialItem: isAm ? 0 : 1,
                              ),
                              onSelectedItemChanged: (index) =>
                                  updateTime(am: index == 0),
                              children: <Widget>[
                                Center(
                                  child: Text(
                                    StringConstants.am,
                                    style: pickerTextStyle,
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    StringConstants.pm,
                                    style: pickerTextStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimens.sizeX24),
                CustomButton(
                  text: StringConstants.select,
                  backgroundColor: LightColor.secondaryColor,
                  foregroundColor: LightColor.inverseTextColor,
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
