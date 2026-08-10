part of 'venue_court_bloc.dart';

enum VenueCourtStatus { idle, loading, success, failure }

final class VenueCourtState extends Equatable {
  const VenueCourtState({
    this.status = VenueCourtStatus.idle,
    this.venues = const <VenueCourtModel>[],
    this.errorMessage,
    this.currentPage = 0,
    this.lastPage = 1,
    this.total = 0,
    this.hasMorePages = false,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.refreshTick = 0,
  });

  final VenueCourtStatus status;
  final List<VenueCourtModel> venues;
  final String? errorMessage;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool hasMorePages;
  final bool isLoadingMore;
  final String? loadMoreError;
  final int refreshTick;

  VenueCourtState copyWith({
    VenueCourtStatus? status,
    List<VenueCourtModel>? venues,
    String? errorMessage,
    bool clearError = false,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? hasMorePages,
    bool? isLoadingMore,
    String? loadMoreError,
    bool clearLoadMoreError = false,
    int? refreshTick,
  }) {
    return VenueCourtState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: clearLoadMoreError
          ? null
          : loadMoreError ?? this.loadMoreError,
      refreshTick: refreshTick ?? this.refreshTick,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    venues,
    errorMessage,
    currentPage,
    lastPage,
    total,
    hasMorePages,
    isLoadingMore,
    loadMoreError,
    refreshTick,
  ];
}
