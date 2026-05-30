import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/custom_image_view.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_delete_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/core/widgets/loading_widget.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_templates/public_templates_bloc.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_bottom_action_bar.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_onboarding_step_content.dart';

class VendorCourtManager extends StatelessWidget {
  const VendorCourtManager({
    super.key,
    required this.cubit,
    required this.state,
  });

  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;

  Future<void> _showAddCourtSheet(BuildContext context) async {
    final String? courtName = await showAppBottomSheet<String>(
      context: context,
      child: const _AddCourtSheet(),
    );

    if (courtName != null) {
      cubit.addCourt(name: courtName);
      final String? courtId = cubit.state.activeCourtId;
      if (context.mounted && courtId != null) {
        unawaited(_openCourtEditor(context, courtId));
      }
    }
  }

  Future<void> _openCourtEditor(BuildContext context, String courtId) async {
    cubit.selectCourt(courtId);
    final PublicTemplatesBloc publicTemplatesBloc = context
        .read<PublicTemplatesBloc>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: <BlocProvider<dynamic>>[
            BlocProvider<VendorOnboardingCubit>.value(value: cubit),
            BlocProvider<PublicTemplatesBloc>.value(value: publicTemplatesBloc),
          ],
          child: CourtOnboardingPage(courtId: courtId),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveCourt(
    BuildContext context,
    String courtId,
    String courtName,
  ) async {
    final bool confirmed = await showDeleteDialog(
      context: context,
      title: 'Delete Court?',
      message:
          'Are you sure you want to delete "$courtName"? This action cannot be undone.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      icon: Icons.delete_outline_rounded,
      confirmColor: LightColor.redColor,
    );

    if (confirmed) {
      cubit.removeCourt(courtId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Courts',
                      style: FutsalTheme.getTextTheme(context).bodyTextMedium
                          ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    SizedBox(height: AppDimens.sizeX2),
                    Text(
                      'Manage courts in compact view',
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppDimens.sizeX10),
              _AddCourtButton(onTap: () => _showAddCourtSheet(context)),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          if (state.isLoadingCourts)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppDimens.paddingX24),
              child: Center(child: LoadingWidget()),
            )
          else if (state.courts.isEmpty)
            GestureDetector(
              onTap: () => _showAddCourtSheet(context),
              child: const _CourtEmptyStateCompact(),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.courts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppDimens.sizeX10),
              itemBuilder: (BuildContext context, int index) {
                final CourtDraft court = state.courts[index];
                final int completedSections = _completedSectionCount(court);
                return _CourtListTile(
                  court: court,
                  isSelected: state.activeCourtId == court.id,
                  completedSections: completedSections,
                  totalSections: courtSectionDefinitions.length,
                  onTap: () => _openCourtEditor(context, court.id),
                  onRemove: () => _confirmRemoveCourt(
                    context,
                    court.id,
                    court.name.trim().isEmpty
                        ? 'Unnamed Court'
                        : court.name.trim(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  int _completedSectionCount(CourtDraft court) {
    int completedSections = 0;
    for (
      int sectionIndex = 0;
      sectionIndex < courtSectionDefinitions.length;
      sectionIndex++
    ) {
      if (cubit.courtSectionStatus(court.id, sectionIndex) ==
          StepStatus.complete) {
        completedSections++;
      }
    }
    return completedSections;
  }
}

class _AddCourtButton extends StatelessWidget {
  const _AddCourtButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.secondaryColor,
      borderRadius: BorderRadius.circular(AppDimens.radiusX6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Padding(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX10,
            vertical: AppDimens.paddingX10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.add_rounded,
                size: AppDimens.sizeX12,
                color: LightColor.whiteColor,
              ),
              SizedBox(width: AppDimens.sizeX4),
              Text(
                'New Court',
                style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
                  color: LightColor.whiteColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtEmptyStateCompact extends StatelessWidget {
  const _CourtEmptyStateCompact();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: AppDimens.sizeX42,
            height: AppDimens.sizeX42,
            decoration: BoxDecoration(
              color: LightColor.secondaryColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            ),
            child: const Icon(
              Icons.stadium_rounded,
              color: LightColor.whiteColor,
              size: AppDimens.sizeX20,
            ),
          ),
          const SizedBox(width: AppDimens.sizeX10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No courts yet',
                  style: FutsalTheme.getTextTheme(
                    context,
                  ).bodyTextMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: AppDimens.sizeX4),
                Text(
                  'Add your first court to continue setup.',
                  style: FutsalTheme.getTextTheme(context).bodySubTitle
                      ?.copyWith(color: LightColor.secondaryTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtListTile extends StatelessWidget {
  const _CourtListTile({
    required this.court,
    required this.isSelected,
    required this.completedSections,
    required this.totalSections,
    required this.onTap,
    required this.onRemove,
  });

  final CourtDraft court;
  final bool isSelected;
  final int completedSections;
  final int totalSections;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final String courtName = court.name.trim().isEmpty
        ? 'Unnamed Court'
        : court.name.trim();
    final bool isComplete = completedSections == totalSections;

    final double progress = totalSections == 0
        ? 0
        : completedSections / totalSections;
    final int progressPercent = (progress.clamp(0, 1) * 100).round();
    final UploadRef? coverImage = court.photos.isNotEmpty
        ? court.photos.first
        : (court.memories.isNotEmpty ? court.memories.first : null);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        child: Ink(
          padding: AppUtils().getPadding(all: AppDimens.paddingX10),
          decoration: BoxDecoration(
            color: isSelected
                ? LightColor.secondaryLight.withValues(alpha: 0.16)
                : LightColor.background,
            borderRadius: BorderRadius.circular(AppDimens.radiusX10),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryLight
                  : LightColor.greyBorderColor,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _CourtThumbnail(image: coverImage),
                  const SizedBox(width: AppDimens.sizeX12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          courtName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FutsalTheme.getTextTheme(context).bodyTextSmall
                              ?.copyWith(
                                color: LightColor.primaryTextColor,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppDimens.sizeX6),
                        Row(
                          children: <Widget>[
                            _CourtMetricPill(
                              icon: isComplete
                                  ? Icons.check_circle_rounded
                                  : Icons.pie_chart_rounded,
                              label: '$progressPercent%',
                              isStrong: isComplete,
                            ),
                            const SizedBox(width: AppDimens.sizeX6),
                            _CourtMetricPill(
                              icon: Icons.schedule_rounded,
                              label:
                                  '${court.slotConfigs.length} ${court.slotConfigs.length == 1 ? 'slot' : 'slots'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimens.sizeX8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        formatDouble(court.basePrice).isEmpty
                            ? '-'
                            : formatDouble(court.basePrice),
                        style: FutsalTheme.getTextTheme(context).bodyTextSmall
                            ?.copyWith(
                              color: LightColor.secondaryColor,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppDimens.sizeX6),
                      GestureDetector(
                        onTap: onRemove,
                        child: Container(
                          width: AppDimens.sizeX28,
                          height: AppDimens.sizeX28,
                          decoration: BoxDecoration(
                            color: LightColor.primaryTextColor.withValues(
                              alpha: 0.05,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: AppDimens.sizeX12,
                            color: LightColor.secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.sizeX10),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0, 1),
                  minHeight: AppDimens.sizeX4,
                  backgroundColor: LightColor.greyBorderColor,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isComplete
                        ? LightColor.secondaryColor
                        : LightColor.secondaryLight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourtThumbnail extends StatelessWidget {
  const _CourtThumbnail({required this.image});

  final UploadRef? image;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.sizeX58,
      height: AppDimens.sizeX58,
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: image?.remoteUrl?.trim().isNotEmpty == true
          ? CustomImageView(
              url: image!.remoteUrl,
              width: AppDimens.sizeX58,
              height: AppDimens.sizeX58,
              fit: BoxFit.cover,
            )
          : const Icon(
              Icons.stadium_rounded,
              color: LightColor.secondaryColor,
              size: AppDimens.sizeX24,
            ),
    );
  }
}

class _CourtMetricPill extends StatelessWidget {
  const _CourtMetricPill({
    required this.icon,
    required this.label,
    this.isStrong = false,
  });

  final IconData icon;
  final String label;
  final bool isStrong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.paddingX8,
        vertical: AppDimens.paddingX4,
      ),
      decoration: BoxDecoration(
        color: isStrong
            ? LightColor.secondaryLight.withValues(alpha: 0.2)
            : LightColor.cardColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: LightColor.greyBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: AppDimens.sizeX12,
            color: isStrong
                ? LightColor.secondaryColor
                : LightColor.secondaryTextColor,
          ),
          const SizedBox(width: AppDimens.sizeX4),
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle?.copyWith(
              color: isStrong
                  ? LightColor.secondaryColor
                  : LightColor.secondaryTextColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class CourtOnboardingPage extends StatefulWidget {
  const CourtOnboardingPage({super.key, required this.courtId});

  final String courtId;

  @override
  State<CourtOnboardingPage> createState() => CourtOnboardingPageState();
}

class CourtOnboardingPageState extends State<CourtOnboardingPage> {
  late final VendorOnboardingCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<VendorOnboardingCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _cubit.selectCourt(widget.courtId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorOnboardingCubit, VendorOnboardingState>(
      bloc: _cubit,
      builder: (BuildContext context, VendorOnboardingState state) {
        CourtDraft? court;
        for (final CourtDraft item in state.courts) {
          if (item.id == widget.courtId) {
            court = item;
            break;
          }
        }
        final String courtName = court == null || court.name.trim().isEmpty
            ? 'Court Setup'
            : court.name.trim();

        return Scaffold(
          backgroundColor: LightColor.whiteColor,
          appBar: AppBar(
            title: Text(
              courtName,
              style: FutsalTheme.getTextTheme(context).bodyTextMedium?.copyWith(
                color: LightColor.primaryTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: false,
            leading: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: LightColor.primaryTextColor,
                size: AppDimens.sizeX18,
              ),
            ),
            backgroundColor: LightColor.whiteColor,
            elevation: 0,
            surfaceTintColor: LightColor.background,
            foregroundColor: LightColor.primaryTextColor,
          ),
          bottomNavigationBar: court == null
              ? null
              : VendorBottomActionBar(
                  hasPrevious: true,
                  isSubmitting: state.isSubmitting,
                  nextLabel: _cubit.nextButtonLabel,
                  onPrevious: () {
                    if (_cubit.currentSectionIndex == 0 &&
                        _cubit.currentSubstepIndex == 0) {
                      Navigator.of(context).maybePop();
                      return;
                    }
                    _cubit.previous();
                  },
                  onNext: () async {
                    await _cubit.next();
                    if (!context.mounted) return;
                    if (!_cubit.state.isInCourtCategory ||
                        _cubit.state.activeCourtId != widget.courtId) {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
          body: SafeArea(
            top: false,
            child: court == null
                ? const Center(child: Text('Court not found.'))
                : SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: AppUtils().getPadding(
                      horizontal: AppDimens.paddingX12,
                      vertical: AppDimens.paddingX10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        VendorOnboardingStepContent(
                          title: 'Court Setup',
                          cubit: _cubit,
                          state: state,
                          court: court,
                          errorSpacing: AppDimens.sizeX10,
                          contentSpacing: AppDimens.sizeX12,
                        ),
                        const SizedBox(height: AppDimens.sizeX90),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _AddCourtSheet extends StatefulWidget {
  const _AddCourtSheet();

  @override
  State<_AddCourtSheet> createState() => _AddCourtSheetState();
}

class _AddCourtSheetState extends State<_AddCourtSheet> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Add New Court',
          style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX10),
        Text(
          'Enter a name for the court. You can change it later. \nMake sure to use a proper standard name for the court.',
          style: FutsalTheme.getTextTheme(context).bodyTextSmall?.copyWith(
            color: LightColor.secondaryTextColor,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX18),
        CustomTextField(
          controller: _nameController,
          focusNode: _focusNode,
          labelText: 'Court Name',
          hintText: 'e.g. Court A, Main Field',
          icon: Icons.sports_soccer_rounded,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: AppDimens.sizeX20),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                backgroundColor: Colors.white,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: AppDimens.sizeX46,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: AppDimens.sizeX14),
            Expanded(
              child: CustomButton(
                text: 'Add Court',
                minHeight: AppDimens.sizeX46,
                onPressed: _submit,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.sizeX20),
      ],
    );
  }
}
