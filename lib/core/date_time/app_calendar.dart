import 'package:flutter/widgets.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:nepali_utils/nepali_utils.dart';

enum AppCalendar {
  ad,

  bs;

  String get label => switch (this) {
    AppCalendar.ad => 'English (AD)',
    AppCalendar.bs => 'Nepali (BS)',
  };

  String get shortLabel => switch (this) {
    AppCalendar.ad => 'AD',
    AppCalendar.bs => 'BS',
  };
}

enum CalendarScript {
  english,

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

@immutable
class AppCalendarPreference {
  const AppCalendarPreference({
    this.calendar = AppCalendar.ad,
    this.script = CalendarScript.english,
  });

  final AppCalendar calendar;

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

final class AppCalendarController extends ValueNotifier<AppCalendarPreference> {
  AppCalendarController._() : super(_fromStorage());

  static final AppCalendarController instance = AppCalendarController._();

  AppCalendar get calendar => value.calendar;
  CalendarScript get script => value.script;

  static void restore() {
    final AppCalendarPreference stored = _fromStorage();
    if (instance.value != stored) instance.value = stored;
    NepaliUtils(stored.script.language);
  }

  void setCalendar(AppCalendar calendar) =>
      _update(value.copyWith(calendar: calendar));

  void setScript(CalendarScript script) =>
      _update(value.copyWith(script: script));

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
