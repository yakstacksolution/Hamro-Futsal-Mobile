part of 'venue_reviews_bloc.dart';

const int kVenueReviewsPreviewSize = 5;

const int kVenueReviewsPageSize = 5;

sealed class VenueReviewsEvent extends Equatable {
  const VenueReviewsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchVenueReviewsEvent extends VenueReviewsEvent {
  const FetchVenueReviewsEvent({
    required this.venueId,
    this.perPage = kVenueReviewsPageSize,
    this.refresh = false,
  });

  final int venueId;
  final int perPage;

  final bool refresh;

  @override
  List<Object?> get props => <Object?>[venueId, perPage, refresh];
}

final class LoadMoreVenueReviewsEvent extends VenueReviewsEvent {
  const LoadMoreVenueReviewsEvent();
}

final class SubmitReviewChangeRequestEvent extends VenueReviewsEvent {
  const SubmitReviewChangeRequestEvent({
    required this.reviewId,
    required this.input,
  });

  final int reviewId;
  final ReviewChangeRequestInput input;

  @override
  List<Object?> get props => <Object?>[
    reviewId,
    input.type,
    input.reason,
    input.requestedReview,
  ];
}
