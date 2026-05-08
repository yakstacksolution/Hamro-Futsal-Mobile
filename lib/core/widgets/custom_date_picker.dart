import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';

Future<DateTime?> customCupertinoDatePicker(
  BuildContext context,
  String title, {
  DateTime? initialDate,
  DateTime? maxDate,
  DateTime? minDate,
}) async {
  final completer = Completer<DateTime?>();

  DateTime normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  final DateTime now = DateTime.now();
  DateTime computedMaxDate =
      maxDate ?? DateTime(now.year + 50, now.month, now.day);
  DateTime computedMinDate =
      minDate ?? DateTime(now.year - 100, now.month, now.day);
  DateTime computedInitialDate = initialDate ?? now;

  computedMaxDate = normalizeDate(computedMaxDate);
  computedMinDate = normalizeDate(computedMinDate);
  computedInitialDate = normalizeDate(computedInitialDate);

  computedInitialDate = computedInitialDate.isAfter(computedMaxDate)
      ? computedMaxDate
      : computedInitialDate.isBefore(computedMinDate)
      ? computedMinDate
      : computedInitialDate;

  DateTime selectedDate = computedInitialDate;
  Key datePickerKey = UniqueKey();

  return showModalBottomSheet<DateTime?>(
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                      onTap: () {
                        setState(() {
                          selectedDate = computedInitialDate;
                          datePickerKey = UniqueKey();
                        });
                      },
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
                Flexible(
                  child: ScrollDateTimePicker(
                    infiniteScroll: true,
                    visibleItem: 5,
                    key: datePickerKey,
                    itemExtent: 48,
                    onChange: (date) => selectedDate = normalizeDate(date),
                    itemFlex: const DateTimePickerItemFlex(
                      weekdayFlex: 7,
                      dayFlex: 2,
                      monthFlex: 8,
                      yearFlex: 4,
                    ),
                    dateOption: DateTimePickerOption(
                      dateFormat: DateFormat('MMMM dd y'),
                      minDate: computedMinDate,
                      maxDate: computedMaxDate,
                      initialDate: computedInitialDate,
                    ),
                    wheelOption: DateTimePickerWheelOption(
                      perspective: 0.01,
                      diameterRatio: 100,
                      squeeze: 1.1,
                      offAxisFraction: 0.0,
                      physics: const BouncingScrollPhysics(),
                    ),
                    centerWidget: DateTimePickerCenterWidget(
                      builder: (context, constraints, child) => Container(
                        height: constraints.maxHeight,
                        decoration: BoxDecoration(
                          color: LightColor.secondaryLight.withValues(
                            alpha: 0.15,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX10,
                          ),
                        ),
                      ),
                    ),
                    style: DateTimePickerStyle(
                      activeStyle: textTheme.bodyTextLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: LightColor.primaryTextColor,
                      ),
                      inactiveStyle: textTheme.bodyTextLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColor.secondaryTextColor,
                      ),
                      disabledStyle: textTheme.bodyTextLarge!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: LightColor.secondaryTextColor.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppDimens.sizeX24),
                CustomButton(
                  text: 'Select',
                  backgroundColor: LightColor.secondaryColor,
                  foregroundColor: LightColor.whiteColor,
                  minHeight: AppDimens.sizeX46,
                  margin: AppUtils().getMargin(
                    top: AppDimens.marginX16,
                    bottom: AppDimens.marginX16,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    completer.complete(selectedDate);
                  },
                ),
                SizedBox(height: 12),
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
