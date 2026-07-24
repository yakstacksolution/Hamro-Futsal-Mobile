import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/features/account/data/data_source/account_remote_data_source.dart';
import 'package:hamro_footsall/features/account/data/repositories/account_repository_impl.dart';

void main() {
  test('loads finance values only from the remote data source', () async {
    final remote = _FakeAccountRemoteDataSource();
    final repository = AccountRepositoryImpl(remoteDataSource: remote);

    final summary = await repository.getSummary();

    expect(remote.summaryCalls, 1);
    expect(
      summary.getOrElse(() => throw StateError('summary')).availableBalance,
      12500,
    );
    expect(
      summary.getOrElse(() => throw StateError('summary')).reservedBalance,
      2000,
    );
  });

  test('settlement sends the required request data', () async {
    final remote = _FakeAccountRemoteDataSource();
    final repository = AccountRepositoryImpl(remoteDataSource: remote);

    await repository.requestSettlement(
      amount: 5000,
      idempotencyKey: 'unique-1',
      scope: 'venues',
      venueIds: const <int>[101],
      paymentProofPath: '/tmp/proof.png',
      note: 'Weekly payout',
    );

    expect(remote.lastSettlement?['amount'], 5000);
    expect(remote.lastSettlement?['idempotency_key'], 'unique-1');
    expect(remote.lastSettlement?['scope'], 'venues');
    expect(remote.lastSettlement?['venue_ids'], const <int>[101]);
    expect(remote.lastSettlement?['payment_proof_path'], '/tmp/proof.png');
  });

  test('uses dummy finance responses when backend requests fail', () async {
    final repository = AccountRepositoryImpl(
      remoteDataSource: _ErrorAccountRemoteDataSource(),
    );

    final summary = await repository.getSummary();
    final statement = await repository.getStatement();
    final settlements = await repository.getSettlements();
    final requestedSettlement = await repository.requestSettlement(
      amount: 5000,
      idempotencyKey: 'dummy-request-1',
      scope: 'all',
      venueIds: const <int>[101, 102],
      paymentProofPath: '/tmp/proof.png',
    );

    expect(summary.isRight(), isTrue);
    expect(
      summary.getOrElse(() => throw StateError('summary')).availableBalance,
      18500,
    );
    expect(statement.getOrElse(() => const []), hasLength(2));
    expect(settlements.getOrElse(() => const []), hasLength(1));
    expect(
      requestedSettlement
          .getOrElse(() => throw StateError('settlement'))
          .amount,
      5000,
    );
  });
}

class _ErrorAccountRemoteDataSource implements AccountRemoteDataSource {
  Result get error => Result.error(DataError('Backend unavailable', 500, null));

  @override
  Future<Result> getAccountSummary() async => error;

  @override
  Future<Result> getAccountStatement({Map<String, dynamic>? query}) async =>
      error;

  @override
  Future<Result> getSettlements() async => error;

  @override
  Future<Result> requestSettlement(Map<String, dynamic> data) async => error;
}

class _FakeAccountRemoteDataSource implements AccountRemoteDataSource {
  int summaryCalls = 0;
  Map<String, dynamic>? lastSettlement;

  @override
  Future<Result> getAccountSummary() async {
    summaryCalls++;
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
  Future<Result> requestSettlement(Map<String, dynamic> data) async {
    lastSettlement = data;
    return Result.success(<String, dynamic>{
      'data': <String, dynamic>{
        'id': 'st-1',
        'amount': data['amount'],
        'status': 'pending',
      },
    });
  }

  @override
  Future<Result> getAccountStatement({Map<String, dynamic>? query}) async =>
      Result.success(<String, dynamic>{'data': <dynamic>[]});

  @override
  Future<Result> getSettlements() async =>
      Result.success(<String, dynamic>{'data': <dynamic>[]});
}
