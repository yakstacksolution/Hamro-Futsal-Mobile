part of 'public_court_options_bloc.dart';

sealed class PublicCourtOptionsEvent extends Equatable {
  const PublicCourtOptionsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchPublicCourtOptionsEvent extends PublicCourtOptionsEvent {
  const FetchPublicCourtOptionsEvent();
}

final class FetchPublicAmenitiesEvent extends PublicCourtOptionsEvent {
  const FetchPublicAmenitiesEvent();
}

final class FetchPublicFacilitiesEvent extends PublicCourtOptionsEvent {
  const FetchPublicFacilitiesEvent();
}

/// Loads `GET /match-formate` on its own, for screens that need the formats
/// (and their ids) without the rest of the court-options payload.
final class FetchPublicMatchFormatsEvent extends PublicCourtOptionsEvent {
  const FetchPublicMatchFormatsEvent();
}
