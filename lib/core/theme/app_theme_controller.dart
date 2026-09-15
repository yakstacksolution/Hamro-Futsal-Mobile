import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';

final class AppThemeController extends ValueNotifier<ThemeMode> {
  AppThemeController._() : super(_initialMode());

  static final AppThemeController instance = AppThemeController._();

  bool get isDark =>
      value == ThemeMode.dark ||
      (value == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  /// The mode this session started on, before the reader changed anything.
  ///
  /// Only [restore] sets it. Kept so a redundant write is not made on startup:
  /// restoring is not a choice the reader made, and must not look like one.
  static ThemeMode _restored = ThemeMode.system;

  static ThemeMode _initialMode() {
    final AppSettings settings = AppSettings();
    // Settings are usually ready by now, but this is a lazily-created
    // singleton: whoever reads a colour first builds it, and that can happen
    // before storage is open. [restore] is what guarantees the stored choice
    // is applied — see its doc.
    if (!settings.isInitialized) return ThemeMode.system;
    return _modeFromStorage(settings.appThemeMode);
  }

  /// Applies the mode saved on this device.
  ///
  /// Call once from `main`, straight after settings are initialised. The
  /// controller reads storage when it is first built, but it is built lazily —
  /// the first `LightColor.*` read anywhere creates it — so if that happened
  /// before storage was open, it fell back to [ThemeMode.system] and stayed
  /// there for the whole session, even though the reader's choice was sitting
  /// in storage. That is the bug where picking Light, closing the app and
  /// reopening it came back on System.
  ///
  /// Restoring is not a choice, so nothing is written back and no rebuild is
  /// forced: this runs before the first frame.
  static void restore() {
    final AppSettings settings = AppSettings();
    if (!settings.isInitialized) return;
    final ThemeMode stored = _modeFromStorage(settings.appThemeMode);
    _restored = stored;
    if (instance.value != stored) instance.value = stored;
  }

  /// What is actually on disk, whatever this controller currently shows.
  @visibleForTesting
  static ThemeMode get storedMode {
    final AppSettings settings = AppSettings();
    if (!settings.isInitialized) return ThemeMode.system;
    return _modeFromStorage(settings.appThemeMode);
  }

  /// The mode restored at startup — the reader's standing choice.
  @visibleForTesting
  static ThemeMode get restoredMode => _restored;

  void setDarkMode(bool enabled) {
    setThemeMode(enabled ? ThemeMode.dark : ThemeMode.light);
  }

  void setThemeMode(ThemeMode next) {
    final AppSettings settings = AppSettings();
    if (settings.isInitialized) {
      // Written before the early return below, so choosing the mode the app is
      // already showing still records it — picking System on a device that is
      // currently light has to stick.
      settings.appThemeMode = next.name;
      settings.darkMode = next == ThemeMode.dark;
      _restored = next;
    }
    if (value == next) return;
    value = next;
    _rebuildEverything();
  }

  static ThemeMode _modeFromStorage(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
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
