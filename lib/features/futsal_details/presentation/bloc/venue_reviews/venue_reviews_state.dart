part of 'venue_reviews_bloc.dart';

enum VenueReviewsStatus {
  idle,
  loading,
  refreshing,
  loadingMore,
  success,
  failure,
}

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

  final VenueReviewPageModel page;

  final List<VenueReviewModel> reviews;

  final int venueId;
  final String? errorMessage;

  final ReviewChangeRequestStatus changeRequestStatus;
  final String? changeRequestMessage;

  final int changeRequestReviewId;

  bool get isLoading => status == VenueReviewsStatus.loading;
  bool get isLoadingMore => status == VenueReviewsStatus.loadingMore;
  bool get isFailure => status == VenueReviewsStatus.failure;
  bool get isEmpty => reviews.isEmpty && status == VenueReviewsStatus.success;

  bool get isSubmittingChangeRequest =>
      changeRequestStatus == ReviewChangeRequestStatus.submitting;

  bool get canLoadMore => page.hasMorePages && venueId > 0;

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
