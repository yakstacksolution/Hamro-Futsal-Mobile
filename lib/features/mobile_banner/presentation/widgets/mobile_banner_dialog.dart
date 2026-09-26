import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/routers/link_opener.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/utils/custom_image_view.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/mobile_banner/data/model/mobile_banner_model.dart';
import 'package:hamro_futsal/features/mobile_banner/data/repositories/mobile_banner_repository_impl.dart';
import 'package:hamro_futsal/features/mobile_banner/domain/repository/mobile_banner_repository.dart';

/// How the user left a [MobileBannerDialog].
enum MobileBannerAction {
  /// The close icon: hide it for now, show it again next launch.
  close,

  /// "Don't show again": dismiss it on the server so it never comes back.
  dontShowAgain,
}

/// Fetches the signed-in user's banners and shows them, one full-screen dialog
/// after another. The close icon only hides a banner for this launch; "Don't
/// show again" dismisses it server-side so it does not come back.
abstract final class MobileBannerPresenter {
  /// Once per app launch: the dashboard can be rebuilt (sign out and back in,
  /// returning from onboarding) without the banners popping up again.
  static bool _hasShownThisLaunch = false;

  static Future<void> showIfAny(
    BuildContext context, {
    MobileBannerRepository? repository,
  }) async {
    if (_hasShownThisLaunch || !AppSettings().hasSession) return;
    _hasShownThisLaunch = true;

    final MobileBannerRepository repo =
        repository ?? MobileBannerRepositoryImpl();
    final result = await repo.getMobileBanners();
    // A failed fetch is silent: the banner is a nice-to-have, never a blocker.
    final List<MobileBannerModel> banners = result.fold(
      (_) => const <MobileBannerModel>[],
      (List<MobileBannerModel> banners) => banners,
    );

    for (final MobileBannerModel banner in banners) {
      if (!context.mounted) return;
      // Load the image first so the dialog never opens on a placeholder; a
      // banner whose image cannot load is skipped rather than shown broken.
      final bool loaded = await _precache(context, banner.imageUrl);
      if (!loaded || !context.mounted) continue;
      // Only show over the dashboard itself, not over a screen pushed on top.
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

      final MobileBannerAction? action =
          await showGeneralDialog<MobileBannerAction>(
            context: context,
            barrierDismissible: false,
            barrierColor: Colors.black.withValues(alpha: 0.55),
            transitionDuration: const Duration(milliseconds: 220),
            pageBuilder: (BuildContext dialogContext, _, __) =>
                MobileBannerDialog(banner: banner),
            transitionBuilder:
                (_, Animation<double> animation, __, Widget child) {
                  final Animation<double> curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  return FadeTransition(
                    opacity: curved,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
                      child: child,
                    ),
                  );
                },
          );

      if (action == MobileBannerAction.dontShowAgain) {
        // Fire-and-forget: a failed dismiss just means it shows next launch.
        repo.dismissMobileBanner(banner.id);
      } else if (action != MobileBannerAction.close) {
        // Left some other way (back gesture, tapped through to the link):
        // stop here rather than stacking the rest on top of where they went.
        return;
      }
    }
  }

  static Future<bool> _precache(BuildContext context, String url) async {
    bool ok = true;
    await precacheImage(
      CachedNetworkImageProvider(
        Uri.encodeFull(url),
        cacheManager: customCacheManager,
      ),
      context,
      onError: (_, __) => ok = false,
    );
    return ok;
  }
}

/// The banner image as a centered card over the dimmed dashboard, with a
/// close icon floating over its top-right corner and a "Don't show again"
/// checkbox over the bottom of the image.
///
/// The checkbox only records the choice; the close icon applies it, popping
/// [MobileBannerAction.dontShowAgain] when ticked (the caller then dismisses
/// the banner on the server) and [MobileBannerAction.close] otherwise. Pops
/// null when left through the link.
class MobileBannerDialog extends StatefulWidget {
  const MobileBannerDialog({super.key, required this.banner});

  final MobileBannerModel banner;

  @override
  State<MobileBannerDialog> createState() => _MobileBannerDialogState();
}

class _MobileBannerDialogState extends State<MobileBannerDialog> {
  /// Keeps the card phone-sized on tablets instead of stretching edge to edge.
  static const double _maxCardWidth = 420;

  bool _dontShowAgain = false;

  MobileBannerModel get banner => widget.banner;

  void _close() => Navigator.of(context).pop(
    _dontShowAgain
        ? MobileBannerAction.dontShowAgain
        : MobileBannerAction.close,
  );

  Future<void> _openLink(BuildContext context) async {
    final Uri? uri = Uri.tryParse(banner.link ?? '');
    if (uri == null || !uri.hasScheme) return;
    Navigator.of(context).pop();
    await LinkOpener.open(uri);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasLink = banner.link != null;
    final BorderRadius radius = BorderRadius.circular(AppDimens.radiusX16);

    return Semantics(
      label: banner.title,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingX28,
              vertical: AppDimens.paddingX32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxCardWidth),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Flexible so a tall banner shrinks to fit short screens.
                  Flexible(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: LightColor.qrSurface,
                        borderRadius: radius,
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 24,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: radius,
                        child: Stack(
                          children: <Widget>[
                            // Sized by the image itself: full card width,
                            // natural aspect ratio.
                            GestureDetector(
                              onTap: hasLink ? () => _openLink(context) : null,
                              child: CustomImageView(
                                url: banner.imageUrl,
                                width: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              top: AppDimens.paddingX12,
                              right: AppDimens.paddingX12,
                              child: _CloseButton(onTap: _close),
                            ),
                            // Fades the image's bottom edge to dark so the
                            // white checkbox reads over any artwork. Ignores
                            // taps, which still reach the image's link.
                            const Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: AppDimens.sizeX56,
                              child: IgnorePointer(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: <Color>[
                                        Colors.transparent,
                                        Color(0x8C000000),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: AppDimens.paddingX6,
                              bottom: AppDimens.paddingX6,
                              child: _DontShowAgainCheckbox(
                                value: _dontShowAgain,
                                onChanged: (bool value) =>
                                    setState(() => _dontShowAgain = value),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Translucent dark circle: readable over any banner artwork.
    return Material(
      color: Colors.black.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: AppDimens.sizeX32,
          height: AppDimens.sizeX32,
          child: Icon(
            Icons.close_rounded,
            size: AppDimens.sizeX20,
            color: Colors.white,
            semanticLabel: MaterialLocalizations.of(context).closeButtonLabel,
          ),
        ),
      ),
    );
  }
}

class _DontShowAgainCheckbox extends StatelessWidget {
  const _DontShowAgainCheckbox({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    // Sits on the dark scrim at the image's bottom edge, so it is white on
    // dark in both themes. The whole row is the tap target, not just the box.
    return Semantics(
      checked: value,
      label: StringConstants.dontShowAgain,
      excludeSemantics: true,
      // A general dialog has no Material ancestor for the ink to paint on.
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(AppDimens.radiusX8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimens.paddingX6,
              horizontal: AppDimens.paddingX8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: AppDimens.sizeX18,
                  height: AppDimens.sizeX18,
                  decoration: BoxDecoration(
                    color: value ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimens.radiusX4),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: value
                      ? const Icon(
                          Icons.check_rounded,
                          size: AppDimens.sizeX14,
                          color: LightColor.onQrSurface,
                        )
                      : null,
                ),
                const SizedBox(width: AppDimens.sizeX8),
                Text(
                  StringConstants.dontShowAgain,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
