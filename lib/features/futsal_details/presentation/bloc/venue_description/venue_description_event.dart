part of 'venue_description_bloc.dart';

sealed class VenueDescriptionEvent extends Equatable {
  const VenueDescriptionEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchVenueDescriptionEvent extends VenueDescriptionEvent {
  const FetchVenueDescriptionEvent({required this.venueSlug});

  final String venueSlug;

  @override
  List<Object?> get props => <Object?>[venueSlug];
}
