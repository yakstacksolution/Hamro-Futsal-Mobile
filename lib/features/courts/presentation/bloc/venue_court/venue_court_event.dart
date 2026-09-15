part of 'venue_court_bloc.dart';

sealed class VenueCourtEvent extends Equatable {
  const VenueCourtEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchVenueCourtEvent extends VenueCourtEvent {
  const FetchVenueCourtEvent({this.silent = false, this.loadMore = false});

  final bool silent;
  final bool loadMore;

  @override
  List<Object?> get props => <Object?>[silent, loadMore];
}
