import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: VendorPanelHeading(
                  title: 'Customize Slots and Payments',
                  subtitle:
                      'Define date and time slots once, then attach pricing and optional payment percentages per slot.',
                ),
              ),
              FilledButton.icon(
                onPressed: cubit.addSlotToActiveCourt,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Slot'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (court.slotConfigs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: LightColor.backgroundWarm,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: LightColor.border),
              ),
              child: const Text(
                'No slot configuration added yet. Add a slot to define the booking schedule for this court.',
                style: TextStyle(color: LightColor.subtitleText),
              ),
            )
          else
            Column(
              children: court.slotConfigs
                  .map(
                    (SlotPricingDraft slot) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _SlotCard(
                        key: ValueKey<String>(slot.id),
                        slot: slot,
                        showPricingFields: subsectionIndex == 1,
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
      ),
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({
    super.key,
    required this.slot,
    required this.showPricingFields,
    required this.onChanged,
    required this.onToggleDay,
    required this.onRemove,
  });

  final SlotPricingDraft slot;
  final bool showPricingFields;
  final ValueChanged<SlotPricingDraft> onChanged;
  final ValueChanged<String> onToggleDay;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LightColor.backgroundWarm,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: LightColor.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.schedule_rounded, color: LightColor.secondary),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Slot Configuration',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: LightColor.titleText,
                  ),
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 12),
          VendorInputField(
            label: 'Slot label',
            initialValue: slot.label,
            onChanged: (String value) => onChanged(slot.copyWith(label: value)),
          ),
          const SizedBox(height: 14),
          const VendorFieldLabel('Days'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: weekdayOptions
                .map(
                  (String day) => VendorSelectableChip(
                    label: day,
                    isSelected: slot.days.contains(day),
                    onTap: () => onToggleDay(day),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: VendorInputField(
                  label: 'Start time',
                  initialValue: slot.startTime,
                  onChanged: (String value) =>
                      onChanged(slot.copyWith(startTime: value)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: VendorInputField(
                  label: 'End time',
                  initialValue: slot.endTime,
                  onChanged: (String value) =>
                      onChanged(slot.copyWith(endTime: value)),
                ),
              ),
            ],
          ),
          if (showPricingFields) ...<Widget>[
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Expanded(
                  child: VendorInputField(
                    label: 'Price',
                    initialValue: formatDouble(slot.price),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (String value) => onChanged(
                      slot.copyWith(
                        price: parseDouble(value),
                        clearPrice: value.trim().isEmpty,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VendorInputField(
                    label: 'Payment % (optional)',
                    initialValue: formatDouble(slot.paymentPercent),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (String value) => onChanged(
                      slot.copyWith(
                        paymentPercent: parseDouble(value),
                        clearPaymentPercent: value.trim().isEmpty,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
