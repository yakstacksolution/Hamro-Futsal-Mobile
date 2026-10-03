import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/kathmandu_time.dart';
import 'package:hamro_futsal/features/bookings/data/model/booking_model.dart';
import 'package:hamro_futsal/features/bookings/domain/repository/booking_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/data/model/court_availability_slots_model.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';
import 'package:hamro_futsal/features/vendor_operations/presentation/bloc/vendor_ops_bloc.dart';

final DateTime _week = DateTime(2026, 9, 27); // Sunday
final DateTime _today = DateTime(2026, 9, 26);

const OpsCourt _court = OpsCourt(
  id: 6,
  venueId: 1,
  venueName: 'Dhananjay sport',
  name: 'Shidartha',
  openMinute: 6 * 60,
  closeMinute: 8 * 60,
  basePrice: 1200,
);

OpsCourtWeekAvailability _parse(dynamic payload) =>
    CourtAvailabilitySlotsModel.fromResponse(
      payload,
      courtId: 6,
      weekStart: _week,
    );

void main() {
  group('staging response', () {
    // A real `court-availability-slots?type=week` answer for court 14, taken
    // on Sunday 27 Sep 2026 (Tue–Fri trimmed; `grid` cut to one cell).
    final dynamic staging = jsonDecode(
      File(
        'test/vendor_operations/fixtures/court_availability_slots_week.json',
      ).readAsStringSync(),
    );
    const OpsCourt court14 = OpsCourt(
      id: 14,
      venueId: 2,
      venueName: 'Dhanawantary Sports',
      name: 'Court 1',
      basePrice: 1200,
    );

    test('reads days[].slots[], not the grid, with past slots as past', () {
      final OpsCourtWeekAvailability w =
          CourtAvailabilitySlotsModel.fromResponse(
            staging,
            courtId: 14,
            weekStart: _week,
          );
      expect(w.days.keys, <String>['2026-09-27', '2026-09-28', '2026-10-03']);
      for (final List<OpsServerSlot> day in w.days.values) {
        expect(day.map((OpsServerSlot s) => (s.start, s.end)), <(int, int)>[
          (360, 420),
          (720, 780),
        ]);
      }
      // `status: unavailable` but `cell_type: past`.
      expect(
        w.days['2026-09-27']!.map((OpsServerSlot s) => s.state),
        everyElement(OpsServerSlotState.past),
      );
      final OpsServerSlot mon = w.days['2026-09-28']!.first;
      expect(mon.state, OpsServerSlotState.available);
      expect(mon.price, 1200);
      expect(mon.reason, isNull);
    });

    test('draws the table the way the server does', () {
      final OpsWeekTable t = buildWeekTable(
        court: court14,
        bookings: const <BookingModel>[],
        weekStart: _week,
        today: _week,
        nowMinute: 13 * 60 + 30,
        server: CourtAvailabilitySlotsModel.fromResponse(
          staging,
          courtId: 14,
          weekStart: _week,
        ),
      );
      expect(t.live, isTrue);
      expect(t.rows, <int>[360, 720]);
      expect(t.endOf(720), 780);
      // Sunday (today): both past.
      expect(t.cells[0][0].kind, OpsCellKind.past);
      expect(t.cells[1][0].kind, OpsCellKind.past);
      // Monday and Saturday: free at Rs 1200.
      for (final int d in <int>[1, 6]) {
        expect(t.cells[0][d].kind, OpsCellKind.available);
        expect(t.cells[0][d].cell!.price, 1200);
      }
      expect(t.freeCount, 4);
    });
  });

  group('CourtAvailabilitySlotsModel.fromDayResponse', () {
    final DateTime day = DateTime(2026, 9, 28);
    OpsDayAvailability
    parseDay() => CourtAvailabilitySlotsModel.fromDayResponse(
      jsonDecode(
        File(
          'test/vendor_operations/fixtures/court_availability_slots_day.json',
        ).readAsStringSync(),
      ),
      date: day,
    );

    test('reads days[].slots once, not again from the flat slots', () {
      // The fixture repeats each court's slots under `days` and `slots`.
      expect(parseDay().slots[6]!.days['2026-09-28'], hasLength(3));
    });

    test('falls back to the flat slots when there are no days', () {
      final OpsDayAvailability parsed =
          CourtAvailabilitySlotsModel.fromDayResponse(<String, dynamic>{
            'data': <String, dynamic>{
              'venues': <dynamic>[
                <String, dynamic>{
                  'id': 2,
                  'name': 'Dhanawantary Sports',
                  'courts': <dynamic>[
                    <String, dynamic>{
                      'id': 14,
                      'venue_id': 2,
                      'name': 'Court 1',
                      'slots': <dynamic>[
                        <String, dynamic>{
                          'date': '2026-09-29',
                          'start_time': '12:00:00',
                          'end_time': '13:00:00',
                          'status': 'available',
                          'cell_type': 'available',
                          'price': 1200,
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          }, date: DateTime(2026, 9, 29));
      expect(
        parsed.slots[14]!.days['2026-09-29']!.single.state,
        OpsServerSlotState.available,
      );
    });

    test('a booked slot keeps its booking and payment', () {
      final OpsDayAvailability parsed =
          CourtAvailabilitySlotsModel.fromDayResponse(<String, dynamic>{
            'data': <String, dynamic>{
              'socket_channels': <String>[
                'private-vendor.4.booking.2026-09-29',
              ],
              'venues': <dynamic>[
                <String, dynamic>{
                  'id': 2,
                  'name': 'Dhanawantary Sports',
                  'courts': <dynamic>[
                    <String, dynamic>{
                      'id': 14,
                      'venue_id': 2,
                      'name': 'Court 1',
                      'days': <dynamic>[
                        <String, dynamic>{
                          'date': '2026-09-29',
                          'slots': <dynamic>[
                            <String, dynamic>{
                              'venue_id': 2,
                              'court_id': 14,
                              'date': '2026-09-29',
                              'start_time': '06:00:00',
                              'end_time': '07:00:00',
                              'status': 'booked',
                              'reason': 'booking_confirmed',
                              'cell_type': 'booked',
                              'cell_title': 'Test Customer',
                              'booking': <String, dynamic>{
                                'id': 528,
                                'booking_code': 'BK-TEST0002',
                                'booking_status': 'confirmed',
                                'payment_status': 'paid',
                                'booking_type': 'manual',
                                'customer_name': 'Test Customer',
                                'booking_date': '2026-09-29',
                                'start_time': '06:00:00',
                                'end_time': '07:00:00',
                                'total_amount': 1200,
                                'paid_amount': 1200,
                                'balance_due': 0,
                                'venue': <String, dynamic>{'id': 2},
                                'court': <String, dynamic>{'id': 14},
                                'user': null,
                                'slots': <dynamic>[
                                  <String, dynamic>{
                                    'id': 529,
                                    'date': '2026-09-29',
                                    'start_time': '06:00:00',
                                    'end_time': '07:00:00',
                                    'price': 1200,
                                    'status': 'confirmed',
                                  },
                                ],
                                'payments': <dynamic>[
                                  <String, dynamic>{
                                    'id': 602,
                                    'payment_method': 'cash',
                                    'amount': 1200,
                                    'status': 'success',
                                  },
                                ],
                              },
                            },
                          ],
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          }, date: DateTime(2026, 9, 29));
      final OpsServerSlot slot = parsed.slots[14]!.days['2026-09-29']!.single;
      expect(slot.state, OpsServerSlotState.booked);
      expect(slot.booking!.id, 528);
      expect(paymentStateOf(slot.booking!), OpsPaymentState.paid);
      expect(parsed.bookings.single.id, 528);
    });

    test('reads every court of every venue, with its venue', () {
      final OpsDayAvailability parsed = parseDay();
      expect(
        parsed.courts.map((OpsCourt c) => (c.id, c.venueId, c.venueName)),
        <(int, int, String)>[
          (6, 1, 'Dhananjay sport'),
          (14, 2, 'Dhanawantary Sports'),
          (33, 2, 'Dhanawantary Sports'),
          (35, 34, 'Goal zone futsal'),
        ],
      );
      expect(parsed.courts.first.name, 'Shidartha');
      expect(parsed.courts.first.basePrice, 1200);
      expect(parsed.courts.first.slotMinutes, 60);
      final Map<int, OpsCourtWeekAvailability> byCourt = parsed.slots;
      expect(byCourt.keys, unorderedEquals(<int>[6, 14, 33, 35]));
      final OpsCourtWeekAvailability shidartha = byCourt[6]!;
      expect(shidartha.type, OpsAvailabilityResponseType.day);
      expect(shidartha.key, '6|2026-09-28|day');
      expect(
        shidartha.days['2026-09-28']!.map(
          (OpsServerSlot s) => (s.start, s.state, s.price),
        ),
        <(int, OpsServerSlotState, double?)>[
          (6 * 60, OpsServerSlotState.past, null),
          (20 * 60 + 33, OpsServerSlotState.available, 1200),
          (22 * 60 + 34, OpsServerSlotState.available, 1200),
        ],
      );
    });

    test('a court with no slots has an empty day', () {
      expect(parseDay().slots[33]!.days, <String, List<OpsServerSlot>>{
        '2026-09-28': const <OpsServerSlot>[],
      });
    });

    test('a past slot carrying a booking is booked, with the booking', () {
      final OpsDayAvailability parsed = parseDay();
      final OpsServerSlot slot = parsed.slots[35]!.days['2026-09-28']!.last;
      expect(parsed.bookings.map((BookingModel b) => b.id), <int>[408]);
      expect(slot.state, OpsServerSlotState.booked);
      expect(slot.bookingId, 408);
      final BookingModel booking = slot.booking!;
      expect(booking.courtId, 35);
      expect(booking.venueId, 34);
      expect(bookingIntervalsOn(booking, '2026-09-28'), <(int, int)>[
        (17 * 60, 18 * 60),
      ]);
    });

    test('the Day board opens a booking only the server sent', () {
      final OpsBoard board = buildOpsBoard(
        courts: const <OpsCourt>[
          OpsCourt(
            id: 35,
            venueId: 34,
            venueName: 'Goal zone futsal',
            name: 'Court A',
          ),
        ],
        bookings: const <BookingModel>[],
        date: day,
        today: day,
        nowMinute: 20 * 60,
        server: <int, OpsCourtWeekAvailability>{35: parseDay().slots[35]!},
      );
      final List<OpsCell> cells = board.venues.single.courts.single.cells;
      expect(cells.map((OpsCell c) => (c.start, c.kind)), <(int, OpsCellKind)>[
        (16 * 60, OpsCellKind.past),
        (17 * 60, OpsCellKind.booked),
      ]);
      expect(cells.last.booking!.id, 408);
    });
  });

  group('CourtAvailabilitySlotsModel', () {
    test('uses the selected date for a day response with undated slots', () {
      final DateTime day = DateTime(2026, 9, 29);
      final OpsCourtWeekAvailability w =
          CourtAvailabilitySlotsModel.fromResponse(
            <String, dynamic>{
              'status': 'success',
              'data': <String, dynamic>{
                'slots': <dynamic>[
                  <String, dynamic>{
                    'start_time': '18:00:00',
                    'end_time': '19:00:00',
                    'status': 'available',
                  },
                ],
              },
            },
            courtId: 6,
            start: day,
            type: OpsAvailabilityResponseType.day,
          );

      expect(w.key, '6|2026-09-29');
      expect(w.days.keys, <String>['2026-09-29']);
      expect(w.days['2026-09-29']!.single.start, 18 * 60);
    });

    test('reads a list of days, each with its slots', () {
      final OpsCourtWeekAvailability w = _parse(<String, dynamic>{
        'status': 'success',
        'data': <String, dynamic>{
          'days': <dynamic>[
            <String, dynamic>{
              'date': '2026-09-27',
              'slots': <dynamic>[
                <String, dynamic>{
                  'start_time': '07:00:00',
                  'end_time': '08:00:00',
                  'status': 'booked',
                  'booking_id': 471,
                },
                <String, dynamic>{
                  'start_time': '06:00:00',
                  'end_time': '07:30:00',
                  'status': 'available',
                  'price': '1,500.00',
                },
              ],
            },
            <String, dynamic>{'date': '2026-09-28', 'slots': <dynamic>[]},
          ],
        },
      });
      expect(w.days.keys, <String>['2026-09-27', '2026-09-28']);
      final List<OpsServerSlot> sun = w.days['2026-09-27']!;
      expect(sun.map((OpsServerSlot s) => s.start), <int>[360, 420]);
      expect(sun.first.end, 450);
      expect(sun.first.state, OpsServerSlotState.available);
      expect(sun.first.price, 1500);
      expect(sun.last.state, OpsServerSlotState.booked);
      expect(sun.last.bookingId, 471);
      expect(w.days['2026-09-28'], isEmpty);
    });

    test('a booked slot takes its booking id and the server\'s title', () {
      final OpsServerSlot s = _parse(<String, dynamic>{
        'data': <String, dynamic>{
          'days': <dynamic>[
            <String, dynamic>{
              'date': '2026-09-28',
              'slots': <dynamic>[
                <String, dynamic>{
                  'start_time': '06:00:00',
                  'end_time': '07:00:00',
                  'status': 'unavailable',
                  'cell_type': 'booked',
                  'cell_title': 'Dibya',
                  'booking': <String, dynamic>{'id': 481},
                },
                <String, dynamic>{
                  'start_time': '07:00:00',
                  'end_time': '08:00:00',
                  'status': 'held',
                  'held_by_me': true,
                },
              ],
            },
          ],
        },
      }).days['2026-09-28']!.first;
      expect(s.state, OpsServerSlotState.booked);
      expect(s.bookingId, 481);
      expect(s.reason, 'Dibya');
    });

    test('a slot this vendor holds stays bookable', () {
      final OpsServerSlot s = _parse(<String, dynamic>{
        'data': <String, dynamic>{
          'days': <dynamic>[
            <String, dynamic>{
              'date': '2026-09-28',
              'slots': <dynamic>[
                <String, dynamic>{
                  'start_time': '07:00:00',
                  'status': 'held',
                  'cell_type': 'held',
                  'held_by_me': true,
                },
              ],
            },
          ],
        },
      }).days['2026-09-28']!.single;
      expect(s.state, OpsServerSlotState.available);
    });

    test('reads a date → slots map', () {
      final OpsCourtWeekAvailability w = _parse(<String, dynamic>{
        'data': <String, dynamic>{
          '2026-09-29': <dynamic>[
            <String, dynamic>{
              'start_time': '06:00',
              'end_time': '07:00',
              'is_available': false,
              'reason': 'Maintenance',
            },
          ],
        },
      });
      final OpsServerSlot s = w.days['2026-09-29']!.single;
      expect(s.state, OpsServerSlotState.closed);
      expect(s.reason, 'Maintenance');
    });

    test('reads one flat list of slots that carry their own date', () {
      final OpsCourtWeekAvailability w = _parse(<String, dynamic>{
        'data': <dynamic>[
          <String, dynamic>{
            'date': '2026-09-30',
            'start_time': '2026-09-30 06:00:00',
            'end_time': '2026-09-30 07:00:00',
            'status': 'on hold',
          },
        ],
      });
      expect(w.days['2026-09-30']!.single.state, OpsServerSlotState.held);
      expect(w.days['2026-09-30']!.single.start, 360);
    });
  });

  group('buildWeekTable with server slots', () {
    test('a reported day follows the server; other days the schedule', () {
      final OpsWeekTable t = buildWeekTable(
        court: _court,
        bookings: const <BookingModel>[],
        weekStart: _week,
        today: _today,
        nowMinute: 0,
        server: _parse(<String, dynamic>{
          'data': <String, dynamic>{
            'days': <dynamic>[
              <String, dynamic>{
                'date': '2026-09-27',
                'slots': <dynamic>[
                  <String, dynamic>{
                    'start_time': '06:00',
                    'end_time': '07:00',
                    'status': 'available',
                    'price': 900,
                  },
                  <String, dynamic>{
                    'start_time': '07:00',
                    'end_time': '08:00',
                    'status': 'on_hold',
                  },
                ],
              },
              <String, dynamic>{'date': '2026-09-28', 'slots': <dynamic>[]},
            ],
          },
        }),
      );
      expect(t.live, isTrue);
      expect(t.rows, <int>[360, 420]);
      expect(t.endOf(360), 420);
      // Sunday: from the server.
      expect(t.cells[0][0].kind, OpsCellKind.available);
      expect(t.cells[0][0].cell!.price, 900);
      expect(t.cells[1][0].kind, OpsCellKind.closed);
      expect(t.cells[1][0].note, 'On hold');
      // Monday: the server reported no slots.
      expect(t.closedDays[1], 'No slots');
      // Tuesday: not reported, the court's own schedule.
      expect(t.cells[0][2].kind, OpsCellKind.available);
      expect(t.cells[0][2].cell!.price, 1200);
    });

    test('a server week for another court is ignored', () {
      final OpsWeekTable t = buildWeekTable(
        court: _court,
        bookings: const <BookingModel>[],
        weekStart: _week,
        today: _today,
        nowMinute: 0,
        server: OpsCourtWeekAvailability(
          courtId: 99,
          weekStart: _week,
          days: const <String, List<OpsServerSlot>>{
            '2026-09-27': <OpsServerSlot>[],
          },
        ),
      );
      expect(t.live, isFalse);
      expect(t.closedDays, isEmpty);
    });
  });

  group('VendorOpsBloc', () {
    setUp(
      () =>
          KathmanduClock.debugSetUtcNow(() => DateTime.utc(2026, 9, 27, 4, 15)),
    );
    tearDown(() => KathmanduClock.debugSetUtcNow(null));

    test('the Day board loads every court in one call; the Week table asks '
        'for its court\'s week', () async {
      final _Repo repo = _Repo();
      final VendorOpsBloc bloc = VendorOpsBloc(repository: repo)
        ..add(const VendorOpsStarted());
      await pumpEventQueue();

      // Day view: one `type=day` call answers for every court, and the
      // Week table's court's week is prefetched behind it.
      expect(repo.dayCalls, <String>['2026-09-27']);
      expect(repo.calls, <(int, int, String)>[(1, 6, '2026-09-27')]);
      expect(bloc.state.daySlotsFor(6, _week), isNotNull);
      expect(bloc.state.daySlotsFor(7, _week), isNotNull);
      // A day answer is not mistaken for the week starting that day.
      expect(bloc.state.weekSlotsFor(7, _week), isNull);

      // Week view: opens on the prefetched week, no new call; back to it
      // later, no new call either.
      bloc.add(const VendorOpsViewChanged(OpsAvailabilityView.week));
      await pumpEventQueue();
      expect(repo.calls, <(int, int, String)>[(1, 6, '2026-09-27')]);
      bloc.add(const VendorOpsWeekCourtChanged(7));
      await pumpEventQueue();
      bloc.add(const VendorOpsWeekCourtChanged(6));
      await pumpEventQueue();
      expect(repo.calls, hasLength(2));

      // Next week in the Week view: only the shown court.
      bloc.add(VendorOpsDateChanged(DateTime(2026, 10, 4)));
      await pumpEventQueue();
      expect(repo.calls, hasLength(3));
      expect(repo.calls.last, (1, 6, '2026-10-04'));
      expect(repo.dayCalls, hasLength(1));
      await bloc.close();
    });

    test('a court drawn from its server week on the Day board', () async {
      final VendorOpsBloc bloc = VendorOpsBloc(repository: _Repo(slots: true))
        ..add(const VendorOpsStarted());
      await pumpEventQueue();
      final OpsCourtRow row = bloc.state.board!.venues.single.courts.firstWhere(
        (OpsCourtRow r) => r.court.id == 7,
      );
      // Court 7 has 6:00–8:00 of its own; the server says 18:00–19:00.
      expect(
        row.cells.map((OpsCell c) => (c.start, c.kind)),
        <(int, OpsCellKind)>[(1080, OpsCellKind.available)],
      );
      await bloc.close();
    });
  });
}

class _NoBookings implements BookingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Repo extends VendorOpsRepository {
  _Repo({this.slots = false}) : super(bookingRepository: _NoBookings());

  /// Answer with one 18:00–19:00 free slot on every day, instead of nothing.
  final bool slots;
  final List<(int, int, String)> calls = <(int, int, String)>[];

  /// Dates the Day board asked for, one `type=day` call each.
  final List<String> dayCalls = <String>[];

  static const List<OpsServerSlot> _evening = <OpsServerSlot>[
    OpsServerSlot(start: 1080, end: 1140, state: OpsServerSlotState.available),
  ];

  static const List<OpsCourt> _courts = <OpsCourt>[
    _court,
    OpsCourt(
      id: 7,
      venueId: 1,
      venueName: 'Dhananjay sport',
      name: 'Court 2',
      openMinute: 6 * 60,
      closeMinute: 8 * 60,
    ),
  ];

  @override
  Future<Either<AppException, OpsDayAvailability>> loadDay(
    DateTime date,
  ) async {
    dayCalls.add(isoDate(date));
    return right(
      OpsDayAvailability(
        date: date,
        courts: _courts,
        slots: <int, OpsCourtWeekAvailability>{
          for (final OpsCourt c in _courts)
            c.id: OpsCourtWeekAvailability(
              courtId: c.id,
              weekStart: date,
              type: OpsAvailabilityResponseType.day,
              days: <String, List<OpsServerSlot>>{
                if (slots) isoDate(date): _evening,
              },
            ),
        },
      ),
    );
  }

  @override
  Future<Either<AppException, List<BookingModel>>> loadBookingsBetween(
    DateTime from,
    DateTime to,
  ) async => right(const <BookingModel>[]);

  @override
  Future<Either<AppException, OpsCourtWeekAvailability>> loadCourtWeekSlots({
    required int venueId,
    required int courtId,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) async {
    calls.add((venueId, courtId, isoDate(start)));
    return right(
      OpsCourtWeekAvailability(
        courtId: courtId,
        weekStart: start,
        days: <String, List<OpsServerSlot>>{
          if (slots)
            for (int d = 0; d < 7; d++)
              isoDate(
                DateTime(start.year, start.month, start.day + d),
              ): const <OpsServerSlot>[
                OpsServerSlot(
                  start: 1080,
                  end: 1140,
                  state: OpsServerSlotState.available,
                ),
              ],
        },
      ),
    );
  }
}
