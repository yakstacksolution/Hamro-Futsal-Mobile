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
