part of 'public_venue_bloc.dart';

sealed class PublicVenueEvent extends Equatable {
  const PublicVenueEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchPublicVenuesEvent extends PublicVenueEvent {
  const FetchPublicVenuesEvent({
    this.filter = VenueFilter.empty,
    this.origin,
    this.completer,
  });

  final VenueFilter filter;

  final VenueOrigin? origin;

  final Completer<void>? completer;

  @override
  List<Object?> get props => <Object?>[filter, origin];
}

final class LoadMorePublicVenuesEvent extends PublicVenueEvent {
  const LoadMorePublicVenuesEvent();
}

final class RetryLoadMorePublicVenuesEvent extends PublicVenueEvent {
  const RetryLoadMorePublicVenuesEvent();
}
