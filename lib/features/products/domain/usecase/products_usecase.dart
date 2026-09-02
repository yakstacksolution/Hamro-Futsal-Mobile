import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/products/data/model/product_models.dart';
import 'package:hamro_futsal/features/products/domain/repository/products_repository.dart';

final class ProductsUseCase {
  const ProductsUseCase(this._repository);

  final ProductsRepository _repository;

  Future<Either<AppException, List<ProductVenueModel>>> getVenues() async =>
      await _repository.getVenues();

  Future<Either<AppException, List<ProductModel>>> getProducts({
    required int venueId,
    int perPage = 15,
  }) async => await _repository.getProducts(venueId: venueId, perPage: perPage);

  Future<Either<AppException, ProductModel>> createProduct(
    ProductPayload payload,
  ) async => await _repository.createProduct(payload);

  Future<Either<AppException, ProductModel>> updateProduct({
    required int productId,
    required ProductPayload payload,
  }) async =>
      await _repository.updateProduct(productId: productId, payload: payload);

  Future<Either<AppException, void>> deleteProduct(int productId) async =>
      await _repository.deleteProduct(productId);
}
