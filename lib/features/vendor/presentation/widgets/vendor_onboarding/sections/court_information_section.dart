import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class CourtInformationSection extends StatelessWidget {
  const CourtInformationSection({
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
    switch (subsectionIndex) {
      case 0:
        return _CourtBasicInfoSubsection(cubit: cubit, court: court);
      case 1:
        return _CourtDescriptionSubsection(cubit: cubit, court: court);
      case 2:
        return _CourtTimeSchedulesSubsection(cubit: cubit, court: court);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _CourtBasicInfoSubsection extends StatelessWidget {
  const _CourtBasicInfoSubsection({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Court Info',
            subtitle: 'Set the name, base price, and type for this court.',
          ),
          const SizedBox(height: 18),
          VendorInputField(
            label: 'Court name',
            initialValue: court.name,
            onChanged: (String value) =>
                cubit.updateActiveCourt(court.copyWith(name: value)),
          ),
          const SizedBox(height: 14),
          VendorInputField(
            label: 'Base price',
            initialValue: formatDouble(court.basePrice),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (String value) => cubit.updateActiveCourt(
              court.copyWith(
                basePrice: parseDouble(value),
                clearBasePrice: value.trim().isEmpty,
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: court.courtType,
            items: courtTypeOptions
                .map(
                  (String item) =>
                      DropdownMenuItem<String>(value: item, child: Text(item)),
                )
                .toList(),
            decoration: vendorInputDecoration('Court type'),
            onChanged: (String? value) => cubit.updateActiveCourt(
              court.copyWith(courtType: value, clearCourtType: value == null),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtDescriptionSubsection extends StatelessWidget {
  const _CourtDescriptionSubsection({required this.cubit, required this.court});

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Description',
            subtitle:
                'Tell customers about this court. Describe the surface, size, and any unique features.',
          ),
          const SizedBox(height: 18),
          VendorInputField(
            label: 'Court description',
            initialValue: court.description,
            maxLines: 6,
            onChanged: (String value) =>
                cubit.updateActiveCourt(court.copyWith(description: value)),
          ),
        ],
      ),
    );
  }
}

class _CourtTimeSchedulesSubsection extends StatelessWidget {
  const _CourtTimeSchedulesSubsection({
    required this.cubit,
    required this.court,
  });

  final VendorOnboardingCubit cubit;
  final CourtDraft court;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const VendorPanelHeading(
            title: 'Time Schedules',
            subtitle:
                'Configure which days this court is available and set operating hours.',
          ),
          const SizedBox(height: 18),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: court.availability.isOpen24Hours,
            activeThumbColor: LightColor.secondary,
            title: const Text(
              'Open 24 hours',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'If enabled, open/close time fields are hidden.',
            ),
            onChanged: (bool value) => cubit.updateActiveCourt(
              court.copyWith(
                availability: court.availability.copyWith(
                  isOpen24Hours: value,
                  openTime: value ? '' : court.availability.openTime,
                  closeTime: value ? '' : court.availability.closeTime,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const VendorFieldLabel('Availability days'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: weekdayOptions
                .map(
                  (String day) => VendorSelectableChip(
                    label: day,
                    isSelected: court.availability.days.contains(day),
                    onTap: () => cubit.toggleAvailabilityDay(day),
                  ),
                )
                .toList(),
          ),
          if (!court.availability.isOpen24Hours) ...<Widget>[
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: VendorInputField(
                    label: 'Open time',
                    initialValue: court.availability.openTime,
                    onChanged: (String value) => cubit.updateActiveCourt(
                      court.copyWith(
                        availability: court.availability.copyWith(
                          openTime: value,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VendorInputField(
                    label: 'Close time',
                    initialValue: court.availability.closeTime,
                    onChanged: (String value) => cubit.updateActiveCourt(
                      court.copyWith(
                        availability: court.availability.copyWith(
                          closeTime: value,
                        ),
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
