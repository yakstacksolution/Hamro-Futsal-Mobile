import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/court_amenities_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/court_booking_payment_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/court_information_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/court_slots_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_business_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_information_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_policy_section.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_step_rail.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_unified_stepper.dart';

class VendorOnboardingStepContent extends StatelessWidget {
  const VendorOnboardingStepContent({
    super.key,
    required this.title,
    required this.cubit,
    required this.state,
    this.court,
    this.errorSpacing = AppDimens.sizeX14,
    this.contentSpacing = AppDimens.sizeX14,
    this.showStepper = true,
  });

  final String title;
  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;
  final CourtDraft? court;
  final double errorSpacing;
  final double contentSpacing;

  /// False when the steps are shown in a [VendorOnboardingStepRail] beside
  /// the form instead (desktop).
  final bool showStepper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (showStepper)
          VendorUnifiedStepper(
            title: title,
            sections: cubit.activeSections,
            activeSectionIndex: cubit.currentSectionIndex,
            statusForSection: _sectionStatus,
            onSectionSelected: cubit.selectSection,
            substeps: cubit.activeSubsteps,
            activeSubstepIndex: cubit.currentSubstepIndex,
            statusForSubstep: _substepStatus,
            onSubstepSelected: cubit.selectSubstep,
          ),
        if (state.errorMessage != null &&
            state.errorMessage!.isNotEmpty &&
            state.errorOrigin != VendorErrorOrigin.api) ...<Widget>[
          if (showStepper) SizedBox(height: errorSpacing),
          VendorErrorBanner(message: state.errorMessage!),
        ],
        if (showStepper || state.errorMessage?.isNotEmpty == true)
          SizedBox(height: contentSpacing),
        RepaintBoundary(
          child: VendorOnboardingSectionContent(
            cubit: cubit,
            state: state,
            court: court,
          ),
        ),
      ],
    );
  }

  StepStatus _sectionStatus(int sectionIndex) {
    if (!state.isInCourtCategory) {
      return cubit.futsalSectionStatus(sectionIndex);
    }
    final String? activeCourtId = state.activeCourtId;
    if (activeCourtId == null) return StepStatus.locked;
    return cubit.courtSectionStatus(activeCourtId, sectionIndex);
  }

  StepStatus _substepStatus(int subsectionIndex) {
    if (!state.isInCourtCategory) {
      return cubit.futsalSubstepStatus(
        cubit.currentSectionIndex,
        subsectionIndex,
      );
    }
    final String? activeCourtId = state.activeCourtId;
    if (activeCourtId == null) return StepStatus.locked;
    return cubit.courtSubstepStatus(
      activeCourtId,
      cubit.currentSectionIndex,
      subsectionIndex,
    );
  }
}

/// The desktop step rail for the onboarding's current category, with the
/// same statuses and navigation as [VendorOnboardingStepContent]'s stepper.
class VendorOnboardingStepRail extends StatelessWidget {
  const VendorOnboardingStepRail({
    super.key,
    required this.title,
    required this.cubit,
    required this.state,
  });

  final String title;
  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;

  @override
  Widget build(BuildContext context) {
    final VendorOnboardingStepContent statuses = VendorOnboardingStepContent(
      title: title,
      cubit: cubit,
      state: state,
    );
    return VendorStepRail(
      title: title,
      sections: cubit.activeSections,
      activeSectionIndex: cubit.currentSectionIndex,
      activeSubstepIndex: cubit.currentSubstepIndex,
      statusForSection: statuses._sectionStatus,
      statusForSubstep: statuses._substepStatus,
      onSectionSelected: cubit.selectSection,
      onSubstepSelected: cubit.selectSubstep,
    );
  }
}

class VendorOnboardingSectionContent extends StatelessWidget {
  const VendorOnboardingSectionContent({
    super.key,
    required this.cubit,
    required this.state,
    this.court,
  });

  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;
  final CourtDraft? court;

  @override
  Widget build(BuildContext context) {
    if (!state.isInCourtCategory) return _buildFutsalSection();
    return _buildCourtSection();
  }

  Widget _buildFutsalSection() {
    return switch (cubit.currentSectionIndex) {
      0 => FutsalInformationSection(
        cubit: cubit,
        draft: state.futsal,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      1 => FutsalPolicySection(
        cubit: cubit,
        draft: state.futsal,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      2 => FutsalBusinessSection(
        cubit: cubit,
        draft: state.futsal,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildCourtSection() {
    final CourtDraft? activeCourt = court ?? state.activeCourt;
    if (activeCourt == null) return const SizedBox.shrink();

    return switch (cubit.currentSectionIndex) {
      0 => CourtInformationSection(
        cubit: cubit,
        court: activeCourt,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      1 => CourtBookingPaymentSection(
        cubit: cubit,
        court: activeCourt,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      2 => CourtAmenitiesSection(
        cubit: cubit,
        court: activeCourt,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      3 => CourtSlotsSection(
        cubit: cubit,
        court: activeCourt,
        subsectionIndex: cubit.currentSubstepIndex,
      ),
      _ => const SizedBox.shrink(),
    };
  }
}
