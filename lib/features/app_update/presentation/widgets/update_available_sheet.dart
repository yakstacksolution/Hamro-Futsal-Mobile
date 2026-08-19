import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/app_utils.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_footsall/core/widgets/custom_button.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_update_check.dart';
import 'package:hamro_footsall/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_error_message.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_release_notes.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_version_summary.dart';

/// Shows the dismissible "update available" sheet for an optional update.
///
/// [bloc] is passed explicitly rather than read from [context]: the sheet is
/// opened from the root navigator, which sits above the provider that owns the
/// bloc.
Future<void> showUpdateAvailableSheet({
  required BuildContext context,
  required AppUpdateBloc bloc,
}) {
  return showAppBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    // Swiping away is the same intent as "Later", handled below.
    builder: (BuildContext sheetContext) => BlocProvider<AppUpdateBloc>.value(
      value: bloc,
      child: const UpdateAvailableSheet(),
    ),
  ).whenComplete(() {
    if (bloc.isClosed) return;
    // Swiping the sheet away is the same intent as "Later", so snooze — without
    // it the prompt would return on the next resume. An update already handed to
    // Play is left alone: the download bar takes over from here.
    final AppUpdateState state = bloc.state;
    final bool updateInFlight =
        state.isStartingUpdate || state.isDownloading || state.isReadyToInstall;
    if (!updateInFlight) {
      bloc.add(const SnoozeAppUpdateEvent());
    }
  });
}

class UpdateAvailableSheet extends StatelessWidget {
  const UpdateAvailableSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);

    return BlocBuilder<AppUpdateBloc, AppUpdateState>(
      builder: (BuildContext context, AppUpdateState state) {
        final AppUpdateCheck? check = state.check;
        if (check == null) return const SizedBox.shrink();

        return Center(
          child: ConstrainedBox(
            // Keeps the sheet readable on tablets and desktop, where a
            // full-width sheet would stretch the copy across the screen, and
            // caps the height so a long changelog on a short screen scrolls
            // instead of overflowing.
            constraints: BoxConstraints(
              maxWidth: AppDimens.updateSheetMaxWidth,
              maxHeight:
                  MediaQuery.sizeOf(context).height *
                  AppDimens.updateSheetHeightFactor,
            ),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: AppUtils().getPadding(
                symmetricHorizontal: AppDimens.paddingX20,
                bottom: AppDimens.paddingX8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(AppDimens.paddingX10),
                        decoration: BoxDecoration(
                          color: LightColor.secondaryColor.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimens.radiusX12,
                          ),
                        ),
                        child: const Icon(
                          Icons.system_update_rounded,
                          color: LightColor.secondaryColor,
                          size: AppDimens.sizeX24,
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingX12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              check.manifest?.releaseTitle ??
                                  StringConstants.updateAvailable,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.headingSubTitle?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: LightColor.primaryTextColor,
                              ),
                            ),
                            const SizedBox(height: AppDimens.paddingX2),
                            Text(
                              StringConstants.newVersionAvailableMessage,
                              style: textTheme.bodySubTitle?.copyWith(
                                color: LightColor.secondaryTextColor,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingX16),
                  UpdateVersionSummary(check: check),
                  UpdateReleaseNotes(notes: check.releaseNotes),
                  if (state.isDownloading ||
                      state.isReadyToInstall) ...<Widget>[
                    const SizedBox(height: AppDimens.paddingX16),
                    _DownloadStatus(state: state),
                  ],
                  if (state.errorMessage != null) ...<Widget>[
                    const SizedBox(height: AppDimens.paddingX12),
                    UpdateErrorMessage(message: state.errorMessage!),
                  ],
                  const SizedBox(height: AppDimens.paddingX20),
                  _SheetActions(state: state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({required this.state});

  final AppUpdateState state;

  @override
  Widget build(BuildContext context) {
    final AppUpdateBloc bloc = context.read<AppUpdateBloc>();

    // Once the background download has finished, the only meaningful action is
    // restarting to install it.
    final bool readyToInstall = state.isReadyToInstall;
    final String primaryLabel = readyToInstall
        ? StringConstants.restartToInstall
        : StringConstants.updateNow;

    return Row(
      children: <Widget>[
        Expanded(
          child: CustomButton(
            text: StringConstants.later,
            isOutlined: true,
            foregroundColor: LightColor.secondaryTextColor,
            borderColor: LightColor.dividerColor,
            onPressed: () {
              bloc.add(const SnoozeAppUpdateEvent());
              Navigator.of(context).maybePop();
            },
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          flex: 2,
          child: CustomButton(
            text: primaryLabel,
            icon: readyToInstall
                ? Icons.restart_alt_rounded
                : Icons.download_rounded,
            isLoading: state.isStartingUpdate,
            onPressed: () {
              if (readyToInstall) {
                bloc.add(const CompleteFlexibleUpdateEvent());
                return;
              }
              bloc.add(const StartAppUpdateEvent());
              // The Play flexible flow keeps the user in the app, so the sheet
              // stays open to show progress. A store redirect leaves the app
              // anyway, and the sheet is behind it.
              if (!(state.check?.canUsePlayFlow ?? false)) {
                Navigator.of(context).maybePop();
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DownloadStatus extends StatelessWidget {
  const _DownloadStatus({required this.state});

  final AppUpdateState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final bool ready = state.isReadyToInstall;

    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingX12),
      decoration: BoxDecoration(
        color: ready
            ? LightColor.secondaryColor.withValues(alpha: 0.08)
            : LightColor.inputFillColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX10),
      ),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: AppDimens.sizeX20,
            height: AppDimens.sizeX20,
            child: ready
                ? const Icon(
                    Icons.check_circle_rounded,
                    size: AppDimens.sizeX20,
                    color: LightColor.secondaryColor,
                  )
                : const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: LightColor.secondaryColor,
                  ),
          ),
          const SizedBox(width: AppDimens.paddingX12),
          Expanded(
            child: Text(
              ready
                  ? StringConstants.updateReadyMessage
                  : StringConstants.updateInBackgroundHint,
              style: textTheme.bodySubTitle?.copyWith(
                color: LightColor.primaryTextColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
