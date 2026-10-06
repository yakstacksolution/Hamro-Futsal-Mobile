import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hamro_futsal/core/routers/app_routers.dart';
import 'package:hamro_futsal/core/routers/deep_link_target.dart';

class DeepLinkService {
  DeepLinkService._();

  static final DeepLinkService instance = DeepLinkService._();

  AppLinks? _appLinks;
  StreamSubscription<Uri>? _subscription;
  DeepLinkTarget? _pending;
  bool _navigationInProgress = false;
  bool _started = false;

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

  bool openInternal(Uri uri) {
    final DeepLinkTarget? target = DeepLinkTarget.parse(uri);
    if (target == null) return false;

    debugPrint('In-app link queued: $target');
    _pending = target;
    flush();
    return true;
  }

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
