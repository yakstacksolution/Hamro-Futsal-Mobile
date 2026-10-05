import 'package:flutter/widgets.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:nepali_utils/nepali_utils.dart';

/// The calendar systems the app can show and pick dates in.
///
/// Dates are always stored, compared and sent to the API as Gregorian
/// [DateTime]s; the calendar only decides how a date is *shown* and *picked*.
enum AppCalendar {
  /// Gregorian — Anno Domini.
  ad,

  /// Bikram Sambat — Nepal's official calendar.
  bs;

  String get label => switch (this) {
    AppCalendar.ad => 'English (AD)',
    AppCalendar.bs => 'Nepali (BS)',
  };

  /// `AD` / `BS`, for a compact badge beside a date.
  String get shortLabel => switch (this) {
    AppCalendar.ad => 'AD',
    AppCalendar.bs => 'BS',
  };
}

/// The script Bikram Sambat dates are written in.
enum CalendarScript {
  /// `Asoj 17, 2083`.
  english,

  /// `असोज १७, २०८३`.
  nepali;

  String get label => switch (this) {
    CalendarScript.english => 'English letters',
    CalendarScript.nepali => 'नेपाली',
  };

  Language get language => switch (this) {
    CalendarScript.english => Language.english,
    CalendarScript.nepali => Language.nepali,
  };
}

/// The reader's calendar choice.
@immutable
class AppCalendarPreference {
  const AppCalendarPreference({
    this.calendar = AppCalendar.ad,
    this.script = CalendarScript.english,
  });

  final AppCalendar calendar;

  /// Only used for [AppCalendar.bs]; AD dates are always in English.
  final CalendarScript script;

  bool get isBs => calendar == AppCalendar.bs;

  AppCalendarPreference copyWith({
    AppCalendar? calendar,
    CalendarScript? script,
  }) => AppCalendarPreference(
    calendar: calendar ?? this.calendar,
    script: script ?? this.script,
  );

  @override
  bool operator ==(Object other) =>
      other is AppCalendarPreference &&
      other.calendar == calendar &&
      other.script == script;

  @override
  int get hashCode => Object.hash(calendar, script);
}

/// App-wide calendar preference, saved on the device.
///
/// Listen to it (`ValueListenableBuilder`) to redraw dates when the reader
/// switches calendars; every helper in `core/date_time` reads it as the
/// default.
final class AppCalendarController extends ValueNotifier<AppCalendarPreference> {
  AppCalendarController._() : super(_fromStorage());

  static final AppCalendarController instance = AppCalendarController._();

  AppCalendar get calendar => value.calendar;
  CalendarScript get script => value.script;

  /// Applies the saved choice. Call once from `main` after settings are
  /// initialised — this controller is created lazily and may have been built
  /// before storage was open (same reason as `AppThemeController.restore`).
  static void restore() {
    final AppCalendarPreference stored = _fromStorage();
    if (instance.value != stored) instance.value = stored;
    NepaliUtils(stored.script.language);
  }

  void setCalendar(AppCalendar calendar) =>
      _update(value.copyWith(calendar: calendar));

  void setScript(CalendarScript script) =>
      _update(value.copyWith(script: script));

  /// Back to English (AD) without saving anything — on logout, whose
  /// storage has just been cleared. The script is a device preference and
  /// stays.
  void resetToDefault() {
    final AppCalendarPreference next = value.copyWith(
      calendar: AppCalendar.ad,
    );
    if (value == next) return;
    value = next;
    _redrawEverything();
  }

  void _update(AppCalendarPreference next) {
    final AppSettings settings = AppSettings();
    if (settings.isInitialized) {
      settings.useNepaliCalendar = next.isBs;
      settings.appCalendarScript = next.script.name;
    }
    // nepali_utils formats in its own default language when none is passed.
    NepaliUtils(next.script.language);
    if (value == next) return;
    value = next;
    _redrawEverything();
  }

  /// Dates are formatted inside ordinary `build` methods all over the app,
  /// so a calendar switch repaints every widget rather than relying on each
  /// screen to listen — the same approach as a theme switch.
  static void _redrawEverything() {
    final Element? root;
    try {
      root = WidgetsBinding.instance.rootElement;
    } catch (_) {
      return; // No binding yet (start-up, plain unit tests): nothing drawn.
    }
    if (root == null) return;
    void markDirty(Element element) {
      element.markNeedsBuild();
      element.visitChildren(markDirty);
    }

    markDirty(root);
  }

  static AppCalendarPreference _fromStorage() {
    final AppSettings settings = AppSettings();
    if (!settings.isInitialized) return const AppCalendarPreference();
    return AppCalendarPreference(
      calendar: (settings.useNepaliCalendar ?? false)
          ? AppCalendar.bs
          : AppCalendar.ad,
      script:
          CalendarScript.values.asNameMap()[settings.appCalendarScript] ??
          CalendarScript.english,
    );
  }
}
