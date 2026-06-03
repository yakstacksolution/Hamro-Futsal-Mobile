part of 'public_venue_bloc.dart';

sealed class PublicVenueEvent extends Equatable {
  const PublicVenueEvent();

  @override
  List<Object?> get props => <Object?>[];
}

/// Loads the first page (and resets any previously loaded pages).
final class FetchPublicVenuesEvent extends PublicVenueEvent {
  const FetchPublicVenuesEvent({this.filter = VenueFilter.empty});

  final VenueFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

/// Appends the next page to the already-loaded venues.
final class LoadMorePublicVenuesEvent extends PublicVenueEvent {
  const LoadMorePublicVenuesEvent();
}
