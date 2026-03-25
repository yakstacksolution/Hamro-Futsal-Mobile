import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_confirm_dialog.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_state.dart';
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
      confirmColor: LightColor.red,
      icon: Icons.delete_outline_rounded,
    );

    if (confirmed) {
      cubit.removeCourt(courtId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      // padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const <Widget>[
                    Text(
                      'Courts',
                      style: TextStyle(
                        color: LightColor.titleText,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage courts in compact view',
                      style: TextStyle(
                        color: LightColor.subtitleText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _AddCourtButton(onTap: () => _showAddCourtSheet(context)),
            ],
          ),
          const SizedBox(height: 12),
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
      color: LightColor.secondary,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.add_rounded, size: 12, color: LightColor.white),
              SizedBox(width: 4),
              Text(
                'Add New Court',
                style: TextStyle(
                  color: LightColor.white,
                  fontSize: 11,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LightColor.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: LightColor.secondaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stadium_rounded,
              color: LightColor.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'No courts yet',
                  style: TextStyle(
                    color: LightColor.titleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Add your first court to continue setup.',
                  style: TextStyle(
                    color: LightColor.subtitleText,
                    fontSize: 10,
                    height: 1.35,
                  ),
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
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? LightColor.secondaryLight : LightColor.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? LightColor.secondary : LightColor.border,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.secondary.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: <Widget>[
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      courtName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: LightColor.titleText,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (isComplete)
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 11,
                            color: LightColor.accentGreen,
                          )
                        else
                          Icon(
                            Icons.pie_chart_rounded,
                            size: 11,
                            color: isSelected
                                ? LightColor.secondary
                                : LightColor.subtitleText,
                          ),
                        const SizedBox(width: 3),
                        Text(
                          isComplete
                              ? 'Complete'
                              : '$completedSections/$totalSections',
                          style: TextStyle(
                            color: isComplete
                                ? LightColor.accentGreen
                                : (isSelected
                                      ? LightColor.secondary
                                      : LightColor.subtitleText),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: LightColor.black.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 12,
                    color: LightColor.subtitleText,
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
        const Text(
          'Add New Court',
          style: TextStyle(
            color: LightColor.titleText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Enter a name for the court. You can change it later. \nMake sure to use a proper standard name for the court.',
          style: TextStyle(
            color: LightColor.subtitleText,
            fontSize: 12,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        CustomTextField(
          controller: _nameController,
          focusNode: _focusNode,
          labelText: 'Court Name',
          hintText: 'e.g. Court A, Main Field',
          icon: Icons.sports_soccer_rounded,
          textInputAction: TextInputAction.done,
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: CustomButton(
                text: 'Cancel',
                isOutlined: true,
                backgroundColor: Colors.white,
                foregroundColor: LightColor.skyBlue,
                borderColor: LightColor.skyBlue,
                minHeight: 46,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: CustomButton(
                text: 'Add Court',
                minHeight: 46,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
