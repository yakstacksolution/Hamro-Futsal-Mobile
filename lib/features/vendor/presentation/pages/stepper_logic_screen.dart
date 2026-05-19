import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_bottom_action_bar.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_category_switcher.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_court_manager.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_header.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_shell.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_step_content.dart';
import 'package:hamro_footsall/features/vendor/presentation/utils/vendor_template_defaults.dart';

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
  final AppUtils _appUtils = AppUtils();

  @override
  void initState() {
    _cubit = context.read<VendorOnboardingCubit>();
    unawaited(_bootstrapScreen());

    super.initState();
  }

  Future<void> _bootstrapScreen() async {
    final int? futsalId = widget.futsalId;

    if (futsalId != null && futsalId > 0) {
      await _cubit.fetchVendorOnboarding(futsalId);
      if (!mounted) return;
    }

    _fetchBackgroundResources();
  }

  void _fetchBackgroundResources() {
    final PublicTemplatesBloc templatesBloc = context
        .read<PublicTemplatesBloc>();
    final PublicTemplatesState templatesState = templatesBloc.state;
    if (templatesState.templates.isNotEmpty) {
      _applyTemplateDefaults(context, templatesState.templates);
      return;
    }
    if (templatesState.status != PublicTemplatesStatus.loading) {
      templatesBloc.add(FetchPublicTemplatesEvent());
    }
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
        BlocListener<VendorOnboardingCubit, VendorOnboardingState>(
          listenWhen:
              (VendorOnboardingState previous, VendorOnboardingState current) =>
                  previous.isRestoringDraft && !current.isRestoringDraft,
          listener: (BuildContext context, VendorOnboardingState state) {
            final PublicTemplatesState templatesState = context
                .read<PublicTemplatesBloc>()
                .state;
            if (templatesState.templates.isNotEmpty) {
              _applyTemplateDefaults(context, templatesState.templates);
            }
          },
        ),
      ],
      child: BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
        buildWhen:
            (VendorOnboardingState previous, VendorOnboardingState current) {
              return previous.isRestoringDraft != current.isRestoringDraft ||
                  previous.isSubmitting != current.isSubmitting ||
                  previous.isCompleted != current.isCompleted ||
                  previous.cursor != current.cursor ||
                  previous.futsalPointer != current.futsalPointer ||
                  previous.courtPointersById != current.courtPointersById ||
                  previous.futsal != current.futsal ||
                  previous.courts != current.courts ||
                  previous.activeCourtId != current.activeCourtId ||
                  previous.errorKeys != current.errorKeys ||
                  previous.errorMessage != current.errorMessage ||
                  previous.errorOrigin != current.errorOrigin ||
                  previous.remoteFutsalId != current.remoteFutsalId ||
                  previous.isLoadingCourts != current.isLoadingCourts;
            },
        builder: (BuildContext context, VendorOnboardingState state) {
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
              cubit: cubit,
            ),
            body: SafeArea(
              top: false,
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: _appUtils.getPadding(
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
                    if (!state.isInCourtCategory &&
                        cubit.isCourtEditorVisible) ...<Widget>[
                      const SizedBox(height: AppDimens.sizeX14),
                      VendorOnboardingStepContent(
                        title: 'Futsal Steps',
                        cubit: cubit,
                        state: state,
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
    if (_hasAppliedTemplateDefaults || templates.isEmpty) {
      return;
    }

    final VendorOnboardingCubit cubit = context.read<VendorOnboardingCubit>();
    if (cubit.state.isRestoringDraft) return;

    final FutsalDraft draft = cubit.state.futsal;
    final String? description = draft.description.trim().isEmpty
        ? templateDefaultFor(templates, VendorTemplateField.futsalDescription)
        : null;
    final String? courtDescription = templateDefaultFor(
      templates,
      VendorTemplateField.courtDescription,
    );
    final String? cancellationPolicy = draft.cancellationPolicy.trim().isEmpty
        ? templateDefaultFor(templates, VendorTemplateField.cancellationPolicy)
        : null;
    final String? futsalRules = draft.futsalRules.trim().isEmpty
        ? templateDefaultFor(templates, VendorTemplateField.futsalRules)
        : null;

    cubit.setDefaultCourtDescription(courtDescription);

    final bool hasFutsalUpdates =
        description != null ||
        cancellationPolicy != null ||
        futsalRules != null;

    if (!hasFutsalUpdates) {
      _hasAppliedTemplateDefaults = true;
      return;
    }

    if (hasFutsalUpdates) {
      cubit.updateFutsal(
        draft.copyWith(
          description: description ?? draft.description,
          cancellationPolicy: cancellationPolicy ?? draft.cancellationPolicy,
          futsalRules: futsalRules ?? draft.futsalRules,
        ),
      );
    }

    _hasAppliedTemplateDefaults = true;
  }
}
