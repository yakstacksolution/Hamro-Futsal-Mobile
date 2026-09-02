import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/transactions/data/model/transaction_history_model.dart';

void main() {
  group('TransactionHistoryPageModel.fromResponse', () {
    final Map<String, dynamic> response = <String, dynamic>{
      'status': 'success',
      'message': 'Transaction history fetched successfully.',
      'data': <String, dynamic>{
        'filters': <String, dynamic>{'direction': 'all', 'type': 'all'},
        'summary': <String, dynamic>{
          'incoming_total': 14155.48,
          'outgoing_total': 11006,
          'net_total': 3149.48,
          'transaction_count': 11,
        },
        'items': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'booking-26',
            'source': 'booking',
            'direction': 'incoming',
            'title': 'Booking income',
            'reference': 'BK-8ZYZNZLN',
            'amount': 1166.62,
            'gross_amount': 1275,
            'commission_amount': 108.38,
            'status': 'pending_clearance',
            'payment_status': 'partial',
            'booking_status': 'confirmed',
            'transaction_date': '2026-10-02',
            'created_at': '2026-07-16 19:24:06',
            'venue': <String, dynamic>{
              'id': 1,
              'name': 'Dhananjay sport',
              'address': 'Nagarjun Municipality Nepal',
            },
            'meta': <String, dynamic>{'booking_id': 26},
            'sort_at': 1790878500,
          },
          <String, dynamic>{
            'id': 'expense-1',
            'source': 'expense',
            'direction': 'outgoing',
            'title': 'Bill',
            'reference': 'EXP-1',
            'amount': 1000,
            'gross_amount': 1000,
            'commission_amount': 0,
            'status': 'recorded',
            'payment_status': null,
            'booking_status': null,
            'payment_method': 'cash',
            'transaction_date': '2026-06-06',
            'created_at': '2026-06-06 06:24:33',
            'venue': <String, dynamic>{'id': 1, 'name': 'Dhananjay sport'},
            'meta': <String, dynamic>{
              'expense_id': 1,
              'court_id': 3,
              'court_name': null,
              'note': 'Hi',
            },
            'sort_at': 1780683300,
          },
        ],
        'pagination': <String, dynamic>{
          'current_page': 1,
          'last_page': 1,
          'per_page': 20,
          'total': 11,
          'from': 1,
          'to': 11,
          'has_more_pages': false,
        },
      },
    };

    test('reads items out of data.items', () {
      final TransactionHistoryPageModel page =
          TransactionHistoryPageModel.fromResponse(response);
      expect(page.items.length, 2);
    });

    test('signs bookings incoming and expenses outgoing', () {
      final TransactionHistoryPageModel page =
          TransactionHistoryPageModel.fromResponse(response);
      expect(page.items.first.isIncoming, isTrue);
      expect(page.items.last.isIncoming, isFalse);
    });

    test('keeps the composite string id and booking/expense ids from meta', () {
      final TransactionHistoryPageModel page =
          TransactionHistoryPageModel.fromResponse(response);
      expect(page.items.first.id, 'booking-26');
      expect(page.items.first.bookingId, 26);
      expect(page.items.last.expenseId, 1);
      expect(page.items.last.note, 'Hi');
    });

    test('maps the booking row fields', () {
      final TransactionHistoryItemModel item =
          TransactionHistoryPageModel.fromResponse(response).items.first;
      expect(item.source, 'booking');
      expect(item.displayTitle, 'Booking income');
      expect(item.amount, 1166.62);
      expect(item.grossAmount, 1275);
      expect(item.commissionAmount, 108.38);
      expect(item.hasCommission, isTrue);
      expect(item.statusLabel, 'Pending Clearance');
      expect(item.paymentStatusLabel, 'Partial');
      expect(item.venueName, 'Dhananjay sport');
      expect(item.subtitle, 'BK-8ZYZNZLN · Dhananjay sport');
      expect(item.date, DateTime(2026, 10, 2));
    });

    test('an expense has no commission and keeps its payment method', () {
      final TransactionHistoryItemModel item =
          TransactionHistoryPageModel.fromResponse(response).items.last;
      expect(item.hasCommission, isFalse);
      expect(item.paymentMethod, 'cash');
      expect(item.paymentStatusLabel, isEmpty);
      // `court_name` is null in meta even though `court_id` is set.
      expect(item.courtName, isNull);
    });

    test('reads the summary totals', () {
      final TransactionHistorySummaryModel summary =
          TransactionHistoryPageModel.fromResponse(response).summary!;
      expect(summary.incomingTotal, 14155.48);
      expect(summary.outgoingTotal, 11006);
      expect(summary.netTotal, 3149.48);
      expect(summary.transactionCount, 11);
    });

    test('honours has_more_pages over page arithmetic', () {
      final TransactionHistoryPageModel page =
          TransactionHistoryPageModel.fromResponse(response);
      expect(page.page, 1);
      expect(page.total, 11);
      // 1 * 20 < 11 is false anyway, but has_more_pages is the authority.
      expect(page.hasMore, isFalse);
    });

    test('has_more_pages true keeps pagination open on page 1 of 3', () {
      final Map<String, dynamic> multi = <String, dynamic>{
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            <String, dynamic>{'id': 'booking-1', 'amount': 10},
          ],
          'pagination': <String, dynamic>{
            'current_page': 1,
            'last_page': 3,
            'per_page': 20,
            'total': 45,
            'has_more_pages': true,
          },
        },
      };
      expect(TransactionHistoryPageModel.fromResponse(multi).hasMore, isTrue);
    });

    test('an empty payload degrades instead of throwing', () {
      final TransactionHistoryPageModel page =
          TransactionHistoryPageModel.fromResponse(<String, dynamic>{});
      expect(page.items, isEmpty);
      expect(page.summary, isNull);
      expect(page.hasMore, isFalse);
    });
  });
}
