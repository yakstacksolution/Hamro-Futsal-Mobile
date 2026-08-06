import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_venue_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_venues_use_case.dart';
import 'package:hamro_footsall/features/public/presentation/bloc/public_venue/public_venue_bloc.dart';
import 'package:hamro_footsall/features/public/presentation/models/venue_filter.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';
import 'package:hamro_footsall/features/public/data/model/category_filter_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_faq_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_help_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';

/// The live `GET /venues` envelope: `data.venues` + `data.pagination`.
Map<String, dynamic> venuePayload({
  required int currentPage,
  required int lastPage,
  required int perPage,
  required int total,
  required List<int> ids,
}) {
  return <String, dynamic>{
    'status': 'success',
    'message': 'Venues fetched successfully.',
    'data': <String, dynamic>{
      'venues': ids
          .map(
            (int id) => <String, dynamic>{
              'id': id,
              'name': 'Venue $id',
              'slug': 'venue-$id',
              'address': 'Kathmandu',
              'price': 1500,
              'max_player': 12,
              'is_open': false,
              'court_types': <dynamic>[
                <String, dynamic>{
                  'id': 1,
                  'name': 'Indoor Turf',
                  'slug': 'indoor-turf',
                },
              ],
              'venue_gallery_images': <dynamic>[
                <String, dynamic>{
                  'id': id,
                  'media_id': id,
                  'image_url': null,
                  'sort_order': 1,
                },
              ],
              'longitude': '85.28400990',
              'latitude': '27.73306600',
              'distance_km': id.toDouble(),
            },
          )
          .toList(),
      'pagination': <String, dynamic>{
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
        'from': ((currentPage - 1) * perPage) + 1,
        'to': ((currentPage - 1) * perPage) + ids.length,
        'has_more_pages': currentPage < lastPage,
      },
    },
  };
}

/// Stand-in for the device fix, so the bloc never touches the GPS in tests.
VenueOrigin? _testOrigin() => (latitude: 27.7172, longitude: 85.3240);

