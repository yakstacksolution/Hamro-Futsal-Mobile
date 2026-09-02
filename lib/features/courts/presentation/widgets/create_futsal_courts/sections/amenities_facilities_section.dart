import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/courts/presentation/bloc/create_futsal_courts_bloc.dart';
import 'package:hamro_futsal/features/courts/presentation/widgets/create_futsal_courts/selection_option_chip.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';

class AmenitiesFacilitiesSection extends StatelessWidget {
  const AmenitiesFacilitiesSection({super.key, required this.bloc});

  final CreateFutsalCourtsBloc bloc;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        bloc.state.selectedAmenities.isNotEmpty ||
        bloc.state.selectedFacilities.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(
          title: StringConstants.amenities,
          subtitle: StringConstants
              .selectTheValueAddedServicesPlayersCanExpectOnBookingDays,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: CreateFutsalCourtsBloc.amenityOptions
              .map(
                (String option) => SelectionOptionChip(
                  label: option,
                  isSelected: bloc.state.selectedAmenities.contains(option),
                  onTap: () => bloc.toggleAmenity(option),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        const _SectionTitle(
          title: StringConstants.facilities,
          subtitle: StringConstants
              .markThePhysicalVenueFacilitiesAvailableForTeamsAndVisitors,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: CreateFutsalCourtsBloc.facilityOptions
              .map(
                (String option) => SelectionOptionChip(
                  label: option,
                  isSelected: bloc.state.selectedFacilities.contains(option),
                  onTap: () => bloc.toggleFacility(option),
                ),
              )
              .toList(),
        ),
        if (!hasSelection) ...<Widget>[
          const SizedBox(height: 12),
          Text(
            bloc.amenitiesSelectionError()!,
            style: TextStyle(
              color: LightColor.secondaryTextColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 20),
        CustomTextField(
          controller: bloc.amenitiesNotesController,
          focusNode: bloc.amenitiesNotesFocus,
          ensureVisibleOnFocus: true,
          isRequired: false,
          labelText: StringConstants.amenitiesNotes,
          hintText: StringConstants
              .mentionEquipmentQualitySeatingCapacityOrAnyPremiumServices,
          icon: Icons.sticky_note_2_rounded,
          iconColor: LightColor.monoIconColor,
          minLines: 3,
          maxLines: 4,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
            color: LightColor.primaryTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: LightColor.secondaryTextColor,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
