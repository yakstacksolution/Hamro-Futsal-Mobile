import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_time_field.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

const List<String> weekdayOptions = <String>[
  'Sun',
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
];

TimeOfDay? timeOfDayFromString(String value) {
  final List<String> parts = value.split(':');
  if (parts.length != 2) return null;
  final int? hour = int.tryParse(parts.first);
  final int? minute = int.tryParse(parts.last);
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String formatTimeOfDay(TimeOfDay time) {
  final String hour = time.hour.toString().padLeft(2, '0');
  final String minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

int minutesFromTimeOfDay(TimeOfDay time) {
  return (time.hour * 60) + time.minute;
}

class CourtSlotsSection extends StatelessWidget {
  const CourtSlotsSection({
    super.key,
    required this.cubit,
    required this.court,
    required this.subsectionIndex,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final int subsectionIndex;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      child: switch (subsectionIndex) {
        0 => _WeekendHolidayView(cubit: cubit, court: court),
        1 => _SlotScheduleView(cubit: cubit, court: court),
        _ => _SlotPricingView(cubit: cubit, court: court),
      },
    );
  }
}

class _SlotScheduleView extends StatelessWidget {
  const _SlotScheduleView({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        VendorOnboardingSectionHeader(
          title: 'Slot Schedule',
          subtitle: 'Create reusable booking slots with days and times',
          icon: Icons.calendar_month_rounded,
          trailing: SizedBox(
            width: AppDimens.sizeX90,
            child: CustomButton(
              text: 'Add Slot',
              minHeight: AppDimens.sizeX34,
              fontSize: AppDimens.fontBodyTextSmall,
              verticalPadding: AppDimens.paddingX2,
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.whiteColor,
              onPressed: cubit.addSlotToActiveCourt,
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sizeX12),
        if (court.slotConfigs.isEmpty)
          const _EmptySlotsCard()
        else
          Column(
            children: court.slotConfigs
                .map(
                  (SlotPricingDraft slot) => Padding(
                    padding: AppUtils().getPadding(
                      bottom: AppDimens.paddingX12,
                    ),
                    child: _ScheduleSlotCard(
                      key: ValueKey<String>(slot.id),
                      slot: slot,
                      onChanged: (SlotPricingDraft nextSlot) =>
                          cubit.updateSlot(slot.id, nextSlot),
                      onToggleDay: (String day) =>
                          cubit.toggleSlotDay(slot.id, day),
                      onRemove: () => cubit.removeSlot(slot.id),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _WeekendHolidayView extends StatelessWidget {
  const _WeekendHolidayView({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  Future<void> _pickHolidayDates(BuildContext context) async {
    final Set<String>? picked = await showDialog<Set<String>>(
      context: context,
      builder: (BuildContext context) {
        return _CustomCalendarDatePickerDialog(
          title: 'Holiday dates',
          initialDates: court.holidayDates,
        );
      },
    );
    if (picked == null || picked.isEmpty) return;
    cubit.addCourtHolidayDates(picked);
  }

  Future<void> _pickClosedDate(BuildContext context) async {
    final ClosedDateDraft? picked = await showDialog<ClosedDateDraft>(
      context: context,
      builder: (BuildContext context) {
        return _ClosedDateDialog(
          initialDates: court.closedDates
              .map((ClosedDateDraft item) => item.date)
              .toSet(),
        );
      },
    );
    if (picked == null) return;
    cubit.addCourtClosedDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VendorOnboardingSectionHeader(
          title: 'Weekend, Holidays & Closures',
          subtitle: 'Special days for pricing and booking availability',
          icon: Icons.event_repeat_rounded,
        ),
        const SizedBox(height: AppDimens.sizeX12),
        Text(
          'Weekend days',
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX10),
        Wrap(
          spacing: AppDimens.sizeX8,
          runSpacing: AppDimens.sizeX8,
          children: weekdayOptions
              .map(
                (String day) => VendorSelectableChip(
                  label: day,
                  isSelected: court.weekendDays.contains(day),
                  onTap: () => cubit.toggleCourtWeekendDay(day),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppDimens.sizeX16),
        _DateCollectionCard(
          title: 'Holiday dates',
          subtitle: 'Bookings remain open and holiday pricing can apply.',
          icon: Icons.celebration_rounded,
          dates: court.holidayDates,
          emptyText: 'No holiday dates added.',
          actionLabel: 'Add Holiday',
          onAdd: () => _pickHolidayDates(context),
          onRemove: cubit.removeCourtHolidayDate,
          isHighlighted: true,
        ),
        const SizedBox(height: AppDimens.sizeX12),
        _ClosedDateCollectionCard(
          title: 'Closed dates',
          subtitle: 'Close a full day or only a specific hour range.',
          icon: Icons.event_busy_rounded,
          dates: court.closedDates,
          emptyText: 'No closed dates added.',
          actionLabel: 'Add Closed Date',
          onAdd: () => _pickClosedDate(context),
          onRemove: cubit.removeCourtClosedDate,
        ),
      ],
    );
  }
}

class _SlotPricingView extends StatelessWidget {
  const _SlotPricingView({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VendorOnboardingSectionHeader(
          title: 'Slot Pricing',
          subtitle: 'Weekend, holiday, and discount pricing',
          icon: Icons.attach_money_rounded,
        ),
        const SizedBox(height: AppDimens.sizeX12),
        if (court.slotConfigs.isEmpty)
          const _EmptySlotsCard()
        else
          Column(
            children: court.slotConfigs
                .map(
                  (SlotPricingDraft slot) => Padding(
                    padding: AppUtils().getPadding(
                      bottom: AppDimens.paddingX12,
                    ),
                    child: _PricingSlotCard(
                      key: ValueKey<String>('pricing-${slot.id}'),
                      slot: slot,
                      court: court,
                      onChanged: (SlotPricingDraft nextSlot) =>
                          cubit.updateSlot(slot.id, nextSlot),
                    ),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _ScheduleSlotCard extends StatelessWidget {
  const _ScheduleSlotCard({
    super.key,
    required this.slot,
    required this.onChanged,
    required this.onToggleDay,
    required this.onRemove,
  });

  final SlotPricingDraft slot;
  final ValueChanged<SlotPricingDraft> onChanged;
  final ValueChanged<String> onToggleDay;
  final VoidCallback onRemove;

  Future<void> _confirmDelete(BuildContext context) async {
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: 'Delete Slot',
      message:
          'Are you sure you want to delete this slot? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      confirmColor: LightColor.secondaryColor,
    );
    if (confirmed) {
      onRemove();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SlotShell(
      title: slot.label.trim().isEmpty ? 'Slot Configuration' : slot.label,
      subtitle: '${slot.startTime} - ${slot.endTime}',
      trailing: IconButton(
        onPressed: () => _confirmDelete(context),
        icon: const Icon(Icons.delete_outline_rounded),
        color: LightColor.secondaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VendorInputField(
            isRequired: true,
            label: 'Slot label',
            initialValue: slot.label,
            onChanged: (String value) => onChanged(slot.copyWith(label: value)),
          ),
          const SizedBox(height: AppDimens.sizeX14),
          const VendorFieldLabel('Booking days'),
          const SizedBox(height: AppDimens.sizeX10),
          Wrap(
            spacing: AppDimens.sizeX8,
            runSpacing: AppDimens.sizeX8,
            children: <Widget>[
              VendorSelectableChip(
                label: 'All',
                isSelected: weekdayOptions.every(slot.days.contains),
                onTap: () => onChanged(
                  slot.copyWith(
                    days: weekdayOptions.every(slot.days.contains)
                        ? const <String>{}
                        : weekdayOptions.toSet(),
                  ),
                ),
              ),
              ...weekdayOptions.map(
                (String day) => VendorSelectableChip(
                  label: day,
                  isSelected: slot.days.contains(day),
                  onTap: () => onToggleDay(day),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX18),
          Row(
            children: <Widget>[
              Expanded(
                child: CustomTimeField(
                  label: 'Start time',
                  value: slot.startTime,
                  onChanged: (String value) =>
                      onChanged(slot.copyWith(startTime: value)),
                ),
              ),
              const SizedBox(width: AppDimens.sizeX12),
              Expanded(
                child: CustomTimeField(
                  label: 'End time',
                  value: slot.endTime,
                  onChanged: (String value) =>
                      onChanged(slot.copyWith(endTime: value)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PricingSlotCard extends StatelessWidget {
  const _PricingSlotCard({
    super.key,
    required this.slot,
    required this.court,
    required this.onChanged,
  });

  final SlotPricingDraft slot;
  final CourtDraft court;
  final ValueChanged<SlotPricingDraft> onChanged;

  Future<void> _addCustomDatePrice(BuildContext context) async {
    final SlotCustomDatePriceDraft? picked =
        await showDialog<SlotCustomDatePriceDraft>(
          context: context,
          builder: (BuildContext context) {
            return _CustomDatePriceDialog(
              initialDates: slot.customDatePrices
                  .map((SlotCustomDatePriceDraft item) => item.date)
                  .toSet(),
              priceForDate: _priceForDate,
              markerForDate: _markerForDate,
            );
          },
        );
    if (picked == null) return;
    onChanged(
      slot.copyWith(
        customDatePrices:
            <SlotCustomDatePriceDraft>[
              ...slot.customDatePrices.where(
                (SlotCustomDatePriceDraft item) => item.date != picked.date,
              ),
              picked,
            ]..sort(
              (SlotCustomDatePriceDraft a, SlotCustomDatePriceDraft b) =>
                  a.date.compareTo(b.date),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SlotShell(
      title: slot.label.trim().isEmpty ? 'Slot Pricing' : slot.label,
      subtitle: '${slot.startTime} - ${slot.endTime}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(height: AppDimens.sizeX10),
          _MoneyField(
            label: 'Weekend price',
            value: slot.weekendPrice,
            onChanged: (String value) => onChanged(
              slot.copyWith(
                weekendPrice: parseDouble(value),
                clearWeekendPrice: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX16),
          _MoneyField(
            label: 'Holiday price',
            value: slot.holidayPrice,
            onChanged: (String value) => onChanged(
              slot.copyWith(
                holidayPrice: parseDouble(value),
                clearHolidayPrice: value.trim().isEmpty,
              ),
            ),
          ),

          const SizedBox(height: AppDimens.sizeX16),
          _DiscountTypeSelector(
            value: slot.discountType,
            onChanged: (String value) =>
                onChanged(slot.copyWith(discountType: value)),
          ),
          const SizedBox(height: AppDimens.sizeX16),
          _MoneyField(
            label: slot.discountType == 'Percent'
                ? 'Discount %'
                : 'Discount price',
            value: slot.discountPrice,
            onChanged: (String value) => onChanged(
              slot.copyWith(
                discountPrice: parseDouble(value),
                clearDiscountPrice: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX16),
          _CustomDatePricesSection(
            prices: slot.customDatePrices,
            onAdd: () => _addCustomDatePrice(context),
            onRemove: (String date) => onChanged(
              slot.copyWith(
                customDatePrices: slot.customDatePrices
                    .where((SlotCustomDatePriceDraft item) => item.date != date)
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double? _priceForDate(DateTime date) {
    final String isoDate = _formatIsoDate(date);
    final String day = _weekdayLabel(date);
    for (final SlotCustomDatePriceDraft item in slot.customDatePrices) {
      if (item.date == isoDate) return item.price;
    }
    if (court.holidayDates.contains(isoDate)) return slot.holidayPrice;
    if (court.weekendDays.contains(day)) return slot.weekendPrice;
    return slot.price ?? court.basePrice;
  }

  _DatePriceMarker? _markerForDate(DateTime date) {
    final String isoDate = _formatIsoDate(date);
    final String day = _weekdayLabel(date);
    for (final SlotCustomDatePriceDraft item in slot.customDatePrices) {
      if (item.date == isoDate) return _DatePriceMarker.custom;
    }
    if (court.holidayDates.contains(isoDate)) return _DatePriceMarker.holiday;
    if (court.weekendDays.contains(day)) return _DatePriceMarker.weekend;
    return null;
  }
}

class _DiscountTypeSelector extends StatelessWidget {
  const _DiscountTypeSelector({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return VendorDropdownField<String>(
      label: 'Discount type',
      initialValue: value == 'Percent' ? 'Percent' : 'Flat',
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(value: 'Percent', child: Text('%')),
        DropdownMenuItem<String>(value: 'Flat', child: Text('Flat')),
      ],
      onChanged: (String? value) {
        if (value == null) return;
        onChanged(value);
      },
    );
  }
}

class _CustomDatePricesSection extends StatelessWidget {
  const _CustomDatePricesSection({
    required this.prices,
    required this.onAdd,
    required this.onRemove,
  });

  final List<SlotCustomDatePriceDraft> prices;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<SlotCustomDatePriceDraft> sorted =
        List<SlotCustomDatePriceDraft>.from(prices)..sort(
          (SlotCustomDatePriceDraft a, SlotCustomDatePriceDraft b) =>
              a.date.compareTo(b.date),
        );
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  'Custom date prices',
                  style: textTheme.bodyTextMedium?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(
                width: AppDimens.sizeX80,
                child: CustomButton(
                  borderRadius: 8,
                  text: 'Add Date',
                  minHeight: AppDimens.sizeX32,
                  fontSize: 10,
                  verticalPadding: AppDimens.paddingX2,
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
          if (sorted.isEmpty)
            Padding(
              padding: AppUtils().getPadding(top: AppDimens.paddingX12),
              child: Text(
                'Optional prices for one-off dates.',
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryTextColor,
                ),
              ),
            )
          else
            Wrap(
              spacing: AppDimens.sizeX8,
              children: sorted
                  .map(
                    (SlotCustomDatePriceDraft item) => InputChip(
                      labelPadding: EdgeInsets.zero,
                      label: Text(
                        '${item.date} · ${formatDouble(item.price)}',
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: LightColor.secondaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onDeleted: () => onRemove(item.date),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: AppDimens.sizeX12,
                      ),
                      deleteIconColor: LightColor.secondaryColor,
                      backgroundColor: LightColor.secondaryLight.withValues(
                        alpha: 0.14,
                      ),
                      side: const BorderSide(
                        color: LightColor.secondaryLight,
                        width: 0.5,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _CustomDatePriceDialog extends StatefulWidget {
  const _CustomDatePriceDialog({
    required this.initialDates,
    required this.priceForDate,
    required this.markerForDate,
  });

  final Set<String> initialDates;
  final double? Function(DateTime date) priceForDate;
  final _DatePriceMarker? Function(DateTime date) markerForDate;

  @override
  State<_CustomDatePriceDialog> createState() => _CustomDatePriceDialogState();
}

class _CustomDatePriceDialogState extends State<_CustomDatePriceDialog> {
  late DateTime _visibleMonth;
  String? _selectedDate;
  String _price = '';

  @override
  void initState() {
    super.initState();
    final DateTime today = _dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    for (final String item in widget.initialDates) {
      final DateTime? date = DateTime.tryParse(item);
      if (date != null) {
        _selectedDate = item;
        _price = formatDouble(widget.priceForDate(date));
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final DateTime minDate = DateTime(1900);
    return AlertDialog(
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: LightColor.cardColor,
      insetPadding: AppUtils().getPadding(horizontal: AppDimens.paddingX16),
      title: Text(
        'Custom date price',
        style: textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _HolidayMonthHeader(
                month: _visibleMonth,
                onPrevious: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month - 1,
                  );
                }),
                onNext: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  );
                }),
              ),
              const SizedBox(height: AppDimens.sizeX12),
              _HolidayCalendarGrid(
                visibleMonth: _visibleMonth,
                minDate: minDate,
                selectedDates: _selectedDate == null
                    ? const <String>{}
                    : <String>{_selectedDate!},
                priceForDate: widget.priceForDate,
                markerForDate: widget.markerForDate,
                onToggle: (DateTime date) => setState(() {
                  _selectedDate = _formatIsoDate(date);
                  _price = formatDouble(widget.priceForDate(date));
                }),
              ),
              const SizedBox(height: AppDimens.sizeX14),
              VendorInputField(
                key: ValueKey<String>(_selectedDate ?? 'custom-date-price'),
                label: 'Price',
                initialValue: _price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (String value) => setState(() {
                  _price = value;
                }),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: 'Apply',
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.whiteColor,
                onPressed: _canApply
                    ? () => Navigator.of(context).pop(
                        SlotCustomDatePriceDraft(
                          date: _selectedDate!,
                          price: parseDouble(_price)!,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool get _canApply {
    final double? parsedPrice = parseDouble(_price);
    return _selectedDate != null && parsedPrice != null && parsedPrice >= 0;
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return VendorInputField(
      label: label,
      initialValue: formatDouble(value),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
    );
  }
}

class _SlotShell extends StatelessWidget {
  const _SlotShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX36,
                height: AppDimens.sizeX36,
                decoration: BoxDecoration(
                  color: LightColor.secondaryLight.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: LightColor.secondaryColor,
                  size: AppDimens.sizeX18,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      subtitle,
                      style: textTheme.bodySubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppDimens.sizeX14),
          child,
        ],
      ),
    );
  }
}

class _DateCollectionCard extends StatelessWidget {
  const _DateCollectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dates,
    required this.emptyText,
    required this.actionLabel,
    required this.onAdd,
    required this.onRemove,
    this.isHighlighted = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Set<String> dates;
  final String emptyText;
  final String actionLabel;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<String> sortedDates = dates.toList()..sort();
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: isHighlighted ? LightColor.cardColor : LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(
          color: isHighlighted
              ? LightColor.secondaryLight
              : LightColor.borderColor,
          width: isHighlighted ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX38,
                height: AppDimens.sizeX38,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(icon, color: LightColor.whiteColor),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      subtitle,
                      style: textTheme.bodySubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                width: AppDimens.sizeX80,
                child: CustomButton(
                  minHeight: AppDimens.sizeX36,
                  text: 'Add Date',
                  borderRadius: 8,

                  onPressed: onAdd,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (sortedDates.isEmpty)
            Text(
              emptyText,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: AppDimens.sizeX8,
              children: sortedDates
                  .map(
                    (String date) => InputChip(
                      label: Text(
                        date,
                        style: textTheme.bodySubTitle?.copyWith(
                          color: LightColor.primaryTextColor,
                        ),
                      ),
                      onDeleted: () => onRemove(date),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: AppDimens.sizeX14,
                      ),
                      backgroundColor: LightColor.whiteColor,
                      side: BorderSide(
                        color: isHighlighted
                            ? LightColor.secondaryLight
                            : LightColor.greyBorderColor,
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ClosedDateCollectionCard extends StatelessWidget {
  const _ClosedDateCollectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.dates,
    required this.emptyText,
    required this.actionLabel,
    required this.onAdd,
    required this.onRemove,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<ClosedDateDraft> dates;
  final String emptyText;
  final String actionLabel;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<ClosedDateDraft> sortedDates = List<ClosedDateDraft>.from(
      dates,
    )..sort((ClosedDateDraft a, ClosedDateDraft b) => a.date.compareTo(b.date));
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: AppDimens.sizeX38,
                height: AppDimens.sizeX38,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                ),
                child: Icon(icon, color: LightColor.whiteColor),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Text(
                      subtitle,
                      style: textTheme.bodySubTitle?.copyWith(
                        color: LightColor.secondaryTextColor,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: AppDimens.sizeX80,
                child: CustomButton(
                  minHeight: AppDimens.sizeX36,
                  text: 'Add Date',
                  borderRadius: 8,
                  onPressed: onAdd,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (sortedDates.isEmpty)
            Text(
              emptyText,
              style: textTheme.bodyTextSmall?.copyWith(
                color: LightColor.secondaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            Wrap(
              spacing: AppDimens.sizeX8,
              runSpacing: AppDimens.sizeX8,
              children: sortedDates
                  .map(
                    (ClosedDateDraft item) => InputChip(
                      label: Text(
                        item.isFullDay
                            ? item.date
                            : '${item.date} · ${item.startTime}-${item.endTime}',
                        style: textTheme.bodySubTitle?.copyWith(
                          color: item.isFullDay
                              ? LightColor.secondaryColor
                              : LightColor.yellowColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      onDeleted: () => onRemove(item.date),
                      deleteIcon: const Icon(
                        Icons.close_rounded,
                        size: AppDimens.sizeX14,
                      ),
                      deleteIconColor: item.isFullDay
                          ? LightColor.secondaryColor
                          : LightColor.yellowColor,
                      backgroundColor: item.isFullDay
                          ? LightColor.secondaryLight.withValues(alpha: 0.14)
                          : LightColor.yellowColor.withValues(alpha: 0.12),
                      side: BorderSide(
                        color: item.isFullDay
                            ? LightColor.secondaryLight
                            : LightColor.yellowColor.withValues(alpha: 0.45),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _EmptySlotsCard extends StatelessWidget {
  const _EmptySlotsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX18),
      decoration: BoxDecoration(
        color: LightColor.background,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Text(
        'No slot configuration added yet. Add a slot to define the booking schedule for this court.',
        style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
          color: LightColor.secondaryTextColor,
          height: 1.5,
        ),
      ),
    );
  }
}

class _ClosedDateDialog extends StatefulWidget {
  const _ClosedDateDialog({required this.initialDates});

  final Set<String> initialDates;

  @override
  State<_ClosedDateDialog> createState() => _ClosedDateDialogState();
}

class _ClosedDateDialogState extends State<_ClosedDateDialog> {
  late DateTime _visibleMonth;
  String? _selectedDate;
  bool _isFullDay = true;
  String _startTime = '06:00';
  String _endTime = '10:00';

  @override
  void initState() {
    super.initState();
    final DateTime tomorrow = _dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    _visibleMonth = DateTime(tomorrow.year, tomorrow.month);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final DateTime tomorrow = _dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    return AlertDialog(
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: LightColor.cardColor,
      insetPadding: AppUtils().getPadding(horizontal: AppDimens.paddingX16),
      title: Text(
        'Closed date',
        style: textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _HolidayMonthHeader(
                month: _visibleMonth,
                onPrevious: _canGoPreviousMonth(tomorrow)
                    ? () => setState(() {
                        _visibleMonth = DateTime(
                          _visibleMonth.year,
                          _visibleMonth.month - 1,
                        );
                      })
                    : null,
                onNext: () => setState(() {
                  _visibleMonth = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month + 1,
                  );
                }),
              ),
              const SizedBox(height: AppDimens.sizeX12),
              _HolidayCalendarGrid(
                visibleMonth: _visibleMonth,
                minDate: tomorrow,
                selectedDates: _selectedDate == null
                    ? const <String>{}
                    : <String>{_selectedDate!},
                onToggle: (DateTime date) => setState(() {
                  _selectedDate = _formatIsoDate(date);
                }),
              ),
              const SizedBox(height: AppDimens.sizeX16),
              const VendorFieldLabel('Closure type'),
              const SizedBox(height: AppDimens.sizeX10),
              SegmentedButton<bool>(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (!states.contains(WidgetState.selected)) {
                      return LightColor.background;
                    }
                    return _isFullDay
                        ? LightColor.secondaryColor
                        : LightColor.yellowColor;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return LightColor.whiteColor;
                    }
                    return LightColor.primaryTextColor;
                  }),
                  side: WidgetStateProperty.resolveWith<BorderSide?>((
                    Set<WidgetState> states,
                  ) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                        color: _isFullDay
                            ? LightColor.secondaryColor
                            : LightColor.yellowColor,
                      );
                    }
                    return const BorderSide(color: LightColor.greyBorderColor);
                  }),
                ),
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.event_busy_rounded),
                    label: Text('Full day'),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.schedule_rounded),
                    label: Text('Hourly'),
                  ),
                ],
                selected: <bool>{_isFullDay},
                onSelectionChanged: (Set<bool> value) {
                  setState(() => _isFullDay = value.first);
                },
              ),
              if (!_isFullDay) ...<Widget>[
                const SizedBox(height: AppDimens.sizeX14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTimeField(
                        label: 'Start time',
                        value: _startTime,
                        onChanged: (String value) => setState(() {
                          _startTime = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX12),
                    Expanded(
                      child: CustomTimeField(
                        label: 'End time',
                        value: _endTime,
                        onChanged: (String value) => setState(() {
                          _endTime = value;
                        }),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppDimens.sizeX12),
              Text(
                _selectedDate == null
                    ? 'No date selected'
                    : 'Selected $_selectedDate',
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: 'Apply',
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.whiteColor,
                onPressed: _canApply
                    ? () => Navigator.of(context).pop(
                        ClosedDateDraft(
                          date: _selectedDate!,
                          isFullDay: _isFullDay,
                          startTime: _isFullDay ? '' : _startTime,
                          endTime: _isFullDay ? '' : _endTime,
                        ),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool get _canApply {
    if (_selectedDate == null) return false;
    if (_isFullDay) return true;
    final TimeOfDay? start = timeOfDayFromString(_startTime);
    final TimeOfDay? end = timeOfDayFromString(_endTime);
    if (start == null || end == null) return false;
    return minutesFromTimeOfDay(start) < minutesFromTimeOfDay(end);
  }

  bool _canGoPreviousMonth(DateTime minDate) {
    final DateTime previous = DateTime(
      _visibleMonth.year,
      _visibleMonth.month - 1,
    );
    final DateTime minMonth = DateTime(minDate.year, minDate.month);
    return !previous.isBefore(minMonth);
  }
}

class _CustomCalendarDatePickerDialog extends StatefulWidget {
  const _CustomCalendarDatePickerDialog({
    required this.title,
    required this.initialDates,
  });

  final String title;
  final Set<String> initialDates;

  @override
  State<_CustomCalendarDatePickerDialog> createState() =>
      _CustomCalendarDatePickerDialogState();
}

class _CustomCalendarDatePickerDialogState
    extends State<_CustomCalendarDatePickerDialog> {
  late DateTime _visibleMonth;
  late final Set<String> _selectedDates;

  @override
  void initState() {
    super.initState();
    final DateTime tomorrow = _dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    _visibleMonth = DateTime(tomorrow.year, tomorrow.month);
    _selectedDates = widget.initialDates.where((String item) {
      final DateTime? date = DateTime.tryParse(item);
      return date != null && !_dateOnly(date).isBefore(tomorrow);
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final DateTime tomorrow = _dateOnly(
      DateTime.now().add(const Duration(days: 1)),
    );
    return AlertDialog(
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: LightColor.cardColor,
      insetPadding: AppUtils().getPadding(horizontal: AppDimens.paddingX16),
      titlePadding: AppUtils().getPadding(
        left: AppDimens.paddingX18,
        top: AppDimens.paddingX18,
        right: AppDimens.paddingX18,
      ),
      contentPadding: AppUtils().getPadding(
        left: AppDimens.paddingX18,
        top: AppDimens.paddingX12,
        right: AppDimens.paddingX18,
      ),
      actionsPadding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX10,
      ),
      title: Text(
        widget.title,
        style: textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _HolidayMonthHeader(
              month: _visibleMonth,
              onPrevious: _canGoPreviousMonth(tomorrow)
                  ? () => setState(() {
                      _visibleMonth = DateTime(
                        _visibleMonth.year,
                        _visibleMonth.month - 1,
                      );
                    })
                  : null,
              onNext: () => setState(() {
                _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month + 1,
                );
              }),
            ),
            const SizedBox(height: AppDimens.sizeX12),
            _HolidayCalendarGrid(
              visibleMonth: _visibleMonth,
              minDate: tomorrow,
              selectedDates: _selectedDates,
              onToggle: _toggleDate,
            ),
            const SizedBox(height: AppDimens.sizeX12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_selectedDates.length} selected',
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: 'Apply',
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.whiteColor,
                onPressed: _selectedDates.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(_selectedDates),
              ),
            ),
          ],
        ),
      ],
    );
  }

  bool _canGoPreviousMonth(DateTime minDate) {
    final DateTime previous = DateTime(
      _visibleMonth.year,
      _visibleMonth.month - 1,
    );
    final DateTime minMonth = DateTime(minDate.year, minDate.month);
    return !previous.isBefore(minMonth);
  }

  void _toggleDate(DateTime date) {
    final String isoDate = _formatIsoDate(date);
    setState(() {
      if (!_selectedDates.add(isoDate)) {
        _selectedDates.remove(isoDate);
      }
    });
  }
}

class _HolidayMonthHeader extends StatelessWidget {
  const _HolidayMonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback? onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left_rounded),
          color: LightColor.secondaryColor,
          disabledColor: LightColor.secondaryTextColor.withValues(alpha: 0.35),
        ),
        Expanded(
          child: Text(
            _formatMonthLabel(month),
            textAlign: TextAlign.center,
            style: textTheme.bodyTextMedium?.copyWith(
              color: LightColor.primaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded),
          color: LightColor.secondaryColor,
        ),
      ],
    );
  }
}

class _HolidayCalendarGrid extends StatelessWidget {
  const _HolidayCalendarGrid({
    required this.visibleMonth,
    required this.minDate,
    required this.selectedDates,
    required this.onToggle,
    this.priceForDate,
    this.markerForDate,
  });

  final DateTime visibleMonth;
  final DateTime minDate;
  final Set<String> selectedDates;
  final ValueChanged<DateTime> onToggle;
  final double? Function(DateTime date)? priceForDate;
  final _DatePriceMarker? Function(DateTime date)? markerForDate;

  @override
  Widget build(BuildContext context) {
    final List<DateTime?> cells = _monthCells(visibleMonth);
    return Column(
      children: <Widget>[
        Row(
          children: weekdayOptions
              .map(
                (String day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                          ?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppDimens.sizeX8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 2,
            crossAxisSpacing: 6,
          ),
          itemCount: cells.length,
          itemBuilder: (BuildContext context, int index) {
            final DateTime? date = cells[index];
            if (date == null) return const SizedBox.shrink();
            final bool isDisabled = date.isBefore(minDate);
            final bool isSelected = selectedDates.contains(
              _formatIsoDate(date),
            );
            return _HolidayDateCell(
              date: date,
              isDisabled: isDisabled,
              isSelected: isSelected,
              price: priceForDate?.call(date),
              marker: markerForDate?.call(date),
              onTap: isDisabled ? null : () => onToggle(date),
            );
          },
        ),
      ],
    );
  }
}

class _HolidayDateCell extends StatelessWidget {
  const _HolidayDateCell({
    required this.date,
    required this.isDisabled,
    required this.isSelected,
    required this.onTap,
    this.price,
    this.marker,
  });

  final DateTime date;
  final bool isDisabled;
  final bool isSelected;
  final VoidCallback? onTap;
  final double? price;
  final _DatePriceMarker? marker;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _dateCellBackgroundColor(
            isDisabled: isDisabled,
            isSelected: isSelected,
            marker: marker,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          border: Border.all(
            color: isSelected
                ? LightColor.secondaryColor
                : _dateCellBorderColor(isDisabled: isDisabled, marker: marker),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '${date.day}',
              style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                color: isDisabled
                    ? LightColor.secondaryTextColor.withValues(alpha: 0.35)
                    : (isSelected
                          ? LightColor.whiteColor
                          : LightColor.primaryTextColor),
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
            if (price != null) ...<Widget>[
              const SizedBox(height: 2),
              Text(
                formatDouble(price),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                    ?.copyWith(
                      color: isDisabled
                          ? LightColor.secondaryTextColor.withValues(
                              alpha: 0.28,
                            )
                          : (isSelected
                                ? LightColor.whiteColor
                                : LightColor.secondaryColor),
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _DatePriceMarker { custom, holiday, weekend }

Color _dateCellBackgroundColor({
  required bool isDisabled,
  required bool isSelected,
  required _DatePriceMarker? marker,
}) {
  if (isDisabled) return LightColor.background;
  if (isSelected) return LightColor.secondaryColor;
  return switch (marker) {
    _DatePriceMarker.custom => LightColor.secondaryLight.withValues(alpha: 0.2),
    _DatePriceMarker.holiday => LightColor.yellowColor.withValues(alpha: 0.16),
    _DatePriceMarker.weekend => LightColor.primarySoft.withValues(alpha: 0.5),
    null => LightColor.whiteColor,
  };
}

Color _dateCellBorderColor({
  required bool isDisabled,
  required _DatePriceMarker? marker,
}) {
  if (isDisabled) return LightColor.borderColor.withValues(alpha: 0.5);
  return switch (marker) {
    _DatePriceMarker.custom => LightColor.secondaryLight,
    _DatePriceMarker.holiday => LightColor.yellowColor.withValues(alpha: 0.55),
    _DatePriceMarker.weekend => LightColor.secondaryLight.withValues(
      alpha: 0.7,
    ),
    null => LightColor.borderColor,
  };
}

String _formatIsoDate(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

String _weekdayLabel(DateTime date) {
  return weekdayOptions[date.weekday % DateTime.daysPerWeek];
}

List<DateTime?> _monthCells(DateTime visibleMonth) {
  final DateTime firstDay = DateTime(visibleMonth.year, visibleMonth.month);
  final int leadingEmptyCells = firstDay.weekday % DateTime.daysPerWeek;
  final int daysInMonth = DateTime(
    visibleMonth.year,
    visibleMonth.month + 1,
    0,
  ).day;
  return <DateTime?>[
    for (int i = 0; i < leadingEmptyCells; i++) null,
    for (int day = 1; day <= daysInMonth; day++)
      DateTime(visibleMonth.year, visibleMonth.month, day),
  ];
}

String _formatMonthLabel(DateTime date) {
  const List<String> months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.year}';
}
