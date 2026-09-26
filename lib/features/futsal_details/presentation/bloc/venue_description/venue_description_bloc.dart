import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/cache/hive/hive_boxes.dart';
import 'package:hamro_futsal/core/cache/hive/hive_cache_service.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/usecase/get_venue_description_use_case.dart';

part 'venue_description_event.dart';
part 'venue_description_state.dart';

class VenueDescriptionBloc
    extends Bloc<VenueDescriptionEvent, VenueDescriptionState> {
  VenueDescriptionBloc(this._getVenueDescriptionUseCase)
    : super(const VenueDescriptionState()) {
    on<FetchVenueDescriptionEvent>(_onFetchVenueDescription);
  }

  final GetVenueDescriptionUseCase _getVenueDescriptionUseCase;

  FutureOr<void> _onFetchVenueDescription(
    FetchVenueDescriptionEvent event,
    Emitter<VenueDescriptionState> emit,
  ) async {
    final String cacheKey =
        '${HiveCacheService.instance.userScope}:venue:${event.venueSlug}:description';
    final VenueDescriptionModel? cached = await HiveCacheService.instance
        .readItem<VenueDescriptionModel>(
          boxName: HiveBoxes.home,
          key: cacheKey,
          fromJson: VenueDescriptionModel.fromJson,
        );

    emit(
      state.copyWith(
        status: cached == null
            ? VenueDescriptionStatus.loading
            : VenueDescriptionStatus.success,
        venueDescription: cached ?? state.venueDescription,
        clearError: true,
      ),
    );

    final Either<AppException, VenueDescriptionModel> response =
        await _getVenueDescriptionUseCase(venueSlug: event.venueSlug);

    response.fold(
      (AppException failure) => emit(
        cached != null
            ? state.copyWith(
                status: VenueDescriptionStatus.success,
                errorMessage: failure.errorMessage,
              )
            : state.copyWith(
                status: VenueDescriptionStatus.failure,
                errorMessage: failure.errorMessage,
              ),
      ),
      (VenueDescriptionModel venueDescription) {
        unawaited(
          HiveCacheService.instance.syncItem(
            boxName: HiveBoxes.home,
            key: cacheKey,
            json: venueDescription.toJson(),
          ),
        );
        emit(
          state.copyWith(
            status: VenueDescriptionStatus.success,
            venueDescription: venueDescription,
            clearError: true,
          ),
        );
      },
    );
  }
}
