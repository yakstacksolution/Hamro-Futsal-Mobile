part of 'venue_amenities_facilities_bloc.dart';

enum VenueAmenitiesFacilitiesStatus { idle, loading, success, failure }

final class VenueAmenitiesFacilitiesState extends Equatable {
  const VenueAmenitiesFacilitiesState({
    this.status = VenueAmenitiesFacilitiesStatus.idle,
    this.amenitiesFacilities = const VenueAmenitiesFacilitiesModel(),
    this.errorMessage,
  });

  final VenueAmenitiesFacilitiesStatus status;
  final VenueAmenitiesFacilitiesModel amenitiesFacilities;
  final String? errorMessage;

  VenueAmenitiesFacilitiesState copyWith({
    VenueAmenitiesFacilitiesStatus? status,
    VenueAmenitiesFacilitiesModel? amenitiesFacilities,
    String? errorMessage,
    bool clearError = false,
  }) {
    return VenueAmenitiesFacilitiesState(
      status: status ?? this.status,
      amenitiesFacilities: amenitiesFacilities ?? this.amenitiesFacilities,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    amenitiesFacilities,
    errorMessage,
  ];
}
