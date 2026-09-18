import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/review_change_request.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class SubmitReviewChangeRequestUseCase {
  const SubmitReviewChangeRequestUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, String>> call({
    required int reviewId,
    required ReviewChangeRequestInput input,
  }) async => await repository.submitReviewChangeRequest(
    reviewId: reviewId,
    input: input,
  );
}