void main() {
  group('PublicListingVenuePage.fromJson', () {
    test('parses the live second-page envelope and distance values', () {
      final PublicListingVenuePage page = PublicListingVenuePage.fromJson(
        <String, dynamic>{
          'status': 'success',
          'message': 'Venues fetched successfully.',
          'data': <String, dynamic>{
            'venues': <dynamic>[
              <String, dynamic>{
                'id': 36,
                'name': 'KickOff Futsal',
                'longitude': '85.55195510',
                'latitude': '27.61691800',
                'distance_km': 21.53,
              },
              <String, dynamic>{
                'id': 35,
                'name': 'Victory Futsal',
                'distance_km': '184.5',
              },
            ],
            'pagination': <String, dynamic>{
              'current_page': 2,
              'last_page': 2,
              'per_page': 5,
              'total': 9,
              'from': 6,
              'to': 9,
              'has_more_pages': false,
            },
          },
        },
      );

      expect(page.venues, hasLength(2));
      expect(page.venues.first.distanceKm, 21.53);
      expect(page.venues.first.latitude, 27.616918);
      expect(page.venues.first.longitude, 85.5519551);
      expect(page.venues.last.distanceKm, 184.5);
      expect(page.page, 2);
      expect(page.lastPage, 2);
      expect(page.from, 6);
      expect(page.to, 9);
      expect(page.hasMore, isFalse);
    });

    test('parses the live single-page envelope', () {
      final PublicListingVenuePage page = PublicListingVenuePage.fromJson(
        venuePayload(
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: 9,
          ids: <int>[33, 36, 2, 37, 35, 1, 32, 34, 8],
        ),
      );

      expect(page.venues, hasLength(9));
      expect(page.venues.first.id, 33);
      expect(page.venues.first.name, 'Venue 33');
      expect(page.venues.first.distanceKm, 33);
      expect(page.venues.first.distanceMeters, 33000);
      expect(page.page, 1);
      expect(page.perPage, 10);
      expect(page.total, 9);
      expect(page.lastPage, 1);
      expect(page.from, 1);
      expect(page.to, 9);
      expect(page.hasMore, isFalse);
    });

    test('trusts has_more_pages over the page-size estimate', () {
      final PublicListingVenuePage page = PublicListingVenuePage.fromJson(
        venuePayload(
          currentPage: 1,
          lastPage: 3,
          perPage: 10,
          total: 25,
          ids: <int>[1, 2, 3],
        ),
      );

      expect(page.hasMore, isTrue);
    });

    test('treats an empty page as the end of the list', () {
      final PublicListingVenuePage page = PublicListingVenuePage.fromJson(
        venuePayload(
          currentPage: 2,
          lastPage: 5,
          perPage: 10,
          total: 50,
          ids: const <int>[],
        ),
      );

      expect(page.venues, isEmpty);
      expect(page.hasMore, isFalse);
    });
  });

  group('PublicVenueBloc pagination', () {
    test('loads the first page and reports the total', () async {
      final _FakePublicRepository repository = _FakePublicRepository();
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      final Future<PublicVenueState> loaded = bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );
      bloc.add(const FetchPublicVenuesEvent());
      final PublicVenueState state = await loaded;

      expect(repository.requestedPages, <int>[1]);
      expect(state.venues.map((PublicListingVenueModel v) => v.id), <int>[
        1,
        2,
      ]);
      expect(state.page, 1);
      expect(state.total, 5);
      expect(state.hasReachedMax, isFalse);
      expect(state.canLoadMore, isTrue);
    });

    test('appends pages until the last one and then stops', () async {
      final _FakePublicRepository repository = _FakePublicRepository();
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      bloc.add(const FetchPublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );

      for (int expectedPage = 2; expectedPage <= 3; expectedPage++) {
        bloc.add(const LoadMorePublicVenuesEvent());
        await bloc.stream.firstWhere(
          (PublicVenueState state) =>
              state.page == expectedPage && !state.isLoadingMore,
        );
      }

      final PublicVenueState state = bloc.state;
      expect(repository.requestedPages, <int>[1, 2, 3]);
      expect(state.venues.map((PublicListingVenueModel v) => v.id), <int>[
        1,
        2,
        3,
        4,
        5,
      ]);
      expect(state.hasReachedMax, isTrue);
      expect(state.canLoadMore, isFalse);

      // At the end of the list, further scroll ticks must not hit the network.
      bloc.add(const LoadMorePublicVenuesEvent());
      await Future<void>.delayed(Duration.zero);
      expect(repository.requestedPages, <int>[1, 2, 3]);
    });

    test('drops venues already loaded when a page repeats them', () async {
      final _FakePublicRepository repository = _FakePublicRepository(
        // Page 2 re-sends venue 2 from page 1.
        pages: const <List<int>>[
          <int>[1, 2],
          <int>[2, 3],
        ],
        total: 4,
      );
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      bloc.add(const FetchPublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );
      bloc.add(const LoadMorePublicVenuesEvent());
      final PublicVenueState state = await bloc.stream.firstWhere(
        (PublicVenueState state) => state.page == 2 && !state.isLoadingMore,
      );

      expect(state.venues.map((PublicListingVenueModel v) => v.id), <int>[
        1,
        2,
        3,
      ]);
    });

    test(
      'a failed page keeps the loaded venues and blocks auto-retry',
      () async {
        final _FakePublicRepository repository = _FakePublicRepository(
          failFromPage: 2,
        );
        final PublicVenueBloc bloc = PublicVenueBloc(
          GetPublicVenuesUseCase(repository),
          perPage: 2,
        );
        addTearDown(bloc.close);

        bloc.add(const FetchPublicVenuesEvent());
        await bloc.stream.firstWhere(
          (PublicVenueState state) => state.status == PublicVenueStatus.success,
        );

        bloc.add(const LoadMorePublicVenuesEvent());
        final PublicVenueState failed = await bloc.stream.firstWhere(
          (PublicVenueState state) => state.hasLoadMoreError,
        );

        expect(failed.loadMoreErrorMessage, 'Venues unavailable.');
        expect(failed.venues, hasLength(2));
        expect(failed.status, PublicVenueStatus.success);
        expect(failed.canLoadMore, isFalse);

        // Scrolling again must not re-fire the request that just failed.
        bloc.add(const LoadMorePublicVenuesEvent());
        await Future<void>.delayed(Duration.zero);
        expect(repository.requestedPages, <int>[1, 2]);
      },
    );

    test('an explicit retry re-requests the failed page', () async {
      final _FakePublicRepository repository = _FakePublicRepository(
        failFromPage: 2,
        failOnce: true,
      );
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      bloc.add(const FetchPublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );
      bloc.add(const LoadMorePublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.hasLoadMoreError,
      );

      bloc.add(const RetryLoadMorePublicVenuesEvent());
      final PublicVenueState state = await bloc.stream.firstWhere(
        (PublicVenueState state) => state.page == 2 && !state.isLoadingMore,
      );

      expect(repository.requestedPages, <int>[1, 2, 2]);
      expect(state.venues.map((PublicListingVenueModel v) => v.id), <int>[
        1,
        2,
        3,
        4,
      ]);
      expect(state.hasLoadMoreError, isFalse);
    });

    test('sends the device origin with every page of one listing', () async {
      final _FakePublicRepository repository = _FakePublicRepository();
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      bloc.add(const FetchPublicVenuesEvent());
      final PublicVenueState first = await bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );
      expect(first.hasOrigin, isTrue);
      expect(first.origin?.latitude, 27.7172);

      bloc.add(const LoadMorePublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.page == 2 && !state.isLoadingMore,
      );

      // Same origin on both pages: distances across the list stay comparable.
      expect(repository.requestedOrigins, <(double?, double?)>[
        (27.7172, 85.3240),
        (27.7172, 85.3240),
      ]);
    });

    test('requests without an origin when there is no fix', () async {
      final _FakePublicRepository repository = _FakePublicRepository();
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: () => null,
      );
      addTearDown(bloc.close);

      bloc.add(const FetchPublicVenuesEvent());
      final PublicVenueState state = await bloc.stream.firstWhere(
        (PublicVenueState s) => s.status == PublicVenueStatus.success,
      );

      expect(state.hasOrigin, isFalse);
      expect(repository.requestedOrigins, <(double?, double?)>[(null, null)]);
    });

    test('an explicit event origin overrides the resolver', () async {
      final _FakePublicRepository repository = _FakePublicRepository();
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      bloc.add(
        const FetchPublicVenuesEvent(
          origin: (latitude: 26.6440, longitude: 88.0071),
        ),
      );
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );

      expect(repository.requestedOrigins, <(double?, double?)>[
        (26.6440, 88.0071),
      ]);
    });

    test('reloading the first page discards the accumulated pages', () async {
      final _FakePublicRepository repository = _FakePublicRepository();
      final PublicVenueBloc bloc = PublicVenueBloc(
        GetPublicVenuesUseCase(repository),
        perPage: 2,
        originResolver: _testOrigin,
      );
      addTearDown(bloc.close);

      bloc.add(const FetchPublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.status == PublicVenueStatus.success,
      );
      bloc.add(const LoadMorePublicVenuesEvent());
      await bloc.stream.firstWhere(
        (PublicVenueState state) => state.page == 2 && !state.isLoadingMore,
      );

      bloc.add(const FetchPublicVenuesEvent());
      final PublicVenueState state = await bloc.stream.firstWhere(
        (PublicVenueState state) =>
            state.status == PublicVenueStatus.success && state.page == 1,
      );

      expect(state.venues.map((PublicListingVenueModel v) => v.id), <int>[
        1,
        2,
      ]);
      expect(state.hasReachedMax, isFalse);
    });
  });
}

