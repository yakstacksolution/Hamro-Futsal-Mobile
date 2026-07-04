import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_text.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

class VendorOnboardingHeader extends StatelessWidget {
  const VendorOnboardingHeader({
    super.key,
    required this.cubit,
    required this.state,
  });

  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;

  static const EdgeInsets _containerPadding = EdgeInsets.all(
    AppDimens.paddingX14,
  );
  static const EdgeInsets _progressBadgePadding = EdgeInsets.symmetric(
    horizontal: AppDimens.sizeX8,
    vertical: AppDimens.sizeX8,
  );

  static const SizedBox _gapW8 = SizedBox(width: AppDimens.sizeX8);
  static const SizedBox _gapW10 = SizedBox(width: AppDimens.sizeX10);
  static const SizedBox _gapH4 = SizedBox(height: AppDimens.sizeX4);
  static const SizedBox _gapH12 = SizedBox(height: AppDimens.sizeX12);

  @override
  Widget build(BuildContext context) {
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);

    final double completion = cubit.overallCompletion.clamp(0.0, 1.0);
    final int progressPercent = (completion * 100).round();

    final bool isCourt = state.isInCourtCategory;
    final String title = isCourt ? 'Court setup' : 'Futsal setup';
    final String subtitle = isCourt
        ? 'Manage court details and booking flow'
        : 'Complete business profile and location';

    final String futsalStatus =
        'Futsal ${stepStatusLabel(cubit.futsalSectionStatus(0))}';
    final String courtsLabel = '${state.courts.length} courts';
    final String saveLabel = saveStatusLabel(
      state.saveStatus,
      state.lastSavedAt,
    );

    final Color white14 = LightColor.whiteColor.withOpacity(0.14);
    final Color white10 = LightColor.whiteColor.withOpacity(0.10);
    final Color white08 = LightColor.whiteColor.withOpacity(0.08);
    final Color white16 = LightColor.whiteColor.withOpacity(0.16);
    final Color white82 = LightColor.whiteColor.withOpacity(0.82);
    final Color white88 = LightColor.whiteColor.withOpacity(0.88);
    final Color white95 = LightColor.whiteColor.withOpacity(0.95);

    final BorderRadius cardRadius = BorderRadius.circular(AppDimens.radiusX12);
    final BorderRadius badgeRadius = BorderRadius.circular(AppDimens.radiusX6);
    final BorderRadius pillRadius = BorderRadius.circular(AppDimens.radiusX56);

    return RepaintBoundary(
      child: Container(
        padding: _containerPadding,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[
              LightColor.secondaryColor,
              LightColor.secondaryDark,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: cardRadius,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: LightColor.secondaryColor.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: AppDimens.sizeX42,
                  height: AppDimens.sizeX42,
                  decoration: BoxDecoration(
                    color: white14,
                    borderRadius: cardRadius,
                    border: Border.all(color: white10),
                  ),
                  child: Icon(
                    isCourt
                        ? Icons.stadium_rounded
                        : Icons.sports_soccer_rounded,
                    color: LightColor.whiteColor,
                    size: AppDimens.sizeX20,
                  ),
                ),
                _gapW10,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextLarge?.copyWith(
                          color: LightColor.whiteColor,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      _gapH4,
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: white88,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                _gapW8,
                Container(
                  padding: _progressBadgePadding,
                  decoration: BoxDecoration(
                    color: white14,
                    borderRadius: badgeRadius,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        '$progressPercent%',
                        style: textTheme.bodyTextSmall?.copyWith(
                          color: LightColor.whiteColor,
                          fontSize: AppDimens.sizeX12,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      _gapH4,
                      Text(
                        StringConstants.done,
                        style: textTheme.bodyMiniSubTitle?.copyWith(
                          color: white82,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            _gapH12,
            ClipRRect(
              borderRadius: pillRadius,
              child: LinearProgressIndicator(
                minHeight: AppDimens.sizeX8,
                value: completion,
                backgroundColor: white16,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  LightColor.whiteColor,
                ),
              ),
            ),
            _gapH12,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  _CompactInfoChip(
                    icon: Icons.account_balance_wallet_rounded,
                    label: futsalStatus,
                    textTheme: textTheme,
                    iconColor: white95,
                    textColor: white95,
                    backgroundColor: white10,
                    borderColor: white08,
                    radius: pillRadius,
                  ),
                  _gapW8,
                  _CompactInfoChip(
                    icon: Icons.grid_view_rounded,
                    label: courtsLabel,
                    textTheme: textTheme,
                    iconColor: white95,
                    textColor: white95,
                    backgroundColor: white10,
                    borderColor: white08,
                    radius: pillRadius,
                  ),
                  _gapW8,
                  _CompactInfoChip(
                    icon: Icons.cloud_done_rounded,
                    label: saveLabel,
                    textTheme: textTheme,
                    iconColor: white95,
                    textColor: white95,
                    backgroundColor: white10,
                    borderColor: white08,
                    radius: pillRadius,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactInfoChip extends StatelessWidget {
  const _CompactInfoChip({
    required this.icon,
    required this.label,
    required this.textTheme,
    required this.iconColor,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.radius,
  });

  final IconData icon;
  final String label;
  final FutsalTextTheme textTheme;
  final Color iconColor;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final BorderRadius radius;

  static const EdgeInsets _padding = EdgeInsets.symmetric(
    horizontal: AppDimens.sizeX8,
    vertical: AppDimens.sizeX6,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: AppDimens.sizeX14, color: iconColor),
          const SizedBox(width: AppDimens.sizeX6),
          Text(
            label,
            style: textTheme.bodySubTitle?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
