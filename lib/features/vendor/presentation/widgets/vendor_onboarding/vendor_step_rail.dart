import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

/// Desktop step navigation: every section as a row, the active one opened
/// to show its sub-steps — the vertical counterpart of the phone's chip
/// rows, with the same statuses and the same jump-to-step taps.
class VendorStepRail extends StatelessWidget {
  const VendorStepRail({
    super.key,
    required this.title,
    required this.sections,
    required this.activeSectionIndex,
    required this.activeSubstepIndex,
    required this.statusForSection,
    required this.statusForSubstep,
    required this.onSectionSelected,
    required this.onSubstepSelected,
  });

  final String title;
  final List<VendorSectionDefinition> sections;
  final int activeSectionIndex;
  final int activeSubstepIndex;
  final StepStatus Function(int sectionIndex) statusForSection;

  /// Status of a sub-step of the active section.
  final StepStatus Function(int subsectionIndex) statusForSubstep;
  final ValueChanged<int> onSectionSelected;
  final ValueChanged<int> onSubstepSelected;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    return VendorPanel(
      padding: const EdgeInsets.all(AppDimens.paddingX8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.bodyTextMedium?.copyWith(
                      color: LightColor.primaryTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  'Step ${activeSectionIndex + 1}.${activeSubstepIndex + 1}',
                  style: textTheme.bodyMiniSubTitle?.copyWith(
                    color: LightColor.hintTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          for (int s = 0; s < sections.length; s++) ...<Widget>[
            _SectionRow(
              index: s,
              section: sections[s],
              status: statusForSection(s),
              isActive: s == activeSectionIndex,
              onTap: () => onSectionSelected(s),
            ),
            if (s == activeSectionIndex)
              for (int i = 0; i < sections[s].substeps.length; i++)
                _SubstepRow(
                  substep: sections[s].substeps[i],
                  status: statusForSubstep(i),
                  isActive: i == activeSubstepIndex,
                  isLast: i == sections[s].substeps.length - 1,
                  onTap: () => onSubstepSelected(i),
                ),
          ],
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.index,
    required this.section,
    required this.status,
    required this.isActive,
    required this.onTap,
  });

  final int index;
  final VendorSectionDefinition section;
  final StepStatus status;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool locked = status == StepStatus.locked;
    return Material(
      color: isActive
          ? LightColor.secondaryColor.withValues(alpha: 0.08)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
        onTap: locked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: <Widget>[
              _StatusBadge(
                status: status,
                isActive: isActive,
                label: '${index + 1}',
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      section.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyTextSmall?.copyWith(
                        color: locked
                            ? LightColor.hintTextColor
                            : LightColor.primaryTextColor,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    Text(
                      section.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMiniSubTitle?.copyWith(
                        color: LightColor.hintTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isActive
                    ? Icons.keyboard_arrow_down_rounded
                    : Icons.chevron_right_rounded,
                size: AppDimens.sizeX18,
                color: LightColor.hintTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubstepRow extends StatelessWidget {
  const _SubstepRow({
    required this.substep,
    required this.status,
    required this.isActive,
    required this.isLast,
    required this.onTap,
  });

  final VendorSubstepDefinition substep;
  final StepStatus status;
  final bool isActive;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final Color dot = switch (status) {
      StepStatus.complete => LightColor.secondaryColor,
      StepStatus.error => LightColor.redColor,
      _ when isActive => LightColor.secondaryColor,
      _ => LightColor.borderColor,
    };
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      onTap: status == StepStatus.locked ? null : onTap,
      child: Padding(
        // Under the section badge: the guide line runs down its centre.
        padding: const EdgeInsets.only(left: 20, right: 8),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                width: 16,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      top: 0,
                      bottom: isLast ? null : 0,
                      height: isLast ? 18 : null,
                      child: Container(
                        width: 1.5,
                        color: LightColor.dividerColor,
                      ),
                    ),
                    Container(
                      width: isActive ? 10 : 8,
                      height: isActive ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status == StepStatus.complete || isActive
                            ? dot
                            : LightColor.cardColor,
                        border: Border.all(color: dot, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.paddingX12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    substep.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyTextSmall?.copyWith(
                      fontSize: AppDimens.fontBodySubTitle + 1,
                      color: isActive
                          ? LightColor.brandTextColor
                          : LightColor.secondaryTextColor,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
              if (status == StepStatus.complete)
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: LightColor.secondaryColor,
                )
              else if (status == StepStatus.error)
                Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: LightColor.redColor,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isActive,
    required this.label,
  });

  final StepStatus status;
  final bool isActive;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final (Color bg, Color fg, IconData? icon) = switch (status) {
      StepStatus.complete => (
        LightColor.secondaryColor,
        LightColor.inverseTextColor,
        Icons.check_rounded,
      ),
      StepStatus.error => (
        LightColor.redColor,
        LightColor.inverseTextColor,
        Icons.priority_high_rounded,
      ),
      StepStatus.locked => (
        LightColor.inputFillColor,
        LightColor.hintTextColor,
        Icons.lock_outline_rounded,
      ),
      _ when isActive => (
        LightColor.secondaryColor,
        LightColor.inverseTextColor,
        null,
      ),
      _ => (LightColor.inputFillColor, LightColor.secondaryTextColor, null),
    };
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: icon != null
          ? Icon(icon, size: 15, color: fg)
          : Text(
              label,
              style: textTheme.bodyMiniSubTitle?.copyWith(
                color: fg,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}
