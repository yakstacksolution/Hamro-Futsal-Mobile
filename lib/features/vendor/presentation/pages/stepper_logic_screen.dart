import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/court_amenities_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/court_booking_payment_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/court_information_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/court_media_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/court_slots_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_business_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_information_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/sections/futsal_policy_section.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_bottom_action_bar.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_category_switcher.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_court_manager.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_header.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_shell.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_unified_stepper.dart';

class StepperLogicScreen extends StatelessWidget {
  const StepperLogicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VendorOnboardingCubit, VendorOnboardingState>(
      listenWhen:
          (VendorOnboardingState previous, VendorOnboardingState current) {
            return previous.isCompleted != current.isCompleted ||
                (previous.saveStatus != current.saveStatus &&
                    current.saveStatus == DraftSaveStatus.failure);
          },
      listener: (BuildContext context, VendorOnboardingState state) {
        if (state.isCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vendor onboarding is complete and saved locally.'),
            ),
          );
        } else if (state.saveStatus == DraftSaveStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft save failed. Try again.')),
          );
        }
      },
      builder: (BuildContext context, VendorOnboardingState state) {
        final VendorOnboardingCubit cubit = context
            .read<VendorOnboardingCubit>();

        if (state.isRestoringDraft) {
          return const Scaffold(
            backgroundColor: LightColor.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return VendorOnboardingShell(
          isSubmitting: state.isSubmitting,
          onSaveDraft: () => unawaited(cubit.saveDraftNow()),
          onReset: () => unawaited(cubit.resetOnboarding()),
          bottomBar: VendorBottomActionBar(
            hasPrevious: cubit.canGoPrevious,
            isSubmitting: state.isSubmitting,
            nextLabel: cubit.nextButtonLabel,
            saveStatus: state.saveStatus,
            lastSavedAt: state.lastSavedAt,
            onPrevious: cubit.previous,
            onSave: () => unawaited(cubit.saveDraftNow()),
            onNext: () => unawaited(cubit.next()),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  VendorOnboardingHeader(cubit: cubit, state: state),
                  // const SizedBox(height: 16),
                  // VendorCategorySwitcher(
                  //   activeCategory: state.cursor.category,
                  //   canAccessCourtCategory: cubit.canAccessCourtCategory,
                  //   onCategorySelected: cubit.selectCategory,
                  // ),
                  if (state.isInCourtCategory) ...<Widget>[
                    const SizedBox(height: 16),
                    VendorCourtManager(cubit: cubit, state: state),
                  ],
                  if (cubit.isCourtEditorVisible) ...<Widget>[
                    const SizedBox(height: 16),
                    VendorUnifiedStepper(
                      title: state.isInCourtCategory
                          ? '${state.activeCourt?.name.trim().isNotEmpty == true ? state.activeCourt!.name.trim() : 'Court'} Steps'
                          : 'Futsal Steps',
                      sections: cubit.activeSections,
                      activeSectionIndex: cubit.currentSectionIndex,
                      statusForSection: (int sectionIndex) {
                        if (!state.isInCourtCategory) {
                          return cubit.futsalSectionStatus(sectionIndex);
                        }
                        final String? activeCourtId = state.activeCourtId;
                        if (activeCourtId == null) return StepStatus.locked;
                        return cubit.courtSectionStatus(
                          activeCourtId,
                          sectionIndex,
                        );
                      },
                      onSectionSelected: cubit.selectSection,
                      substeps: cubit.activeSubsteps,
                      activeSubstepIndex: cubit.currentSubstepIndex,
                      statusForSubstep: (int subsectionIndex) {
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
                      },
                      onSubstepSelected: cubit.selectSubstep,
                    ),
                  ],
                  if (state.errorMessage != null) ...<Widget>[
                    const SizedBox(height: 16),
                    VendorErrorBanner(message: state.errorMessage!),
                  ],
                  if (cubit.isCourtEditorVisible) ...<Widget>[
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _ActiveSectionContent(
                        key: ValueKey<String>(
                          '${state.cursor.category.name}-${state.cursor.sectionIndex}-${state.cursor.subsectionIndex}-${state.activeCourtId ?? 'none'}',
                        ),
                        cubit: cubit,
                        state: state,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveSectionContent extends StatelessWidget {
  const _ActiveSectionContent({
    super.key,
    required this.cubit,
    required this.state,
  });

  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;

  @override
  Widget build(BuildContext context) {
    if (!state.isInCourtCategory) {
      switch (cubit.currentSectionIndex) {
        case 0:
          return FutsalInformationSection(
            cubit: cubit,
            draft: state.futsal,
            subsectionIndex: cubit.currentSubstepIndex,
          );
        case 1:
          return FutsalPolicySection(
            cubit: cubit,
            draft: state.futsal,
            subsectionIndex: cubit.currentSubstepIndex,
          );
        case 2:
          return FutsalBusinessSection(
            cubit: cubit,
            draft: state.futsal,
            subsectionIndex: cubit.currentSubstepIndex,
          );
      }
    }

    final CourtDraft court = state.activeCourt!;
    switch (cubit.currentSectionIndex) {
      case 0:
        return CourtInformationSection(
          cubit: cubit,
          court: court,
          subsectionIndex: cubit.currentSubstepIndex,
        );
      case 1:
        return CourtBookingPaymentSection(
          cubit: cubit,
          court: court,
          subsectionIndex: cubit.currentSubstepIndex,
        );
      case 2:
        return CourtAmenitiesSection(cubit: cubit, court: court);
      case 3:
        return CourtMediaSection(cubit: cubit, court: court);
      case 4:
        return CourtSlotsSection(
          cubit: cubit,
          court: court,
          subsectionIndex: cubit.currentSubstepIndex,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
