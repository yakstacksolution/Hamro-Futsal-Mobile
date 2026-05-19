part of 'venue_court_bloc.dart';

enum VenueCourtStatus { idle, loading, success, failure }

final class VenueCourtState extends Equatable {
  const VenueCourtState({
    this.status = VenueCourtStatus.idle,
    this.venues = const <VenueCourtModel>[],
    this.errorMessage,
  });

  final VenueCourtStatus status;
  final List<VenueCourtModel> venues;
  final String? errorMessage;

  VenueCourtState copyWith({
    VenueCourtStatus? status,
    List<VenueCourtModel>? venues,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VenueCourtState(
      status: status ?? this.status,
      venues: venues ?? this.venues,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, venues, errorMessage];
}
