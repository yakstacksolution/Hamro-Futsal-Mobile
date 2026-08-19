import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/products/data/model/product_models.dart';

abstract class ProductsRepository {
  Future<Either<AppException, List<ProductVenueModel>>> getVenues();

  Future<Either<AppException, List<ProductModel>>> getProducts({
    required int venueId,
    int perPage = 15,
  });

  Future<Either<AppException, ProductModel>> createProduct(
    ProductPayload payload,
  );

  Future<Either<AppException, ProductModel>> updateProduct({
    required int productId,
    required ProductPayload payload,
  });

  Future<Either<AppException, void>> deleteProduct(int productId);
}
