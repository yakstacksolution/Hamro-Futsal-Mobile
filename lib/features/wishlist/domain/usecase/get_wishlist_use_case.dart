import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetWishlistUseCase {
  const GetWishlistUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, PublicListingVenuePage>> call() async =>
      await repository.getWishlist();
}
