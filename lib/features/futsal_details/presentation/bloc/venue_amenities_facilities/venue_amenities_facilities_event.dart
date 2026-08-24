part of 'venue_amenities_facilities_bloc.dart';

sealed class VenueAmenitiesFacilitiesEvent extends Equatable {
  const VenueAmenitiesFacilitiesEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchVenueAmenitiesFacilitiesEvent
    extends VenueAmenitiesFacilitiesEvent {
  const FetchVenueAmenitiesFacilitiesEvent({required this.venueId});

  final int venueId;

  @override
  List<Object?> get props => <Object?>[venueId];
}
