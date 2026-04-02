import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/public/data/data_source/public_remote_data_source.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';

final class PublicRepositoryImpl extends PublicRepository {
  PublicRepositoryImpl({PublicRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? PublicRemoteDataSourceImpl();

  final PublicRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<PublicServiceModel>>> getServices() async {
    final response = await _remoteDataSource.getServices();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final List<dynamic> items = _extractList(
        payload: response.getValue(),
        key: 'services',
      );
      return right(
        items
            .whereType<Map>()
            .map(
              (Map item) =>
                  PublicServiceModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse public services from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicPackageModel>>> getPackages() async {
    final response = await _remoteDataSource.getPackages();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final List<dynamic> items = _extractList(
        payload: response.getValue(),
        key: 'packages',
      );
      return right(
        items
            .whereType<Map>()
            .map(
              (Map item) =>
                  PublicPackageModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse public packages from server.',
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicTemplateModel>>> getTemplates() async {
    final response = await _remoteDataSource.getTemplates();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final dynamic payload = response.getValue();
      final List<dynamic> items = _extractTemplateList(payload);
      return right(
        items
            .whereType<Map>()
            .map(
              (Map item) =>
                  PublicTemplateModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList(),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse public templates from server.',
          statusCode: 0,
        ),
      );
    }
  }

  List<dynamic> _extractTemplateList(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic nestedTemplates = payload['data'];
      if (nestedTemplates is Map<String, dynamic> &&
          nestedTemplates['templates'] is List) {
        return nestedTemplates['templates'] as List<dynamic>;
      }
    }

    return _extractList(payload: payload, key: 'templates');
  }

  List<dynamic> _extractList({required dynamic payload, required String key}) {
    if (payload is List) return payload;

    if (payload is Map<String, dynamic>) {
      final dynamic direct = payload[key];
      if (direct is List) return direct;

      final dynamic data =
          payload['data'] ?? payload['items'] ?? payload['results'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final dynamic nested = data[key] ?? data['items'] ?? data['results'];
        if (nested is List) return nested;
      }
    }

    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      return _extractList(payload: map, key: key);
    }

    return const <dynamic>[];
  }
}
