import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/core/widgets/custom_text_field.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';

class VendorBottomActionBar extends StatelessWidget {
  const VendorBottomActionBar({
    super.key,
    required this.hasPrevious,
    required this.isSubmitting,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
    this.cubit,
  });

  final bool hasPrevious;
  final bool isSubmitting;
  final String nextLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VendorOnboardingCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !isSubmitting;
    final bool isAddFirstCourt = nextLabel == 'Add First Court';

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppUtils().getPadding(top: AppDimens.paddingX8),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppDimens.radiusX14),
            topRight: Radius.circular(AppDimens.radiusX14),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: AppDimens.sizeX18,
              sigmaY: AppDimens.sizeX18,
            ),
            child: Container(
              padding: AppUtils().getPadding(all: AppDimens.paddingX8),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: LightColor.whiteColor.withOpacity(0.94),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimens.radiusX14),
                  topRight: Radius.circular(AppDimens.radiusX14),
                ),
                border: Border.symmetric(
                  horizontal: BorderSide(color: LightColor.greyBorderColor),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: AppDimens.radiusX22,
                    offset: const Offset(0, AppDimens.sizeX10),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  if (hasPrevious) ...<Widget>[
                    _SecondaryActionButton(
                      icon: Icons.arrow_back_ios,
                      label: 'Back',
                      onTap: canInteract ? onPrevious : null,
                    ),
                    const SizedBox(width: AppDimens.sizeX12),
                  ],
                  Expanded(
                    child: _PrimaryActionButton(
                      label: nextLabel,
                      onTap: canInteract
                          ? () => isAddFirstCourt
                              ? _showAddCourtSheet(context)
                              : onNext()
                          : null,
                      isLoading: isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddCourtSheet(BuildContext context) async {
    if (cubit == null) return;
    final String? courtName = await showAppBottomSheet<String>(
      context: context,
      child: const _AddCourtSheet(),
    );

    if (courtName != null) {
      cubit!.addCourt(name: courtName);
    }
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        child: Ink(
          height: AppDimens.sizeX46,
          padding: AppUtils().getPadding(horizontal: AppDimens.paddingX20),
          decoration: BoxDecoration(
            color: LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(color: LightColor.greyBorderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                icon,
                size: AppDimens.sizeX16,
                color: isDisabled
                    ? LightColor.greyBorderColor
                    : LightColor.primaryTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Text(
                label,
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? LightColor.greyBorderColor
                          : LightColor.primaryTextColor,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        height: AppDimens.sizeX46,
        child: CustomButton(
          text: label,
          onPressed: onTap,
          isLoading: isLoading,
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
          'Add First Court',
          style: FutsalTheme.getTextTheme(context).bodyTextLarge?.copyWith(
            color: LightColor.primaryTextColor,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppDimens.sizeX10),
        Text(
          'Enter a name for your first court. You can change it later.\nMake sure to use a proper standard name for the court.',
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
