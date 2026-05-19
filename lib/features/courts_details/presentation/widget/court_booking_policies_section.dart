import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';

class CourtBookingPoliciesSection extends StatelessWidget {
  const CourtBookingPoliciesSection({super.key, required this.policies});

  final List<String> policies;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return Padding(
      padding: AppUtils().getPadding(
        top: AppDimens.paddingX12,
        left: AppDimens.paddingX20,
        right: AppDimens.paddingX20,
      ),
      child: Container(
        width: double.infinity,
        padding: AppUtils().getPadding(all: AppDimens.paddingX16),
        decoration: BoxDecoration(
          color: LightColor.cardColor,
          borderRadius: BorderRadius.circular(AppDimens.radiusX10),
          boxShadow: [
            BoxShadow(
              color: LightColor.shadowColor.withValues(alpha: 0.04),
              blurRadius: AppDimens.sizeX12,
              offset: const Offset(0, AppDimens.sizeX4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.policy_outlined,
                  size: AppDimens.sizeX24,
                  color: LightColor.secondaryColor,
                ),
                const SizedBox(width: AppDimens.sizeX8),
                Text(
                  'Booking Policies',
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX16),
            if (policies.isEmpty)
              Text(
                'No booking policy added yet.',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Column(
                children: policies.asMap().entries.map((entry) {
                  final isLast = entry.key == policies.length - 1;
                  return Padding(
                    padding: AppUtils().getPadding(
                      bottom: isLast ? 0 : AppDimens.paddingX12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: AppDimens.sizeX24,
                          height: AppDimens.sizeX24,
                          decoration: BoxDecoration(
                            color: LightColor.secondaryColor,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX8,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: textTheme.bodySubTitle?.copyWith(
                                color: LightColor.whiteColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimens.sizeX12),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: textTheme.bodyTextSmall?.copyWith(
                              color: LightColor.secondaryTextColor,
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
