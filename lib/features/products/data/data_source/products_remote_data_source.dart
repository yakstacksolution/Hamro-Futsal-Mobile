import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/api/client.dart';

abstract class ProductsRemoteDataSource {
  Future<Result> getVenues();
  Future<Result> getProducts({required int venueId, int perPage = 15});
  Future<Result> createProduct(Map<String, dynamic> data);
  Future<Result> updateProduct({
    required int productId,
    required Map<String, dynamic> data,
  });
  Future<Result> deleteProduct(int productId);
}

final class ProductsRemoteDataSourceImpl extends ProductsRemoteDataSource {
  @override
  Future<Result> getVenues() async =>
      await Client.instance().getAuthManager().getDropdownVenueCourts();

  @override
  Future<Result> getProducts({required int venueId, int perPage = 15}) async =>
      await Client.instance().getAuthManager().getProducts(
        venueId: venueId,
        perPage: perPage,
      );

  @override
  Future<Result> createProduct(Map<String, dynamic> data) async =>
      await Client.instance().getAuthManager().createProduct(data);

  @override
  Future<Result> updateProduct({
    required int productId,
    required Map<String, dynamic> data,
  }) async => await Client.instance().getAuthManager().updateProduct(
    productId: productId,
    data: data,
  );

  @override
  Future<Result> deleteProduct(int productId) async => await Client.instance()
      .getAuthManager()
      .deleteProduct(productId: productId);
}
