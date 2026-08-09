import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_time_field.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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

class _SlotScheduleView extends StatefulWidget {
  const _SlotScheduleView({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  State<_SlotScheduleView> createState() => _SlotScheduleViewState();
}

class _SlotScheduleViewState extends State<_SlotScheduleView> {
  String? _selectedSlotId;
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    // Load the latest slots for this court once the view is mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSlots());
  }

  Future<void> _loadSlots() async {
    if (!mounted) return;
    setState(() => _loadingSlots = true);
    await widget.cubit.fetchActiveCourtSlots();
    if (mounted) setState(() => _loadingSlots = false);
  }

  Future<void> _openSlotSheet({SlotPricingDraft? existing}) async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) =>
          _SlotFormSheet(cubit: widget.cubit, slot: existing),
    );
  }

  Future<void> _confirmDelete(SlotPricingDraft slot) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => _SlotDeleteDialog(
        onConfirm: () => widget.cubit.deleteCourtSlot(slot),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<SlotPricingDraft> slots = widget.court.slotConfigs;
    final bool hasSelection =
        _selectedSlotId != null &&
        slots.any((SlotPricingDraft slot) => slot.id == _selectedSlotId);
    final List<SlotPricingDraft> filtered = hasSelection
        ? slots
              .where((SlotPricingDraft slot) => slot.id == _selectedSlotId)
              .toList()
        : slots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        VendorOnboardingSectionHeader(
          title: StringConstants.slotSchedule,
          subtitle: StringConstants.createReusableBookingSlotsWithDaysAndTimes,
          icon: Icons.calendar_month_rounded,
          trailing: SizedBox(
            width: AppDimens.sizeX90,
            child: CustomButton(
              text: StringConstants.addSlot,
              minHeight: AppDimens.sizeX34,
              fontSize: AppDimens.fontBodyTextSmall,
              verticalPadding: AppDimens.paddingX2,
              backgroundColor: LightColor.secondaryColor,
              foregroundColor: LightColor.inverseTextColor,
              onPressed: () => _openSlotSheet(),
            ),
          ),
        ),
        const SizedBox(height: AppDimens.sizeX12),
        if (_loadingSlots && slots.isEmpty)
          const _SlotsLoadingIndicator()
        else if (slots.isEmpty)
          const _EmptySlotsCard()
        else ...<Widget>[
          _SlotFilterDropdown(
            slots: slots,
            selectedId: hasSelection ? _selectedSlotId : null,
            onChanged: (String? id) => setState(() => _selectedSlotId = id),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Column(
            children: filtered
                .map(
                  (SlotPricingDraft slot) => Padding(
                    padding: AppUtils().getPadding(
                      bottom: AppDimens.paddingX12,
                    ),
                    child: _SlotListTile(
                      key: ValueKey<String>(slot.id),
                      slot: slot,
                      onEdit: () => _openSlotSheet(existing: slot),
                      onDelete: () => _confirmDelete(slot),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Inline loading indicator shown while the slot list is being fetched.
class _SlotsLoadingIndicator extends StatelessWidget {
  const _SlotsLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(vertical: AppDimens.paddingX24),
      alignment: Alignment.center,
      child: const CustomLoading(
        color: LightColor.secondaryColor,
        size: 28,
        strokeWidth: 3,
        secondCircleColor: LightColor.secondaryLight,
        thirdCircleColor: LightColor.secondaryLight,
      ),
    );
  }
}

/// Delete-confirmation dialog whose action button shows a loading state while
/// the slot is being deleted, and only closes once the backend confirms.
class _SlotDeleteDialog extends StatefulWidget {
  const _SlotDeleteDialog({required this.onConfirm});

  final Future<String?> Function() onConfirm;

  @override
  State<_SlotDeleteDialog> createState() => _SlotDeleteDialogState();
}

class _SlotDeleteDialogState extends State<_SlotDeleteDialog> {
  bool _isDeleting = false;
  String? _error;

  Future<void> _delete() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
      _error = null;
    });
    final String? error = await widget.onConfirm();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isDeleting = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return AlertDialog(
      backgroundColor: LightColor.cardColor,
      surfaceTintColor: LightColor.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
      ),
      title: Text(
        StringConstants.deleteSlot,
        style: textTheme.bodyTextLarge?.copyWith(
          color: LightColor.primaryTextColor,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            StringConstants
                .areYouSureYouWantToDeleteThisSlotThisActionCannotBeUndone,
            style: textTheme.bodyTextSmall?.copyWith(
              color: LightColor.secondaryTextColor,
              height: 1.5,
            ),
          ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AppDimens.sizeX10),
            Text(
              _error!,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.redColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: StringConstants.cancel,
                isOutlined: true,
                foregroundColor: LightColor.brandTextColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: _isDeleting
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: StringConstants.delete,
                icon: Icons.delete_outline_rounded,
                isLoading: _isDeleting,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.redColor,
                foregroundColor: LightColor.inverseTextColor,
                onPressed: _isDeleting ? null : _delete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Read-only slot summary row with an Update / Delete menu. Editing happens in
/// the [_SlotFormSheet] bottom sheet.
class _SlotListTile extends StatelessWidget {
  const _SlotListTile({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
    this.infoText,
  });

  final SlotPricingDraft slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  /// Secondary line under the slot name. Defaults to the booking days; the
  /// pricing sub-step passes a price summary instead.
  final String? infoText;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final List<String> days = weekdayOptions.where(slot.days.contains).toList();
    final String detailText =
        infoText ?? (days.isEmpty ? 'No booking days' : days.join(' · '));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Material(
          color: LightColor.cardColor,
          child: InkWell(
            onTap: onEdit,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _timeBlock(textTheme),
                  Expanded(
                    child: Padding(
                      padding: AppUtils().getPadding(
                        left: AppDimens.paddingX12,
                        right: AppDimens.paddingX4,
                        top: AppDimens.paddingX10,
                        bottom: AppDimens.paddingX10,
                      ),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  _slotDisplayTitle(slot),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyTextMedium?.copyWith(
                                    color: LightColor.primaryTextColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: AppDimens.sizeX6),
                                Text(
                                  detailText,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySubTitle?.copyWith(
                                    color: LightColor.secondaryTextColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _menu(context, textTheme),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeBlock(dynamic textTheme) {
    final ({String time, String meridiem}) start = _splitTime(slot.startTime);
    final ({String time, String meridiem}) end = _splitTime(slot.endTime);
    final bool hasTime = start.time.isNotEmpty || end.time.isNotEmpty;

    return Container(
      width: AppDimens.sizeX100,
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX12,
        vertical: AppDimens.paddingX12,
      ),
      color: LightColor.secondaryLight.withValues(alpha: 0.16),
      child: Center(
        child: hasTime
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _timeText(start, textTheme),
                  Padding(
                    padding: AppUtils().getPadding(
                      vertical: AppDimens.paddingX6,
                    ),
                    child: Container(
                      width: double.infinity,
                      height: 1,
                      color: LightColor.secondaryColor.withValues(alpha: 0.4),
                    ),
                  ),
                  _timeText(end, textTheme),
                ],
              )
            : Icon(
                Icons.schedule_rounded,
                color: LightColor.brandTextColor,
                size: AppDimens.sizeX20,
              ),
      ),
    );
  }

  Widget _timeText(({String time, String meridiem}) value, dynamic textTheme) {
    final String label = value.meridiem.isEmpty
        ? value.time
        : '${value.time} ${value.meridiem}';
    return Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: textTheme.bodyTextSmall?.copyWith(
        color: LightColor.brandTextColor,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _menu(BuildContext context, dynamic textTheme) {
    return PopupMenuButton<int>(
      icon: Icon(Icons.more_vert_rounded, color: LightColor.secondaryTextColor),
      color: LightColor.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      onSelected: (int value) => value == 0 ? onEdit() : onDelete(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.edit_outlined,
                size: AppDimens.sizeX18,
                color: LightColor.brandTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(StringConstants.update, style: textTheme.bodyTextSmall),
            ],
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.delete_outline_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.redColor,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(StringConstants.delete, style: textTheme.bodyTextSmall),
            ],
          ),
        ),
      ],
    );
  }

  ({String time, String meridiem}) _splitTime(String value) {
    final String raw = value.trim();
    if (raw.isEmpty) return (time: '', meridiem: '');
    final RegExpMatch? match = RegExp(
      r'(\d{1,2})\s*:\s*(\d{2})\s*(AM|PM)?',
      caseSensitive: false,
    ).firstMatch(raw);
    if (match != null) {
      return (
        time: '${match.group(1)}:${match.group(2)}',
        meridiem: (match.group(3) ?? '').toUpperCase(),
      );
    }
    return (time: raw, meridiem: '');
  }
}

/// Bottom sheet to create or edit a slot (label, booking days, start/end time).
/// Performs the save itself so the action button can show a loading state and
/// the sheet only closes once the backend confirms success.
class _SlotFormSheet extends StatefulWidget {
  const _SlotFormSheet({required this.cubit, this.slot});

  final VendorOnboardingCubit cubit;
  final SlotPricingDraft? slot;

  @override
  State<_SlotFormSheet> createState() => _SlotFormSheetState();
}

class _SlotFormSheetState extends State<_SlotFormSheet> {
  late final TextEditingController _labelController;
  late Set<String> _days;
  late String _startTime;
  late String _endTime;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final SlotPricingDraft? slot = widget.slot;
    _labelController = TextEditingController(text: slot?.label ?? '');
    _days = <String>{...?slot?.days};
    _startTime = slot?.startTime ?? '';
    _endTime = slot?.endTime ?? '';
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  bool get _allSelected => weekdayOptions.every(_days.contains);

  Future<void> _submit() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    final String label = _labelController.text.trim();
    if (label.isEmpty) {
      setState(() => _error = 'Enter a slot label.');
      return;
    }
    if (_days.isEmpty) {
      setState(() => _error = 'Select at least one booking day.');
      return;
    }
    if (_startTime.trim().isEmpty || _endTime.trim().isEmpty) {
      setState(() => _error = 'Select both start and end time.');
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    final SlotPricingDraft draft =
        (widget.slot ?? const SlotPricingDraft(id: '')).copyWith(
          label: label,
          days: _days,
          startTime: _startTime,
          endTime: _endTime,
        );
    final String? error = await widget.cubit.saveCourtSlot(draft);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSaving = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool isEdit = widget.slot != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusX20),
          ),
        ),
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX16,
          right: AppDimens.paddingX16,
          top: AppDimens.paddingX12,
          bottom: AppDimens.paddingX20,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: AppDimens.sizeX40,
                    height: AppDimens.sizeX4,
                    decoration: BoxDecoration(
                      color: LightColor.greyBorderColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                Row(
                  children: <Widget>[
                    Text(
                      isEdit ? 'Edit Slot' : 'Add Slot',
                      style: textTheme.bodyTextLarge?.copyWith(
                        color: LightColor.primaryTextColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                      child: Icon(
                        Icons.close_rounded,
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sizeX16),
                VendorInputField(
                  isRequired: true,
                  label: StringConstants.slotLabel,
                  controller: _labelController,
                  initialValue: '',
                  hintText: StringConstants.eGMorningSlot,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                ),
                const SizedBox(height: AppDimens.sizeX16),
                const VendorFieldLabel('Booking days'),
                const SizedBox(height: AppDimens.sizeX10),
                Wrap(
                  spacing: AppDimens.sizeX8,
                  runSpacing: AppDimens.sizeX8,
                  children: <Widget>[
                    VendorSelectableChip(
                      label: StringConstants.all,
                      isSelected: _allSelected,
                      onTap: () => setState(() {
                        _error = null;
                        if (_allSelected) {
                          _days = <String>{};
                        } else {
                          _days = weekdayOptions.toSet();
                        }
                      }),
                    ),
                    ...weekdayOptions.map(
                      (String day) => VendorSelectableChip(
                        label: day,
                        isSelected: _days.contains(day),
                        onTap: () => setState(() {
                          _error = null;
                          if (!_days.add(day)) _days.remove(day);
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sizeX16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomTimeField(
                        label: StringConstants.startTime,
                        value: _startTime,
                        onChanged: (String value) => setState(() {
                          _error = null;
                          _startTime = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX12),
                    Expanded(
                      child: CustomTimeField(
                        label: StringConstants.endTime,
                        value: _endTime,
                        onChanged: (String value) => setState(() {
                          _error = null;
                          _endTime = value;
                        }),
                      ),
                    ),
                  ],
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppDimens.sizeX12),
                  Text(
                    _error!,
                    style: textTheme.bodySubTitle?.copyWith(
                      color: LightColor.redColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.sizeX20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        text: StringConstants.cancel,
                        isOutlined: true,
                        foregroundColor: LightColor.brandTextColor,
                        borderColor: LightColor.secondaryColor,
                        minHeight: AppDimens.sizeX44,
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX12),
                    Expanded(
                      child: CustomButton(
                        text: isEdit ? 'Update Slot' : 'Add Slot',
                        icon: Icons.check_rounded,
                        isLoading: _isSaving,
                        minHeight: AppDimens.sizeX44,
                        backgroundColor: LightColor.secondaryColor,
                        foregroundColor: LightColor.inverseTextColor,
                        onPressed: _isSaving ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _slotDisplayTitle(SlotPricingDraft slot) =>
    slot.label.trim().isEmpty ? 'Untitled slot' : slot.label.trim();

String _slotTimeSummary(SlotPricingDraft slot) {
  final String start = slot.startTime.trim();
  final String end = slot.endTime.trim();
  if (start.isEmpty && end.isEmpty) return 'Time not set';
  return '$start - $end';
}

String _slotDaysSummary(SlotPricingDraft slot) {
  final List<String> ordered = weekdayOptions
      .where(slot.days.contains)
      .toList();
  if (ordered.isEmpty) return 'No booking days';
  if (ordered.length == weekdayOptions.length) return 'Every day';
  return ordered.join(', ');
}

/// Compact dropdown used by both the slot schedule and pricing sub-steps to
/// quickly jump to a single slot (or show all). Each entry shows the slot name,
/// time, and booking days; [selectedId] of null means "All slots".
class _SlotFilterDropdown extends StatelessWidget {
  const _SlotFilterDropdown({
    required this.slots,
    required this.selectedId,
    required this.onChanged,
  });

  final List<SlotPricingDraft> slots;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  static const String _allValue = '__all__';

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Container(
      padding: AppUtils().getPadding(horizontal: AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.filter_list_rounded,
            color: LightColor.brandTextColor,
            size: AppDimens.sizeX20,
          ),
          const SizedBox(width: AppDimens.sizeX8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedId ?? _allValue,
                isExpanded: true,
                itemHeight: null,
                icon: Icon(
                  Icons.expand_more_rounded,
                  color: LightColor.brandTextColor,
                ),
                borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                dropdownColor: LightColor.cardColor,
                elevation: 3,
                menuMaxHeight: AppDimens.sizeX320,
                padding: AppUtils().getPadding(vertical: AppDimens.paddingX12),
                selectedItemBuilder: (BuildContext context) => <Widget>[
                  _filterButtonLabel('All slots', textTheme),
                  ...slots.map(
                    (SlotPricingDraft slot) =>
                        _filterButtonLabel(_slotDisplayTitle(slot), textTheme),
                  ),
                ],
                items: <DropdownMenuItem<String>>[
                  DropdownMenuItem<String>(
                    value: _allValue,
                    child: _allSlotsItem(textTheme, selectedId == null),
                  ),
                  ...slots.map(
                    (SlotPricingDraft slot) => DropdownMenuItem<String>(
                      value: slot.id,
                      child: _slotFilterItem(slot, textTheme, selectedId),
                    ),
                  ),
                ],
                onChanged: (String? value) => onChanged(
                  (value == null || value == _allValue) ? null : value,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterButtonLabel(String text, dynamic textTheme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodyTextMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: LightColor.primaryTextColor,
        ),
      ),
    );
  }

  Widget _allSlotsItem(dynamic textTheme, bool isSelected) {
    return Padding(
      padding: AppUtils().getPadding(vertical: AppDimens.paddingX10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              StringConstants.allSlots,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyTextMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? LightColor.brandTextColor
                    : LightColor.primaryTextColor,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_circle_rounded,
              size: AppDimens.sizeX18,
              color: LightColor.brandTextColor,
            ),
        ],
      ),
    );
  }

  Widget _slotFilterItem(
    SlotPricingDraft slot,
    dynamic textTheme,
    String? selectedId,
  ) {
    final bool isSelected = slot.id == selectedId;
    return Padding(
      padding: AppUtils().getPadding(vertical: AppDimens.paddingX10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        _slotDisplayTitle(slot),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? LightColor.brandTextColor
                              : LightColor.primaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX8),
                    Text(
                      _slotTimeSummary(slot),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        fontSize: 10.0,
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sizeX4),
                _metaLine(
                  Icons.event_rounded,
                  _slotDaysSummary(slot),
                  textTheme,
                ),
              ],
            ),
          ),
          if (isSelected)
            Padding(
              padding: EdgeInsets.only(left: AppDimens.sizeX8),
              child: Icon(
                Icons.check_circle_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.brandTextColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _metaLine(IconData icon, String text, dynamic textTheme) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          size: AppDimens.sizeX14,
          color: LightColor.secondaryTextColor,
        ),
        const SizedBox(width: AppDimens.sizeX6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyTextSmall?.copyWith(
              fontSize: 10.0,
              color: LightColor.secondaryTextColor,
            ),
          ),
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
          title: StringConstants.holidayDates,
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
          title: StringConstants.weekendHolidaysAndClosures,
          subtitle: StringConstants.specialDaysForPricingAndBookingAvailability,
          icon: Icons.event_repeat_rounded,
        ),
        const SizedBox(height: AppDimens.sizeX12),
        Text(
          StringConstants.weekendDays,
          style: textTheme.bodyTextSmall?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX10),
        Wrap(
          spacing: AppDimens.sizeX8,
          runSpacing: AppDimens.sizeX8,
          children: WeekdayOption.values
              .map(
                (WeekdayOption day) => VendorSelectableChip(
                  label: day.label,
                  isSelected: court.weekendDays.contains(day.key),
                  onTap: () => cubit.toggleCourtWeekendDay(day.key),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppDimens.sizeX16),
        _DateCollectionCard(
          title: StringConstants.holidayDates,
          subtitle: StringConstants.bookingsRemainOpenAndHolidayPricingCanApply,
          icon: Icons.celebration_rounded,
          dates: court.holidayDates,
          emptyText: StringConstants.noHolidayDatesAdded,
          actionLabel: 'Add Holiday',
          onAdd: () => _pickHolidayDates(context),
          onRemove: cubit.removeCourtHolidayDate,
          isHighlighted: true,
        ),
        const SizedBox(height: AppDimens.sizeX12),
        _ClosedDateCollectionCard(
          title: StringConstants.closedDates,
          subtitle: StringConstants.closeAFullDayOrOnlyASpecificHourRange,
          icon: Icons.event_busy_rounded,
          dates: court.closedDates,
          emptyText: StringConstants.noClosedDatesAdded,
          actionLabel: 'Add Closed Date',
          onAdd: () => _pickClosedDate(context),
          onRemove: cubit.removeCourtClosedDate,
        ),
      ],
    );
  }
}

class _SlotPricingView extends StatefulWidget {
  const _SlotPricingView({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  State<_SlotPricingView> createState() => _SlotPricingViewState();
}

class _SlotPricingViewState extends State<_SlotPricingView> {
  String? _selectedSlotId;
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSlots());
  }

  Future<void> _loadSlots() async {
    if (!mounted) return;
    setState(() => _loadingSlots = true);
    await widget.cubit.fetchActiveCourtSlots();
    if (mounted) setState(() => _loadingSlots = false);
  }

  Future<void> _openPricingSheet(SlotPricingDraft slot) async {
    FocusScope.of(context).unfocus();
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => _SlotPricingSheet(
        cubit: widget.cubit,
        court: widget.court,
        slot: slot,
      ),
    );
  }

  Future<void> _confirmDelete(SlotPricingDraft slot) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext _) => _SlotDeleteDialog(
        onConfirm: () => widget.cubit.deleteCourtSlot(slot),
      ),
    );
  }

  /// Price summary shown under the slot name in place of booking days.
  String _pricingSummary(SlotPricingDraft slot) {
    final List<String> parts = <String>[];
    if (slot.weekendPrice != null) {
      parts.add('Weekend ${formatDouble(slot.weekendPrice)}');
    }
    if (slot.holidayPrice != null) {
      parts.add('Holiday ${formatDouble(slot.holidayPrice)}');
    }
    if (slot.discountPrice != null) {
      final String value = slot.discountType == 'Percent'
          ? '${formatDouble(slot.discountPrice)}%'
          : formatDouble(slot.discountPrice);
      parts.add('Discount $value');
    }
    return parts.isEmpty ? 'No special pricing set' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final List<SlotPricingDraft> slots = widget.court.slotConfigs;
    final bool hasSelection =
        _selectedSlotId != null &&
        slots.any((SlotPricingDraft slot) => slot.id == _selectedSlotId);
    final List<SlotPricingDraft> filtered = hasSelection
        ? slots
              .where((SlotPricingDraft slot) => slot.id == _selectedSlotId)
              .toList()
        : slots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const VendorOnboardingSectionHeader(
          title: StringConstants.slotPricing,
          subtitle: StringConstants.weekendHolidayAndDiscountPricing,
          icon: Icons.attach_money_rounded,
        ),
        const SizedBox(height: AppDimens.sizeX12),
        if (_loadingSlots && slots.isEmpty)
          const _SlotsLoadingIndicator()
        else if (slots.isEmpty)
          const _EmptySlotsCard()
        else ...<Widget>[
          _SlotFilterDropdown(
            slots: slots,
            selectedId: hasSelection ? _selectedSlotId : null,
            onChanged: (String? id) => setState(() => _selectedSlotId = id),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          Column(
            children: filtered
                .map(
                  (SlotPricingDraft slot) => Padding(
                    padding: AppUtils().getPadding(
                      bottom: AppDimens.paddingX12,
                    ),
                    child: _SlotListTile(
                      key: ValueKey<String>('pricing-${slot.id}'),
                      slot: slot,
                      infoText: _pricingSummary(slot),
                      onEdit: () => _openPricingSheet(slot),
                      onDelete: () => _confirmDelete(slot),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

/// Bottom sheet to update a slot's pricing (weekend / holiday / discount and
/// custom date prices). Edits a working copy and saves via the cubit, only
/// closing once the backend confirms success.
class _SlotPricingSheet extends StatefulWidget {
  const _SlotPricingSheet({
    required this.cubit,
    required this.court,
    required this.slot,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;
  final SlotPricingDraft slot;

  @override
  State<_SlotPricingSheet> createState() => _SlotPricingSheetState();
}

class _SlotPricingSheetState extends State<_SlotPricingSheet> {
  late SlotPricingDraft _slot;
  String? _error;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _slot = widget.slot;
  }

  void _update(SlotPricingDraft next) {
    setState(() {
      _slot = next;
      _error = null;
    });
  }

  Future<void> _addCustomDatePrice() async {
    FocusScope.of(context).unfocus();
    final SlotCustomDatePriceDraft? picked =
        await showDialog<SlotCustomDatePriceDraft>(
          context: context,
          builder: (BuildContext _) {
            return _CustomDatePriceDialog(
              initialDates: _slot.customDatePrices
                  .map((SlotCustomDatePriceDraft item) => item.date)
                  .toSet(),
              priceForDate: _priceForDate,
              markerForDate: _markerForDate,
            );
          },
        );
    if (picked == null) return;
    _update(
      _slot.copyWith(
        customDatePrices:
            <SlotCustomDatePriceDraft>[
              ..._slot.customDatePrices.where(
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

  Future<void> _submit() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSaving = true;
      _error = null;
    });
    final String? error = await widget.cubit.saveCourtSlotPricing(_slot);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _isSaving = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.radiusX20),
          ),
        ),
        padding: AppUtils().getPadding(
          left: AppDimens.paddingX16,
          right: AppDimens.paddingX16,
          top: AppDimens.paddingX12,
          bottom: AppDimens.paddingX20,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: AppDimens.sizeX40,
                    height: AppDimens.sizeX4,
                    decoration: BoxDecoration(
                      color: LightColor.greyBorderColor,
                      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _slotDisplayTitle(_slot),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.primaryTextColor,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(AppDimens.radiusX20),
                      child: Icon(
                        Icons.close_rounded,
                        color: LightColor.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sizeX4),
                Text(
                  StringConstants.updatePricingForThisSlot,
                  style: textTheme.bodySubTitle?.copyWith(
                    color: LightColor.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                _MoneyField(
                  label: StringConstants.weekendPrice,
                  value: _slot.weekendPrice,
                  onChanged: (String value) => _update(
                    _slot.copyWith(
                      weekendPrice: parseDouble(value),
                      clearWeekendPrice: value.trim().isEmpty,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                _MoneyField(
                  label: StringConstants.holidayPrice,
                  value: _slot.holidayPrice,
                  onChanged: (String value) => _update(
                    _slot.copyWith(
                      holidayPrice: parseDouble(value),
                      clearHolidayPrice: value.trim().isEmpty,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                _DiscountTypeSelector(
                  value: _slot.discountType,
                  onChanged: (String value) =>
                      _update(_slot.copyWith(discountType: value)),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                _MoneyField(
                  label: _slot.discountType == 'Percent'
                      ? 'Discount %'
                      : 'Discount price',
                  value: _slot.discountPrice,
                  onChanged: (String value) => _update(
                    _slot.copyWith(
                      discountPrice: parseDouble(value),
                      clearDiscountPrice: value.trim().isEmpty,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX16),
                _CustomDatePricesSection(
                  prices: _slot.customDatePrices,
                  onAdd: _addCustomDatePrice,
                  onRemove: (String date) => _update(
                    _slot.copyWith(
                      customDatePrices: _slot.customDatePrices
                          .where(
                            (SlotCustomDatePriceDraft item) =>
                                item.date != date,
                          )
                          .toList(),
                    ),
                  ),
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: AppDimens.sizeX12),
                  Text(
                    _error!,
                    style: textTheme.bodySubTitle?.copyWith(
                      color: LightColor.redColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: AppDimens.sizeX20),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: CustomButton(
                        text: StringConstants.cancel,
                        isOutlined: true,
                        foregroundColor: LightColor.brandTextColor,
                        borderColor: LightColor.secondaryColor,
                        minHeight: AppDimens.sizeX44,
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX12),
                    Expanded(
                      child: CustomButton(
                        text: StringConstants.savePricing,
                        icon: Icons.check_rounded,
                        isLoading: _isSaving,
                        minHeight: AppDimens.sizeX44,
                        backgroundColor: LightColor.secondaryColor,
                        foregroundColor: LightColor.inverseTextColor,
                        onPressed: _isSaving ? null : _submit,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double? _priceForDate(DateTime date) {
    final String isoDate = _formatIsoDate(date);
    final String day = _weekdayLabel(date);
    for (final SlotCustomDatePriceDraft item in _slot.customDatePrices) {
      if (item.date == isoDate) return item.price;
    }
    if (widget.court.holidayDates.contains(isoDate)) return _slot.holidayPrice;
    if (widget.court.weekendDays.contains(day)) return _slot.weekendPrice;
    return _slot.price ?? widget.court.basePrice;
  }

  _DatePriceMarker? _markerForDate(DateTime date) {
    final String isoDate = _formatIsoDate(date);
    final String day = _weekdayLabel(date);
    for (final SlotCustomDatePriceDraft item in _slot.customDatePrices) {
      if (item.date == isoDate) return _DatePriceMarker.custom;
    }
    if (widget.court.holidayDates.contains(isoDate)) {
      return _DatePriceMarker.holiday;
    }
    if (widget.court.weekendDays.contains(day)) return _DatePriceMarker.weekend;
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
      label: StringConstants.discountType,
      initialValue: value == 'Percent' ? 'Percent' : 'Flat',
      items: const <DropdownMenuItem<String>>[
        DropdownMenuItem<String>(value: 'Percent', child: Text('%')),
        DropdownMenuItem<String>(
          value: 'Flat',
          child: Text(StringConstants.flat),
        ),
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
                  StringConstants.customDatePrices,
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
                  text: StringConstants.addDate,
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
                StringConstants.optionalPricesForOneOffDates,
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
                          color: LightColor.brandTextColor,
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
        StringConstants.customDatePrice,
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
                label: StringConstants.price,
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
                text: StringConstants.cancel,
                isOutlined: true,
                foregroundColor: LightColor.brandTextColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: StringConstants.apply,
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.inverseTextColor,
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
                child: Icon(icon, color: LightColor.inverseTextColor),
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
                  text: StringConstants.addDate,
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
                child: Icon(icon, color: LightColor.inverseTextColor),
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
                  text: StringConstants.addDate,
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
                              ? LightColor.brandTextColor
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
        StringConstants
            .noSlotConfigurationAddedYetAddASlotToDefineTheBo243e88c0,
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
        StringConstants.closedDate,
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
                      return LightColor.inverseTextColor;
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
                    return BorderSide(color: LightColor.greyBorderColor);
                  }),
                ),
                segments: const <ButtonSegment<bool>>[
                  ButtonSegment<bool>(
                    value: true,
                    icon: Icon(Icons.event_busy_rounded),
                    label: Text(StringConstants.fullDay),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: Icon(Icons.schedule_rounded),
                    label: Text(StringConstants.hourly),
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
                        label: StringConstants.startTime,
                        value: _startTime,
                        onChanged: (String value) => setState(() {
                          _startTime = value;
                        }),
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX12),
                    Expanded(
                      child: CustomTimeField(
                        label: StringConstants.endTime,
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
                text: StringConstants.cancel,
                isOutlined: true,
                foregroundColor: LightColor.brandTextColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: StringConstants.apply,
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.inverseTextColor,
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
                text: StringConstants.cancel,
                isOutlined: true,
                foregroundColor: LightColor.brandTextColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX42,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX10),
            Expanded(
              child: CustomButton(
                text: StringConstants.apply,
                icon: Icons.check_rounded,
                minHeight: AppDimens.sizeX42,
                backgroundColor: LightColor.secondaryColor,
                foregroundColor: LightColor.inverseTextColor,
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
                          ? LightColor.inverseTextColor
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
                                ? LightColor.inverseTextColor
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
  return WeekdayOption.forDate(date).key;
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
