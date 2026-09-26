import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/mobile_banner/data/model/mobile_banner_model.dart';

abstract class MobileBannerRepository {
  Future<Either<AppException, List<MobileBannerModel>>> getMobileBanners();

  Future<Either<AppException, Unit>> dismissMobileBanner(String bannerId);
}
