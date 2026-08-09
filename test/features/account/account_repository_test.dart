import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/features/account/data/data_source/account_remote_data_source.dart';
import 'package:hamro_footsall/features/account/data/model/account_models.dart';
import 'package:hamro_footsall/features/account/data/repositories/account_repository_impl.dart';

// Rewritten against the current settlement API. The previous version targeted
// getSummary/getStatement/requestSettlement, which no longer exist, and asserted
// that backend failures fall back to dummy finance figures — the repository now
// surfaces those as a Left instead, which is the behaviour pinned below.

void main() {
  group('AccountRepositoryImpl', () {
    test('reads the account only through the injected data source', () async {
      final _FakeAccountRemoteDataSource remote = _FakeAccountRemoteDataSource();
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remoteDataSource: remote,
      );

      final result = await repository.getSettlementAccount();
      final AccountSummaryModel summary = result.getOrElse(
        () => throw StateError('expected a summary'),
      );

      expect(remote.accountCalls, 1);
      expect(summary.availableBalance, 12500);
      expect(summary.reservedBalance, 2000);
      expect(summary.currency, 'NPR');
      expect(summary.settlementEligible, isTrue);
    });

    test('createSettlement forwards every required field', () async {
      final _FakeAccountRemoteDataSource remote = _FakeAccountRemoteDataSource();
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remoteDataSource: remote,
      );

      await repository.createSettlement(
        amount: 5000,
        transactionReference: 'unique-1',
        paymentProofPath: '/tmp/proof.png',
        venueId: 101,
        note: 'Weekly payout',
      );

      expect(remote.lastSettlement?['amount'], 5000);
      expect(remote.lastSettlement?['transaction_reference'], 'unique-1');
      expect(remote.lastSettlement?['payment_proof_path'], '/tmp/proof.png');
      expect(remote.lastSettlement?['venue_id'], 101);
      expect(remote.lastSettlement?['note'], 'Weekly payout');
    });

    test('omits optional fields that were not supplied', () async {
      final _FakeAccountRemoteDataSource remote = _FakeAccountRemoteDataSource();
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remoteDataSource: remote,
      );

      await repository.createSettlement(
        amount: 250,
        transactionReference: 'ref-2',
        paymentProofPath: '/tmp/p.png',
      );

      expect(remote.lastSettlement?.containsKey('venue_id'), isFalse);
      expect(remote.lastSettlement?.containsKey('note'), isFalse);
    });

    test('getSettlements passes the paging query through', () async {
      final _FakeAccountRemoteDataSource remote = _FakeAccountRemoteDataSource();
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remoteDataSource: remote,
      );

      await repository.getSettlements(perPage: 5, page: 3);

      expect(remote.lastSettlementsQuery?['per_page'], 5);
      expect(remote.lastSettlementsQuery?['page'], 3);
    });

    test('a backend failure surfaces as a Left, never as fabricated figures', () async {
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remoteDataSource: _ErrorAccountRemoteDataSource(),
      );

      expect((await repository.getSettlementAccount()).isLeft(), isTrue);
      expect((await repository.getSettlementBreakdown()).isLeft(), isTrue);
      expect((await repository.getSettlementPreview()).isLeft(), isTrue);
      expect((await repository.getSettlements()).isLeft(), isTrue);
      expect(
        (await repository.createSettlement(
          amount: 5000,
          transactionReference: 'dummy-request-1',
          paymentProofPath: '/tmp/proof.png',
        )).isLeft(),
        isTrue,
      );
    });

    test('a malformed payload is reported rather than thrown', () async {
      final AccountRepositoryImpl repository = AccountRepositoryImpl(
        remoteDataSource: _MalformedAccountRemoteDataSource(),
      );

      // `_unwrap` yields an empty map for a non-map body, so the model falls
      // back to its defaults instead of blowing up the caller.
      final result = await repository.getSettlementAccount();
      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => throw StateError('summary')).availableBalance,
        0,
      );
    });
  });
}

class _ErrorAccountRemoteDataSource implements AccountRemoteDataSource {
  Result get _error =>
      Result.error(DataError('Backend unavailable', 500, null));

  @override
  Future<Result> getSettlementAccount() async => _error;

  @override
  Future<Result> getSettlementBreakdown() async => _error;

  @override
  Future<Result> getSettlementPreview({int? venueId}) async => _error;

  @override
  Future<Result> getSettlements({Map<String, dynamic>? query}) async => _error;

  @override
  Future<Result> createSettlement(Map<String, dynamic> data) async => _error;
}

class _MalformedAccountRemoteDataSource implements AccountRemoteDataSource {
  Result get _junk => Result.success('not-a-map');

  @override
  Future<Result> getSettlementAccount() async => _junk;

  @override
  Future<Result> getSettlementBreakdown() async => _junk;

  @override
  Future<Result> getSettlementPreview({int? venueId}) async => _junk;

  @override
  Future<Result> getSettlements({Map<String, dynamic>? query}) async => _junk;

  @override
  Future<Result> createSettlement(Map<String, dynamic> data) async => _junk;
}

class _FakeAccountRemoteDataSource implements AccountRemoteDataSource {
  int accountCalls = 0;
  Map<String, dynamic>? lastSettlement;
  Map<String, dynamic>? lastSettlementsQuery;

  @override
  Future<Result> getSettlementAccount() async {
    accountCalls++;
    return Result.success(<String, dynamic>{
      'data': <String, dynamic>{
        'currency': 'NPR',
        'available_balance': 12500,
        'reserved_balance': 2000,
        'settlement_eligible': true,
      },
    });
  }

  @override
  Future<Result> getSettlementBreakdown() async =>
      Result.success(<String, dynamic>{'data': <dynamic>[]});

  @override
  Future<Result> getSettlementPreview({int? venueId}) async =>
      Result.success(<String, dynamic>{'data': <String, dynamic>{}});

  @override
  Future<Result> getSettlements({Map<String, dynamic>? query}) async {
    lastSettlementsQuery = query;
    return Result.success(<String, dynamic>{'data': <dynamic>[]});
  }

  @override
  Future<Result> createSettlement(Map<String, dynamic> data) async {
    lastSettlement = data;
    return Result.success(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 'st-1',
        'amount': data['amount'],
        'status': 'pending',
      },
    });
  }
}
