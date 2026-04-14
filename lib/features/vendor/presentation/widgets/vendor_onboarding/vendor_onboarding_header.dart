import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart' hide LightColor;
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_footsall/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_footsall/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

class VendorOnboardingHeader extends StatelessWidget {
  const VendorOnboardingHeader({
    super.key,
    required this.cubit,
    required this.state,
  });

  final VendorOnboardingCubit cubit;
  final VendorOnboardingState state;

  @override
  Widget build(BuildContext context) {
    final int progressPercent = (cubit.overallCompletion * 100).round();

    final bool isCourt = state.isInCourtCategory;
    final String title = isCourt ? 'Court setup' : 'Futsal setup';
    final String subtitle = isCourt
        ? 'Manage court details and booking flow'
        : 'Complete business profile and location';

    return Container(
      padding: AppUtils().getPadding(all: AppDimens.paddingX14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[LightColor.secondaryColor, LightColor.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondaryColor.withValues(alpha: 0.16),
            blurRadius: AppDimens.radiusX18,
            offset: const Offset(0, 8),
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
                  color: LightColor.whiteColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX12),
                  border: Border.all(
                    color: LightColor.whiteColor.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(
                  isCourt ? Icons.stadium_rounded : Icons.sports_soccer_rounded,
                  color: LightColor.whiteColor,
                  size: AppDimens.sizeX20,
                ),
              ),
              const SizedBox(width: AppDimens.sizeX10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FutsalTheme.getTextTheme(context).bodyTextLarge
                          ?.copyWith(
                            color: LightColor.whiteColor,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.whiteColor.withValues(
                              alpha: 0.88,
                            ),
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimens.sizeX8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.sizeX8,
                  vertical: AppDimens.sizeX8,
                ),
                decoration: BoxDecoration(
                  color: LightColor.whiteColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppDimens.radiusX6),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '$progressPercent%',
                      style: FutsalTheme.getTextTheme(context).bodyTextSmall
                          ?.copyWith(
                            color: LightColor.whiteColor,
                            fontSize: AppDimens.sizeX12,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                    ),
                    const SizedBox(height: AppDimens.sizeX4),
                    Text(
                      'Done',
                      style: FutsalTheme.getTextTheme(context).bodyMiniSubTitle
                          ?.copyWith(
                            color: LightColor.whiteColor.withValues(
                              alpha: 0.82,
                            ),
                            fontWeight: FontWeight.w600,
                            height: 1,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.sizeX12),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusX56),
            child: LinearProgressIndicator(
              minHeight: AppDimens.sizeX8,
              value: cubit.overallCompletion,
              backgroundColor: LightColor.whiteColor.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(
                LightColor.whiteColor,
              ),
            ),
          ),
          const SizedBox(height: AppDimens.sizeX12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _CompactInfoChip(
                  icon: Icons.account_balance_wallet_rounded,
                  label:
                      'Futsal ${stepStatusLabel(cubit.futsalSectionStatus(0))}',
                ),
                const SizedBox(width: AppDimens.sizeX8),
                _CompactInfoChip(
                  icon: Icons.grid_view_rounded,
                  label: '${state.courts.length} courts',
                ),
                const SizedBox(width: AppDimens.sizeX8),
                _CompactInfoChip(
                  icon: Icons.cloud_done_rounded,
                  label: saveStatusLabel(state.saveStatus, state.lastSavedAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactInfoChip extends StatelessWidget {
  const _CompactInfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppUtils().getPadding(
        horizontal: AppDimens.sizeX8,
        vertical: AppDimens.sizeX6,
      ),
      decoration: BoxDecoration(
        color: LightColor.whiteColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppDimens.radiusX56),
        border: Border.all(
          color: LightColor.whiteColor.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(
            icon,
            size: AppDimens.sizeX14,
            color: LightColor.whiteColor.withValues(alpha: 0.95),
          ),
          const SizedBox(width: AppDimens.sizeX6),
          Text(
            label,
            style: FutsalTheme.getTextTheme(context).bodySubTitle?.copyWith(
              color: LightColor.whiteColor.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
