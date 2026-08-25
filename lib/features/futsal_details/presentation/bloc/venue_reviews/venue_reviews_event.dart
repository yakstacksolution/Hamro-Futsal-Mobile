part of 'venue_reviews_bloc.dart';

/// Reviews shown inline on the venue details page before "View all".
const int kVenueReviewsPreviewSize = 5;

/// The venue reviews endpoint is consumed five rows at a time everywhere:
/// `/venues/{id}/reviews?page=1&per_page=5`.
const int kVenueReviewsPageSize = 5;

sealed class VenueReviewsEvent extends Equatable {
  const VenueReviewsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads page 1, replacing whatever was held.
final class FetchVenueReviewsEvent extends VenueReviewsEvent {
  const FetchVenueReviewsEvent({
    required this.venueId,
    this.perPage = kVenueReviewsPageSize,
    this.refresh = false,
  });

  final int venueId;
  final int perPage;

  /// Keeps the current rows on screen while refetching, for pull-to-refresh.
  final bool refresh;

  @override
  List<Object?> get props => <Object?>[venueId, perPage, refresh];
}

/// Appends the next page.
final class LoadMoreVenueReviewsEvent extends VenueReviewsEvent {
  const LoadMoreVenueReviewsEvent();
}
