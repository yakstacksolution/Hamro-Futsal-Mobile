import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/opponent_match/presentation/utils/opponent_ui_utils.dart';

/// The "Accept within" pill: the label has to say how much time is really
/// left, not the minutes part of it.
void main() {
  test('under an hour stays mm:ss', () {
    expect(
      OpponentFmt.countdown(const Duration(minutes: 55, seconds: 43)),
      '55:43',
    );
    expect(OpponentFmt.countdown(const Duration(seconds: 9)), '00:09');
  });

  test('hours are not dropped', () {
    // 2026-08-22 16:00 seen from 2026-08-21 23:04:17 — the payload's own
    // remaining_seconds of 60943. This used to read '55:43'.
    expect(OpponentFmt.countdown(const Duration(seconds: 60943)), '16:55:43');
    expect(OpponentFmt.countdown(const Duration(hours: 1)), '1:00:00');
  });

  test('past a day the days lead', () {
    expect(
      OpponentFmt.countdown(const Duration(days: 2, hours: 4, minutes: 12)),
      '2d 04:12',
    );
  });

  test('a spent countdown reads as zero', () {
    expect(OpponentFmt.countdown(Duration.zero), '00:00');
    expect(OpponentFmt.countdown(const Duration(seconds: -5)), '00:00');
  });
}
