import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_update_check.dart';
import 'package:hamro_footsall/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_error_message.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_release_notes.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_version_summary.dart';

/// Full-screen, non-dismissible update wall shown when the installed build is
/// below the minimum supported version or the release is flagged mandatory.
///
/// Deliberately not a route: it is layered above the whole app by
/// [AppUpdateGate], so no navigation — including a notification deep link — can
/// get behind it. The system back button is swallowed too.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return BlocBuilder<AppUpdateBloc, AppUpdateState>(
      builder: (BuildContext context, AppUpdateState state) {
        final AppUpdateCheck? check = state.check;
        final AppUpdateBloc bloc = context.read<AppUpdateBloc>();
        final bool readyToInstall = state.isReadyToInstall;

        // A landscape phone has no room for the badge and the artwork spacing;
        // the actions matter more than the decoration.
        final bool isCompact =
            MediaQuery.sizeOf(context).height <
            AppDimens.updateCompactHeightBreakpoint;

        return PopScope(
          // There is nothing behind this screen to go back to, and leaving the
          // app is the user's only other option.
          canPop: false,
          child: Scaffold(
            backgroundColor: LightColor.background,
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimens.updateWallMaxWidth,
                  ),
                  child: SingleChildScrollView(
                    padding: AppUtils().getPadding(
                      symmetricHorizontal: AppDimens.paddingX24,
                      symmetricVertical: isCompact
                          ? AppDimens.paddingX20
                          : AppDimens.paddingX32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (!isCompact) ...<Widget>[
                          const _UpdateBadge(),
                          const SizedBox(height: AppDimens.paddingX24),
                        ],
                        Text(
                          check?.manifest?.releaseTitle ??
                              StringConstants.updateRequired,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headingSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: LightColor.primaryTextColor,
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingX10),
                        Text(
                          StringConstants.forcedUpdateMessage,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyTextSmall?.copyWith(
                            color: LightColor.secondaryTextColor,
                            height: 1.5,
                          ),
                        ),
                        if (check != null) ...<Widget>[
                          const SizedBox(height: AppDimens.paddingX20),
                          UpdateVersionSummary(check: check),
                          // Notes give way first when the screen is short.
                          UpdateReleaseNotes(
                            notes: check.releaseNotes,
                            maxHeight: isCompact ? 96 : null,
                          ),
                        ],
                        if (state.isDownloading) ...<Widget>[
                          const SizedBox(height: AppDimens.paddingX20),
                          const _DownloadingRow(),
                        ],
                        if (state.errorMessage != null) ...<Widget>[
                          const SizedBox(height: AppDimens.paddingX16),
                          UpdateErrorMessage(
                            message: state.errorMessage!,
                            center: true,
                          ),
                        ],
                        SizedBox(
                          height: isCompact
                              ? AppDimens.paddingX20
                              : AppDimens.paddingX24,
                        ),
                        CustomButton(
                          text: readyToInstall
                              ? StringConstants.restartNow
                              : StringConstants.updateNow,
                          icon: readyToInstall
                              ? Icons.restart_alt_rounded
                              : Icons.download_rounded,
                          minHeight: AppDimens.sizeX48,
                          fontSize: AppDimens.fontBodyTextMedium,
                          isLoading: state.isStartingUpdate,
                          onPressed: () => bloc.add(
                            readyToInstall
                                ? const CompleteFlexibleUpdateEvent()
                                : const StartAppUpdateEvent(),
                          ),
                        ),
                        const SizedBox(height: AppDimens.paddingX10),
                        // Escape hatch when the native Play flow is broken on
                        // the device: go straight to the store listing.
                        CustomButton(
                          text: Platform.isIOS
                              ? StringConstants.openAppStore
                              : StringConstants.openPlayStore,
                          isOutlined: true,
                          foregroundColor: LightColor.secondaryColor,
                          borderColor: LightColor.secondaryColor,
                          minHeight: AppDimens.sizeX46,
                          onPressed: () => bloc.add(const OpenStoreEvent()),
                        ),
                        const SizedBox(height: AppDimens.paddingX8),
                        // Re-checking lets the wall clear itself after the user
                        // updates and returns without a cold start.
                        TextButton(
                          onPressed: state.isChecking
                              ? null
                              : () => bloc.add(
                                  const CheckAppUpdateEvent(manual: true),
                                ),
                          child: Text(
                            state.isChecking
                                ? StringConstants.checkingForUpdates
                                : StringConstants.checkForUpdates,
                            style: textTheme.bodySubTitle?.copyWith(
                              color: LightColor.secondaryTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UpdateBadge extends StatelessWidget {
  const _UpdateBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppDimens.sizeX80,
        height: AppDimens.sizeX80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: LightColor.secondaryColor.withValues(alpha: 0.1),
          border: Border.all(
            color: LightColor.secondaryColor.withValues(alpha: 0.22),
            width: 1.4,
          ),
        ),
        child: const Icon(
          Icons.rocket_launch_rounded,
          size: AppDimens.sizeX40,
          color: LightColor.secondaryColor,
        ),
      ),
    );
  }
}

class _DownloadingRow extends StatelessWidget {
  const _DownloadingRow();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    // Play reports the install *stage*, never a byte count, so the bar is
    // indeterminate — it signals liveness, not a percentage.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(
              width: AppDimens.sizeX18,
              height: AppDimens.sizeX18,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: LightColor.secondaryColor,
              ),
            ),
            const SizedBox(width: AppDimens.paddingX10),
            Flexible(
              child: Text(
                StringConstants.downloadingUpdate,
                textAlign: TextAlign.center,
                style: textTheme.bodySubTitle?.copyWith(
                  color: LightColor.secondaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimens.paddingX12),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          child: const LinearProgressIndicator(
            minHeight: 4,
            color: LightColor.secondaryColor,
            backgroundColor: LightColor.inputFillColor,
          ),
        ),
      ],
    );
  }
}
