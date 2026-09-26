import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/mobile_banner/data/data_source/mobile_banner_data_source.dart';
import 'package:hamro_futsal/features/mobile_banner/data/model/mobile_banner_model.dart';
import 'package:hamro_futsal/features/mobile_banner/domain/repository/mobile_banner_repository.dart';

final class MobileBannerRepositoryImpl implements MobileBannerRepository {
  MobileBannerRepositoryImpl({MobileBannerRemoteDataSource? remoteDataSource})
    : _remoteDataSource =
          remoteDataSource ?? MobileBannerRemoteDataSourceImpl();

  final MobileBannerRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<MobileBannerModel>>>
  getMobileBanners() async {
    final response = await _remoteDataSource.getMobileBanners();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    try {
      return right(MobileBannerModel.listFromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseMobileBannersFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, Unit>> dismissMobileBanner(
    String bannerId,
  ) async {
    final response = await _remoteDataSource.dismissMobileBanner(bannerId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(unit);
  }
}
