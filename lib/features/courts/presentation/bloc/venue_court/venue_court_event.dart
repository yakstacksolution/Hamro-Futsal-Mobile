part of 'venue_court_bloc.dart';

sealed class VenueCourtEvent extends Equatable {
  const VenueCourtEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchVenueCourtEvent extends VenueCourtEvent {
  const FetchVenueCourtEvent();
}

final class UpsertVenueCourtLocallyEvent extends VenueCourtEvent {
  const UpsertVenueCourtLocallyEvent({
    required this.venueId,
    required this.court,
  });

  final int venueId;
  final CourtDraft court;

  @override
  List<Object?> get props => <Object?>[venueId, court];
}

/// Removes a court from the cached venues without hitting the API. Dispatched
/// after a successful delete-court call so the list reflects the change.
final class RemoveVenueCourtLocallyEvent extends VenueCourtEvent {
  const RemoveVenueCourtLocallyEvent({
    required this.venueId,
    required this.court,
  });

  final int? venueId;
  final CourtDraft court;

  @override
  List<Object?> get props => <Object?>[venueId, court];
}
