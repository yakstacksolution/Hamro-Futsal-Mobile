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

  final int page;

  final int total;

  final bool hasReachedMax;
  final bool isLoadingMore;

  final String? loadMoreErrorMessage;

  final VenueFilter activeFilter;

  final VenueOrigin? origin;

  final String? errorMessage;

  bool get canLoadMore =>
      status == PublicVenueStatus.success &&
      !isLoadingMore &&
      !hasReachedMax &&
      loadMoreErrorMessage == null;

  bool get hasLoadMoreError => loadMoreErrorMessage != null;

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
