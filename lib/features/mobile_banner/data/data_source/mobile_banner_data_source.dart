import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class MobileBannerRemoteDataSource {
  Future<Result> getMobileBanners();
  Future<Result> dismissMobileBanner(String bannerId);
}

final class MobileBannerRemoteDataSourceImpl
    implements MobileBannerRemoteDataSource {
  @override
  Future<Result> getMobileBanners() async =>
      await Client.instance().getAuthManager().getMobileBanners();

  @override
  Future<Result> dismissMobileBanner(String bannerId) async =>
      await Client.instance().getAuthManager().dismissMobileBanner(bannerId);
}
