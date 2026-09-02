import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_text.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_cubit.dart';
import 'package:hamro_futsal/features/vendor/presentation/bloc/vendor_onboarding_cubit/vendor_onboarding_state.dart';
import 'package:hamro_futsal/features/vendor/presentation/widgets/vendor_onboarding/vendor_form_components.dart';

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
    final FutsalTextTheme textTheme = FutsalTheme.getTextTheme(context);
    final double completion = cubit.overallCompletion.clamp(0.0, 1.0);
    final int progressPercent = (completion * 100).round();
    final bool isCourt = state.isInCourtCategory;

    final Color foreground = LightColor.onBrandSurface.withValues(alpha: 0.96);
    final Color mutedForeground = LightColor.onBrandSurface.withValues(
      alpha: 0.76,
    );
    final Color surface = LightColor.onBrandSurface.withValues(alpha: 0.12);
    final Color border = LightColor.onBrandSurface.withValues(alpha: 0.10);

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool veryCompact = constraints.maxWidth < 330;
          final double chipMaxWidth = veryCompact
              ? constraints.maxWidth - AppDimens.paddingX24
              : (constraints.maxWidth - AppDimens.paddingX34) / 2;

          return Container(
            padding: const EdgeInsets.all(AppDimens.paddingX12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[
                  LightColor.secondaryColor,
                  LightColor.secondaryDark,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              border: Border.all(color: border),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: LightColor.secondaryColor.withValues(alpha: 0.14),
                  blurRadius: AppDimens.radiusX14,
                  offset: const Offset(0, AppDimens.sizeX6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _HeaderIcon(isCourt: isCourt, surface: surface),
                    const SizedBox(width: AppDimens.sizeX10),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isCourt ? 'Court setup' : 'Futsal setup',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyTextLarge?.copyWith(
                              color: foreground,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                            ),
                          ),
                          if (!veryCompact) ...<Widget>[
                            const SizedBox(height: AppDimens.sizeX3),
                            Text(
                              isCourt
                                  ? 'Court details and booking setup'
                                  : 'Business profile and location',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodyTextSmall?.copyWith(
                                color: mutedForeground,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppDimens.sizeX8),
                    _ProgressBadge(
                      progressPercent: progressPercent,
                      textTheme: textTheme,
                      surface: surface,
                      foreground: foreground,
                    ),
                  ],
                ),
                const SizedBox(height: AppDimens.sizeX10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.radiusX50),
                  child: LinearProgressIndicator(
                    minHeight: AppDimens.sizeX4,
                    value: completion,
                    backgroundColor: LightColor.onBrandSurface.withValues(
                      alpha: 0.16,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      LightColor.onBrandSurface,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimens.sizeX10),
                Wrap(
                  spacing: AppDimens.sizeX6,
                  runSpacing: AppDimens.sizeX6,
                  children: <Widget>[
                    _CompactInfoChip(
                      icon: Icons.check_circle_outline_rounded,
                      label:
                          'Futsal ${stepStatusLabel(cubit.futsalSectionStatus(0))}',
                      maxWidth: chipMaxWidth,
                      textTheme: textTheme,
                      foreground: foreground,
                      surface: surface,
                      border: border,
                    ),
                    _CompactInfoChip(
                      icon: Icons.stadium_outlined,
                      label:
                          '${state.courts.length} ${state.courts.length == 1 ? 'court' : 'courts'}',
                      maxWidth: chipMaxWidth,
                      textTheme: textTheme,
                      foreground: foreground,
                      surface: surface,
                      border: border,
                    ),
                    _CompactInfoChip(
                      icon: Icons.cloud_done_outlined,
                      label: saveStatusLabel(
                        state.saveStatus,
                        state.lastSavedAt,
                      ),
                      maxWidth: chipMaxWidth,
                      textTheme: textTheme,
                      foreground: foreground,
                      surface: surface,
                      border: border,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.isCourt, required this.surface});

  final bool isCourt;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppDimens.sizeX36,
      height: AppDimens.sizeX36,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Icon(
        isCourt ? Icons.stadium_rounded : Icons.sports_soccer_rounded,
        color: LightColor.inverseTextColor,
        size: AppDimens.sizeX18,
      ),
    );
  }
}

class _ProgressBadge extends StatelessWidget {
  const _ProgressBadge({
    required this.progressPercent,
    required this.textTheme,
    required this.surface,
    required this.foreground,
  });

  final int progressPercent;
  final FutsalTextTheme textTheme;
  final Color surface;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.sizeX8,
        vertical: AppDimens.sizeX6,
      ),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusX8),
      ),
      child: Text(
        '$progressPercent% ${StringConstants.done}',
        style: textTheme.bodyMiniSubTitle?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
      ),
    );
  }
}

class _CompactInfoChip extends StatelessWidget {
  const _CompactInfoChip({
    required this.icon,
    required this.label,
    required this.maxWidth,
    required this.textTheme,
    required this.foreground,
    required this.surface,
    required this.border,
  });

  final IconData icon;
  final String label;
  final double maxWidth;
  final FutsalTextTheme textTheme;
  final Color foreground;
  final Color surface;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.sizeX8,
          vertical: AppDimens.sizeX6,
        ),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusX50),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: AppDimens.sizeX12, color: foreground),
            const SizedBox(width: AppDimens.sizeX4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMiniSubTitle?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
