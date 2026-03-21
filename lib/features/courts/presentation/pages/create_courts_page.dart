import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/courts/presentation/bloc/create_footsall_courts_bloc.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_courts_action_result.dart';
import 'package:hamro_footsall/features/courts/presentation/models/picked_location.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/create_courts_action_bar.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/create_courts_payload_preview_sheet.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/create_courts_step_scaffold.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/exact_location_picker_sheet.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/sections/amenities_facilities_section.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/sections/basic_information_section.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/sections/branding_review_section.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/sections/business_registration_section.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/sections/choose_package_section.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/sections/policies_section.dart';
import 'package:hamro_footsall/features/courts/presentation/widgets/create_footsall_courts/wizard_step_bar.dart';

class CreateCourtsPage extends StatefulWidget {
  const CreateCourtsPage({super.key});

  @override
  State<CreateCourtsPage> createState() => _CreateCourtsPageState();
}

class _CreateCourtsPageState extends State<CreateCourtsPage> {
  late final CreateFootsallCourtsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = CreateFootsallCourtsBloc();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  void _onAppBarBackPressed() {
    unawaited(_handleBackNavigation());
  }

  void _onPrimaryPressed() {
    unawaited(_handlePrimaryAction());
  }

  void _onSecondaryPressed() {
    unawaited(_handleSecondaryAction());
  }

  void _onPickLogoPressed() {
    unawaited(_handlePickLogo());
  }

  void _onPickExactLocationPressed() {
    unawaited(_handlePickExactLocation());
  }

  Future<void> _handleBackNavigation() async {
    if (_bloc.state.isSubmitting) return;

    FocusScope.of(context).unfocus();
    final bool shouldPop = await _bloc.goToPreviousStep();
    if (shouldPop && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handlePrimaryAction() async {
    FocusScope.of(context).unfocus();

    final CreateCourtsActionResult result = await _bloc.handlePrimaryAction();
    if (!mounted) return;

    if (result.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result.errorMessage!)));
    }

    final payload = result.payload;
    if (payload == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Shop payload is ready to send.')),
    );
    await showCreateCourtsPayloadPreviewSheet(context, payload);
  }

  Future<void> _handleSecondaryAction() async {
    if (_bloc.state.isSubmitting) return;

    FocusScope.of(context).unfocus();
    if (_bloc.state.currentStep > 0) {
      await _bloc.goToPreviousStep();
      return;
    }

    await _bloc.resetForm();
  }

  Future<void> _handlePickLogo() async {
    final String? errorMessage = await _bloc.pickLogoFromDevice();
    if (errorMessage != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  Future<void> _handlePickExactLocation() async {
    final PickedLocation? picked = await showModalBottomSheet<PickedLocation>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ExactLocationPickerSheet(
          initialLabel: _bloc.exactLocationController.text.trim().isEmpty
              ? null
              : _bloc.exactLocationController.text.trim(),
          initialLatitude: _bloc.state.selectedLatitude,
          initialLongitude: _bloc.state.selectedLongitude,
        );
      },
    );

    if (picked == null) return;
    _bloc.applyPickedLocation(picked);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bloc,
      builder: (BuildContext context, Widget? child) {
        final state = _bloc.state;
        final steps = CreateFootsallCourtsBloc.steps;

        return Scaffold(
          backgroundColor: LightColor.background,
          appBar: AppBar(
            title: const Text(
              'Create Footsall Court',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: false,
            leading: IconButton(
              padding: const EdgeInsets.only(left: 12, right: 4),
              icon: const Icon(Icons.arrow_back_ios, size: 18),
              onPressed: state.isSubmitting ? null : _onAppBarBackPressed,
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
          ),
          body: Column(
            children: <Widget>[
              WizardStepBar(currentStep: state.currentStep, steps: steps),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[Color(0xFFF8FBFF), Color(0xFFF1F4FA)],
                    ),
                  ),
                  child: PageView(
                    controller: _bloc.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      CreateCourtsStepScaffold(
                        formKey: _bloc.formKeys[0],
                        stepIndex: 0,
                        totalSteps: steps.length,
                        title: steps[0].title,
                        subtitle: steps[0].subtitle,
                        icon: steps[0].icon,
                        child: BasicInformationSection(bloc: _bloc),
                      ),
                      CreateCourtsStepScaffold(
                        formKey: _bloc.formKeys[1],
                        stepIndex: 1,
                        totalSteps: steps.length,
                        title: steps[1].title,
                        subtitle: steps[1].subtitle,
                        icon: steps[1].icon,
                        child: BusinessRegistrationSection(
                          bloc: _bloc,
                          onPickExactLocation: _onPickExactLocationPressed,
                        ),
                      ),
                      CreateCourtsStepScaffold(
                        formKey: _bloc.formKeys[2],
                        stepIndex: 2,
                        totalSteps: steps.length,
                        title: steps[2].title,
                        subtitle: steps[2].subtitle,
                        icon: steps[2].icon,
                        child: AmenitiesFacilitiesSection(bloc: _bloc),
                      ),
                      CreateCourtsStepScaffold(
                        formKey: _bloc.formKeys[3],
                        stepIndex: 3,
                        totalSteps: steps.length,
                        title: steps[3].title,
                        subtitle: steps[3].subtitle,
                        icon: steps[3].icon,
                        child: PoliciesSection(bloc: _bloc),
                      ),
                      CreateCourtsStepScaffold(
                        formKey: _bloc.formKeys[4],
                        stepIndex: 4,
                        totalSteps: steps.length,
                        title: steps[4].title,
                        subtitle: steps[4].subtitle,
                        icon: steps[4].icon,
                        child: ChoosePackageSection(bloc: _bloc),
                      ),
                      CreateCourtsStepScaffold(
                        formKey: _bloc.formKeys[5],
                        stepIndex: 5,
                        totalSteps: steps.length,
                        title: steps[5].title,
                        subtitle: steps[5].subtitle,
                        icon: steps[5].icon,
                        child: BrandingReviewSection(
                          bloc: _bloc,
                          onPickLogo: _onPickLogoPressed,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: CreateCourtsActionBar(
            currentStep: state.currentStep,
            isLastStep: state.isLastStep,
            isSubmitting: state.isSubmitting,
            onSecondaryPressed: _onSecondaryPressed,
            onPrimaryPressed: _onPrimaryPressed,
          ),
        );
      },
    );
  }
}
