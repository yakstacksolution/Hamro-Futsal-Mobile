part of 'public_court_options_bloc.dart';

sealed class PublicCourtOptionsEvent extends Equatable {
  const PublicCourtOptionsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchPublicCourtOptionsEvent extends PublicCourtOptionsEvent {
  const FetchPublicCourtOptionsEvent();
}
