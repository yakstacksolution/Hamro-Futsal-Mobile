import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/account/data/model/account_models.dart';
import 'package:hamro_futsal/features/account/presentation/bloc/account_bloc/account_bloc.dart';

/// `actions.can_request_settlement` decides whether Pay Commission is live.
///
/// The app used to layer its own conditions on top — commission owed, a
/// requestable amount, nothing in review — and they disagreed with the server:
/// an account the API called eligible either had the button greyed out, or had
/// it live until it opened a page that refused.
AccountSummaryModel _summary({
  bool canRequest = true,
  num commission = 757.5,
  num requestable = 79.5,
  num balance = 1970.5,
}) => AccountSummaryModel.fromJson(<String, dynamic>{
  'available_balance': balance,
  'cards': <String, dynamic>{'commission': commission, 'total_earned': 17450},
  'actions': <String, dynamic>{
    'can_request_settlement': canRequest,
    'requestable_amount': requestable,
  },
});

/// Mirrors the screen's gate.
bool _canSettle(AccountState state) =>
    state.summary.settlementEligible &&
    state.submitStatus != AccountStatus.loading;

void main() {
  test('the live payload enables the button', () {
    // The account response from /auth/settlement-account.
    final AccountState state = AccountState(summary: _summary());

    expect(state.summary.settlementEligible, isTrue);
    expect(state.summary.totalCommission, 757.5);
    expect(state.summary.requestableAmount, 79.5);
    expect(_canSettle(state), isTrue);
  });

  test('a settlement in review does not disable it', () {
    // One approved settlement, exactly the account that was blocked before.
    final AccountState state = AccountState(
      summary: _summary(),
      settlementCounts: const SettlementStatusCounts(approved: 1),
      settlements: <SettlementModel>[
        SettlementModel.fromJson(<String, dynamic>{
          'id': '9',
          'requested_amount': 678,
          'status': 'approved',
        }),
      ],
    );

    expect(
      state.hasPendingSettlement,
      isTrue,
      reason: 'there really is one in review',
    );
    // The server still says yes, so the button stays live.
    expect(_canSettle(state), isTrue);
  });

  test('the answer is the same before and after visiting Settlements', () {
    final AccountState fresh = AccountState(summary: _summary());
    final AccountState afterVisiting = fresh.copyWith(
      settlementCounts: const SettlementStatusCounts(approved: 1),
    );
    expect(_canSettle(afterVisiting), _canSettle(fresh));
  });

  test('only the server turns it off', () {
    final AccountState blocked = AccountState(
      summary: _summary(canRequest: false),
    );
    expect(_canSettle(blocked), isFalse);
  });

  test('a small requestable amount is still settleable', () {
    // 79.5 against 757.5 of commission: the server decides what that means,
    // not a local "commission owed" rule.
    final AccountState state = AccountState(
      summary: _summary(requestable: 79.5),
    );
    expect(_canSettle(state), isTrue);
  });

  test('a submit in flight disables it', () {
    final AccountState submitting = AccountState(
      summary: _summary(),
      submitStatus: AccountStatus.loading,
    );
    expect(_canSettle(submitting), isFalse);
  });
}
