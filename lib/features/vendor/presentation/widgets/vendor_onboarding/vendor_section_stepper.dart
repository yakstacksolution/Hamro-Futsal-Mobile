import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class VendorSectionStepper extends StatelessWidget {
  const VendorSectionStepper({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.activeSectionIndex,
    required this.statusForSection,
    required this.onSectionSelected,
  });

  final String title;
  final String subtitle;
  final List<VendorSectionDefinition> sections;
  final int activeSectionIndex;
  final StepStatus Function(int sectionIndex) statusForSection;
  final ValueChanged<int> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return VendorPanel(
      // padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          VendorPanelHeading(title: title, subtitle: subtitle),
          const SizedBox(height: 10),
          SizedBox(
            height: 54,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: sections.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final VendorSectionDefinition section = sections[index];
                final StepStatus status = statusForSection(index);
                return _SmallHorizontalStep(
                  title: _shortTitle(section.title),
                  icon: section.icon,
                  status: status,
                  isSelected: activeSectionIndex == index,
                  onTap: () => onSectionSelected(index),
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

    if (value.length <= 12) return value;

    final List<String> words = value.split(' ');
    if (words.length >= 2) {
      return words.take(2).join(' ');
    }

    return value;
  }
}

class _SmallHorizontalStep extends StatelessWidget {
  const _SmallHorizontalStep({
    required this.title,
    required this.icon,
    required this.status,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final StepStatus status;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _statusColor(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minWidth: 92, maxWidth: 124),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? LightColor.secondarySoft
                : LightColor.inputFillColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? LightColor.secondaryColor
                  : LightColor.borderColor,
              width: isSelected ? 1.2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? LightColor.secondaryColor
                          : LightColor.whiteColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : LightColor.borderColor,
                      ),
                    ),
                    child: Icon(
                      status == StepStatus.complete
                          ? Icons.check_rounded
                          : icon,
                      size: 14,
                      color: status == StepStatus.complete
                          ? (isSelected
                                ? Colors.white
                                : LightColor.secondaryColor)
                          : (isSelected
                                ? Colors.white
                                : LightColor.secondaryColor),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected
                            ? LightColor.primaryDark
                            : LightColor.primaryTextColor,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected
                      ? LightColor.secondaryColor
                      : status == StepStatus.complete
                      ? LightColor.secondaryColor.withValues(alpha: 0.25)
                      : LightColor.borderColor,
                  borderRadius: BorderRadius.circular(999),
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
      case StepStatus.locked:
        return LightColor.hintTextColor;
      case StepStatus.pending:
        return LightColor.borderColor;
      case StepStatus.notStarted:
        return LightColor.borderColor;
      case StepStatus.error:
        return LightColor.redColor;
    }
  }
}
