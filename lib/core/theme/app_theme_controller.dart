import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';

final class AppThemeController extends ValueNotifier<ThemeMode> {
  AppThemeController._() : super(_initialMode());

  static final AppThemeController instance = AppThemeController._();

  bool get isDark => value == ThemeMode.dark;

  static ThemeMode _initialMode() {
    final AppSettings settings = AppSettings();
    return settings.isInitialized && settings.darkMode
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  void setDarkMode(bool enabled) {
    final ThemeMode next = enabled ? ThemeMode.dark : ThemeMode.light;
    final AppSettings settings = AppSettings();
    if (settings.isInitialized) settings.darkMode = enabled;
    if (value == next) return;
    value = next;
    _rebuildEverything();
  }

  /// Rebuilds the whole widget tree after a brightness change.
  ///
  /// Swapping [ThemeData] only invalidates widgets that actually *depend* on
  /// the `Theme` inherited widget — i.e. the ones calling `Theme.of(context)`
  /// or `context.appColors`. The vast majority of this app reads colours from
  /// `LightColor.*`, which resolves against [instance] rather than a
  /// [BuildContext], so the framework has no dependency to invalidate and never
  /// calls their `build()` again. The result is a half-themed screen until the
  /// app is restarted.
  ///
  /// Marking every element dirty forces each `build()` to re-run and re-read
  /// the new brightness. This deliberately uses [Element.markNeedsBuild] rather
  /// than re-keying the tree: nothing is unmounted, so [State] objects, scroll
  /// offsets, in-progress forms and the navigation stack all survive the
  /// toggle.
  static void _rebuildEverything() {
    void markAllDirty() {
      void markDirty(Element element) {
        element.markNeedsBuild();
        element.visitChildren(markDirty);
      }

      final Element? root = WidgetsBinding.instance.rootElement;
      if (root != null) markDirty(root);
    }

    // Marking synchronously matters: it lands in the SAME frame as the
    // ValueNotifier's own rebuild, so the whole app changes at once. Deferring
    // to a post-frame callback pushed the `LightColor` half a frame behind the
    // `Theme.of(context)` half, which read as the theme changing in two steps.
    //
    // markNeedsBuild() throws if called while the tree is being built, so only
    // go direct in the phases where that cannot be happening. A toggle comes
    // from a gesture callback, which is `idle`, so this is the normal path.
    final SchedulerPhase phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      markAllDirty();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) => markAllDirty());
      SchedulerBinding.instance.ensureVisualUpdate();
    }
  }
}
