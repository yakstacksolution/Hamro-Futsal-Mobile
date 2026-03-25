import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/light_color.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_models.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class VendorSubstepStepper extends StatelessWidget {
  const VendorSubstepStepper({
    super.key,
    required this.substeps,
    required this.activeSubstepIndex,
    required this.statusForSubstep,
    required this.onSubstepSelected,
  });

  final List<VendorSubstepDefinition> substeps;
  final int activeSubstepIndex;
  final StepStatus Function(int subsectionIndex) statusForSubstep;
  final ValueChanged<int> onSubstepSelected;

  @override
  Widget build(BuildContext context) {
    final VendorSubstepDefinition activeStep = substeps[activeSubstepIndex];
    final StepStatus activeStatus = statusForSubstep(activeSubstepIndex);

    return VendorPanel(
      // padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Step Breakdown',
            style: TextStyle(
              color: LightColor.titleText,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            activeStep.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: LightColor.subtitleText,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: substeps.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (BuildContext context, int index) {
                final VendorSubstepDefinition substep = substeps[index];
                final StepStatus status = statusForSubstep(index);

                return _PremiumSubstepPill(
                  index: index,
                  title: _compactTitle(substep.title),
                  status: status,
                  isSelected: index == activeSubstepIndex,
                  onTap: () => onSubstepSelected(index),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          _ActiveStepFooter(
            index: activeSubstepIndex,
            title: activeStep.title,
            status: activeStatus,
          ),
        ],
      ),
    );
  }

  String _compactTitle(String value) {
    final String title = value.trim();
    if (title.length <= 12) return title;

    final List<String> words = title.split(' ');
    if (words.length >= 2) {
      return '${words[0]} ${words[1]}';
    }

    return title;
  }
}

class _PremiumSubstepPill extends StatelessWidget {
  const _PremiumSubstepPill({
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
    final Color accentColor = _statusColor(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minWidth: 94, maxWidth: 128),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? const LinearGradient(
                    colors: <Color>[Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.transparent : LightColor.border,
            ),
            boxShadow: isSelected
                ? <BoxShadow>[
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.18),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.18)
                          : const Color(0xFFF8FAFC),
                      shape: BoxShape.circle,
                    ),
                    child: status == StepStatus.complete
                        ? Icon(
                            Icons.check_rounded,
                            size: 13,
                            color: isSelected
                                ? Colors.white
                                : LightColor.secondary,
                          )
                        : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : LightColor.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isSelected ? Colors.white : LightColor.titleText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 3,
                  value: _progressValue(status),
                  backgroundColor: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSelected ? Colors.white : accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _progressValue(StepStatus status) {
    switch (status) {
      case StepStatus.complete:
        return 1;
      case StepStatus.inProgress:
        return 0.6;
      case StepStatus.error:
        return 1;
      case StepStatus.locked:
        return 0;
      case StepStatus.notStarted:
        return 0.08;
      case StepStatus.pending:
        return 0.12;
    }
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
        return const Color(0xFF94A3B8);
      case StepStatus.pending:
        return const Color(0xFFCBD5E1);
    }
  }
}

class _ActiveStepFooter extends StatelessWidget {
  const _ActiveStepFooter({
    required this.index,
    required this.title,
    required this.status,
  });

  final int index;
  final String title;
  final StepStatus status;

  @override
  Widget build(BuildContext context) {
    final Color color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LightColor.border),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: LightColor.titleText,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(_statusIcon(status), size: 16, color: color),
        ],
      ),
    );
  }

  Color _statusColor(StepStatus status) {
    switch (status) {
      case StepStatus.locked:
        return LightColor.hintText;
      case StepStatus.notStarted:
        return const Color(0xFF94A3B8);
      case StepStatus.inProgress:
        return LightColor.amber;
      case StepStatus.complete:
        return LightColor.secondary;
      case StepStatus.error:
        return LightColor.red;
      case StepStatus.pending:
        return const Color(0xFFCBD5E1);
    }
  }

  IconData _statusIcon(StepStatus status) {
    switch (status) {
      case StepStatus.locked:
        return Icons.lock_outline_rounded;
      case StepStatus.notStarted:
        return Icons.radio_button_unchecked_rounded;
      case StepStatus.inProgress:
        return Icons.timelapse_rounded;
      case StepStatus.complete:
        return Icons.check_circle_rounded;
      case StepStatus.error:
        return Icons.error_outline_rounded;
      case StepStatus.pending:
        return Icons.more_horiz_rounded;
    }
  }
}
