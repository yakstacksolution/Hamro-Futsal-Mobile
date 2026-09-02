import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

/// Fetches the signed-in candidate's wishlisted venues — the response (and
/// therefore the model) is identical to the home venue listing.
final class GetWishlistUseCase {
  const GetWishlistUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, PublicListingVenuePage>> call() async =>
      await repository.getWishlist();
}
