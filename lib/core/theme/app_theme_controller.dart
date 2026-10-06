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

  static void restore() {
    final AppSettings settings = AppSettings();
    if (!settings.isInitialized) return;
    final ThemeMode stored = _modeFromStorage(settings.appThemeMode);
    _restored = stored;
    if (instance.value != stored) instance.value = stored;
  }

  @visibleForTesting
  static ThemeMode get storedMode {
    final AppSettings settings = AppSettings();
    if (!settings.isInitialized) return ThemeMode.system;
    return _modeFromStorage(settings.appThemeMode);
  }

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
