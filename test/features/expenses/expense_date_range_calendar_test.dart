import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/expenses/presentation/widgets/expense_date_range_sheet.dart';

/// The custom-range sheet draws its month grid in the profile's calendar and
/// always hands back Gregorian dates.
void main() {
  setUpAll(() async => AppSettings().init(_MemoryPreferences()));
  tearDown(() => AppCalendarController.instance.setCalendar(AppCalendar.ad));

  // 13 – 19 April 2024 = Baishakh 1 – 7, 2081.
  final DateTimeRange initial = DateTimeRange(
    start: DateTime(2024, 4, 13),
    end: DateTime(2024, 4, 19),
  );

  /// Opens the sheet; [onPicked] gets what it returns.
  Future<void> open(
    WidgetTester tester, [
    ValueSetter<DateTimeRange?>? onPicked,
  ]) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (BuildContext context) => TextButton(
            onPressed: () async {
              final DateTimeRange? picked = await ExpenseDateRangeSheet.show(
                context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialRange: initial,
              );
              onPicked?.call(picked);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('English calendar: Gregorian month', (tester) async {
    await open(tester);
    expect(find.text('April 2024'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('31'), findsNothing);
  });

  testWidgets('Nepali calendar: BS month, picks return AD dates', (
    tester,
  ) async {
    AppCalendarController.instance.setCalendar(AppCalendar.bs);
    DateTimeRange? picked;
    await open(tester, (DateTimeRange? r) => picked = r);

    expect(find.textContaining('Baishakh'), findsWidgets);
    expect(find.textContaining('2081'), findsOneWidget);
    expect(find.textContaining('April'), findsNothing);
    // Baishakh 2081 has 31 days.
    expect(find.text('31'), findsOneWidget);

    await tester.tap(find.text('10'));
    await tester.tap(find.text('15'));
    await tester.pump();
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    // Baishakh 10 – 15, 2081 = 22 – 27 April 2024.
    expect(picked?.start, DateTime(2024, 4, 22));
    expect(picked?.end, DateTime(2024, 4, 27));
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
