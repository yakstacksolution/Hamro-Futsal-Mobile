import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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
                focusNode: bloc.cityFocus,
                ensureVisibleOnFocus: true,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => bloc.countryFocus.requestFocus(),
                labelText: StringConstants.city,
                hintText: StringConstants.kathmandu,
                icon: Icons.location_city_rounded,
                validator: (String? value) =>
                    bloc.requiredValidator(value, fieldName: 'City'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: bloc.countryController,
                focusNode: bloc.countryFocus,
                ensureVisibleOnFocus: true,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => bloc.establishedYearFocus.requestFocus(),
                labelText: StringConstants.country,
                hintText: StringConstants.nepal,
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
          labelText: StringConstants.exactLocationRequired,
          hintText: StringConstants.tapToPickOnMap,
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
          focusNode: bloc.establishedYearFocus,
          ensureVisibleOnFocus: true,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.basicPriceFocus.requestFocus(),
          labelText: StringConstants.establishedYearRequired,
          hintText: '2018',
          icon: Icons.event_available_rounded,
          validator: bloc.establishedYearValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.basicPriceController,
          focusNode: bloc.basicPriceFocus,
          ensureVisibleOnFocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.registrationFocus.requestFocus(),
          labelText: StringConstants.basicPriceRequired,
          hintText: '1500',
          icon: Icons.payments_rounded,
          validator: bloc.basicPriceValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.registrationController,
          focusNode: bloc.registrationFocus,
          ensureVisibleOnFocus: true,
          isRequired: false,
          textInputAction: TextInputAction.done,
          labelText: StringConstants.registrationNumberOptional,
          hintText: StringConstants.registrationNumberExample,
          icon: Icons.assignment_rounded,
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          key: ValueKey<String>('status-${bloc.state.status}'),
          initialValue: bloc.state.status,
          decoration: customTextFieldDecoration(
            context: context,
            labelText: StringConstants.status,
            hintText: StringConstants.selectStatus,
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
