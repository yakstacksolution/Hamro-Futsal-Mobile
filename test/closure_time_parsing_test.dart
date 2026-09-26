import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/widgets/custom_time_field.dart';

void main() {
  test('reads the time field format and the server format alike', () {
    expect(
      timeOfDayFromString('06 : 00 PM'),
      const TimeOfDay(hour: 18, minute: 0),
    );
    expect(
      timeOfDayFromString('12 : 30 AM'),
      const TimeOfDay(hour: 0, minute: 30),
    );
    expect(
      timeOfDayFromString('06:00'),
      const TimeOfDay(hour: 6, minute: 0),
    );
  });

  test('a picked hourly range compares start before end', () {
    final TimeOfDay start = timeOfDayFromString(
      formatTimeOfDay(const TimeOfDay(hour: 6, minute: 0)),
    )!;
    final TimeOfDay end = timeOfDayFromString('10 : 00 PM')!;
    expect(minutesFromTimeOfDay(start) < minutesFromTimeOfDay(end), isTrue);
  });
}
