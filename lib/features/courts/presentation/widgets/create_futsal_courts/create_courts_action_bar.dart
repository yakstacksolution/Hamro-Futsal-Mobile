import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';

class CreateCourtsActionBar extends StatelessWidget {
  const CreateCourtsActionBar({
    super.key,
    required this.currentStep,
    required this.isLastStep,
    required this.isSubmitting,
    required this.onSecondaryPressed,
    required this.onPrimaryPressed,
  });

  final int currentStep;
  final bool isLastStep;
  final bool isSubmitting;
  final VoidCallback onSecondaryPressed;
  final VoidCallback onPrimaryPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 66,
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: LightColor.elevatedCardColor,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: LightColor.shadowOf(0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: CustomButton(
                text: currentStep > 0 ? 'Back' : 'Reset',
                icon: currentStep > 0
                    ? Icons.arrow_back_ios
                    : Icons.refresh_rounded,
                onPressed: isSubmitting ? null : onSecondaryPressed,
                isOutlined: true,
                backgroundColor: LightColor.elevatedCardColor,
                foregroundColor: LightColor.secondaryColor,
                borderColor: LightColor.secondaryColor,
                minHeight: 50,
                verticalPadding: 2,
              ),
            ),
            const SizedBox(width: 50),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: isLastStep ? 'Create Shop' : 'Continue',
                icon: isLastStep
                    ? Icons.add_business_rounded
                    : Icons.arrow_forward_ios,
                onPressed: isSubmitting ? null : onPrimaryPressed,
                isLoading: isSubmitting,
                backgroundColor: isLastStep
                    ? LightColor.warningColor
                    : LightColor.secondaryColor,
                foregroundColor: LightColor.inverseTextColor,
                minHeight: 50,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
