part of 'public_venue_bloc.dart';

sealed class PublicVenueEvent extends Equatable {
  const PublicVenueEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the first page (and resets any previously loaded pages).
final class FetchPublicVenuesEvent extends PublicVenueEvent {
  const FetchPublicVenuesEvent({
    this.filter = VenueFilter.empty,
    this.origin,
    this.completer,
  });

  final VenueFilter filter;

  /// Origin to measure `distance_km` from. Omit to use the current device fix.
  final VenueOrigin? origin;

  /// Completed once this fetch has finished — emitted, failed or been
  /// superseded. Pull to refresh awaits it instead of watching the state
  /// stream: an unchanged (cached) result emits nothing, so a stream wait
  /// would never end. Deliberately left out of [props].
  final Completer<void>? completer;

  @override
  List<Object?> get props => <Object?>[filter, origin];
}

/// Appends the next page to the already-loaded venues.
///
/// Ignored unless [PublicVenueState.canLoadMore], so the scroll listener can
/// fire it freely.
final class LoadMorePublicVenuesEvent extends PublicVenueEvent {
  const LoadMorePublicVenuesEvent();
}

/// Clears a load-more failure and retries the same page — the user tapping
/// "Retry" in the list footer.
final class RetryLoadMorePublicVenuesEvent extends PublicVenueEvent {
  const RetryLoadMorePublicVenuesEvent();
}
