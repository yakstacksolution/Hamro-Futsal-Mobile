import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';

class VendorBottomActionBar extends StatelessWidget {
  const VendorBottomActionBar({
    super.key,
    required this.hasPrevious,
    required this.isSubmitting,
    required this.nextLabel,
    required this.onPrevious,
    required this.onNext,
  });

  final bool hasPrevious;
  final bool isSubmitting;
  final String nextLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bool canInteract = !isSubmitting;

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
                      onTap: canInteract ? onNext : null,
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
