import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/features/courts/presentation/models/create_courts_step_definition.dart';

class WizardStepBar extends StatelessWidget {
  const WizardStepBar({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  final int currentStep;
  final List<CreateCourtsStepDefinition> steps;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List<Widget>.generate(steps.length * 2 - 1, (int index) {
            if (index.isOdd) {
              final bool isCompleted = currentStep > index ~/ 2;
              return SizedBox(
                width: 28,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 22),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? LightColor.secondaryColor
                        : LightColor.borderColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              );
            }

            final int stepIndex = index ~/ 2;
            final CreateCourtsStepDefinition step = steps[stepIndex];
            final bool isCompleted = currentStep > stepIndex;
            final bool isActive = currentStep == stepIndex;

            return SizedBox(
              width: 68,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted || isActive
                          ? LightColor.secondaryColor
                          : Colors.white,
                      border: Border.all(
                        color: isCompleted || isActive
                            ? LightColor.secondaryColor
                            : LightColor.borderColor,
                        width: 2,
                      ),
                      boxShadow: isActive
                          ? <BoxShadow>[
                              BoxShadow(
                                color: LightColor.secondaryColor.withValues(
                                  alpha: 0.28,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                key: ValueKey<String>('check'),
                                color: Colors.white,
                                size: 18,
                              )
                            : Icon(
                                step.icon,
                                key: ValueKey<int>(stepIndex),
                                color: isActive
                                    ? Colors.white
                                    : LightColor.hintTextColor,
                                size: 17,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    step.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive
                          ? LightColor.secondaryColor
                          : isCompleted
                          ? LightColor.secondaryTextColor
                          : LightColor.hintTextColor,
                      letterSpacing: isActive ? 0.2 : 0,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
