import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hamro_footsall/core/routers/root_navigator_key.dart';
import 'package:hamro_footsall/core/theme/app_colors.dart';
import 'package:hamro_footsall/core/theme/futsal_theme.dart';
import 'package:hamro_footsall/core/utils/dimens.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';
import 'package:hamro_footsall/features/app_update/presentation/bloc/app_update_bloc.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/force_update_screen.dart';
import 'package:hamro_footsall/features/app_update/presentation/widgets/update_available_sheet.dart';

/// Wraps the entire app and owns update presentation:
///
/// * runs a check shortly after launch and again whenever the app returns to
///   the foreground (throttled inside the bloc),
/// * shows the dismissible sheet for an optional update, exactly once per check,
/// * layers a non-dismissible wall over everything for a mandatory update,
/// * offers "Restart to install" once a background download has finished.
///
/// Mount it inside `MaterialApp.router`'s `builder` so it sits above every route
/// but below the theme — a forced update then cannot be navigated around.
/// Requires an [AppUpdateBloc] provided above it.
class AppUpdateGate extends StatefulWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  State<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends State<AppUpdateGate>
    with WidgetsBindingObserver {
  /// Small delay so the first frame, splash removal and FCM/token work are not
  /// competing with the version request.
  static const Duration _initialCheckDelay = Duration(milliseconds: 1500);

  bool _isSheetVisible = false;

  /// Held so the pending check is cancelled if the app is torn down first —
  /// otherwise a widget test disposing the tree leaves a live timer behind.
  Timer? _initialCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialCheckTimer = Timer(_initialCheckDelay, () {
      if (!mounted) return;
      context.read<AppUpdateBloc>().add(const CheckAppUpdateEvent());
    });
  }

  @override
  void dispose() {
    _initialCheckTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Catches the common "user updated from the store and came back" case, and
    // picks up a freshly published mandatory release without a cold start.
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AppUpdateBloc>().add(const CheckAppUpdateEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppUpdateBloc, AppUpdateState>(
      listenWhen: (AppUpdateState previous, AppUpdateState current) =>
          previous.promptPending != current.promptPending ||
          previous.status != current.status,
      listener: _handleState,
      builder: (BuildContext context, AppUpdateState state) {
        return Stack(
          children: <Widget>[
            widget.child,
            if (state.shouldBlockApp)
              const Positioned.fill(child: ForceUpdateScreen())
            else if (state.isReadyToInstall)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _InstallReadyBanner(),
              ),
          ],
        );
      },
    );
  }

  void _handleState(BuildContext context, AppUpdateState state) {
    // The wall handles mandatory updates; the sheet is only for optional ones.
    if (!state.promptPending || state.isForced || _isSheetVisible) return;

    final BuildContext? navigatorContext = RootNavigatorKey.key.currentContext;
    if (navigatorContext == null) return;

    final AppUpdateBloc bloc = context.read<AppUpdateBloc>();
    // Consume the prompt before awaiting, so a rebuild mid-animation cannot
    // open a second sheet.
    bloc.add(const AppUpdatePromptShownEvent());
    _isSheetVisible = true;

    showUpdateAvailableSheet(
      context: navigatorContext,
      bloc: bloc,
    ).whenComplete(() => _isSheetVisible = false);
  }
}

/// Persistent bar offering the restart that installs an already-downloaded
/// flexible update. Play requires an explicit user action for this.
class _InstallReadyBanner extends StatelessWidget {
  const _InstallReadyBanner();

  @override
  Widget build(BuildContext context) {
    final textTheme = FutsalTheme.getTextTheme(context);
    final AppUpdateBloc bloc = context.read<AppUpdateBloc>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.paddingX12),
        // Centred and capped: a single-line bar stretched across a tablet
        // reads as a page element rather than a transient notice.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppDimens.updateBannerMaxWidth,
            ),
            child: Material(
              color: LightColor.primaryTextColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: AppDimens.paddingX14,
                  top: AppDimens.paddingX6,
                  right: AppDimens.paddingX6,
                  bottom: AppDimens.paddingX6,
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.check_circle_rounded,
                      color: LightColor.secondaryLight,
                      size: AppDimens.sizeX20,
                    ),
                    const SizedBox(width: AppDimens.paddingX10),
                    Expanded(
                      child: Text(
                        StringConstants.updateDownloaded,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySubTitle?.copyWith(
                          color: LightColor.inverseTextColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimens.paddingX8),
                    TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.paddingX12,
                          vertical: AppDimens.paddingX8,
                        ),
                      ),
                      onPressed: () =>
                          bloc.add(const CompleteFlexibleUpdateEvent()),
                      child: Text(
                        StringConstants.restartToInstall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySubTitle?.copyWith(
                          color: LightColor.secondaryLight,
                          fontWeight: FontWeight.w800,
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
  }
}
