import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class ResolveVenueLinkUseCase {
  const ResolveVenueLinkUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, PublicListingVenueModel?>> call({
    String? slug,
    int? id,
    double? latitude,
    double? longitude,
  }) => repository.getVenueByLink(
    slug: slug,
    id: id,
    latitude: latitude,
    longitude: longitude,
  );
}
