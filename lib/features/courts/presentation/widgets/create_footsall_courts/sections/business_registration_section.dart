import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';

class BusinessRegistrationSection extends StatelessWidget {
  const BusinessRegistrationSection({
    super.key,
    required this.bloc,
    required this.onPickExactLocation,
  });

  final CreateFootsallCourtsBloc bloc;
  final VoidCallback onPickExactLocation;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: CustomTextField(
                controller: bloc.cityController,
                textInputAction: TextInputAction.next,
                labelText: 'City *',
                hintText: 'Kathmandu',
                icon: Icons.location_city_rounded,
                validator: (String? value) =>
                    bloc.requiredValidator(value, fieldName: 'City'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: bloc.countryController,
                textInputAction: TextInputAction.next,
                labelText: 'Country *',
                hintText: 'Nepal',
                icon: Icons.public_rounded,
                validator: (String? value) =>
                    bloc.requiredValidator(value, fieldName: 'Country'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.exactLocationController,
          labelText: 'Exact Location *',
          hintText: 'Tap to pick on map',
          icon: Icons.place_rounded,
          readOnly: true,
          onTap: onPickExactLocation,
          suffixIcon: const Icon(
            Icons.map_outlined,
            color: LightColor.secondaryColor,
            size: 20,
          ),
          validator: bloc.exactLocationValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.establishedYearController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          labelText: 'Established Year *',
          hintText: '2018',
          icon: Icons.event_available_rounded,
          validator: bloc.establishedYearValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.basicPriceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          labelText: 'Basic Price *',
          hintText: '1500',
          icon: Icons.payments_rounded,
          validator: bloc.basicPriceValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.registrationController,
          textInputAction: TextInputAction.next,
          labelText: 'Registration Number',
          hintText: 'REG-2026-00123',

          icon: Icons.assignment_rounded,
          validator: (String? value) =>
              bloc.requiredValidator(value, fieldName: 'Registration number'),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: ValueKey<String>('status-${bloc.state.status}'),
          initialValue: bloc.state.status,
          decoration: customTextFieldDecoration(
            context: context,
            labelText: 'Status',
            hintText: 'Select status',
            icon: Icons.toggle_on_rounded,
          ),
          items: CreateFootsallCourtsBloc.statuses
              .map(
                (String status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status.toUpperCase()),
                ),
              )
              .toList(),
          onChanged: (String? value) {
            if (value == null) return;
            bloc.updateStatus(value);
          },
        ),
      ],
    );
  }
}
