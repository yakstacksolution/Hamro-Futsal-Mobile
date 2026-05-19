import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';

abstract class PublicRepository {
  Future<Either<AppException, List<PublicServiceModel>>> getServices();
  Future<Either<AppException, List<PublicPackageModel>>> getPackages();
  Future<Either<AppException, List<PublicOptionModel>>> getCourtTypes();
  Future<Either<AppException, List<PublicOptionModel>>> getMatchFormats();
  Future<Either<AppException, List<PublicOptionModel>>> getAmenities();
  Future<Either<AppException, List<PublicOptionModel>>> getFacilities();
  Future<Either<AppException, List<PublicTemplateModel>>> getTemplates();
}
