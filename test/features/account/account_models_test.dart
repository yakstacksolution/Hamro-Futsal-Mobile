import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/presentation/utils/account_ui_utils.dart';

/// Parsing is pinned against the real server payloads: money arrives with
/// paisa, and `exact_amount_required` means a rounded figure is a rejected
/// request.
void main() {
  group('AccountSummaryModel.fromJson', () {
    final json = <String, dynamic>{
      'available_balance': 11711.99,
      'pending_clearance': 4639.49,
      'cards': {'total_earned': 17820, 'commission': 1468.52, 'settled': 0},
      'actions': {
        'can_request_settlement': true,
        'requestable_amount': 11711.99,
      },
      'sections': [
        {'key': 'breakdown', 'label': 'Futsal breakdown', 'count': 2},
        {'key': 'settlements', 'label': 'Settlements', 'count': 0},
      ],
      'recent_activity': [
        {
          'type': 'booking_payment',
          'title': 'Venue booking payment',
          'reference': 'BK-8ZYZNZLN',
          'date': '2026-10-02',
          'amount': 1275,
          'direction': 'credit',
          'venue_name': 'Dhananjay sport',
        },
        {
          'type': 'platform_commission',
          'title': 'Platform commission',
          'reference': 'BK-8ZYZNZLN',
          'date': '2026-10-02',
          'amount': 108.38,
          'direction': 'debit',
          'venue_name': 'Dhananjay sport',
        },
      ],
    };

    test('keeps paisa on every balance', () {
      final summary = AccountSummaryModel.fromJson(json);

      expect(summary.availableBalance, 11711.99);
      expect(summary.pendingClearance, 4639.49);
      expect(summary.totalCommission, 1468.52);
      expect(summary.totalEarned, 17820);
      expect(summary.totalSettled, 0);
    });

    test('reads the settlement action', () {
      final summary = AccountSummaryModel.fromJson(json);

      expect(summary.settlementEligible, isTrue);
      expect(summary.requestableAmount, 11711.99);
    });

    test('exposes section counts by key', () {
      final summary = AccountSummaryModel.fromJson(json);

      expect(summary.sectionCount('breakdown'), 2);
      expect(summary.sectionCount('settlements'), 0);
      expect(summary.sectionCount('nope'), isNull);
    });

    test('maps activity direction, type and venue', () {
      final entries = AccountSummaryModel.fromJson(json).recentActivity;

      expect(entries, hasLength(2));
      expect(entries.first.type, AccountEntryType.bookingIncome);
      expect(entries.first.isCredit, isTrue);
      expect(entries.first.venueName, 'Dhananjay sport');
      expect(entries.last.type, AccountEntryType.commission);
      expect(entries.last.isCredit, isFalse);
      expect(entries.last.amount, 108.38);
    });

    test('a copyWith carries the new fields through', () {
      final summary = AccountSummaryModel.fromJson(json).copyWith(venues: []);

      expect(summary.requestableAmount, 11711.99);
      expect(summary.sectionCount('breakdown'), 2);
    });
  });

  group('SettlementBreakdownModel.fromResponse', () {
    test('reads per-futsal balances and the count', () {
      final breakdown = SettlementBreakdownModel.fromResponse({
        'data': {
          'items': [
            {
              'venue_id': 1,
              'venue_name': 'Dhananjay sport',
              'address': 'Nagarjun Municipality Nepal',
              'available_balance': 11711.99,
              'pending_clearance': 3385.49,
              'total_earned': 16500,
              'can_request_settlement': true,
            },
            {
              'venue_id': 2,
              'venue_name': 'Dhanawantary Sports',
              'address': 'Kathmandu',
              'available_balance': 0,
              'pending_clearance': 1254,
              'total_earned': 1320,
              'can_request_settlement': false,
            },
          ],
          'count': 2,
        },
      });

      expect(breakdown.count, 2);
      expect(breakdown.venues, hasLength(2));
      expect(breakdown.venues.first.id, 1);
      expect(breakdown.venues.first.availableBalance, 11711.99);
      expect(breakdown.venues.first.location, 'Nagarjun Municipality Nepal');
      expect(breakdown.venues.first.settlementEligible, isTrue);
      expect(breakdown.venues.last.settlementEligible, isFalse);
    });
  });

  group('SettlementPreviewModel.fromResponse', () {
    test('reads a consolidated preview', () {
      final preview = SettlementPreviewModel.fromResponse({
        'data': {
          'scope': 'consolidated',
          'title': 'Request Consolidated Settlement',
          'subtitle': 'All futsals',
          'recipient': {
            'name': 'HamroFutsal',
            'phone': '+977 986-8187579',
            'logo_url': 'https://example.test/logo.png',
          },
          'venue': null,
          'maximum_payable': 11711.99,
          'default_amount': 11711.99,
          'pending_clearance': 4639.49,
          'exact_amount_required': true,
          'accepted_proof_types': ['jpg', 'jpeg', 'png', 'pdf'],
          'proof_max_size_mb': 10,
        },
      });

      expect(preview.isVenueScoped, isFalse);
      expect(preview.venue, isNull);
      expect(preview.title, 'Request Consolidated Settlement');
      expect(preview.subtitle, 'All futsals');
      expect(preview.recipient.name, 'HamroFutsal');
      expect(preview.recipient.phone, '+977 986-8187579');
      expect(preview.maximumPayable, 11711.99);
      expect(preview.defaultAmount, 11711.99);
      expect(preview.exactAmountRequired, isTrue);
      expect(preview.acceptedProofTypes, ['jpg', 'jpeg', 'png', 'pdf']);
      expect(preview.proofMaxBytes, 10 * 1024 * 1024);
      expect(preview.eligible, isTrue);
    });

    test('reads a venue-scoped preview', () {
      final preview = SettlementPreviewModel.fromResponse({
        'data': {
          'scope': 'venue',
          'title': 'Request Settlement',
          'subtitle': 'Dhananjay sport',
          'venue': {
            'id': 1,
            'name': 'Dhananjay sport',
            'address': 'Nagarjun Municipality Nepal',
          },
          'maximum_payable': 11711.99,
          'default_amount': 11711.99,
          'pending_clearance': 3385.49,
          'exact_amount_required': true,
        },
      });

      expect(preview.isVenueScoped, isTrue);
      expect(preview.venue?.id, 1);
      expect(preview.venue?.address, 'Nagarjun Municipality Nepal');
    });

    test('nothing payable is not eligible', () {
      final preview = SettlementPreviewModel.fromResponse({
        'data': {'maximum_payable': 0},
      });

      expect(preview.eligible, isFalse);
    });

    test('falls back to sane proof rules when the server omits them', () {
      final preview = SettlementPreviewModel.fromResponse({
        'data': {'maximum_payable': 500},
      });

      expect(preview.acceptedProofTypes, ['jpg', 'jpeg', 'png', 'pdf']);
      expect(preview.proofMaxSizeMb, 10);
      // No explicit default means the whole payable amount is offered.
      expect(preview.defaultAmount, 500);
    });
  });

  group('SettlementPageModel.fromResponse', () {
    test('reads the summary and an empty first page', () {
      final page = SettlementPageModel.fromResponse(
        {
          'data': {
            'summary': {'pending': 0, 'approved': 0, 'paid': 0, 'rejected': 0},
            'items': <dynamic>[],
            'pagination': {
              'current_page': 1,
              'last_page': 1,
              'per_page': 20,
              'total': 0,
              'has_more_pages': false,
            },
          },
        },
        requestedPage: 1,
        requestedPerPage: 20,
      );

      expect(page.items, isEmpty);
      expect(page.summary.total, 0);
      expect(page.summary.inProgress, 0);
      expect(page.hasMorePages, isFalse);
      expect(page.perPage, 20);
    });

    test('counts in-progress requests from the summary', () {
      final page = SettlementPageModel.fromResponse(
        {
          'data': {
            'summary': {'pending': 1, 'approved': 2, 'paid': 3, 'rejected': 1},
            'items': <dynamic>[],
          },
        },
        requestedPage: 1,
        requestedPerPage: 20,
      );

      expect(page.summary.inProgress, 3);
      expect(page.summary.total, 7);
    });

    test('sorts rows newest first and keeps paisa', () {
      final page = SettlementPageModel.fromResponse(
        {
          'data': {
            'items': [
              {
                'id': 1,
                'amount': 100.5,
                'status': 'pending',
                'created_at': '2026-01-01 10:00:00',
              },
              {
                'id': 2,
                'amount': 11711.99,
                'status': 'paid',
                'venue_id': 1,
                'venue_name': 'Dhananjay sport',
                'transaction_reference': 'txn-9',
                'created_at': '2026-05-01 10:00:00',
              },
            ],
          },
        },
        requestedPage: 1,
        requestedPerPage: 20,
      );

      expect(page.items.first.id, '2');
      expect(page.items.first.amount, 11711.99);
      expect(page.items.first.venueId, 1);
      expect(page.items.first.venueName, 'Dhananjay sport');
      expect(page.items.first.transactionReference, 'txn-9');
      expect(page.items.first.status, SettlementStatus.paid);
    });

    test('infers another page when one comes back full', () {
      final page = SettlementPageModel.fromResponse(
        {
          'data': {
            'items': [
              for (int i = 0; i < 2; i++)
                {'id': i, 'amount': 10, 'status': 'pending'},
            ],
          },
        },
        requestedPage: 1,
        requestedPerPage: 2,
      );

      expect(page.hasMorePages, isTrue);
      expect(page.lastPage, 2);
    });
  });

  group('AccountFmt', () {
    test('shows paisa only when the server sent them', () {
      expect(AccountFmt.npr(11711.99), 'NPR 11,711.99');
      expect(AccountFmt.npr(17820), 'NPR 17,820');
      expect(AccountFmt.npr(0), 'NPR 0');
      expect(AccountFmt.npr(-108.38), '-NPR 108.38');
      expect(AccountFmt.npr(1468.5), 'NPR 1,468.50');
    });

    test('the amount field starts on a plain, ungrouped value', () {
      expect(AccountFmt.amountInput(11711.99), '11711.99');
      expect(AccountFmt.amountInput(1200), '1200');
    });
  });
}
