import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class CouponRemoteDataSource {
  Future<Result> getActiveCoupons();
  Future<Result> applyCoupon({required Map<String, dynamic> data});
}

final class CouponRemoteDataSourceImpl extends CouponRemoteDataSource {
  @override
  Future<Result> getActiveCoupons() async =>
      await Client.instance().getAuthManager().getActiveCoupons();

  @override
  Future<Result> applyCoupon({required Map<String, dynamic> data}) async =>
      await Client.instance().getAuthManager().applyCoupon(data: data);
}
