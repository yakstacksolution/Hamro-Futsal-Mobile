import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/booking_recurrence.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/recurring_availability_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_court_item_model.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

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
            decoration: BoxDecoration(
              color: LightColor.inverseTextColor,
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
    required this.weekdays,
    required this.onWeekdayToggled,
    required this.startDate,
    required this.selectedCourt,
    this.selectedTime,
    this.isCheckingAvailability = false,
    this.availability,
  });

  final BookingMode mode;
  final ValueChanged<BookingMode> onModeChanged;
  final BookingRecurrence recurrence;
  final ValueChanged<BookingRecurrence> onRecurrenceChanged;

  /// Weekdays the booking repeats on (`DateTime.monday`…`sunday`), already
  /// resolved — never empty while recurring.
  final Set<int> weekdays;

  /// Adds or removes one weekday. Removing the last one is a no-op upstream.
  final ValueChanged<int> onWeekdayToggled;

  final DateTime startDate;
  final VenueCourtItemModel selectedCourt;
  final String? selectedTime;

  /// While the `/bookings/recurring-availability` call is in flight we show a
  /// spinner on the duration boxes (instead of a separate section below).
  final bool isCheckingAvailability;

  /// Latest `/bookings/recurring-availability` result for this selection, when
  /// one has been fetched. Drives the available / unavailable breakdown.
  final RecurringAvailabilityModel? availability;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool recurring = mode == BookingMode.recurring;
    final List<DateTime> dates = recurrence.datesFrom(
      startDate,
      weekdays: weekdays,
    );

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
                      StringConstants.recurringBooking,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      recurring
                          ? 'Every ${RecurringWeekdays.summary(weekdays)} · same time'
                          : 'Repeat weekly on the days you choose',
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
                      _SectionLabel(label: StringConstants.repeatOn),
                      const SizedBox(height: AppDimens.sizeX8),
                      _WeekdayPicker(
                        selected: weekdays,
                        enabled: !isCheckingAvailability,
                        onToggled: onWeekdayToggled,
                      ),
                      const SizedBox(height: AppDimens.sizeX12),
                      _SectionLabel(label: StringConstants.repeatFor),
                      const SizedBox(height: AppDimens.sizeX8),
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
                                      ? Center(
                                          child: SizedBox(
                                            width: AppDimens.sizeX12,
                                            height: AppDimens.sizeX12,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 1.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    LightColor.inverseTextColor,
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
                                                    ? LightColor
                                                          .inverseTextColor
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  '${dates.length} sessions · ${_shortDate(dates.first)} → ${_shortDate(dates.last)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySubTitle?.copyWith(
                                    color: LightColor.secondaryColor,
                                  ),
                                ),
                                if (availability != null &&
                                    availability!.hasSessions) ...<Widget>[
                                  const SizedBox(height: AppDimens.sizeX2),
                                  Text(
                                    availability!.hasUnavailableDates
                                        ? '${availability!.availableCount} available · ${availability!.unavailableCount} unavailable'
                                        : 'All ${availability!.totalCount} dates available',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMiniSubTitle?.copyWith(
                                      color: availability!.hasUnavailableDates
                                          ? LightColor.redColor
                                          : LightColor.hintTextColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
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
                                      StringConstants
                                          .selectATimeSlotToSeePrices,
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
                                  availability: availability,
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

  String _shortDate(DateTime date) =>
      '${_daysShort[date.weekday - 1]} ${date.day} ${_months[date.month - 1]}';
}

/// Small caption above a group of controls inside the recurring card.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
        color: LightColor.hintTextColor,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Sunday-first row of weekday toggles.
///
/// The set is never empty — the bloc refuses the tap that would clear the last
/// day — so the picker always describes a bookable schedule.
class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({
    required this.selected,
    required this.onToggled,
    required this.enabled,
  });

  final Set<int> selected;
  final ValueChanged<int> onToggled;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Row(
      children: RecurringWeekdays.displayOrder
          .map((int weekday) {
            final bool isOn = selected.contains(weekday);
            // The last remaining day cannot be turned off, so it reads as locked
            // rather than as a control that silently ignores taps.
            final bool isLocked = isOn && selected.length == 1;

            return Expanded(
              child: Padding(
                padding: AppUtils().getPadding(right: AppDimens.paddingX6),
                child: Semantics(
                  button: true,
                  selected: isOn,
                  label: RecurringWeekdays.fullLabel(weekday),
                  child: GestureDetector(
                    onTap: !enabled || isLocked
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            onToggled(weekday);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      height: AppDimens.sizeX36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isOn
                            ? LightColor.secondaryColor
                            : LightColor.inputFillColor,
                        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                        border: Border.all(
                          color: isOn
                              ? LightColor.secondaryColor
                              : LightColor.dividerColor,
                        ),
                      ),
                      child: Text(
                        RecurringWeekdays.initial(weekday),
                        style: textTheme.bodySubTitle?.copyWith(
                          color: isOn
                              ? LightColor.inverseTextColor
                              : LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          })
          .toList(growable: false),
    );
  }
}

class _RecurringPriceInfoButton extends StatelessWidget {
  const _RecurringPriceInfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: StringConstants.recurringPriceDetails,
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
    this.availability,
  });

  final VenueCourtItemModel court;
  final List<DateTime> dates;
  final String selectedTime;
  final RecurringAvailabilityModel? availability;

  bool _isAvailable(DateTime date) {
    final RecurringAvailabilityModel? model = availability;
    if (model == null || !model.hasSessions) return true;
    return !model.unavailableDateKeys.contains(_apiDate(date));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool knowsAvailability =
        availability != null && availability!.hasSessions;
    final List<DateTime> availableDates = dates
        .where(_isAvailable)
        .toList(growable: false);
    final List<DateTime> unavailableDates = dates
        .where((DateTime date) => !_isAvailable(date))
        .toList(growable: false);

    // Only the dates that can actually be booked are charged.
    final double total = availableDates.fold<double>(
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
                      StringConstants.recurringPriceDetails,
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
          if (knowsAvailability) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX12),
            _AvailabilityBanner(
              availableCount: availableDates.length,
              unavailableCount: unavailableDates.length,
            ),
          ],
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
                final bool ok = _isAvailable(date);

                return Container(
                  width: double.infinity,
                  padding: AppUtils().getPadding(
                    horizontal: AppDimens.paddingX12,
                    vertical: AppDimens.paddingX10,
                  ),
                  decoration: BoxDecoration(
                    color: ok
                        ? LightColor.inputFillColor
                        : LightColor.redColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(AppDimens.radiusX10),
                    border: ok
                        ? null
                        : Border.all(
                            color: LightColor.redColor.withValues(alpha: 0.35),
                          ),
                  ),
                  // Date on the left, price pushed to the right edge, so the
                  // prices form a readable column down the sheet instead of
                  // trailing each date at a different offset.
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              _detailDate(date),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySubTitle?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w700,
                                decoration: ok
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(height: AppDimens.sizeX2),
                            Row(
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    selectedTime,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: textTheme.bodyMiniSubTitle?.copyWith(
                                      color: LightColor.hintTextColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (knowsAvailability) ...<Widget>[
                                  const SizedBox(width: AppDimens.sizeX6),
                                  Icon(
                                    ok
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    size: AppDimens.sizeX12,
                                    color: ok
                                        ? LightColor.secondaryColor
                                        : LightColor.redColor,
                                  ),
                                  const SizedBox(width: AppDimens.sizeX4),
                                  Text(
                                    ok ? 'Available' : 'Unavailable',
                                    style: textTheme.bodyMiniSubTitle?.copyWith(
                                      color: ok
                                          ? LightColor.secondaryColor
                                          : LightColor.redColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppDimens.sizeX16),
                      Text(
                        'Rs ${price.toStringAsFixed(0)}',
                        style: textTheme.bodySubTitle?.copyWith(
                          color: ok
                              ? LightColor.primaryTextColor
                              : LightColor.hintTextColor,
                          fontWeight: FontWeight.w800,
                          decoration: ok ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppDimens.sizeX14),
          Divider(height: 1, color: LightColor.dividerColor),
          const SizedBox(height: AppDimens.sizeX12),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Total · ${availableDates.length} sessions',
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

  static String _apiDate(DateTime date) {
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    return '${date.year.toString().padLeft(4, '0')}-$month-$day';
  }

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

  /// `Sunday, 16 Aug 2026` — the weekday is spelled out here because the sheet
  /// is where the user checks which days they are actually paying for.
  String _detailDate(DateTime date) =>
      '${RecurringWeekdays.fullLabel(date.weekday)}, '
      '${date.day} ${_months[date.month - 1]} ${date.year}';
}

/// Available / unavailable split for a recurring schedule, shown above the
/// per-date price list so the counts are visible before scrolling.
class _AvailabilityBanner extends StatelessWidget {
  const _AvailabilityBanner({
    required this.availableCount,
    required this.unavailableCount,
  });

  final int availableCount;
  final int unavailableCount;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool allOk = unavailableCount == 0;

    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX10,
      ),
      decoration: BoxDecoration(
        color: (allOk ? LightColor.secondaryColor : LightColor.redColor)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            allOk ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            size: AppDimens.sizeX18,
            color: allOk ? LightColor.secondaryColor : LightColor.redColor,
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  allOk
                      ? 'All $availableCount dates available'
                      : '$availableCount available · $unavailableCount unavailable',
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!allOk) ...<Widget>[
                  const SizedBox(height: AppDimens.sizeX2),
                  Text(
                    'Unavailable dates are not charged and will be skipped.',
                    style: textTheme.bodyMiniSubTitle?.copyWith(
                      color: LightColor.hintTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
