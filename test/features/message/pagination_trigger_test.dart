import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/message/presentation/utils/pagination_trigger.dart';

void main() {
  final DateTime t0 = DateTime(2026, 9, 14, 10);

  test('scrolling near the end asks for the next page', () {
    final PaginationTrigger trigger = PaginationTrigger();

    expect(
      trigger.allows(userDriven: true, extentAfter: 100, canLoad: true),
      isTrue,
    );
  });

  test('a re-layout never asks for a page', () {
    final PaginationTrigger trigger = PaginationTrigger();

    // This is the loop that walked the endpoint to page 7: the page that just
    // landed leaves the viewport near the end, and the list re-lays itself out
    // — with no scroll gesture behind it.
    for (int i = 0; i < 5; i++) {
      expect(
        trigger.allows(userDriven: false, extentAfter: 10, canLoad: true),
        isFalse,
      );
    }
  });

  test('two scrolls in quick succession ask only once', () {
    final PaginationTrigger trigger = PaginationTrigger();

    expect(
      trigger.allows(userDriven: true, extentAfter: 20, canLoad: true, now: t0),
      isTrue,
    );
    expect(
      trigger.allows(
        userDriven: true,
        extentAfter: 20,
        canLoad: true,
        now: t0.add(const Duration(milliseconds: 100)),
      ),
      isFalse,
      reason: 'the cooldown has not elapsed',
    );
  });

  test('a cooled-down trigger asks again', () {
    final PaginationTrigger trigger = PaginationTrigger();

    expect(
      trigger.allows(userDriven: true, extentAfter: 20, canLoad: true, now: t0),
      isTrue,
    );
    expect(
      trigger.allows(
        userDriven: true,
        extentAfter: 20,
        canLoad: true,
        now: t0.add(const Duration(seconds: 2)),
      ),
      isTrue,
    );
  });

  test('far from the end nothing is asked for', () {
    final PaginationTrigger trigger = PaginationTrigger();

    expect(
      trigger.allows(userDriven: true, extentAfter: 900, canLoad: true),
      isFalse,
    );
  });

  test('a standing error or an in-flight load blocks every trigger', () {
    final PaginationTrigger trigger = PaginationTrigger();

    expect(
      trigger.allows(userDriven: true, extentAfter: 10, canLoad: false),
      isFalse,
    );
  });

  test('a reset clears the cooldown so a new search can load at once', () {
    final PaginationTrigger trigger = PaginationTrigger();

    expect(
      trigger.allows(userDriven: true, extentAfter: 10, canLoad: true, now: t0),
      isTrue,
    );
    trigger.reset();
    expect(
      trigger.allows(
        userDriven: true,
        extentAfter: 10,
        canLoad: true,
        now: t0.add(const Duration(milliseconds: 10)),
      ),
      isTrue,
    );
  });

  test('one fling cannot fetch a run of pages', () {
    final PaginationTrigger trigger = PaginationTrigger();
    DateTime clock = t0;
    int requests = 0;

    // A single fling emits a scroll update roughly every frame — ~50 of them
    // over 800ms — and each one used to qualify on its own.
    for (int frame = 0; frame < 50; frame++) {
      clock = clock.add(const Duration(milliseconds: 16));
      if (trigger.allows(
        userDriven: true,
        extentAfter: 40,
        canLoad: true,
        now: clock,
      )) {
        requests++;
      }
    }

    expect(requests, 1);
  });
}
