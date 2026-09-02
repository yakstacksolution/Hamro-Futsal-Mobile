import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/app_utils.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class VendorUnifiedStepper extends StatelessWidget {
  const VendorUnifiedStepper({
    super.key,
    required this.title,
    required this.sections,
    required this.activeSectionIndex,
    required this.statusForSection,
    required this.onSectionSelected,
    required this.substeps,
    required this.activeSubstepIndex,
    required this.statusForSubstep,
    required this.onSubstepSelected,
  });

  final String title;
  final List<VendorSectionDefinition> sections;
  final int activeSectionIndex;
  final StepStatus Function(int sectionIndex) statusForSection;
  final ValueChanged<int> onSectionSelected;
  final List<VendorSubstepDefinition> substeps;
  final int activeSubstepIndex;
  final StepStatus Function(int subsectionIndex) statusForSubstep;
  final ValueChanged<int> onSubstepSelected;

  static final AppUtils _appUtils = AppUtils();
  static final EdgeInsets _badgePadding = _appUtils.getPadding(
    horizontal: AppDimens.sizeX8,
    vertical: AppDimens.sizeX6,
  );
  static final EdgeInsets _dividerPadding = _appUtils.getPadding(
    vertical: AppDimens.sizeX8,
  );
  static final EdgeInsets _stepChipPadding = _appUtils.getPadding(
    horizontal: AppDimens.sizeX10,
    vertical: AppDimens.sizeX6,
  );
  static const Duration _chipAnimationDuration = Duration(milliseconds: 90);

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final TextStyle? titleStyle = textTheme.bodyTextMedium?.copyWith(
      color: LightColor.primaryTextColor,
      fontWeight: FontWeight.w700,
    );
    final TextStyle? badgeStyle = textTheme.bodySubTitle?.copyWith(
      color: LightColor.inverseTextColor,
      fontWeight: FontWeight.w700,
    );
    final TextStyle? stepStyle = textTheme.bodyTextSmall?.copyWith(
      fontSize: AppDimens.fontBodySubTitle + AppDimens.sizeX1,
      fontWeight: FontWeight.w700,
    );
    final TextStyle? substepStyle = textTheme.bodyMiniSubTitle?.copyWith(
      fontWeight: FontWeight.w600,
    );
    final TextStyle? substepBadgeStyle = textTheme.bodyMiniSubTitle?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(child: Text(title, style: titleStyle)),
              Container(
                padding: _badgePadding,
                decoration: BoxDecoration(
                  color: LightColor.secondaryColor,
                  borderRadius: BorderRadius.circular(AppDimens.sizeX4),
                ),
                child: Text(
                  '${activeSectionIndex + 1}.${activeSubstepIndex + 1}',
                  style: badgeStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX8),
          SizedBox(
            height: AppDimens.sizeX36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: sections.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimens.sizeX8),
              itemBuilder: (BuildContext context, int index) {
                final VendorSectionDefinition section = sections[index];
                final StepStatus status = statusForSection(index);
                return _CompactStepChip(
                  index: index,
                  title: section.title,
                  icon: section.icon,
                  status: status,
                  isSelected: activeSectionIndex == index,
                  textStyle: stepStyle,
                  onTap: () => onSectionSelected(index),
                );
              },
            ),
          ),

          Padding(
            padding: _dividerPadding,
            child: Row(
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX2,
                  height: AppDimens.sizeX2,
                  decoration: BoxDecoration(
                    color: LightColor.borderColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX6),
                Expanded(
                  child: Container(
                    height: AppDimens.sizeX1,
                    color: LightColor.dividerColor,
                  ),
                ),
                const SizedBox(width: AppDimens.sizeX6),
                Container(
                  width: AppDimens.sizeX2,
                  height: AppDimens.sizeX2,
                  decoration: BoxDecoration(
                    color: LightColor.borderColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Substeps Row
          SizedBox(
            height: AppDimens.sizeX28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: substeps.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AppDimens.sizeX6),
              itemBuilder: (BuildContext context, int index) {
                final VendorSubstepDefinition substep = substeps[index];
                final StepStatus status = statusForSubstep(index);
                return _CompactSubstepChip(
                  index: index,
                  title: substep.title, //_compactTitle(substep.title),
                  status: status,
                  isSelected: index == activeSubstepIndex,
                  titleStyle: substepStyle,
                  badgeStyle: substepBadgeStyle,
                  onTap: () => onSubstepSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactStepChip extends StatelessWidget {
  const _CompactStepChip({
    required this.index,
    required this.title,
    required this.icon,
    required this.status,
    required this.isSelected,
    required this.textStyle,
    required this.onTap,
  });

  final int index;
  final String title;
  final IconData icon;
  final StepStatus status;
  final bool isSelected;
  final TextStyle? textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LightColor.transparentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: VendorUnifiedStepper._chipAnimationDuration,
          curve: Curves.easeOut,
          padding: VendorUnifiedStepper._stepChipPadding,
          decoration: BoxDecoration(
            color: isSelected
                ? LightColor.secondaryColor
                : LightColor.whiteColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX8),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : LightColor.greyBorderColor,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.secondaryColor.withValues(alpha: 0.2),
                      blurRadius: AppDimens.radiusX8,
                      offset: const Offset(0, AppDimens.sizeX2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                status == StepStatus.complete ? Icons.check_rounded : icon,
                size: AppDimens.sizeX16,
                color: isSelected
                    ? LightColor.inverseTextColor
                    : status == StepStatus.complete
                    ? LightColor.primaryTextColor
                    : LightColor.primaryTextColor,
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Text(
                title,

                style: textStyle?.copyWith(
                  color: isSelected
                      ? LightColor.inverseTextColor
                      : LightColor.primaryTextColor,
                ),
              ),
              if (status == StepStatus.complete && !isSelected) ...<Widget>[
                const SizedBox(width: AppDimens.sizeX4),
                Container(
                  width: AppDimens.sizeX6,
                  height: AppDimens.sizeX6,
                  decoration: const BoxDecoration(
                    color: LightColor.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSubstepChip extends StatelessWidget {
  const _CompactSubstepChip({
    required this.index,
    required this.title,
    required this.status,
    required this.isSelected,
    required this.titleStyle,
    required this.badgeStyle,
    required this.onTap,
  });

  final int index;
  final String title;
  final StepStatus status;
  final bool isSelected;
  final TextStyle? titleStyle;
  final TextStyle? badgeStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(status);
    final Color backgroundColor = isSelected
        ? LightColor.secondaryColor
        : status == StepStatus.locked
        ? LightColor.inputFillColor
        : LightColor.whiteColor;
    final Color borderColor = isSelected
        ? LightColor.secondaryColor
        : status == StepStatus.complete
        ? LightColor.secondarySoft
        : status == StepStatus.error
        ? LightColor.redColor.withValues(alpha: 0.22)
        : LightColor.dividerColor;
    final Color badgeColor = isSelected
        ? LightColor.inverseTextColor
        : status == StepStatus.complete
        ? LightColor.secondarySoft
        : status == StepStatus.error
        ? LightColor.redLightColor.withValues(alpha: 0.55)
        : status == StepStatus.inProgress
        ? LightColor.warningLightColor
        : LightColor.inputFillColor;
    final Color badgeTextColor = isSelected
        ? LightColor.secondaryColor
        : status == StepStatus.complete
        ? LightColor.secondaryColor
        : status == StepStatus.error
        ? LightColor.redColor
        : status == StepStatus.inProgress
        ? LightColor.warningColor
        : status == StepStatus.locked
        ? LightColor.hintTextColor
        : LightColor.primaryTextColor;
    final Color titleColor = isSelected
        ? LightColor.inverseTextColor
        : status == StepStatus.error
        ? LightColor.redColor
        : status == StepStatus.locked
        ? LightColor.hintTextColor
        : LightColor.secondaryTextColor;

    return Material(
      color: LightColor.transparentColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: VendorUnifiedStepper._chipAnimationDuration,
          curve: Curves.easeOut,
          padding: VendorUnifiedStepper._stepChipPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusX6),
            border: Border.all(color: borderColor, width: isSelected ? 1.2 : 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: AppDimens.sizeX16,
                height: AppDimens.sizeX16,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.circle,
                ),
                child: status == StepStatus.complete
                    ? Icon(
                        Icons.check_rounded,
                        size: AppDimens.sizeX10,
                        color: badgeTextColor,
                      )
                    : Text(
                        '${index + 1}',
                        style: badgeStyle?.copyWith(color: badgeTextColor),
                      ),
              ),
              const SizedBox(width: AppDimens.sizeX6),
              Text(title, style: titleStyle?.copyWith(color: titleColor)),
              const SizedBox(width: AppDimens.sizeX6),
              Container(
                width: AppDimens.sizeX4,
                height: AppDimens.sizeX4,
                decoration: BoxDecoration(
                  color: isSelected ? LightColor.whiteColor : statusColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return LightColor.secondaryColor;
      case StepStatus.inProgress:
        return LightColor.warningColor;
      case StepStatus.error:
        return LightColor.redColor;
      case StepStatus.locked:
        return LightColor.hintTextColor;
      case StepStatus.notStarted:
        return LightColor.disabledTextColor;
      case StepStatus.pending:
        return LightColor.disabledTextColor;
    }
  }
}
