part of 'public_court_options_bloc.dart';

enum PublicCourtOptionsStatus { idle, loading, success, failure }

final class PublicCourtOptionsState extends Equatable {
  const PublicCourtOptionsState({
    this.status = PublicCourtOptionsStatus.idle,
    this.courtTypes = const <PublicOptionModel>[],
    this.matchFormats = const <PublicOptionModel>[],
    this.amenities = const <PublicOptionModel>[],
    this.facilities = const <PublicOptionModel>[],
    this.errorMessage,
  });

  final PublicCourtOptionsStatus status;
  final List<PublicOptionModel> courtTypes;
  final List<PublicOptionModel> matchFormats;
  final List<PublicOptionModel> amenities;
  final List<PublicOptionModel> facilities;
  final String? errorMessage;

  PublicCourtOptionsState copyWith({
    PublicCourtOptionsStatus? status,
    List<PublicOptionModel>? courtTypes,
    List<PublicOptionModel>? matchFormats,
    List<PublicOptionModel>? amenities,
    List<PublicOptionModel>? facilities,
    String? errorMessage,
  }) {
    return PublicCourtOptionsState(
      status: status ?? this.status,
      courtTypes: courtTypes ?? this.courtTypes,
      matchFormats: matchFormats ?? this.matchFormats,
      amenities: amenities ?? this.amenities,
      facilities: facilities ?? this.facilities,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    courtTypes,
    matchFormats,
    amenities,
    facilities,
    errorMessage,
  ];
}
