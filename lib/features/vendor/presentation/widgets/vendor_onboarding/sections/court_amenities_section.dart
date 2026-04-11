import 'package:flutter/material.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class CourtAmenitiesSection extends StatelessWidget {
  const CourtAmenitiesSection({
    super.key,
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
            title: 'Amenities and Facilities',
            subtitle:
                'This is intentionally court-specific so different courts can have different offerings inside the same futsal.',
          ),
          const SizedBox(height: 18),
          const VendorFieldLabel('Amenities'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: courtAmenityOptions
                .map(
                  (String item) => VendorSelectableChip(
                    label: item,
                    isSelected: court.amenities.contains(item),
                    onTap: () => cubit.toggleCourtAmenity(item),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const VendorFieldLabel('Facilities'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: courtFacilityOptions
                .map(
                  (String item) => VendorSelectableChip(
                    label: item,
                    isSelected: court.facilities.contains(item),
                    onTap: () => cubit.toggleCourtFacility(item),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
