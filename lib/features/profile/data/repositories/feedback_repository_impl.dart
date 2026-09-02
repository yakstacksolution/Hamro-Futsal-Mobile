import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/helper/response_helper.dart';
import 'package:hamro_futsal/features/profile/data/data_source/feedback_data_source.dart';
import 'package:hamro_futsal/features/profile/data/model/feedback_history_model.dart';
import 'package:hamro_futsal/features/profile/data/model/feedback_option_model.dart';

final class FeedbackRepositoryImpl {
  FeedbackRepositoryImpl({FeedbackRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? FeedbackDataSourceImpl();

  final FeedbackRemoteDataSource _remoteDataSource;

  static FeedbackCatalog? _catalogCache;
  static Future<Either<AppException, FeedbackCatalog>>? _inFlightCatalog;

  Future<Either<AppException, FeedbackCatalog>> getCatalog({
    bool forceRefresh = false,
  }) {
    if (!forceRefresh && _catalogCache != null) {
      return Future<Either<AppException, FeedbackCatalog>>.value(
        right(_catalogCache!),
      );
    }

    if (!forceRefresh && _inFlightCatalog != null) {
      return _inFlightCatalog!;
    }

    final Future<Either<AppException, FeedbackCatalog>> future =
        _fetchCatalog();
    _inFlightCatalog = future;
    future.whenComplete(() {
      if (identical(_inFlightCatalog, future)) {
        _inFlightCatalog = null;
      }
    });
    return future;
  }

  Future<Either<AppException, FeedbackCatalog>> _fetchCatalog() async {
    final List<dynamic> responses =
        await Future.wait<dynamic>(<Future<dynamic>>[
          _remoteDataSource.getFeedbackTypes(),
          _remoteDataSource.getFeedbackCategories(),
        ]);

    final dynamic typesResponse = responses[0];
    final dynamic categoriesResponse = responses[1];

    if (typesResponse.isError()) {
      return left(ResponseHelper.error(typesResponse));
    }
    if (categoriesResponse.isError()) {
      return left(ResponseHelper.error(categoriesResponse));
    }

    try {
      final FeedbackCatalog catalog = FeedbackCatalog(
        types: _parseOptions(typesResponse.getValue()),
        categories: _parseOptions(categoriesResponse.getValue()),
      );
      _catalogCache = catalog;
      return right(catalog);
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse feedback options from server.',
          statusCode: 0,
        ),
      );
    }
  }

  Future<Either<AppException, bool>> submitFeedback({
    required String feedbackCategoryId,
    required String feedbackTypeId,
    required int rating,
    required String message,
    String? contactInfo,
  }) async {
    final response = await _remoteDataSource.submitFeedback(<String, dynamic>{
      'feedback_category_id':
          int.tryParse(feedbackCategoryId) ?? feedbackCategoryId,
      'feedback_type_id': int.tryParse(feedbackTypeId) ?? feedbackTypeId,
      'rating': rating,
      'message': message.trim(),
      'contact_info': (contactInfo ?? '').trim(),
    });

    if (response.isError()) {
      final AppException error = ResponseHelper.error(response);
      if (error.statusCode != 204) return left(error);
    }

    return right(true);
  }

  Future<Either<AppException, FeedbackListPage>> getMyFeedback({
    int perPage = 15,
  }) async {
    final response = await _remoteDataSource.getMyFeedback(perPage: perPage);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(FeedbackListPage.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse feedback list from server.',
          statusCode: 0,
        ),
      );
    }
  }

  Future<Either<AppException, FeedbackDetailsModel>> getFeedbackDetails(
    String feedbackId,
  ) async {
    final response = await _remoteDataSource.getFeedbackDetails(feedbackId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(FeedbackDetailsModel.fromResponse(response.getValue()));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: 'Could not parse feedback details from server.',
          statusCode: 0,
        ),
      );
    }
  }
}

List<FeedbackOptionModel> _parseOptions(dynamic payload) {
  final List<dynamic> list = _extractList(payload);
  return list
      .whereType<Map>()
      .map(
        (dynamic item) =>
            FeedbackOptionModel.fromJson(Map<String, dynamic>.from(item)),
      )
      .where(
        (FeedbackOptionModel item) =>
            item.id.isNotEmpty || item.name.isNotEmpty,
      )
      .toList(growable: false);
}

List<dynamic> _extractList(dynamic payload) {
  dynamic current = payload;
  for (int depth = 0; depth < 8; depth++) {
    if (current is List) return current;
    if (current is! Map) return const <dynamic>[];

    final Map<String, dynamic> map = Map<String, dynamic>.from(current);
    final dynamic next =
        map['data'] ??
        map['feedback_categories'] ??
        map['feedback_types'] ??
        map['items'] ??
        map['results'] ??
        map['categories'] ??
        map['types'];
    if (next == null) return const <dynamic>[];
    current = next;
  }
  return const <dynamic>[];
}