/// Serves the venue payload page by page, with optional failures.
class _FakePublicRepository extends PublicRepository {
  _FakePublicRepository({
    this.pages = const <List<int>>[
      <int>[1, 2],
      <int>[3, 4],
      <int>[5],
    ],
    this.total = 5,
    this.failFromPage,
    this.failOnce = false,
  });

  final List<List<int>> pages;
  final int total;

  /// Page number that fails, or null when every page succeeds.
  final int? failFromPage;

  /// Fail that page only on its first request (so a retry succeeds).
  final bool failOnce;

  final List<int> requestedPages = <int>[];

  /// (latitude, longitude) received per request, null when none was sent.
  final List<(double?, double?)> requestedOrigins = <(double?, double?)>[];

  int _failures = 0;

  @override
  Future<Either<AppException, PublicListingVenuePage>> getVenueList({
    int page = 1,
    int perPage = 10,
    VenueFilter? filter,
    double? latitude,
    double? longitude,
  }) async {
    requestedPages.add(page);
    requestedOrigins.add((latitude, longitude));

    if (failFromPage == page && (!failOnce || _failures == 0)) {
      _failures++;
      return left(
        DefaultException(errorMessage: 'Venues unavailable.', statusCode: 503),
      );
    }

    final List<int> ids = page <= pages.length
        ? pages[page - 1]
        : const <int>[];

    return right(
      PublicListingVenuePage.fromJson(
        venuePayload(
          currentPage: page,
          lastPage: pages.length,
          perPage: perPage,
          total: total,
          ids: ids,
        ),
      ),
    );
  }

  // The venue listing is the only endpoint under test.
  @override
  Future<Either<AppException, PublicListingVenuePage>> getWishlist() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<CategoryFilterModel>>> getCategoryFilter() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicFaqModel>>> getFaqs() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicHelpModel>>> getHelps() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicPackageModel>>> getPackages() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicServiceModel>>> getServices() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicTemplateModel>>> getTemplates() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getCourtTypes() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getMatchFormats() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getAmenities() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, List<PublicOptionModel>>> getFacilities() =>
      throw UnimplementedError();

  @override
  Future<Either<AppException, bool>> toggleWishlist(int venueId) =>
      throw UnimplementedError();
}
