part of 'venue_description_bloc.dart';

enum VenueDescriptionStatus { idle, loading, success, failure }

final class VenueDescriptionState extends Equatable {
  const VenueDescriptionState({
    this.status = VenueDescriptionStatus.idle,
    this.venueDescription = const VenueDescriptionModel(),
    this.errorMessage,
  });

  final VenueDescriptionStatus status;
  final VenueDescriptionModel venueDescription;
  final String? errorMessage;

  VenueDescriptionState copyWith({
    VenueDescriptionStatus? status,
    VenueDescriptionModel? venueDescription,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VenueDescriptionState(
      status: status ?? this.status,
      venueDescription: venueDescription ?? this.venueDescription,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, venueDescription, errorMessage];
}
