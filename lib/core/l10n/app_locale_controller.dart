import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/l10n/app_language.dart';
import 'package:hamro_futsal/core/l10n/generated/app_localizations.dart';

/// Holds the app language and the matching [AppLocalizations].
///
/// `StringConstants` reads [strings] so copy can be resolved anywhere — in
/// widgets, blocs and validators alike — without a [BuildContext].
final class AppLocaleController extends ValueNotifier<AppLanguage> {
  AppLocaleController._() : super(_initialLanguage()) {
    _strings = lookupAppLocalizations(value.locale);
  }

  static final AppLocaleController instance = AppLocaleController._();

  late AppLocalizations _strings;

  AppLocalizations get strings => _strings;

  Locale get locale => value.locale;

  @override
  set value(AppLanguage next) {
    _strings = lookupAppLocalizations(next.locale);
    super.value = next;
  }

  /// Applies the stored choice once storage is open (see `main`).
  static void restore() {
    final AppLanguage language = _initialLanguage();
    if (instance.value != language) instance.value = language;
  }

  void setLanguage(AppLanguage next) {
    final AppSettings settings = AppSettings();
    if (settings.isInitialized) settings.appLanguage = next.code;
    if (value == next) return;
    value = next;
    _rebuildEverything();
  }

  /// The saved choice, else the device language when we support it, else
  /// English.
  static AppLanguage _initialLanguage() {
    final AppSettings settings = AppSettings();
    final AppLanguage? stored = settings.isInitialized
        ? AppLanguage.fromCode(settings.appLanguage)
        : null;
    if (stored != null) return stored;
    // dart:ui's dispatcher, not WidgetsBinding: copy may be read before the
    // binding exists (unit tests, early startup).
    for (final Locale locale in PlatformDispatcher.instance.locales) {
      final AppLanguage? device = AppLanguage.fromLocale(locale);
      if (device != null) return device;
    }
    return AppLanguage.english;
  }

  /// Copy comes from [strings], not from an inherited widget, so widgets do
  /// not depend on the locale. Rebuild the whole tree — keeping all state and
  /// the navigation stack — so every visible string switches in one frame.
  static void _rebuildEverything() {
    void markAllDirty() {
      void markDirty(Element element) {
        element.markNeedsBuild();
        element.visitChildren(markDirty);
      }

      final Element? root = WidgetsBinding.instance.rootElement;
      if (root != null) markDirty(root);
    }

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
