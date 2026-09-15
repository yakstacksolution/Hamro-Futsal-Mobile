import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';

/// The live `/auth/settlement-recent-activity` shape: credit/debit pairs that
/// share a reference, a date and a `created_at`, and carry no `id`.
Map<String, dynamic> _row({
  required String type,
  required String title,
  required String reference,
  required num amount,
  required String direction,
  String venue = 'Dhanawantary Sports',
  String date = '2026-09-14 06:00:00',
  String createdAt = '2026-09-12 19:57:03',
}) => <String, dynamic>{
  'type': type,
  'title': title,
  'reference': reference,
  'date': date,
  'created_at': createdAt,
  'amount': amount,
  'direction': direction,
  'venue_name': venue,
};

void main() {
  group('recent activity page', () {
    final Map<String, dynamic> response = <String, dynamic>{
      'status': 'success',
      'message': 'Recent activity fetched successfully.',
      'data': <String, dynamic>{
        'venue_id': null,
        'items': <Map<String, dynamic>>[
          _row(
            type: 'booking_payment',
            title: 'Venue booking payment',
            reference: 'BK-TRJSQE1T',
            amount: 1200,
            direction: 'credit',
          ),
          _row(
            type: 'platform_commission',
            title: 'Platform commission',
            reference: 'BK-TRJSQE1T',
            amount: 36,
            direction: 'debit',
          ),
        ],
        'pagination': <String, dynamic>{
          'current_page': 1,
          'last_page': 2,
          'per_page': 10,
          'total': 18,
          'from': 1,
          'to': 10,
          'has_more_pages': true,
        },
      },
    };

    test('parses items, pagination and both directions', () {
      final page = AccountActivityPageModel.fromResponse(
        response,
        requestedPage: 1,
        requestedPerPage: 10,
      );

      expect(page.items, hasLength(2));
      expect(page.currentPage, 1);
      expect(page.lastPage, 2);
      expect(page.perPage, 10);
      expect(page.total, 18);
      expect(page.hasMorePages, isTrue);

      final credit = page.items.first;
      expect(credit.type, AccountEntryType.bookingIncome);
      expect(credit.isCredit, isTrue);
      expect(credit.amount, 1200);
      expect(credit.reference, 'BK-TRJSQE1T');
      expect(credit.venueName, 'Dhanawantary Sports');
      expect(credit.date, DateTime.parse('2026-09-14 06:00:00').toLocal());
      expect(
        credit.createdAt,
        DateTime.parse('2026-09-12 19:57:03').toLocal(),
      );
      expect(credit.recordedApartFromDate, isTrue);

      final debit = page.items.last;
      expect(debit.type, AccountEntryType.commission);
      expect(debit.isCredit, isFalse);
      expect(debit.amount, 36);
    });

    test('a fractional commission keeps its paisa', () {
      final page = AccountActivityPageModel.fromResponse(<String, dynamic>{
        'data': <String, dynamic>{
          'items': <Map<String, dynamic>>[
            _row(
              type: 'platform_commission',
              title: 'Platform commission',
              reference: 'BK-BFLEUQZX',
              amount: 7.5,
              direction: 'debit',
            ),
          ],
        },
      }, requestedPage: 1, requestedPerPage: 10);

      expect(page.items.single.amount, 7.5);
    });

    test('the pair of a booking is told apart despite sharing everything', () {
      final page = AccountActivityPageModel.fromResponse(
        response,
        requestedPage: 1,
        requestedPerPage: 10,
      );
      final identities = page.items.map((e) => e.identity).toSet();
      expect(identities, hasLength(2), reason: 'credit and debit must differ');
      for (final entry in page.items) {
        expect(entry.id, isEmpty, reason: 'the endpoint sends no id');
        expect(entry.identity, isNotEmpty);
      }
    });

    test('the same row parsed twice keeps one identity', () {
      final a = AccountEntryModel.fromJson(
        _row(
          type: 'booking_payment',
          title: 'Venue booking payment',
          reference: 'BK-TRJSQE1T',
          amount: 1200,
          direction: 'credit',
        ),
      );
      final b = AccountEntryModel.fromJson(
        _row(
          type: 'booking_payment',
          title: 'Venue booking payment',
          reference: 'BK-TRJSQE1T',
          amount: 1200,
          direction: 'credit',
        ),
      );
      expect(a.identity, b.identity);
    });

    test('rows of different bookings never collide', () {
      final a = AccountEntryModel.fromJson(
        _row(
          type: 'booking_payment',
          title: 'Venue booking payment',
          reference: 'BK-BHYNBEAG',
          amount: 2500,
          direction: 'credit',
          venue: 'Dhananjay sport',
        ),
      );
      final b = AccountEntryModel.fromJson(
        _row(
          type: 'booking_payment',
          title: 'Venue booking payment',
          reference: 'BK-KMOEIWNT',
          amount: 2500,
          direction: 'credit',
          venue: 'Dhananjay sport',
          createdAt: '2026-09-12 19:07:03',
        ),
      );
      expect(a.identity, isNot(b.identity));
    });
  });
}
