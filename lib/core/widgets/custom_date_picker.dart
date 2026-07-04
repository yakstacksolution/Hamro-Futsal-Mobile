import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:scroll_datetime_picker/scroll_datetime_picker.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

/// Variants supported by [showCustomDatePicker]. Each variant ships with
/// sensible defaults for min/max/initial dates, title, and display format so
/// callers only need to pick a type for the common cases.
enum CustomDatePickerType {
  /// Past-only picker tuned for capturing a user's date of birth.
  dateOfBirth,

  /// Any date in the past (e.g. payment date, document issue date).
  pastDate,

  /// Any date in the future (e.g. expiry date, scheduled booking).
  futureDate,

  /// Unrestricted picker covering a wide window around today.
  anyDate,
}

/// Single entry point for every in-app date picker. The [type] resolves the
/// default bounds, title, and date format; callers can still override any of
/// them via [initialDate], [minDate], [maxDate], [title], and [dateFormat].
Future<DateTime?> showCustomDatePicker(
  BuildContext context, {
  CustomDatePickerType type = CustomDatePickerType.anyDate,
  String? title,
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
  DateFormat? dateFormat,
  String confirmText = 'Select',
}) {
  final _DatePickerSpec spec = _resolveSpec(type);
  final DateTime resolvedMin = minDate ?? spec.minDate;
  final DateTime resolvedMax = maxDate ?? spec.maxDate;
  final DateTime resolvedInitial = initialDate ?? spec.initialDate;

  return _showDateSheet(
    context,
    title: title ?? spec.title,
    initialDate: resolvedInitial,
    minDate: resolvedMin,
    maxDate: resolvedMax,
    dateFormat: dateFormat ?? spec.dateFormat,
    confirmText: confirmText,
  );
}

class _DatePickerSpec {
  const _DatePickerSpec({
    required this.title,
    required this.initialDate,
    required this.minDate,
    required this.maxDate,
    required this.dateFormat,
  });

  final String title;
  final DateTime initialDate;
  final DateTime minDate;
  final DateTime maxDate;
  final DateFormat dateFormat;
}

_DatePickerSpec _resolveSpec(CustomDatePickerType type) {
  final DateTime now = DateTime.now();
  final DateTime today = DateTime(now.year, now.month, now.day);

  switch (type) {
    case CustomDatePickerType.dateOfBirth:
      return _DatePickerSpec(
        title: StringConstants.dateOfBirth,
        initialDate: DateTime(today.year - 18, today.month, today.day),
        minDate: DateTime(1900, 1, 1),
        maxDate: today,
        dateFormat: DateFormat('dd MMM y'),
      );
    case CustomDatePickerType.pastDate:
      return _DatePickerSpec(
        title: StringConstants.selectDate,
        initialDate: today,
        minDate: DateTime(today.year - 100, today.month, today.day),
        maxDate: today,
        dateFormat: DateFormat('dd MMM y'),
      );
    case CustomDatePickerType.futureDate:
      return _DatePickerSpec(
        title: StringConstants.selectDate,
        initialDate: today,
        minDate: today,
        maxDate: DateTime(today.year + 50, today.month, today.day),
        dateFormat: DateFormat('dd MMM y'),
      );
    case CustomDatePickerType.anyDate:
      return _DatePickerSpec(
        title: StringConstants.selectDate,
        initialDate: today,
        minDate: DateTime(today.year - 100, today.month, today.day),
        maxDate: DateTime(today.year + 50, today.month, today.day),
        dateFormat: DateFormat('MMMM dd y'),
      );
  }
}

DateTime _clampDate(DateTime value, DateTime min, DateTime max) {
  if (value.isAfter(max)) return max;
  if (value.isBefore(min)) return min;
  return value;
}

DateTime _normalizeDate(DateTime date) =>
    DateTime(date.year, date.month, date.day);

Future<DateTime?> _showDateSheet(
  BuildContext context, {
  required String title,
  required DateTime initialDate,
  required DateTime minDate,
  required DateTime maxDate,
  required DateFormat dateFormat,
  required String confirmText,
}) async {
  final Completer<DateTime?> completer = Completer<DateTime?>();

  final DateTime normalizedMin = _normalizeDate(minDate);
  final DateTime normalizedMax = _normalizeDate(maxDate);
  final DateTime normalizedInitial = _clampDate(
    _normalizeDate(initialDate),
    normalizedMin,
    normalizedMax,
  );

  DateTime selectedDate = normalizedInitial;
  Key pickerKey = UniqueKey();

  await showModalBottomSheet<DateTime?>(
    context: context,
    isDismissible: true,
    isScrollControlled: true,
    backgroundColor: LightColor.whiteColor,
    barrierColor: Colors.black.withValues(alpha: 0.3),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppDimens.radiusX16),
        topRight: Radius.circular(AppDimens.radiusX16),
      ),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final textTheme = FutsalTheme.getTextTheme(context);
          return SafeArea(
            top: false,
            child: Padding(
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
                            selectedDate = normalizedInitial;
                            pickerKey = UniqueKey();
                          });
                        },
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
                  const SizedBox(height: AppDimens.sizeX12),
                  Flexible(
                    child: ScrollDateTimePicker(
                      key: pickerKey,
                      infiniteScroll: true,
                      visibleItem: 5,
                      itemExtent: 48,
                      onChange: (date) => selectedDate = _normalizeDate(date),
                      itemFlex: const DateTimePickerItemFlex(
                        weekdayFlex: 7,
                        dayFlex: 2,
                        monthFlex: 8,
                        yearFlex: 4,
                      ),
                      dateOption: DateTimePickerOption(
                        dateFormat: dateFormat,
                        minDate: normalizedMin,
                        maxDate: normalizedMax,
                        initialDate: normalizedInitial,
                      ),
                      wheelOption: const DateTimePickerWheelOption(
                        perspective: 0.01,
                        diameterRatio: 100,
                        squeeze: 1.1,
                        offAxisFraction: 0.0,
                        physics: BouncingScrollPhysics(),
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
                  const SizedBox(height: AppDimens.sizeX24),
                  CustomButton(
                    text: confirmText,
                    backgroundColor: LightColor.secondaryColor,
                    foregroundColor: LightColor.whiteColor,
                    minHeight: AppDimens.sizeX46,
                    margin: AppUtils().getMargin(
                      top: AppDimens.marginX16,
                      bottom: AppDimens.marginX16,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      if (!completer.isCompleted) {
                        completer.complete(selectedDate);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  if (!completer.isCompleted) completer.complete(null);
  return completer.future;
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
