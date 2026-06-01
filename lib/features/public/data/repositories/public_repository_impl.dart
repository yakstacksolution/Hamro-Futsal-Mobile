import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/helper/response_helper.dart';
import 'package:hamro_footsall/features/public/data/data_source/public_remote_data_source.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
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
          errorMessage: 'Could not parse court types from server.',
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
          errorMessage: 'Could not parse match formats from server.',
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
          errorMessage: 'Could not parse amenities from server.',
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
          errorMessage: 'Could not parse facilities from server.',
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

  @override
  Future<Either<AppException, PublicVenuePage>> getVenueList({
    int page = 1,
    int perPage = 10,
  }) async {
    // TODO: Swap the dummy generator below for the real endpoint once the
    // backend `/public/venue-list` response is finalised:
    //
    //   final response = await _remoteDataSource.getVenueList(
    //     page: page,
    //     perPage: perPage,
    //   );
    //   if (response.isError()) return left(ResponseHelper.error(response));
    //   return right(PublicVenuePage.fromJson(
    //     Map<String, dynamic>.from(response.getValue() as Map),
    //   ));
    final int safePage = page < 1 ? 1 : page;
    final int safePerPage = perPage < 1 ? 10 : perPage;

    final List<PublicVenueModel> catalog = _dummyVenues;
    final int start = (safePage - 1) * safePerPage;
    if (start >= catalog.length) {
      return right(
        PublicVenuePage(
          venues: const <PublicVenueModel>[],
          page: safePage,
          perPage: safePerPage,
          total: catalog.length,
        ),
      );
    }

    final int end = (start + safePerPage).clamp(0, catalog.length);
    return right(
      PublicVenuePage(
        venues: catalog.sublist(start, end),
        page: safePage,
        perPage: safePerPage,
        total: catalog.length,
      ),
    );
  }

  /// Temporary dummy venues used to populate the home page until the real
  /// `/public/venue-list` endpoint is wired in.
  static final List<PublicVenueModel> _dummyVenues =
      List<PublicVenueModel>.generate(24, (int index) {
        final Map<String, dynamic> seed =
            _venueSeeds[index % _venueSeeds.length];
        return PublicVenueModel(
          id: 'venue_${index + 1}',
          name: seed['name'] as String,
          location: seed['location'] as String,
          price: seed['price'] as String,
          rating: seed['rating'] as double,
          reviewCount: seed['reviewCount'] as int,
          image: seed['image'] as String,
          isOpen: seed['isOpen'] as bool,
          distance: seed['distance'] as String,
          features: List<String>.from(seed['features'] as List<String>),
          raw: <String, dynamic>{},
        );
      });

  static const List<Map<String, dynamic>> _venueSeeds = <Map<String, dynamic>>[
    <String, dynamic>{
      'name': 'Goal Arena Futsal',
      'location': 'Baneshwor, Kathmandu',
      'price': 'Rs. 1,800',
      'rating': 4.8,
      'reviewCount': 128,
      'image':
          'https://images.unsplash.com/photo-1517466787929-bc90951d0974?auto=format&fit=crop&w=1200&q=80',
      'isOpen': true,
      'distance': '1.2 km',
      'features': <String>['Indoor', 'Parking', 'Lights'],
    },
    <String, dynamic>{
      'name': 'Urban Kick Center',
      'location': 'Lalitpur, Jawalakhel',
      'price': 'Rs. 2,000',
      'rating': 4.6,
      'reviewCount': 94,
      'image':
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&w=1200&q=80',
      'isOpen': true,
      'distance': '2.8 km',
      'features': <String>['Turf', 'Shower', 'Cafe'],
    },
    <String, dynamic>{
      'name': 'Champion 5A Side',
      'location': 'Koteshwor, Kathmandu',
      'price': 'Rs. 1,500',
      'rating': 4.5,
      'reviewCount': 76,
      'image':
          'https://images.unsplash.com/photo-1486286701208-1d58e9338013?auto=format&fit=crop&w=1200&q=80',
      'isOpen': false,
      'distance': '3.5 km',
      'features': <String>['Outdoor', 'Training', 'Parking'],
    },
    <String, dynamic>{
      'name': 'Royal Futsal Hub',
      'location': 'Bhaktapur',
      'price': 'Rs. 1,700',
      'rating': 4.7,
      'reviewCount': 111,
      'image':
          'https://images.unsplash.com/photo-1552667466-07770ae110d0?auto=format&fit=crop&w=1200&q=80',
      'isOpen': true,
      'distance': '5.1 km',
      'features': <String>['Indoor', 'Cafe', 'Events'],
    },
  ];

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

      final dynamic data =
          payload['data'] ?? payload['items'] ?? payload['results'];
      if (data is List) return data;
      if (data is Map<String, dynamic>) {
        final dynamic nested =
            _valueForKeys(data, key, alternateKeys) ??
            data['items'] ??
            data['results'];
        if (nested is List) return nested;
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
