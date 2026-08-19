import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class BasicInformationSection extends StatelessWidget {
  const BasicInformationSection({super.key, required this.bloc});

  final CreateFootsallCourtsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        CustomTextField(
          controller: bloc.shopNameController,
          focusNode: bloc.shopNameFocus,
          ensureVisibleOnFocus: true,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.slugFocus.requestFocus(),
          labelText: StringConstants.futsalNameRequired,
          hintText: StringConstants.hamroFutsalArena,
          icon: Icons.badge_rounded,
          validator: (String? value) =>
              bloc.requiredValidator(value, fieldName: 'Futsal name'),
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.slugController,
          focusNode: bloc.slugFocus,
          ensureVisibleOnFocus: true,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.descriptionFocus.requestFocus(),
          labelText: StringConstants.futsalSlug,
          hintText: StringConstants.hamroFutsalArenaSlugExample,
          icon: Icons.link_rounded,
          suffixIcon: IconButton(
            tooltip: StringConstants.autoGenerateFromFutsalName,
            icon: Icon(
              bloc.state.isSlugAuto
                  ? Icons.auto_awesome_rounded
                  : Icons.edit_rounded,
              color: LightColor.secondaryColor,
              size: 20,
            ),
            onPressed: bloc.toggleSlugAutomation,
          ),
          onChanged: bloc.handleSlugChanged,
          validator: bloc.slugValidator,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.descriptionController,
          focusNode: bloc.descriptionFocus,
          ensureVisibleOnFocus: true,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 3,
          maxLines: 5,
          labelText: StringConstants.descriptionRequired,
          hintText:
              StringConstants.describeYourFutsalFacilitiesAndWhatMakesItSpecial,
          icon: Icons.description_rounded,
          validator: (String? value) =>
              bloc.requiredValidator(value, fieldName: 'Description'),
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.phoneController,
          focusNode: bloc.phoneFocus,
          ensureVisibleOnFocus: true,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.emailFocus.requestFocus(),
          labelText: StringConstants.contactPhone,
          hintText: StringConstants.text97798xxxxxxxx,
          icon: Icons.call_rounded,
          validator: (String? value) {
            final String? baseError = bloc.requiredValidator(
              value,
              fieldName: 'Contact phone',
            );
            if (baseError != null) return baseError;
            return bloc.phoneValidator(value);
          },
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.emailController,
          focusNode: bloc.emailFocus,
          ensureVisibleOnFocus: true,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => bloc.websiteFocus.requestFocus(),
          labelText: StringConstants.contactEmail,
          hintText: StringConstants.helloHamrofutsalCom,
          icon: Icons.mail_rounded,
          validator: (String? value) {
            final String? baseError = bloc.requiredValidator(
              value,
              fieldName: 'Contact email',
            );
            if (baseError != null) return baseError;
            return bloc.emailValidator(value);
          },
        ),
        const SizedBox(height: 14),
        CustomTextField(
          controller: bloc.websiteController,
          focusNode: bloc.websiteFocus,
          ensureVisibleOnFocus: true,
          isRequired: false,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          labelText: StringConstants.websiteOptional,
          hintText: StringConstants.hamroFutsalWebsiteUrl,
          icon: Icons.language_rounded,
          validator: bloc.websiteValidator,
        ),
      ],
    );
  }
}
