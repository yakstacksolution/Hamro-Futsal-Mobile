import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/rewards/data/model/rewards_model.dart';
import 'package:hamro_futsal/features/rewards/domain/repository/rewards_repository.dart';
import 'package:hamro_futsal/features/rewards/domain/usecase/rewards_usecase.dart';
import 'package:hamro_futsal/features/rewards/presentation/bloc/rewards_bloc/rewards_bloc.dart';

void main() {
  group('RewardsBloc', () {
    test('loads the wallet', () async {
      final _FakeRewardsRepository repository = _FakeRewardsRepository();
      final RewardsBloc bloc = RewardsBloc(RewardsUseCase(repository));
      addTearDown(bloc.close);

      final Future<RewardsState> loaded = bloc.stream.firstWhere(
        (RewardsState state) => state.summaryStatus == RewardsStatus.success,
      );

      bloc.add(const LoadRewardsEvent());

      final RewardsState state = await loaded;
      expect(repository.summaryCalls, 1);
      expect(state.wallet.availablePoints, 1200);
      expect(state.errorMessage, isNull);
    });

    test('surfaces a wallet failure', () async {
      final _FakeRewardsRepository repository = _FakeRewardsRepository(
        summaryError: DefaultException(
          errorMessage: 'Rewards unavailable.',
          statusCode: 503,
        ),
      );
      final RewardsBloc bloc = RewardsBloc(RewardsUseCase(repository));
      addTearDown(bloc.close);

      final Future<RewardsState> failed = bloc.stream.firstWhere(
        (RewardsState state) => state.summaryStatus == RewardsStatus.failure,
      );

      bloc.add(const LoadRewardsEvent());

      final RewardsState state = await failed;
      expect(state.errorMessage, 'Rewards unavailable.');
      expect(state.isSummaryFailure, isTrue);
    });

    test('appends the next history page and stops at the end', () async {
      final _FakeRewardsRepository repository = _FakeRewardsRepository();
      final RewardsBloc bloc = RewardsBloc(
        RewardsUseCase(repository),
        perPage: 2,
      );
      addTearDown(bloc.close);

      final Future<RewardsState> firstPage = bloc.stream.firstWhere(
        (RewardsState state) => state.historyStatus == RewardsStatus.success,
      );
      bloc.add(const LoadRewardHistoryEvent());
      final RewardsState afterFirst = await firstPage;
      expect(afterFirst.history, hasLength(2));
      expect(afterFirst.hasReachedMax, isFalse);

      final Future<RewardsState> secondPage = bloc.stream.firstWhere(
        (RewardsState state) =>
            state.history.length > 2 && !state.isLoadingMoreHistory,
      );
      bloc.add(const LoadMoreRewardHistoryEvent());
      final RewardsState afterSecond = await secondPage;

      expect(repository.historyPagesRequested, <int>[1, 2]);
      expect(afterSecond.history, hasLength(3));
      expect(afterSecond.historyPage, 2);
      expect(afterSecond.hasReachedMax, isTrue);

      // The end of the list must not trigger further requests.
      bloc.add(const LoadMoreRewardHistoryEvent());
      await Future<void>.delayed(Duration.zero);
      expect(repository.historyPagesRequested, <int>[1, 2]);
    });

    test('generates a coupon and refreshes the balance from it', () async {
      final _FakeRewardsRepository repository = _FakeRewardsRepository();
      final RewardsBloc bloc = RewardsBloc(RewardsUseCase(repository));
      addTearDown(bloc.close);

      final Future<RewardsState> generated = bloc.stream.firstWhere(
        (RewardsState state) => state.generateStatus == RewardsStatus.success,
      );

      bloc.add(const GenerateRewardCouponEvent(points: 500));

      final RewardsState state = await generated;
      expect(repository.generateCalls, <int?>[500]);
      expect(state.generatedCoupon?.code, 'RWD-1');
      expect(state.isGenerating, isFalse);
    });

    test('reports a failed coupon generation', () async {
      final _FakeRewardsRepository repository = _FakeRewardsRepository(
        generateError: DefaultException(
          errorMessage: 'Not enough points.',
          statusCode: 422,
        ),
      );
      final RewardsBloc bloc = RewardsBloc(RewardsUseCase(repository));
      addTearDown(bloc.close);

      final Future<RewardsState> failed = bloc.stream.firstWhere(
        (RewardsState state) => state.generateStatus == RewardsStatus.failure,
      );

      bloc.add(const GenerateRewardCouponEvent());

      final RewardsState state = await failed;
      expect(state.generateErrorMessage, 'Not enough points.');
      expect(state.generatedCoupon, isNull);
    });
  });
}

/// In-memory repository serving two history pages (2 + 1 entries).
class _FakeRewardsRepository extends RewardsRepository {
  _FakeRewardsRepository({this.summaryError, this.generateError});

  final AppException? summaryError;
  final AppException? generateError;

  int summaryCalls = 0;
  final List<int> historyPagesRequested = <int>[];
  final List<int?> generateCalls = <int?>[];

  @override
  Future<Either<AppException, RewardsSummaryModel>> getRewards() async {
    summaryCalls++;
    if (summaryError != null) return left(summaryError!);
    return right(
      const RewardsSummaryModel(
        availablePoints: 1200,
        totalEarnedPoints: 2000,
        totalRedeemedPoints: 800,
        pointsPerCoupon: 500,
        couponValue: 200,
      ),
    );
  }

  @override
  Future<Either<AppException, RewardHistoryPageModel>> getRewardHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    historyPagesRequested.add(page);
    const List<List<int>> pages = <List<int>>[
      <int>[1, 2],
      <int>[3],
    ];
    final List<int> ids = page <= pages.length
        ? pages[page - 1]
        : const <int>[];

    return right(
      RewardHistoryPageModel(
        entries: ids
            .map(
              (int id) => RewardHistoryEntryModel(
                id: id.toString(),
                type: RewardEntryType.earned,
                points: id * 10,
              ),
            )
            .toList(growable: false),
        page: page,
        perPage: perPage,
        total: 3,
        lastPage: 2,
      ),
    );
  }

  @override
  Future<Either<AppException, GeneratedRewardCouponModel>> generateCoupon({
    int? points,
  }) async {
    generateCalls.add(points);
    if (generateError != null) return left(generateError!);
    return right(
      const GeneratedRewardCouponModel(
        code: 'RWD-1',
        discountAmount: 200,
        pointsUsed: 500,
        remainingPoints: 700,
      ),
    );
  }
}
