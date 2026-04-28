import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

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
    }
  }

  Future<void> _confirmRemoveCourt(
    BuildContext context,
    String courtId,
    String courtName,
  ) async {
    final bool confirmed = await showConfirmDialog(
      context: context,
      title: 'Remove Court?',
      message:
          'Are you sure you want to remove "$courtName"? This action cannot be undone and will delete permanently.',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      confirmColor: LightColor.redColor,
      icon: Icons.delete_outline_rounded,
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
          if (state.courts.isEmpty)
            _CourtEmptyStateCompact(
              onAddCourt: () => _showAddCourtSheet(context),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.4,
              ),
              itemCount: state.courts.length,
              itemBuilder: (BuildContext context, int index) {
                final CourtDraft court = state.courts[index];
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

                return _CourtCompactTile(
                  court: court,
                  isSelected: state.activeCourtId == court.id,
                  completedSections: completedSections,
                  totalSections: courtSectionDefinitions.length,
                  onTap: () => cubit.selectCourt(court.id),
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
  const _CourtEmptyStateCompact({required this.onAddCourt});

  final VoidCallback onAddCourt;

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

class _CourtCompactTile extends StatelessWidget {
  const _CourtCompactTile({
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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Ink(
          padding: AppUtils().getPadding(
            horizontal: AppDimens.paddingX12,
            vertical: AppDimens.paddingX6,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? LightColor.secondaryLight
                : LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.borderColor,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.secondaryColor.withValues(alpha: 0.12),
                      blurRadius: AppDimens.sizeX8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: <Widget>[
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      courtName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,

                      style: FutsalTheme.getTextTheme(context).bodySubTitle
                          ?.copyWith(
                            color: LightColor.primaryTextColor,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (isComplete)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: AppDimens.sizeX10,
                            color: LightColor.secondaryColor,
                          )
                        else
                          Icon(
                            Icons.pie_chart_rounded,
                            size: AppDimens.sizeX10,
                            color: isSelected
                                ? LightColor.secondaryColor
                                : LightColor.secondaryTextColor,
                          ),
                        const SizedBox(width: AppDimens.sizeX3),
                        Text(
                          isComplete
                              ? 'Complete'
                              : '$completedSections/$totalSections',
                          style: FutsalTheme.getTextTheme(context).bodySubTitle
                              ?.copyWith(
                                color: isComplete
                                    ? LightColor.secondaryColor
                                    : (isSelected
                                          ? LightColor.secondaryColor
                                          : LightColor.secondaryTextColor),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sizeX2),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: AppDimens.sizeX16,
                  height: AppDimens.sizeX16,
                  decoration: BoxDecoration(
                    color: LightColor.primaryTextColor.withValues(alpha: 0.05),
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
        ),
      ),
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
    Navigator.of(context).pop(name.isEmpty ? null : name);
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
