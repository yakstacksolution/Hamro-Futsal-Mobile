import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/venue_review_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetVenueReviewsUseCase {
  const GetVenueReviewsUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, VenueReviewPageModel>> call({
    required int venueId,
    int page = 1,
    int perPage = 5,
  }) async => await repository.getVenueReviews(
    venueId: venueId,
    page: page,
    perPage: perPage,
  );
}
