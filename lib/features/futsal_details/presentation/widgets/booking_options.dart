import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_recurrence.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_court_item_model.dart';

/// A small animated on/off toggle (custom switch).
class CustomToggleButton extends StatelessWidget {
  const CustomToggleButton({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: AppDimens.sizeX44,
        height: AppDimens.sizeX24,
        padding: AppUtils().getPadding(all: AppDimens.paddingX2),
        decoration: BoxDecoration(
          color: value ? LightColor.secondaryColor : LightColor.dividerColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX50),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: AppDimens.sizeX20,
            height: AppDimens.sizeX20,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class BookingTypeCard extends StatelessWidget {
  const BookingTypeCard({
    super.key,
    required this.mode,
    required this.onModeChanged,
    required this.recurrence,
    required this.onRecurrenceChanged,
    required this.startDate,
    required this.selectedCourt,
    this.selectedTime,
    this.isCheckingAvailability = false,
  });

  final BookingMode mode;
  final ValueChanged<BookingMode> onModeChanged;
  final BookingRecurrence recurrence;
  final ValueChanged<BookingRecurrence> onRecurrenceChanged;
  final DateTime startDate;
  final VenueCourtItemModel selectedCourt;
  final String? selectedTime;

  /// While the `/bookings/recurring-availability` call is in flight we show a
  /// spinner on the duration boxes (instead of a separate section below).
  final bool isCheckingAvailability;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool recurring = mode == BookingMode.recurring;
    final List<DateTime> dates = recurrence.datesFrom(startDate);

    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.05),
            blurRadius: AppDimens.sizeX14,
            offset: const Offset(0, AppDimens.sizeX4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: AppUtils().getPadding(all: AppDimens.paddingX8),
                decoration: BoxDecoration(
                  color: LightColor.secondarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: const Icon(
                  Icons.repeat_rounded,
                  size: AppDimens.sizeX16,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Recurring booking',
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      recurring
                          ? 'Every ${_weekdayFull(startDate)} · same time'
                          : 'Repeat weekly on the same day & time',
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.hintTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              CustomToggleButton(
                value: recurring,
                onChanged: (bool on) => onModeChanged(
                  on ? BookingMode.recurring : BookingMode.single,
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !recurring
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: AppDimens.sizeX12),
                      Row(
                        children: BookingRecurrence.values.map((
                          BookingRecurrence option,
                        ) {
                          final bool selected = option == recurrence;
                          final bool showSpinner =
                              isCheckingAvailability && selected;
                          return Expanded(
                            child: Padding(
                              padding: AppUtils().getPadding(
                                right: AppDimens.paddingX6,
                              ),
                              child: GestureDetector(
                                onTap: isCheckingAvailability
                                    ? null
                                    : () {
                                        HapticFeedback.selectionClick();
                                        onRecurrenceChanged(option);
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: AppUtils().getPadding(
                                    vertical: AppDimens.paddingX8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? LightColor.secondaryColor
                                        : LightColor.inputFillColor,
                                    borderRadius: BorderRadius.circular(
                                      AppDimens.radiusX6,
                                    ),
                                  ),
                                  child: showSpinner
                                      ? const Center(
                                          child: SizedBox(
                                            width: AppDimens.sizeX12,
                                            height: AppDimens.sizeX12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    LightColor.whiteColor,
                                                  ),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          option.label,
                                          textAlign: TextAlign.center,
                                          style: textTheme.bodyMiniSubTitle
                                              ?.copyWith(
                                                color: selected
                                                    ? LightColor.whiteColor
                                                    : LightColor
                                                          .primaryTextColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppDimens.sizeX10),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.event_repeat_rounded,
                            size: AppDimens.sizeX16,
                            color: LightColor.secondaryColor,
                          ),
                          const SizedBox(width: AppDimens.sizeX6),
                          Expanded(
                            child: Text(
                              '${recurrence.sessions} sessions · ${_shortDate(dates.first)} → ${_shortDate(dates.last)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySubTitle?.copyWith(
                                color: LightColor.secondaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppDimens.sizeX8),
                          _RecurringPriceInfoButton(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              if (selectedTime == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Select a time slot to see prices.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              showAppBottomSheet<void>(
                                context: context,
                                child: _RecurringPriceSheet(
                                  court: selectedCourt,
                                  dates: dates,
                                  selectedTime: selectedTime!,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  static const List<String> _daysShort = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _daysFull = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> _months = <String>[
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

  String _weekdayFull(DateTime date) => _daysFull[date.weekday - 1];

  String _shortDate(DateTime date) =>
      '${_daysShort[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';
}

class _RecurringPriceInfoButton extends StatelessWidget {
  const _RecurringPriceInfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Recurring price details',
      child: Material(
        color: LightColor.secondarySoft,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: AppDimens.sizeX30,
            height: AppDimens.sizeX30,
            child: Icon(
              Icons.info_outline_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.secondaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _RecurringPriceSheet extends StatelessWidget {
  const _RecurringPriceSheet({
    required this.court,
    required this.dates,
    required this.selectedTime,
  });

  final VenueCourtItemModel court;
  final List<DateTime> dates;
  final String selectedTime;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final double total = dates.fold<double>(
      0,
      (double sum, DateTime date) => sum + court.priceFor(date, selectedTime),
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                decoration: BoxDecoration(
                  color: LightColor.secondarySoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: AppDimens.sizeX18,
                  color: LightColor.secondaryColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Recurring price details',
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      '${court.name} · $selectedTime',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySubTitle?.copyWith(
                        color: LightColor.hintTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: dates.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppDimens.sizeX8),
              itemBuilder: (BuildContext context, int index) {
                final DateTime date = dates[index];
                final double price = court.priceFor(date, selectedTime);

                return Container(
                  width: double.infinity,
                  padding: AppUtils().getPadding(
                    horizontal: AppDimens.paddingX12,
                    vertical: AppDimens.paddingX10,
                  ),
                  decoration: BoxDecoration(
                    color: LightColor.inputFillColor,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                  ),
                  child: Text(
                    '${_detailDate(date)} [$selectedTime] => Rs ${price.toStringAsFixed(0)}',
                    style: textTheme.bodySubTitle?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.sizeX14),
          const Divider(height: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.sizeX12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Total · ${dates.length} sessions',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Text(
                'Rs ${total.toStringAsFixed(0)}',
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.secondaryColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const List<String> _daysShort = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _months = <String>[
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

  String _detailDate(DateTime date) =>
      '${_daysShort[date.weekday - 1]} ${date.day} ${_months[date.month - 1]} ${date.year}';
}
