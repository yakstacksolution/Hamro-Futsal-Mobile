import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_package_model.dart';
import 'package:hamro_futsal/features/public/data/model/category_filter_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_faq_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_help_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_option_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_service_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_template_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_venue_model.dart';
import 'package:hamro_futsal/features/public/presentation/models/venue_filter.dart';

abstract class PublicRepository {
  Future<Either<AppException, List<PublicServiceModel>>> getServices();
  Future<Either<AppException, List<PublicPackageModel>>> getPackages();
  Future<Either<AppException, List<PublicOptionModel>>> getCourtTypes();
  Future<Either<AppException, List<PublicOptionModel>>> getMatchFormats();
  Future<Either<AppException, List<PublicOptionModel>>> getAmenities();
  Future<Either<AppException, List<PublicOptionModel>>> getFacilities();
  Future<Either<AppException, List<PublicTemplateModel>>> getTemplates();

  /// `GET /venues` — one page of the public listing.
  ///
  /// [latitude]/[longitude] are the origin the server measures `distance_km`
  /// from; they fall back to the device fix when omitted.
  Future<Either<AppException, PublicListingVenuePage>> getVenueList({
    int page,
    int perPage,
    VenueFilter? filter,
    double? latitude,
    double? longitude,
  });
  Future<Either<AppException, List<CategoryFilterModel>>> getCategoryFilter();

  /// `GET /auth/wishlist` — same response shape as the venue listing.
  Future<Either<AppException, PublicListingVenuePage>> getWishlist();

  /// `POST /venues/{venue}/wishlist` — adds/removes the venue from the
  /// signed-in user's wishlist.
  Future<Either<AppException, bool>> toggleWishlist(int venueId);

  /// `GET /faqs` — public frequently-asked questions.
  Future<Either<AppException, List<PublicFaqModel>>> getFaqs();

  /// `GET /helps` — public help topics.
  Future<Either<AppException, List<PublicHelpModel>>> getHelps();
}
