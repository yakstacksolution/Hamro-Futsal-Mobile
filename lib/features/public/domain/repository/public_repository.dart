import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_package_model.dart';
import 'package:hamro_futsal/features/public/data/model/category_filter_model.dart';
import 'package:hamro_futsal/features/public/data/model/help_video_model.dart';
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

  Future<Either<AppException, PublicListingVenuePage>> getVenueList({
    int page,
    int perPage,
    VenueFilter? filter,
    double? latitude,
    double? longitude,
  });

  Future<Either<AppException, PublicListingVenueModel?>> getVenueByLink({
    String? slug,
    int? id,
    double? latitude,
    double? longitude,
  });

  Future<Either<AppException, List<CategoryFilterModel>>> getCategoryFilter();

  Future<Either<AppException, PublicListingVenuePage>> getWishlist();

  Future<Either<AppException, bool>> toggleWishlist(int venueId);

  Future<Either<AppException, List<PublicFaqModel>>> getFaqs();

  Future<Either<AppException, List<PublicHelpModel>>> getHelps();

  Future<Either<AppException, List<HelpVideo>>> getYoutubeVideos();
}
