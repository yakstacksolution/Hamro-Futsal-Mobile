import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

/// Resolves a shared venue link (`/venues/<slug>?venue=<id>`) to the listing
/// row the details page is built from.
///
/// Right returns null when nothing matched — a delisted or renamed venue —
/// which the caller shows differently from a failed request.
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
