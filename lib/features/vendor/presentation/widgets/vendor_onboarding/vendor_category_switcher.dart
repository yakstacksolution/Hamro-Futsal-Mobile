import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';

class VendorCategorySwitcher extends StatelessWidget {
  const VendorCategorySwitcher({
    super.key,
    required this.activeCategory,
    required this.canAccessCourtCategory,
    required this.onCategorySelected,
  });

  final VendorCategory activeCategory;
  final bool canAccessCourtCategory;
  final ValueChanged<VendorCategory> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX4),
      decoration: BoxDecoration(
        color: LightColor.whiteColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        border: Border.all(color: LightColor.greyBorderColor),
        boxShadow: [
          BoxShadow(
            color: LightColor.primaryTextColor.withValues(alpha: 0.04),
            blurRadius: AppDimens.radiusX16,
            offset: const Offset(0, AppDimens.sizeX8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              title: 'Futsal',
              icon: Icons.storefront_rounded,
              isSelected: activeCategory == VendorCategory.futsal,
              isLocked: false,
              onTap: () => onCategorySelected(VendorCategory.futsal),
            ),
          ),
          const SizedBox(width: AppDimens.sizeX6),
          Expanded(
            child: _Tab(
              title: 'Court',
              icon: Icons.stadium_rounded,
              isSelected: activeCategory == VendorCategory.court,
              isLocked: !canAccessCourtCategory,
              onTap: canAccessCourtCategory
                  ? () => onCategorySelected(VendorCategory.court)
                  : () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color bg = isSelected
        ? LightColor.secondaryColor
        : LightColor.whiteColor;

    final Color textColor = isSelected
        ? LightColor.whiteColor
        : isLocked
        ? LightColor.secondaryTextColor
        : LightColor.primaryTextColor;

    // Always white icon color
    final Color iconColor = LightColor.whiteColor;

    return Material(
      color: LightColor.transparentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: AppUtils().getPadding(
            horizontal: AppDimens.sizeX8,
            vertical: AppDimens.sizeX6,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.whiteColor,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimens.sizeX26,
                height: AppDimens.sizeX26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? LightColor.whiteColor.withValues(alpha: 0.16)
                      : LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                ),
                child: Icon(
                  isLocked ? Icons.lock_rounded : icon,
                  size: AppDimens.sizeX16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Expanded(
                child: Text(
                  isLocked ? 'Court (Locked)' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FutsalTheme.getTextTheme(context).bodyTextSmall
                      ?.copyWith(color: textColor, fontWeight: FontWeight.w800),
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: AppDimens.sizeX16,
                  color: LightColor.whiteColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
