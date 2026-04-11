import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/selection_option_chip.dart';

class AmenitiesFacilitiesSection extends StatelessWidget {
  const AmenitiesFacilitiesSection({super.key, required this.bloc});

  final CreateFootsallCourtsBloc bloc;

  @override
  Widget build(BuildContext context) {
    final bool hasSelection =
        bloc.state.selectedAmenities.isNotEmpty ||
        bloc.state.selectedFacilities.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _SectionTitle(
          title: 'Amenities',
          subtitle:
              'Select the value-added services players can expect on booking days.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: CreateFootsallCourtsBloc.amenityOptions
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
          title: 'Facilities',
          subtitle:
              'Mark the physical venue facilities available for teams and visitors.',
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: CreateFootsallCourtsBloc.facilityOptions
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
            style: const TextStyle(
              color: LightColor.darkgrey,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const SizedBox(height: 20),
        CustomTextField(
          controller: bloc.amenitiesNotesController,
          labelText: 'Amenities Notes',
          hintText:
              'Mention equipment quality, seating capacity, or any premium services.',
          icon: Icons.sticky_note_2_rounded,
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
          style: const TextStyle(
            color: LightColor.titleTextColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: LightColor.darkgrey,
            fontSize: 12.5,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
