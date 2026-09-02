import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/media/data/data_source/media_remote_data_source.dart';
import 'package:hamro_futsal/features/media/data/model/media_model.dart';
import 'package:hamro_futsal/features/media/domain/repository/media_repository.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/utils/upload_attachment.dart';

final class MediaRepositoryImpl extends MediaRepository {
  MediaRepositoryImpl({MediaRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MediaRemoteDataSourceImpl();

  final MediaRemoteDataSource _remoteDataSource;

  @override
  Future<Either<AppException, List<MediaModel>>> getMedia() async {
    final response = await _remoteDataSource.getMedia();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final dynamic payload = response.getValue();
      final List<dynamic> items = _extractList(payload);
      final List<MediaModel> media = items
          .whereType<Map>()
          .map(
            (Map item) => MediaModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList();
      return right(media);
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseMediaListFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<MediaModel>>> createMedia(
    List<UploadAttachment> mediaFiles,
  ) async {
    final response = await _remoteDataSource.createMedia(mediaFiles);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final dynamic value = response.getValue();
      final List<dynamic> items = _extractList(value);
      if (items.isNotEmpty) {
        return right(
          items
              .whereType<Map>()
              .map(
                (Map item) =>
                    MediaModel.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
        );
      }

      return right(<MediaModel>[MediaModel.fromJson(_extractMap(value))]);
    } catch (_) {
      return left(
        DefaultException(
          errorMessage:
              StringConstants.couldNotParseCreatedMediaItemsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;
    if (payload is Map<String, dynamic>) {
      final dynamic data =
          payload['data'] ?? payload['items'] ?? payload['results'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final dynamic nestedItems =
            data['media'] ?? data['items'] ?? data['results'];
        if (nestedItems is List) return nestedItems;
      }
      if (data is Map) {
        final Map<String, dynamic> nestedMap = Map<String, dynamic>.from(data);
        final dynamic nestedItems =
            nestedMap['media'] ?? nestedMap['items'] ?? nestedMap['results'];
        if (nestedItems is List) return nestedItems;
      }
      return const <dynamic>[];
    }
    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      final dynamic data = map['data'] ?? map['items'] ?? map['results'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final dynamic nestedItems =
            data['media'] ?? data['items'] ?? data['results'];
        if (nestedItems is List) return nestedItems;
      }
      if (data is Map) {
        final Map<String, dynamic> nestedMap = Map<String, dynamic>.from(data);
        final dynamic nestedItems =
            nestedMap['media'] ?? nestedMap['items'] ?? nestedMap['results'];
        if (nestedItems is List) return nestedItems;
      }
    }
    return const <dynamic>[];
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final dynamic data = payload['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return payload;
    }
    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      final dynamic data = map['data'];
      if (data is Map<String, dynamic>) return data;
      if (data is Map) return Map<String, dynamic>.from(data);
      return map;
    }
    throw const FormatException('Invalid media payload');
  }
}
