part of 'venue_reviews_bloc.dart';

enum VenueReviewsStatus {
  idle,
  loading,
  refreshing,
  loadingMore,
  success,
  failure,
}

/// Lifecycle of one `/reviews/{review}/change-request` submission.
enum ReviewChangeRequestStatus { idle, submitting, success, failure }

final class VenueReviewsState extends Equatable {
  const VenueReviewsState({
    this.status = VenueReviewsStatus.idle,
    this.page = VenueReviewPageModel.empty,
    this.reviews = const <VenueReviewModel>[],
    this.venueId = 0,
    this.errorMessage,
    this.changeRequestStatus = ReviewChangeRequestStatus.idle,
    this.changeRequestMessage,
    this.changeRequestReviewId = 0,
  });

  final VenueReviewsStatus status;

  /// The most recent page's metadata — counts, rating summary, paging.
  final VenueReviewPageModel page;

  /// Every review loaded so far, across pages.
  final List<VenueReviewModel> reviews;

  final int venueId;
  final String? errorMessage;

  /// Tracked apart from [status] so a submission never disturbs the list: the
  /// rows stay put while the request is in flight, and the page only shows a
  /// message when it settles.
  final ReviewChangeRequestStatus changeRequestStatus;
  final String? changeRequestMessage;

  /// The review the in-flight (or just-settled) request belongs to, so a single
  /// card can show its own spinner.
  final int changeRequestReviewId;

  bool get isLoading => status == VenueReviewsStatus.loading;
  bool get isLoadingMore => status == VenueReviewsStatus.loadingMore;
  bool get isFailure => status == VenueReviewsStatus.failure;
  bool get isEmpty => reviews.isEmpty && status == VenueReviewsStatus.success;

  bool get isSubmittingChangeRequest =>
      changeRequestStatus == ReviewChangeRequestStatus.submitting;

  bool get canLoadMore => page.hasMorePages && venueId > 0;

  /// Total the server reports, falling back to what is loaded.
  int get totalCount => page.total > 0 ? page.total : reviews.length;

  VenueReviewsState copyWith({
    VenueReviewsStatus? status,
    VenueReviewPageModel? page,
    List<VenueReviewModel>? reviews,
    int? venueId,
    String? errorMessage,
    bool clearError = false,
    ReviewChangeRequestStatus? changeRequestStatus,
    String? changeRequestMessage,
    int? changeRequestReviewId,
    bool clearChangeRequestMessage = false,
  }) {
    return VenueReviewsState(
      status: status ?? this.status,
      page: page ?? this.page,
      reviews: reviews ?? this.reviews,
      venueId: venueId ?? this.venueId,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      changeRequestStatus: changeRequestStatus ?? this.changeRequestStatus,
      changeRequestMessage: clearChangeRequestMessage
          ? null
          : changeRequestMessage ?? this.changeRequestMessage,
      changeRequestReviewId:
          changeRequestReviewId ?? this.changeRequestReviewId,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    page,
    reviews,
    venueId,
    errorMessage,
    changeRequestStatus,
    changeRequestMessage,
    changeRequestReviewId,
  ];
}
