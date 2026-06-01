part of 'public_venue_bloc.dart';

enum PublicVenueStatus { idle, loading, success, failure }

final class PublicVenueState extends Equatable {
  const PublicVenueState({
    this.status = PublicVenueStatus.idle,
    this.venues = const <PublicVenueModel>[],
    this.page = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final PublicVenueStatus status;
  final List<PublicVenueModel> venues;
  final int page;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? errorMessage;

  PublicVenueState copyWith({
    PublicVenueStatus? status,
    List<PublicVenueModel>? venues,
    int? page,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PublicVenueState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    venues,
    page,
    hasReachedMax,
    isLoadingMore,
    errorMessage,
  ];
}
