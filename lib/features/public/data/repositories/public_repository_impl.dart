import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/public/data/model/category_filter_model.dart';
import 'package:hamro_footsall/features/public/data/data_source/public_remote_data_source.dart';
import 'package:hamro_footsall/features/public/data/model/public_faq_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_help_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/core/utils/string_constants.dart';

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
          errorMessage: StringConstants.couldNotParsePublicServicesFromServer,
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
          errorMessage: StringConstants.couldNotParsePublicPackagesFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicFaqModel>>> getFaqs() async {
    final response = await _remoteDataSource.getFaqs();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final List<dynamic> items = _extractList(
        payload: response.getValue(),
        key: 'faqs',
        alternateKeys: const <String>['faq'],
      );
      return right(
        items
            .whereType<Map>()
            .map(
              (Map item) =>
                  PublicFaqModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .where((PublicFaqModel faq) => faq.question.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseFaqsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicHelpModel>>> getHelps() async {
    final response = await _remoteDataSource.getHelps();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final List<dynamic> items = _extractList(
        payload: response.getValue(),
        key: 'helps',
        alternateKeys: const <String>['help', 'help_topics'],
      );
      return right(
        items
            .whereType<Map>()
            .map(
              (Map item) =>
                  PublicHelpModel.fromJson(Map<String, dynamic>.from(item)),
            )
            .where((PublicHelpModel help) => help.title.isNotEmpty)
            .toList(),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseHelpTopicsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getCourtTypes() async {
    final response = await _remoteDataSource.getCourtTypes();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(_extractOptions(response.getValue(), 'court_types'));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseCourtTypesFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicOptionModel>>>
  getMatchFormats() async {
    final response = await _remoteDataSource.getMatchFormats();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(_extractOptions(response.getValue(), 'match_formats'));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseMatchFormatsFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getAmenities() async {
    final response = await _remoteDataSource.getAmenities();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(_extractOptions(response.getValue(), 'amenities'));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseAmenitiesFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getFacilities() async {
    final response = await _remoteDataSource.getFacilities();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      return right(_extractOptions(response.getValue(), 'facilities'));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseFacilitiesFromServer,
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
          errorMessage: StringConstants.couldNotParsePublicTemplatesFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, PublicListingVenuePage>> getVenueList({
    int page = 1,
    int perPage = 10,
    VenueFilter? filter,
  }) async {
    final int safePage = page < 1 ? 1 : page;
    final int safePerPage = perPage < 1 ? 10 : perPage;

    final response = await _remoteDataSource.getVenueList(
      page: safePage,
      perPage: safePerPage,
      filter: filter,
    );
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final dynamic payload = response.getValue();
      final Map<String, dynamic> json = payload is Map
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{};
      return right(PublicListingVenuePage.fromJson(json));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseVenuesFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  /// Wishlisted venues — same payload shape as the public venue listing, so
  /// it reuses [PublicListingVenuePage] wholesale.
  @override
  Future<Either<AppException, PublicListingVenuePage>> getWishlist() async {
    final response = await _remoteDataSource.getWishlist();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final dynamic payload = response.getValue();
      final Map<String, dynamic> json = payload is Map
          ? Map<String, dynamic>.from(payload)
          : <String, dynamic>{};
      return right(PublicListingVenuePage.fromJson(json));
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseYourWishlistFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  @override
  Future<Either<AppException, bool>> toggleWishlist(int venueId) async {
    final response = await _remoteDataSource.toggleWishlist(venueId);
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }
    return right(true);
  }

  @override
  Future<Either<AppException, List<CategoryFilterModel>>>
  getCategoryFilter() async {
    final response = await _remoteDataSource.getCategoryFilter();
    if (response.isError()) {
      return left(ResponseHelper.error(response));
    }

    try {
      final List<dynamic> items = _extractList(
        payload: response.getValue(),
        key: 'filters',
        alternateKeys: const <String>[
          'filter',
          'categories',
          'category_filter',
        ],
      );
      return right(
        items
            .map(_categoryFilterFromAny)
            .whereType<CategoryFilterModel>()
            .where(
              (CategoryFilterModel item) =>
                  item.isActive && item.title.trim().isNotEmpty,
            )
            .toList(growable: false),
      );
    } catch (_) {
      return left(
        DefaultException(
          errorMessage: StringConstants.couldNotParseCategoryFiltersFromServer,
          statusCode: 0,
        ),
      );
    }
  }

  CategoryFilterModel? _categoryFilterFromAny(dynamic item) {
    if (item is Map) {
      return CategoryFilterModel.fromJson(Map<String, dynamic>.from(item));
    }
    final String title = item?.toString().trim() ?? '';
    if (title.isEmpty) return null;
    return CategoryFilterModel(
      id: title,
      title: title,
      slug: title.toLowerCase(),
      status: 1,
      raw: <String, dynamic>{'title': title, 'status': 1},
    );
  }

  List<PublicOptionModel> _extractOptions(dynamic payload, String key) {
    final List<dynamic> items = _extractList(
      payload: payload,
      key: key,
      alternateKeys: key == 'match_formats'
          ? const <String>['match_formates', 'match_format', 'match_formate']
          : const <String>[],
    );
    return items
        .map(_optionFromAny)
        .whereType<PublicOptionModel>()
        .where((PublicOptionModel item) => item.name.trim().isNotEmpty)
        .toList(growable: false);
  }

  PublicOptionModel? _optionFromAny(dynamic item) {
    if (item is Map) {
      return PublicOptionModel.fromJson(Map<String, dynamic>.from(item));
    }
    final String name = item?.toString().trim() ?? '';
    if (name.isEmpty) return null;
    return PublicOptionModel(
      id: name,
      name: name,
      raw: <String, dynamic>{'name': name},
    );
  }

  List<dynamic> _extractTemplateList(dynamic payload) {
    final List<dynamic> directTemplates = _buildTemplatesFromKnownKeys(payload);
    if (directTemplates.isNotEmpty) {
      return directTemplates;
    }

    if (payload is Map<String, dynamic>) {
      final dynamic nestedTemplates = payload['data'];
      if (nestedTemplates is Map<String, dynamic> &&
          nestedTemplates['templates'] is List) {
        return nestedTemplates['templates'] as List<dynamic>;
      }

      final List<dynamic> nestedDirectTemplates = _buildTemplatesFromKnownKeys(
        nestedTemplates,
      );
      if (nestedDirectTemplates.isNotEmpty) {
        return nestedDirectTemplates;
      }
    }

    return _extractList(payload: payload, key: 'templates');
  }

  List<dynamic> _buildTemplatesFromKnownKeys(dynamic payload) {
    if (payload is! Map) return const <dynamic>[];

    final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
    const List<String> knownKeys = <String>[
      'futsal_description',
      'description',
      'cancelation_policy',
      'cancellation_policy',
      'futsal_rules',
    ];

    final List<Map<String, dynamic>> templates = <Map<String, dynamic>>[];
    for (final String key in knownKeys) {
      if (!map.containsKey(key)) continue;
      templates.add(<String, dynamic>{
        'id': key,
        'key': key,
        'slug': key,
        'title': key,
        'content': map[key],
        'description': map[key],
      });
    }

    return templates;
  }

  List<dynamic> _extractList({
    required dynamic payload,
    required String key,
    List<String> alternateKeys = const <String>[],
  }) {
    if (payload is List) return payload;

    if (payload is Map<String, dynamic>) {
      final dynamic direct = _valueForKeys(payload, key, alternateKeys);
      if (direct is List) return direct;
      // A single object response (e.g. `data.help`) is treated as one item.
      if (direct is Map) return <dynamic>[direct];

      final dynamic data =
          payload['data'] ?? payload['items'] ?? payload['results'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final dynamic nested =
            _valueForKeys(data, key, alternateKeys) ??
            data['items'] ??
            data['results'];
        if (nested is List) return nested;
        if (nested is Map) return <dynamic>[nested];
      }
    }

    if (payload is Map) {
      final Map<String, dynamic> map = Map<String, dynamic>.from(payload);
      return _extractList(payload: map, key: key, alternateKeys: alternateKeys);
    }

    return const <dynamic>[];
  }

  dynamic _valueForKeys(
    Map<String, dynamic> map,
    String key,
    List<String> alternateKeys,
  ) {
    if (map.containsKey(key)) return map[key];
    for (final String alternateKey in alternateKeys) {
      if (map.containsKey(alternateKey)) return map[alternateKey];
    }
    return null;
  }
}
