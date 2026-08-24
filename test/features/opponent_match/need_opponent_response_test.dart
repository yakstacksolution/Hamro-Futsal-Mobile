import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/opponent_match/data/model/opponent_match_model.dart';

/// One row of `GET /auth/opponent-requests?tab=need_opponent`, verbatim: a
/// published request whose venue is a platform booking paid half in cash, with
/// that payment still unverified.
Map<String, dynamic> bookingRow() => <String, dynamic>{
  'id': 18,
  'status': 'published',
  'main_step': 4,
  'sub_step': 1,
  'team': <String, dynamic>{
    'id': 9,
    'name': 'BBC Sport Club',
    'roster_size': 2,
  },
  'match_format': <String, dynamic>{
    'id': 1,
    'name': '5v5',
    'players_per_team': 5,
  },
  'opponent_level': <String, dynamic>{'id': 3, 'title': 'Advanced'},
  'preferred_date': '2026-08-22',
  'preferred_time': '17:00:00',
  'preferred_end_time': '18:00:00',
  'venue': <String, dynamic>{
    'source': 'booking',
    'booking': <String, dynamic>{
      'id': 211,
      'user_id': 4,
      'venue_id': 34,
      'vendor_id': 19,
      'booking_code': 'BK-VFJZKC8V',
      'customer_name': 'Dilli Bhandari',
      'customer_phone': '985655336655',
      'customer_email': 'officialdilli1@gmail.com',
      'booking_date': '2026-08-22',
      'start_time': '17:00:00',
      'end_time': '18:00:00',
      'price_per_slot': 1150,
      'subtotal': 1150,
      'advance_amount': 575,
      'payable_now': 575,
      'balance_due_later': 575,
      'total_amount': 1150,
      'payment_status': 'partial',
      'booking_status': 'pending',
      'status': 'pending',
      'venue': <String, dynamic>{'id': 34, 'name': 'Goal zone futsal'},
      'court': <String, dynamic>{'id': 35, 'name': 'Court A'},
      'payments': <dynamic>[
        <String, dynamic>{
          'id': 231,
          'payment_method': 'cash',
          'payment_type': 'cash',
          'amount': 575,
          'status': 'pending',
          'verification_status': 'pending',
          'has_payment_proof': true,
          'payment_proof_url': '/storage/payment-proofs/4/x.jpg',
        },
      ],
      'paid_amount': 0,
      'balance_due': 1150,
    },
  },
  'cost': <String, dynamic>{
    'cost_type': 'result',
    'court_fee_amount': 1150,
    'split_type': 'custom',
    'split_basis': 'result',
    'requesting_team_percent': 80,
    'opponent_team_percent': 20,
    'requesting_team_amount': null,
    'opponent_team_amount': null,
    'winner_pay_percent': null,
    'loser_pay_percent': null,
    'winner_pay_amount': null,
    'loser_pay_amount': null,
    'roster_size_snapshot': 2,
    'per_player_amount': null,
    'list_display': <String, dynamic>{
      'type': 'result',
      'total_amount': 1150,
      'winner_pay_percent': null,
      'loser_pay_percent': null,
      'winner_pay_amount': null,
      'loser_pay_amount': null,
    },
  },
  'message': 'Looking for a friendly competitive futsal match.',
  'published_at': '2026-08-21 22:45:06',
  'expires_at': '2026-08-22 17:00:00',
  'accept_until_at': '2026-08-22 16:00:00',
  'countdown': <String, dynamic>{
    'accept_until_at': '2026-08-22 16:00:00',
    'is_expired': false,
    'remaining_seconds': 60943.046504,
    'formatted': '16:55:43',
  },
  'invitations_summary': <String, dynamic>{
    'pending_count': 0,
    'total_count': 0,
  },
  'created_at': '2026-08-21 21:15:34',
};

