import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class CourtRulesSection extends StatelessWidget {
  const CourtRulesSection({super.key, required this.rules});

  final List<String> rules;

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
                  Icons.gavel_rounded,
                  size: AppDimens.sizeX22,
                  color: LightColor.warningColor,
                ),
                const SizedBox(width: AppDimens.sizeX8),
                Text(
                  StringConstants.courtRules,
                  style: textTheme.bodyTextLarge?.copyWith(
                    color: LightColor.primaryTextColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.sizeX14),
            if (rules.isEmpty)
              Text(
                StringConstants.noRulesListedYet,
                style: textTheme.bodyTextSmall?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              )
            else
              Column(
                children: rules.asMap().entries.map((entry) {
                  final isLast = entry.key == rules.length - 1;
                  return Padding(
                    padding: AppUtils().getPadding(
                      bottom: isLast ? 0 : AppDimens.paddingX10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: AppDimens.sizeX22,
                          height: AppDimens.sizeX22,
                          decoration: BoxDecoration(
                            color: LightColor.warningLightColor,
                            borderRadius: BorderRadius.circular(
                              AppDimens.radiusX6,
                            ),
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            size: AppDimens.sizeX14,
                            color: LightColor.warningColor,
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
