import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_option_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_court_options_use_case.dart';

part 'public_court_options_event.dart';
part 'public_court_options_state.dart';

class PublicCourtOptionsBloc
    extends Bloc<PublicCourtOptionsEvent, PublicCourtOptionsState> {
  PublicCourtOptionsBloc(this._useCase)
    : super(const PublicCourtOptionsState()) {
    on<FetchPublicCourtOptionsEvent>(_onFetchOptions);
  }

  final GetCourtOptionsUseCase _useCase;

  FutureOr<void> _onFetchOptions(
    FetchPublicCourtOptionsEvent event,
    Emitter<PublicCourtOptionsState> emit,
  ) async {
    emit(state.copyWith(status: PublicCourtOptionsStatus.loading));

    final results = await Future.wait([
      _useCase.getCourtTypes(),
      _useCase.getMatchFormats(),
      _useCase.getAmenities(),
      _useCase.getFacilities(),
    ]);

    final Either<AppException, List<PublicOptionModel>> courtTypesResponse =
        results[0];
    final Either<AppException, List<PublicOptionModel>> matchFormatsResponse =
        results[1];
    final Either<AppException, List<PublicOptionModel>> amenitiesResponse =
        results[2];
    final Either<AppException, List<PublicOptionModel>> facilitiesResponse =
        results[3];

    final AppException? failure = courtTypesResponse.fold(
      (AppException error) => error,
      (_) => null,
    );
    final AppException? matchFailure = matchFormatsResponse.fold(
      (AppException error) => error,
      (_) => null,
    );
    final AppException? amenitiesFailure = amenitiesResponse.fold(
      (AppException error) => error,
      (_) => null,
    );
    final AppException? facilitiesFailure = facilitiesResponse.fold(
      (AppException error) => error,
      (_) => null,
    );

    final List<PublicOptionModel> courtTypes = courtTypesResponse.fold(
      (_) => const <PublicOptionModel>[],
      (List<PublicOptionModel> items) => items,
    );
    final List<PublicOptionModel> matchFormats = matchFormatsResponse.fold(
      (_) => const <PublicOptionModel>[],
      (List<PublicOptionModel> items) => items,
    );
    final List<PublicOptionModel> amenities = amenitiesResponse.fold(
      (_) => const <PublicOptionModel>[],
      (List<PublicOptionModel> items) => items,
    );
    final List<PublicOptionModel> facilities = facilitiesResponse.fold(
      (_) => const <PublicOptionModel>[],
      (List<PublicOptionModel> items) => items,
    );

    emit(
      state.copyWith(
        status:
            failure == null &&
                matchFailure == null &&
                amenitiesFailure == null &&
                facilitiesFailure == null
            ? PublicCourtOptionsStatus.success
            : PublicCourtOptionsStatus.failure,
        courtTypes: courtTypes,
        matchFormats: matchFormats,
        amenities: amenities,
        facilities: facilities,
        errorMessage:
            failure?.errorMessage ??
            matchFailure?.errorMessage ??
            amenitiesFailure?.errorMessage ??
            facilitiesFailure?.errorMessage,
      ),
    );
  }
}
