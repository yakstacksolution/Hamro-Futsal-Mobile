import 'package:flutter/material.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: <Color>[LightColor.secondary, LightColor.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.secondary.withValues(alpha: 0.16),
            blurRadius: 18,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: LightColor.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: LightColor.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Icon(
                  isCourt ? Icons.stadium_rounded : Icons.sports_soccer_rounded,
                  color: LightColor.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LightColor.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: LightColor.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        height: 1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: LightColor.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      '$progressPercent%',
                      style: const TextStyle(
                        color: LightColor.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Done',
                      style: TextStyle(
                        color: LightColor.white.withValues(alpha: 0.82),
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              minHeight: 7,
              value: cubit.overallCompletion,
              backgroundColor: LightColor.white.withValues(alpha: 0.16),
              valueColor: const AlwaysStoppedAnimation<Color>(LightColor.white),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                _CompactInfoChip(
                  icon: Icons.account_balance_wallet_rounded,
                  label:
                      'Futsal ${stepStatusLabel(cubit.futsalSectionStatus(0))}',
                ),
                const SizedBox(width: 8),
                _CompactInfoChip(
                  icon: Icons.grid_view_rounded,
                  label: '${state.courts.length} courts',
                ),
                const SizedBox(width: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: LightColor.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: LightColor.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Icon(icon, size: 13, color: LightColor.white.withValues(alpha: 0.95)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: LightColor.white.withValues(alpha: 0.95),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