void main() {
  group('booking-sourced row', () {
    test('reads the venue, court and booked window from the booking', () {
      final request = OpponentRequestModel.fromJson(bookingRow());

      expect(request.team, 'BBC Sport Club');
      expect(request.venue, contains('Goal zone futsal'));
      expect(request.venue, contains('Court A'));
      expect(request.dateTime, DateTime(2026, 8, 22, 17));
      expect(request.totalFee, 1150);
      expect(request.venueBookingId, '211');
    });

    test('a result-keyed split has no fixed share for either side', () {
      final request = OpponentRequestModel.fromJson(bookingRow());

      expect(request.costType, 'result');
      expect(request.isResultCost, isTrue);
      expect(request.splitBasis, 'result');
      expect(request.requestingTeamPercent, 80);
      expect(request.myPct, isNull);
    });

    test('an unquantified result rule falls back to the stored percentage', () {
      final request = OpponentRequestModel.fromJson(bookingRow());

      // list_display carries nulls on this row, so the sides come from the
      // percentage the cost step saved and the court fee.
      expect(request.loserPayPercent, isNull);
      expect(request.resolvedLoserPercent, 80);
      expect(request.resolvedWinnerPercent, 20);
      expect(request.resolvedLoserAmount, 920);
      expect(request.resolvedWinnerAmount, 230);
    });

    test('list_display wins when the server has quantified the sides', () {
      final Map<String, dynamic> row = bookingRow();
      (row['cost'] as Map<String, dynamic>)['list_display'] = <String, dynamic>{
        'type': 'result',
        'total_amount': 1150,
        'winner_pay_percent': 0,
        'loser_pay_percent': 100,
        'winner_pay_amount': 0,
        'loser_pay_amount': 1150,
      };

      final request = OpponentRequestModel.fromJson(row);

      expect(request.resolvedLoserPercent, 100);
      expect(request.resolvedLoserAmount, 1150);
      // 0 is a real answer here, not "unstated": the winner pays nothing.
      expect(request.resolvedWinnerAmount, 0);
      expect(request.totalFee, 1150);
    });

    test('unverified money is reported apart from paid money', () {
      final payment = OpponentRequestModel.fromJson(
        bookingRow(),
      ).bookingPayment;

      expect(payment, isNotNull);
      expect(payment!.bookingCode, 'BK-VFJZKC8V');
      expect(payment.totalAmount, 1150);
      // The server counts nothing as received yet…
      expect(payment.paidAmount, 0);
      // …though the requester has handed over the advance in cash.
      expect(payment.submittedAmount, 575);
      expect(payment.awaitingVerification, isTrue);
      expect(payment.hasProof, isTrue);
      expect(payment.method, 'cash');
      expect(payment.balanceDue, 1150);
      expect(payment.isFullyPaid, isFalse);
      expect(payment.statusLabel, 'Awaiting payment verification');
    });

    test('a settled booking reports itself as paid in full', () {
      final Map<String, dynamic> row = bookingRow();
      final booking = row['venue']['booking'] as Map<String, dynamic>;
      booking['payment_status'] = 'paid';
      booking['paid_amount'] = 1150;
      booking['balance_due'] = 0;
      (booking['payments'] as List).clear();

      final payment = OpponentRequestModel.fromJson(row).bookingPayment!;

      expect(payment.isFullyPaid, isTrue);
      expect(payment.awaitingVerification, isFalse);
      expect(payment.statusLabel, 'Paid in full');
    });
  });

  group('requester identity', () {
    test('falls back to the linked booking when no requester block', () {
      final request = OpponentRequestModel.fromJson(bookingRow());

      // The list endpoint sends no `requester`; the booking's own user is the
      // requester, and is what the chat action opens a thread with.
      expect(request.requesterUserId, 4);
      expect(request.requesterName, 'Dilli Bhandari');
    });

    test('an explicit requester block still wins', () {
      final Map<String, dynamic> row = bookingRow();
      row['requester'] = <String, dynamic>{'user_id': 77, 'name': 'Sita Rai'};

      final request = OpponentRequestModel.fromJson(row);

      expect(request.requesterUserId, 77);
      expect(request.requesterName, 'Sita Rai');
    });

    test('an external row without a booking names the team instead', () {
      final request = OpponentRequestModel.fromJson(<String, dynamic>{
        'id': 1,
        'status': 'published',
        'team': <String, dynamic>{'id': 16, 'name': 'Team Alpha'},
        'venue': <String, dynamic>{'source': 'external', 'fee_amount': 1500},
      });

      expect(request.requesterUserId, 0);
      expect(request.requesterName, 'Team Alpha');
    });
  });

  group('countdown', () {
    test('the accept window comes from the countdown block', () {
      final request = OpponentRequestModel.fromJson(bookingRow());

      // Not `expires_at` (17:00, the kickoff) — acceptance closes an hour
      // earlier.
      expect(request.acceptDeadline, DateTime(2026, 8, 22, 16));
      expect(request.acceptExpired, isFalse);
      // Fractional seconds floored, not rounded up past the server's figure.
      expect(request.acceptRemaining, const Duration(seconds: 60943));
      // The countdown itself is the timestamp measured against now, so it
      // keeps falling between refreshes instead of restating a fixed figure.
      // Clamped at zero, which is what the fixture's deadline gives once the
      // wall clock has passed it — this assertion used to go negative and fail
      // on any run after 2026-08-22.
      final int left = DateTime(2026, 8, 22, 16)
          .difference(DateTime.now())
          .inSeconds;
      expect(
        request.remainingToAccept.inSeconds,
        closeTo(left.isNegative ? 0 : left, 2),
      );
      expect(request.hasAcceptWindowClosed, isFalse);
    });

    test('an expired countdown closes the window whatever the clock says', () {
      final Map<String, dynamic> row = bookingRow();
      row['countdown'] = <String, dynamic>{
        'accept_until_at': '2126-08-22 16:00:00',
        'is_expired': true,
        'remaining_seconds': 0,
        'formatted': '00:00:00',
      };

      final request = OpponentRequestModel.fromJson(row);

      // The deadline is a century out, so only the server's verdict can be
      // what closes this.
      expect(request.acceptExpired, isTrue);
      expect(request.remainingToAccept, Duration.zero);
      expect(request.hasAcceptWindowClosed, isTrue);
    });

    test('a past accept_until_at closes the window', () {
      final Map<String, dynamic> row = bookingRow();
      row['countdown'] = <String, dynamic>{
        'accept_until_at': '2020-01-01 17:00:00',
        // The server has not swept it yet, so its flag still says open.
        'is_expired': false,
        'remaining_seconds': 0,
        'formatted': '00:00:00',
      };

      final request = OpponentRequestModel.fromJson(row);

      expect(request.remainingToAccept, Duration.zero);
      expect(request.hasAcceptWindowClosed, isFalse);
      // The flag is what the model reports; the deadline is what the ticker
      // measures — both agree there is no time left.
      expect(request.acceptExpired, isFalse);
    });

    test('a row with no countdown still measures against the deadline', () {
      final Map<String, dynamic> row = bookingRow();
      row.remove('countdown');
      row.remove('accept_until_at');
      row['accept_deadline'] = DateTime.now()
          .add(const Duration(minutes: 30))
          .toIso8601String();

      final request = OpponentRequestModel.fromJson(row);

      expect(request.acceptRemaining, isNull);
      expect(request.acceptExpired, isNull);
      expect(request.remainingToAccept.inMinutes, greaterThanOrEqualTo(29));
      expect(request.hasAcceptWindowClosed, isFalse);
    });
  });

  test('an external venue has no booking payment', () {
    final request = OpponentRequestModel.fromJson(<String, dynamic>{
      'id': 1,
      'status': 'published',
      'main_step': 3,
      'team': <String, dynamic>{'id': 16, 'name': 'Team Alpha'},
      'preferred_date': '2026-08-12',
      'preferred_time': '18:00:00',
      'venue': <String, dynamic>{
        'source': 'external',
        'venue_name': 'Green Turf Arena',
        'court_name': 'Court 2',
        'address': 'Kathmandu',
        'date': '2026-08-12',
        'start_time': '18:00:00',
        'end_time': '19:00:00',
        'fee_amount': 1500,
      },
      'cost': <String, dynamic>{
        'court_fee_amount': 1500,
        'split_type': 'custom',
        'split_basis': 'result',
        'requesting_team_percent': 70,
      },
      'accept_until_at': '2026-08-12 17:00:00',
      'countdown': <String, dynamic>{
        'accept_until_at': '2026-08-12 17:00:00',
        'is_expired': true,
        'remaining_seconds': 0,
        'formatted': '00:00:00',
      },
      'invitations_summary': <String, dynamic>{
        'pending_count': 2,
        'total_count': 2,
      },
    });

    expect(request.acceptExpired, isTrue);
    expect(request.hasAcceptWindowClosed, isTrue);
    expect(request.bookingPayment, isNull);
    expect(request.venueSource, 'external');
    expect(request.totalFee, 1500);
    expect(request.invitationCount, 2);
  });
}
