import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/date_time/date_time.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/core/utils/date_format.dart';
import 'package:hamro_futsal/core/widgets/custom_date_picker.dart';
import 'package:intl/intl.dart';

void main() {
  late _MemoryPreferences preferences;

  setUpAll(() async {
    preferences = _MemoryPreferences();
    await AppSettings().init(preferences);
  });

  tearDown(() {
    AppCalendarController.instance
      ..setCalendar(AppCalendar.ad)
      ..setScript(CalendarScript.english);
  });

  group('AppDate', () {
    // Nepali New Year 2081 fell on 13 April 2024.
    final DateTime newYear2081 = DateTime(2024, 4, 13);

    test('converts AD to BS and back', () {
      final bs = AppDate.toBs(newYear2081);
      expect((bs.year, bs.month, bs.day), (2081, 1, 1));
      expect(AppDate.dateOnly(AppDate.toAd(bs)), newYear2081);
      expect(AppDate.fromBs(2081), newYear2081);
    });

    test('clamps dates outside the BS calendar instead of asserting', () {
      expect(AppDate.isBsSupported(DateTime(1800)), isFalse);
      expect(AppDate.toBs(DateTime(1800)).year, 1970);
      expect(AppDate.toBs(DateTime(2400)).year, 2250);
    });
  });

  group('AppDateFormat', () {
    final DateTime day = DateTime(2024, 4, 13, 21, 5);

    test('AD keeps the app\'s existing spelling', () {
      expect(AppDateFormat.date(day), 'Apr 13, 2024');
      expect(AppDateFormat.time(day), '9:05 PM');
    });

    test('BS in English letters and in Nepali script', () {
      expect(
        AppDateFormat.date(day, calendar: AppCalendar.bs),
        allOf(contains('2081'), contains(' 1,')),
      );
      final String nepali = AppDateFormat.date(
        day,
        calendar: AppCalendar.bs,
        script: CalendarScript.nepali,
      );
      expect(nepali, contains('२०८१'));
      expect(nepali, isNot(contains('2081')));
    });

    test('follows the saved calendar choice', () {
      AppCalendarController.instance.setCalendar(AppCalendar.bs);
      expect(AppDateFormat.date(day), contains('2081'));
      expect(preferences.getBool('use_nepali_calendar'), isTrue);
      expect(AppDateFormat.dual(day), allOf(contains('BS'), contains('2024')));
    });
  });

  group('AppDateFormat.format', () {
    // Saturday 13 April 2024 = 1 Baishakh 2081.
    final DateTime d = DateTime(2024, 4, 13, 21, 5);
    const List<String> patterns = <String>[
      'd MMM yyyy',
      'dd MMM yyyy, hh:mm a',
      'EEE, d MMM',
      'MMMM yyyy',
      'MMM',
      'd',
      'EEEE',
    ];

    test('AD is exactly intl', () {
      for (final String p in patterns) {
        expect(AppDateFormat.format(d, p), DateFormat(p).format(d), reason: p);
      }
    });

    test('BS writes the Nepali date with full month names', () {
      AppCalendarController.instance.setCalendar(AppCalendar.bs);
      expect(AppDateFormat.format(d, 'd MMM yyyy'), startsWith('1 '));
      expect(AppDateFormat.format(d, 'd MMM yyyy'), endsWith(' 2081'));
      expect(AppDateFormat.format(d, 'd MMM yyyy'), isNot(contains('Apr')));
      // The short-month token reads as a whole word, never "Bai".
      expect(AppDateFormat.monthShort(d).length, greaterThan(3));
      expect(AppDateFormat.format(d, 'EEE, d MMM'), startsWith('Sat, 1 '));
      expect(AppDateFormat.weekdayName(d), 'Saturday');
      expect(AppDateFormat.format(d, 'hh:mm a'), '9:05 PM');
      expect(AppDateFormat.day(d), '1');
      expect(AppDateFormat.year(d), '2081');
    });

    test('BS in Nepali script uses Devanagari digits', () {
      AppCalendarController.instance
        ..setCalendar(AppCalendar.bs)
        ..setScript(CalendarScript.nepali);
      expect(AppDateFormat.year(d), '२०८१');
      expect(AppDateFormat.digits(12), '१२');
      expect(AppDateFormat.weekdayShort(d), 'शनि');
    });
  });

  group('DateFmt follows the calendar', () {
    final DateTime d = DateTime(2024, 4, 13, 9, 31);

    test('AD keeps the existing spelling', () {
      expect(DateFmt.date(d), 'Apr 13, 2024');
      expect(DateFmt.time(d), '9:31 AM');
      expect(DateFmt.sectionDay(d, now: DateTime(2024, 4, 20)), '13 APR 2024');
    });

    test('BS switches date and section headings; adDate stays AD', () {
      AppCalendarController.instance.setCalendar(AppCalendar.bs);
      expect(DateFmt.date(d), contains('2081'));
      expect(DateFmt.adDate(d), 'Apr 13, 2024');
      expect(
        DateFmt.sectionDay(d, now: DateTime(2024, 4, 13)),
        allOf(startsWith('TODAY'), contains('2081')),
      );
    });
  });

  testWidgets('showCustomDatePicker opens the BS calendar and returns AD', (
    WidgetTester tester,
  ) async {
    AppCalendarController.instance.setCalendar(AppCalendar.bs);
    DateTime? picked;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('en'), Locale('ne')],
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async => picked = await showCustomDatePicker(
              context,
              initialDate: DateTime(2024, 4, 13),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The Bikram Sambat calendar, opened on Baisakh 2081.
    expect(find.textContaining('2081'), findsWidgets);
    await tester.tap(find.text('Select'));
    await tester.pumpAndSettle();
    expect(picked, DateTime(2024, 4, 13));
  });

  testWidgets('Nepali script works under the app\'s English-only locales', (
    WidgetTester tester,
  ) async {
    AppCalendarController.instance
      ..setCalendar(AppCalendar.bs)
      ..setScript(CalendarScript.nepali);
    await tester.pumpWidget(
      MaterialApp(
        // As in main.dart: the app itself supports English only.
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const <Locale>[Locale('en')],
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () =>
                showAppDatePicker(context, initialDate: DateTime(2024, 4, 13)),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('२०८१'), findsWidgets);
  });
}

final class _MemoryPreferences implements Preferences {
  final Map<String, Object> values = <String, Object>{};
  int writes = 0;

  @override
  bool containsKey(String key) => values.containsKey(key);

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  double? getDouble(String key) => values[key] as double?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String> getStringList(String key) =>
      (values[key] as List<String>?) ?? <String>[];

  @override
  Future<bool> remove(String key) async {
    writes++;
    return values.remove(key) != null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    writes++;
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> permissions) async {
    writes++;
    values[key] = List<String>.from(permissions);
    return true;
  }
}
