import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/vendor_operations/data/vendor_ops_repository.dart';
import 'package:hamro_futsal/features/vendor_operations/domain/ops_models.dart';

/// Courts' slots for the week starting [weekStart], from the server — what
/// the Week table shows. The Day board has its own single call
/// ([VendorOpsRepository.loadDay]).
final class GetCourtWeekAvailabilityUseCase {
  const GetCourtWeekAvailabilityUseCase(this._repository);

  final VendorOpsRepository _repository;

  /// Requests in flight at once.
  static const int _concurrency = 4;

  Future<Either<AppException, OpsCourtWeekAvailability>> call({
    required OpsCourt court,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) => _repository.loadCourtWeekSlots(
    venueId: court.venueId,
    courtId: court.id,
    start: start,
    includeEndDate: includeEndDate,
    type: type,
  );

  /// Every court in [courts], keyed by [OpsCourtWeekAvailability.keyOf]. A
  /// court that fails is left out — it falls back to its own schedule — and
  /// the first failure is returned alongside.
  Future<(Map<String, OpsCourtWeekAvailability>, AppException?)> many({
    required List<OpsCourt> courts,
    required DateTime start,
    required bool includeEndDate,
    required OpsAvailabilityResponseType type,
  }) async {
    final Map<String, OpsCourtWeekAvailability> out =
        <String, OpsCourtWeekAvailability>{};
    AppException? failure;
    for (int i = 0; i < courts.length; i += _concurrency) {
      final List<Either<AppException, OpsCourtWeekAvailability>> results =
          await Future.wait(
            <Future<Either<AppException, OpsCourtWeekAvailability>>>[
              for (final OpsCourt court in courts.skip(i).take(_concurrency))
                call(
                  court: court,
                  start: start,
                  includeEndDate: includeEndDate,
                  type: type,
                ),
            ],
          );
      for (final Either<AppException, OpsCourtWeekAvailability> r in results) {
        r.fold(
          (AppException e) => failure ??= e,
          (OpsCourtWeekAvailability w) => out[w.key] = w,
        );
      }
    }
    return (out, failure);
  }
}
