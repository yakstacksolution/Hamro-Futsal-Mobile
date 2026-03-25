import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

/// A compact unified stepper that displays both main steps and substeps
/// in a single section with minimal spacing.
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

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header with title and current step info
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: LightColor.titleText,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: LightColor.secondaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${activeSectionIndex + 1}.${activeSubstepIndex + 1}',
                  style: const TextStyle(
                    color: LightColor.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Steps Row
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (BuildContext context, int index) {
                final VendorSectionDefinition section = sections[index];
                final StepStatus status = statusForSection(index);

                return _CompactStepChip(
                  index: index,
                  title: _shortTitle(section.title),
                  icon: section.icon,
                  status: status,
                  isSelected: activeSectionIndex == index,
                  onTap: () => onSectionSelected(index),
                );
              },
            ),
          ),

          // Subtle divider
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: <Widget>[
                Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: LightColor.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(height: 1, color: LightColor.borderLight),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 2,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: LightColor.border,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),

          // Substeps Row
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: substeps.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (BuildContext context, int index) {
                final VendorSubstepDefinition substep = substeps[index];
                final StepStatus status = statusForSubstep(index);

                return _CompactSubstepChip(
                  index: index,
                  title: _compactTitle(substep.title),
                  status: status,
                  isSelected: index == activeSubstepIndex,
                  onTap: () => onSubstepSelected(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _shortTitle(String title) {
    final String value = title.trim();
    if (value.length <= 10) return value;

    final List<String> words = value.split(' ');
    if (words.length >= 2) {
      return words.take(2).join(' ');
    }
    return value.substring(0, 10);
  }

  String _compactTitle(String value) {
    final String title = value.trim();
    final List<String> words = title.split(' ');

    // Single word - return full word
    if (words.length == 1) return title;

    // Multiple words - return first two words if total <= 15 chars
    if (words.length >= 2) {
      final String twoWords = '${words[0]} ${words[1]}';
      if (twoWords.length <= 15) return twoWords;
      return words[0];
    }
    return title;
  }
}

class _CompactStepChip extends StatelessWidget {
  const _CompactStepChip({
    required this.index,
    required this.title,
    required this.icon,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final int index;
  final String title;
  final IconData icon;
  final StepStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: <Color>[
                      LightColor.secondary,
                      LightColor.secondaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : LightColor.surfaceSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? Colors.transparent : LightColor.border,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: LightColor.secondary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                status == StepStatus.complete ? Icons.check_rounded : icon,
                size: 14,
                color: isSelected
                    ? LightColor.white
                    : status == StepStatus.complete
                    ? LightColor.secondary
                    : LightColor.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? LightColor.white : LightColor.titleText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (status == StepStatus.complete && !isSelected) ...<Widget>[
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: LightColor.secondary,
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
    required this.onTap,
  });

  final int index;
  final String title;
  final StepStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? LightColor.secondaryLight : LightColor.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? LightColor.secondary : LightColor.borderLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 18,
                height: 18,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected
                      ? LightColor.secondary
                      : status == StepStatus.complete
                      ? LightColor.secondaryLight
                      : LightColor.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: status == StepStatus.complete
                    ? Icon(
                        Icons.check_rounded,
                        size: 10,
                        color: isSelected
                            ? LightColor.white
                            : LightColor.secondary,
                      )
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isSelected
                              ? LightColor.white
                              : LightColor.titleText,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? LightColor.secondaryDark
                      : LightColor.subtitleText,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: isSelected ? LightColor.secondary : statusColor,
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
        return LightColor.secondary;
      case StepStatus.inProgress:
        return LightColor.amber;
      case StepStatus.error:
        return LightColor.red;
      case StepStatus.locked:
        return LightColor.hintText;
      case StepStatus.notStarted:
        return LightColor.mutedText;
      case StepStatus.pending:
        return LightColor.mutedText;
    }
  }
}
