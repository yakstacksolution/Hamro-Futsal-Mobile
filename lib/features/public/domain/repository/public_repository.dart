import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/model/category_filter_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';

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
  });
  Future<Either<AppException, List<CategoryFilterModel>>> getCategoryFilter();
}
