import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_packages/public_packages_bloc.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
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

class StepperLogicScreen extends StatefulWidget {
  final int? futsalId;
  final int? mainStep;
  final int? subStep;
  const StepperLogicScreen({
    super.key,
    this.futsalId,
    this.mainStep,
    this.subStep,
  });

  @override
  State<StepperLogicScreen> createState() => _StepperLogicScreenState();
}

class _StepperLogicScreenState extends State<StepperLogicScreen> {
  bool _hasAppliedTemplateDefaults = false;
  late final VendorOnboardingCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<VendorOnboardingCubit>();
    if (widget.futsalId != null && widget.futsalId! > 0) {
      unawaited(_cubit.fetchVendorOnboarding(widget.futsalId!));
    } else {
      context.read<PublicTemplatesBloc>().add(FetchPublicTemplatesEvent());
    }
    context.read<PublicPackagesBloc>().add(FetchPublicPackagesEvent());

    super.initState();
  }

  @override
  void dispose() {
    _cubit.clearOnboardingState();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: <BlocListener<dynamic, dynamic>>[
        BlocListener<PublicTemplatesBloc, PublicTemplatesState>(
          listenWhen:
              (PublicTemplatesState previous, PublicTemplatesState current) =>
                  previous.status != current.status &&
                  current.status == PublicTemplatesStatus.success,
          listener: (BuildContext context, PublicTemplatesState state) {
            _applyTemplateDefaults(context, state.templates);
          },
        ),
        BlocListener<VendorOnboardingCubit, VendorOnboardingState>(
          listenWhen:
              (VendorOnboardingState previous, VendorOnboardingState current) {
                return previous.isCompleted != current.isCompleted ||
                    (previous.saveStatus != current.saveStatus &&
                        current.saveStatus == DraftSaveStatus.failure);
              },
          listener: (BuildContext context, VendorOnboardingState state) {
            if (state.isCompleted) {
              AppUtils().showSnackBar(
                context,
                MsgType.success,
                'Vendor onboarding is complete.',
              );
            } else if (state.saveStatus == DraftSaveStatus.failure) {
              AppUtils().showSnackBar(
                context,
                MsgType.error,
                'Draft save failed. Try again.',
              );
            }
          },
        ),
        BlocListener<VendorOnboardingCubit, VendorOnboardingState>(
          listenWhen:
              (VendorOnboardingState previous, VendorOnboardingState current) {
                return previous.isSubmitting == true &&
                    current.isSubmitting == false &&
                    current.errorOrigin == VendorErrorOrigin.api &&
                    previous.errorMessage != current.errorMessage &&
                    current.errorMessage?.trim().isNotEmpty == true;
              },
          listener: (BuildContext context, VendorOnboardingState state) {
            AppUtils().showSnackBar(
              context,
              MsgType.error,
              state.errorMessage!.trim(),
            );
          },
        ),
      ],
      child: BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
        builder: (BuildContext context, VendorOnboardingState state) {
          // If templates are already loaded, apply defaults once on first build.
          if (!_hasAppliedTemplateDefaults) {
            final PublicTemplatesState templatesState = context
                .read<PublicTemplatesBloc>()
                .state;
            if (templatesState.status == PublicTemplatesStatus.success &&
                templatesState.templates.isNotEmpty) {
              _applyTemplateDefaults(context, templatesState.templates);
            }
          }

          final VendorOnboardingCubit cubit = _cubit;

          if (state.isRestoringDraft) {
            return const Scaffold(
              backgroundColor: LightColor.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return VendorOnboardingShell(
            isSubmitting: state.isSubmitting,
            onReset: () => unawaited(cubit.resetOnboarding()),
            bottomBar: VendorBottomActionBar(
              hasPrevious: cubit.canGoPrevious,
              isSubmitting: state.isSubmitting,
              nextLabel: cubit.nextButtonLabel,
              onPrevious: cubit.previous,
              onNext: () => unawaited(cubit.next()),
            ),
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: AppUtils().getPadding(
                  left: AppDimens.paddingX16,
                  top: AppDimens.paddingX16,
                  right: AppDimens.paddingX16,
                  bottom: AppDimens.paddingX20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    VendorOnboardingHeader(cubit: cubit, state: state),
                    const SizedBox(height: AppDimens.sizeX14),
                    VendorCategorySwitcher(
                      activeCategory: state.cursor.category,
                      canAccessCourtCategory: cubit.canAccessCourtCategory,
                      onCategorySelected: cubit.selectCategory,
                    ),
                    if (state.isInCourtCategory) ...<Widget>[
                      const SizedBox(height: AppDimens.sizeX14),
                      VendorCourtManager(cubit: cubit, state: state),
                    ],
                    if (cubit.isCourtEditorVisible) ...<Widget>[
                      const SizedBox(height: AppDimens.sizeX14),
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
                    if (state.errorMessage != null &&
                        state.errorMessage!.isNotEmpty &&
                        state.errorOrigin != VendorErrorOrigin.api) ...<Widget>[
                      const SizedBox(height: AppDimens.sizeX14),
                      VendorErrorBanner(message: state.errorMessage!),
                    ],
                    if (cubit.isCourtEditorVisible) ...<Widget>[
                      const SizedBox(height: AppDimens.sizeX14),
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
      ),
    );
  }

  void _applyTemplateDefaults(
    BuildContext context,
    List<PublicTemplateModel> templates,
  ) {
    if (_hasAppliedTemplateDefaults ||
        widget.futsalId != null ||
        templates.isEmpty) {
      return;
    }

    final VendorOnboardingCubit cubit = context.read<VendorOnboardingCubit>();
    final FutsalDraft draft = cubit.state.futsal;

    final String? description = draft.description.trim().isEmpty
        ? _templateContentFor(
            templates,
            preferredTitles: const <String>['description'],
            primaryKeywords: const <String>['description'],
            secondaryKeywords: const <String>['about', 'futsal'],
          )
        : null;
    final String? cancellationPolicy = draft.cancellationPolicy.trim().isEmpty
        ? _templateContentFor(
            templates,
            preferredTitles: const <String>['cancel_policy'],
            primaryKeywords: const <String>['cancellation'],
            secondaryKeywords: const <String>['policy', 'refund'],
          )
        : null;
    final String? futsalRules = draft.futsalRules.trim().isEmpty
        ? _templateContentFor(
            templates,
            preferredTitles: const <String>['futsalrules'],
            primaryKeywords: const <String>['rule'],
            secondaryKeywords: const <String>['rules', 'house', 'futsal'],
          )
        : null;

    if (description == null &&
        cancellationPolicy == null &&
        futsalRules == null) {
      return;
    }

    cubit.updateFutsal(
      draft.copyWith(
        description: description ?? draft.description,
        cancellationPolicy: cancellationPolicy ?? draft.cancellationPolicy,
        futsalRules: futsalRules ?? draft.futsalRules,
      ),
    );

    _hasAppliedTemplateDefaults = true;
  }

  String? _templateContentFor(
    List<PublicTemplateModel> templates, {
    List<String> preferredTitles = const <String>[],
    required List<String> primaryKeywords,
    List<String> secondaryKeywords = const <String>[],
  }) {
    // Prefer exact title matches when provided.
    if (preferredTitles.isNotEmpty) {
      final List<String> normalizedTitles = preferredTitles
          .map((String t) => t.trim().toLowerCase())
          .toList();
      final PublicTemplateModel exactMatch = templates.firstWhere(
        (PublicTemplateModel t) =>
            normalizedTitles.contains(t.title.trim().toLowerCase()),
        orElse: () => const PublicTemplateModel(
          id: '',
          title: '',
          description: '',
          createdAt: null,
          updatedAt: null,
          raw: <String, dynamic>{},
        ),
      );
      if (exactMatch.id.isNotEmpty) {
        final String content = _extractTemplateContent(exactMatch).trim();
        if (content.isNotEmpty) return content;
      }
    }

    final List<_MatchedTemplate> matches =
        templates
            .map(
              (PublicTemplateModel template) => _MatchedTemplate(
                template: template,
                score: _templateScore(
                  template,
                  primaryKeywords: primaryKeywords,
                  secondaryKeywords: secondaryKeywords,
                ),
              ),
            )
            .where((_MatchedTemplate match) => match.score > 0)
            .toList()
          ..sort(
            (_MatchedTemplate a, _MatchedTemplate b) =>
                b.score.compareTo(a.score),
          );

    for (final _MatchedTemplate match in matches) {
      final String content = _extractTemplateContent(match.template).trim();
      if (content.isNotEmpty) return content;
    }
    return null;
  }

  int _templateScore(
    PublicTemplateModel template, {
    required List<String> primaryKeywords,
    required List<String> secondaryKeywords,
  }) {
    final String haystack = <String>[
      template.id,
      template.name,
      template.description,
      _stringValue(template.raw['key']),
      _stringValue(template.raw['type']),
      _stringValue(template.raw['category']),
      _stringValue(template.raw['slug']),
      _stringValue(template.raw['template_name']),
      _stringValue(template.raw['title']),
    ].join(' ').toLowerCase();

    int score = 0;
    for (final String keyword in primaryKeywords) {
      if (haystack.contains(keyword.toLowerCase())) {
        score += 3;
      }
    }
    for (final String keyword in secondaryKeywords) {
      if (haystack.contains(keyword.toLowerCase())) {
        score += 1;
      }
    }
    return score;
  }

  String _extractTemplateContent(PublicTemplateModel template) {
    final dynamic content = template.raw['content'];
    if (content is String && content.trim().isNotEmpty) return content;
    if (content is Map) {
      final String nested = _firstNonEmptyString(<dynamic>[
        content['html'],
        content['body'],
        content['text'],
        content['value'],
      ]);
      if (nested.isNotEmpty) return nested;
    }

    return _firstNonEmptyString(<dynamic>[
      template.raw['html'],
      template.raw['body'],
      template.raw['value'],
      template.raw['template'],
      template.raw['text'],
      template.raw['details'],
      template.raw['description'],
      template.description,
    ]);
  }

  String _firstNonEmptyString(List<dynamic> values) {
    for (final dynamic value in values) {
      final String text = _stringValue(value).trim();
      if (text.isNotEmpty) return text;
    }
    return '';
  }

  String _stringValue(dynamic value) => value?.toString() ?? '';
}

class _MatchedTemplate {
  const _MatchedTemplate({required this.template, required this.score});

  final PublicTemplateModel template;
  final int score;
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
