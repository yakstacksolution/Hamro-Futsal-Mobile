import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_routers.dart';
import 'package:hamro_futsal/core/routers/deep_link_target.dart';

/// Opens shared links inside the app.
///
/// Two ways in, both handled: a cold start where the link *is* the launch
/// intent ([AppLinks.getInitialLink]), and a link arriving while the app is
/// already running ([AppLinks.uriLinkStream]).
///
/// Navigation is queued rather than attempted immediately, because a cold
/// start delivers the link before the router has a navigator — the same
/// approach `notification_redirection.dart` takes for FCM taps.
///
/// Resolving the link to a venue is *not* done here: the link becomes a
/// location (`/venues/<slug>?venue=<id>`) and the route behind it fetches the
/// venue. That way a cold-start link the platform hands straight to the
/// router and a link tapped while the app is running end on the same screen.
class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _subscription;
  DeepLinkTarget? _pending;
  bool _navigationInProgress = false;
  bool _started = false;

  /// Begins listening. Safe to call more than once.
  Future<void> start() async {
    if (_started) return;
    _started = true;

    final AppLinks appLinks = _appLinks ??= AppLinks();
    _subscription = appLinks.uriLinkStream.listen(
      handleUri,
      onError: (Object error) => debugPrint('Deep link stream error: $error'),
    );

    try {
      final Uri? initial = await appLinks.getInitialLink();
      if (initial != null) handleUri(initial, isLaunchLink: true);
    } catch (error) {
      debugPrint('Could not read the launch deep link: $error');
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  /// Queues [uri] for navigation, ignoring anything the app does not own.
  ///
  /// [isLaunchLink] marks the URI the app was started with. The router already
  /// opened that one — the platform hands it over as the initial route — so
  /// re-opening it here would stack a second copy of the same page.
  void handleUri(Uri uri, {bool isLaunchLink = false}) {
    final DeepLinkTarget? target = DeepLinkTarget.parse(uri);
    if (target == null) {
      debugPrint('Ignoring unrecognised deep link: $uri');
      return;
    }

    if (isLaunchLink && target == AppRouters.consumedLaunchTarget) {
      debugPrint('Launch deep link already opened by the router: $target');
      return;
    }

    debugPrint('Deep link queued: $target');
    _pending = target;
    flush();
  }

  /// Navigates to whatever is queued, as soon as there is a router to do it
  /// with. Called again from the first frame, so a cold-start link is not lost.
  void flush() {
    final DeepLinkTarget? target = _pending;
    final GoRouter? router = AppRouters.instance;

    if (target == null || router == null || _navigationInProgress) return;

    _pending = null;
    _navigationInProgress = true;

    unawaited(
      _navigate(router, target).whenComplete(() {
        _navigationInProgress = false;
        // A second link can arrive while the first is still opening.
        if (_pending != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => flush());
        }
      }),
    );
  }

  Future<void> _navigate(GoRouter router, DeepLinkTarget target) async {
    switch (target) {
      case VenueDeepLink():
        await router.push<void>(target.location);
    }
  }
}
