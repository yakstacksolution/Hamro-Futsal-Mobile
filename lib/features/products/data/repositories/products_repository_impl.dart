import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/products/data/data_source/products_remote_data_source.dart';
import 'package:hamro_futsal/features/products/data/model/product_models.dart';
import 'package:hamro_futsal/features/products/domain/repository/products_repository.dart';

final class ProductsRepositoryImpl extends ProductsRepository {
  ProductsRepositoryImpl({ProductsRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? ProductsRemoteDataSourceImpl();

  final ProductsRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<ProductVenueModel>>> getVenues() async {
    final response = await _remoteDataSource.getVenues();
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      final venues =
          _findList(
                response.getValue(),
                keys: const [
                  'data',
                  'venues',
                  'venue_courts',
                  'venueCourts',
                  'items',
                  'results',
                ],
                depth: 0,
              )
              .whereType<Map>()
              .map(
                (item) =>
                    ProductVenueModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((venue) => venue.id > 0 && venue.name.isNotEmpty)
              .toList(growable: false);
      return right(venues);
    } catch (_) {
      return left(_parseException('Could not read venues from the server.'));
    }
  }

  @override
  Future<Either<AppException, List<ProductModel>>> getProducts({
    required int venueId,
    int perPage = 15,
  }) async {
    final response = await _remoteDataSource.getProducts(
      venueId: venueId,
      perPage: perPage,
    );
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      final products =
          _findList(
                response.getValue(),
                keys: const ['data', 'products', 'items', 'results'],
                depth: 0,
              )
              .whereType<Map>()
              .map(
                (item) =>
                    ProductModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .where((product) => product.id > 0 && product.name.isNotEmpty)
              .toList(growable: false);
      return right(products);
    } catch (_) {
      return left(_parseException('Could not read products from the server.'));
    }
  }

  @override
  Future<Either<AppException, ProductModel>> createProduct(
    ProductPayload payload,
  ) async {
    final response = await _remoteDataSource.createProduct(payload.toJson());
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      return right(ProductModel.fromJson(_unwrap(response.getValue())));
    } catch (_) {
      return right(
        ProductModel(
          id: 0,
          venueId: payload.venueId,
          name: payload.name,
          price: payload.price,
          isActive: payload.isActive,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, ProductModel>> updateProduct({
    required int productId,
    required ProductPayload payload,
  }) async {
    final response = await _remoteDataSource.updateProduct(
      productId: productId,
      data: payload.toJson(),
    );
    if (response.isError()) return left(ResponseHelper.error(response));
    try {
      return right(ProductModel.fromJson(_unwrap(response.getValue())));
    } catch (_) {
      return right(
        ProductModel(
          id: productId,
          venueId: payload.venueId,
          name: payload.name,
          price: payload.price,
          isActive: payload.isActive,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, void>> deleteProduct(int productId) async {
    final response = await _remoteDataSource.deleteProduct(productId);
    if (response.isError()) return left(ResponseHelper.error(response));
    return right(null);
  }

  DefaultException _parseException(String message) {
    return DefaultException(errorMessage: message, statusCode: 0);
  }

  Map<String, dynamic> _unwrap(dynamic payload) {
    if (payload is! Map) return const <String, dynamic>{};
    for (final key in const ['data', 'product', 'item', 'result']) {
      final dynamic child = payload[key];
      if (child is Map) return _unwrap(child);
    }
    return Map<String, dynamic>.from(payload);
  }

  List<dynamic> _findList(
    dynamic node, {
    required List<String> keys,
    required int depth,
  }) {
    if (node is List) return node;
    if (node is Map && depth < 4) {
      for (final key in keys) {
        final dynamic child = node[key];
        if (child == null) continue;
        final found = _findList(child, keys: keys, depth: depth + 1);
        if (found.isNotEmpty) return found;
      }
    }
    return const <dynamic>[];
  }
}
