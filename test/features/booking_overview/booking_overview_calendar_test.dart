import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/date_time/app_calendar.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';
import 'package:hamro_futsal/features/booking_overview/data/model/booking_overview_model.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/models/booking_analytics.dart';
import 'package:hamro_futsal/features/booking_overview/presentation/widgets/booking_overview_common.dart';

/// The booking overview's top line follows the profile's calendar: the
/// server writes it with Gregorian dates, so in the Nepali calendar it is
/// built on the device from the same range.
void main() {
  setUpAll(() async => AppSettings().init(_MemoryPreferences()));
  tearDown(() => AppCalendarController.instance.setCalendar(AppCalendar.ad));

  // 13 – 19 April 2024 = Baishakh 1 – 7, 2081.
  final BookingRange range = BookingRange.fromApi('2024-04-13', '2024-04-19');
  const String serverLine = 'Apr 13 - Apr 19 · 9 bookings · NPR 8,400';

  Future<String> line(WidgetTester tester, {int count = 9}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BookingContextLine(
            range: range,
            count: count,
            revenue: 8400,
            summaryLine: serverLine,
          ),
        ),
      ),
    );
    return tester.widget<Text>(find.byType(Text)).data!;
  }

  testWidgets('English calendar: the server line as sent', (tester) async {
    expect(await line(tester), serverLine);
  });

  testWidgets('Nepali calendar: the same range in BS dates', (tester) async {
    AppCalendarController.instance.setCalendar(AppCalendar.bs);
    final String text = await line(tester);
    expect(text, contains('Baishakh'));
    expect(text, isNot(contains('Apr')));
    expect(text, contains('9 bookings'));
    expect(text, contains('8,400'));
  });

  testWidgets('one booking reads as one', (tester) async {
    AppCalendarController.instance.setCalendar(AppCalendar.bs);
    expect(await line(tester, count: 1), contains('1 booking ·'));
  });

  test('chart buckets that name their day relabel in BS', () {
    final TrendBucket dated = TrendBucket.fromJson(<String, dynamic>{
      'label': 'Apr 13',
      'value': 1200,
      'date': '2024-04-13',
    });
    final TrendBucket named = TrendBucket.fromJson(<String, dynamic>{
      'label': 'Mon',
      'value': 900,
    });
    expect(dated.date, DateTime(2024, 4, 13));
    expect(named.date, isNull);
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
