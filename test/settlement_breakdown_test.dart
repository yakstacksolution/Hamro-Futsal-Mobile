import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';

void main() {
  const Map<String, dynamic> response = <String, dynamic>{
    'status': 'success',
    'message': 'Settlement breakdown fetched successfully.',
    'data': <String, dynamic>{
      'items': <dynamic>[
        <String, dynamic>{
          'venue_id': 1,
          'venue_name': 'Dhananjay sport',
          'address': 'Nagarjun Municipality Nepal',
          'available_balance': 11711.99,
          'pending_clearance': 3385.49,
          'total_earned': 16500,
          'commission': 1402.52,
          'can_request_settlement': true,
        },
        <String, dynamic>{
          'venue_id': 2,
          'venue_name': 'Dhanawantary Sports',
          'address': 'Kathmandu',
          'available_balance': 0,
          'pending_clearance': 1254,
          'total_earned': 1320,
          'commission': 66,
          'can_request_settlement': false,
        },
      ],
      'count': 2,
    },
  };

  test('parses the settlement-breakdown payload', () {
    final model = SettlementBreakdownModel.fromResponse(response);
    expect(model.count, 2);
    expect(model.venues.length, 2);

    final first = model.venues.first;
    expect(first.id, 1);
    expect(first.name, 'Dhananjay sport');
    expect(first.location, 'Nagarjun Municipality Nepal');
    expect(first.availableBalance, 11711.99);
    expect(first.pendingClearance, 3385.49);
    expect(first.totalEarned, 16500);
    expect(
      first.totalCommission,
      1402.52,
      reason: 'the plain `commission` key must be read',
    );
    expect(first.settlementEligible, isTrue);
  });

  test('honours can_request_settlement: false', () {
    final model = SettlementBreakdownModel.fromResponse(response);
    expect(model.venues.last.settlementEligible, isFalse);
    expect(model.venues.last.totalCommission, 66);
    expect(model.venues.last.availableBalance, 0);
  });
}
