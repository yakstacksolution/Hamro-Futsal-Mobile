part of 'public_venue_bloc.dart';

enum PublicVenueStatus { idle, loading, success, failure }

final class PublicVenueState extends Equatable {
  const PublicVenueState({
    this.status = PublicVenueStatus.idle,
    this.venues = const <PublicListingVenueModel>[],
    this.page = 0,
    this.total = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.loadMoreErrorMessage,
    this.activeFilter = VenueFilter.empty,
    this.origin,
    this.errorMessage,
  });

  final PublicVenueStatus status;
  final List<PublicListingVenueModel> venues;

  /// Highest page number currently loaded (`pagination.current_page`).
  final int page;

  /// Total venues the server reports across all pages (`pagination.total`).
  final int total;

  final bool hasReachedMax;
  final bool isLoadingMore;

  /// Error from the last *load-more* request. Kept apart from [errorMessage] so
  /// a failed page never replaces the venues already on screen, and so the
  /// scroll listener can stop auto-retrying (see [canLoadMore]).
  final String? loadMoreErrorMessage;

  final VenueFilter activeFilter;

  /// Origin sent as `latitude`/`longitude` with this listing, and reused for
  /// every subsequent page so all distances share one reference point. Null
  /// when no location fix was available.
  final VenueOrigin? origin;

  /// Error from the first-page fetch.
  final String? errorMessage;

  /// Whether the scroll listener may request the next page right now.
  ///
  /// False while a page is in flight, at the end of the list, before the first
  /// page has loaded, and after a load-more failure — that last case needs an
  /// explicit [RetryLoadMorePublicVenuesEvent], otherwise every scroll tick
  /// would re-fire the request that just failed.
  bool get canLoadMore =>
      status == PublicVenueStatus.success &&
      !isLoadingMore &&
      !hasReachedMax &&
      loadMoreErrorMessage == null;

  /// True when a load-more attempt failed and is waiting on a retry.
  bool get hasLoadMoreError => loadMoreErrorMessage != null;

  /// Whether the loaded listing was requested with an origin — i.e. whether the
  /// venues can carry `distance_km`.
  bool get hasOrigin => origin != null;

  PublicVenueState copyWith({
    PublicVenueStatus? status,
    List<PublicListingVenueModel>? venues,
    int? page,
    int? total,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? loadMoreErrorMessage,
    bool clearLoadMoreError = false,
    VenueFilter? activeFilter,
    VenueOrigin? origin,
    bool clearOrigin = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublicVenueState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      page: page ?? this.page,
      total: total ?? this.total,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreErrorMessage: clearLoadMoreError
          ? null
          : (loadMoreErrorMessage ?? this.loadMoreErrorMessage),
      activeFilter: activeFilter ?? this.activeFilter,
      origin: clearOrigin ? null : (origin ?? this.origin),
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    venues,
    page,
    total,
    hasReachedMax,
    isLoadingMore,
    loadMoreErrorMessage,
    activeFilter,
    origin,
    errorMessage,
  ];
}
