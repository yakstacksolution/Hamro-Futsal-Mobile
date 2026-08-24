import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_service_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_services_use_case.dart';

part 'public_services_event.dart';
part 'public_services_state.dart';

class PublicServicesBloc
    extends Bloc<PublicServicesEvent, PublicServicesState> {
  PublicServicesBloc(this._getPublicServicesUseCase)
    : super(const PublicServicesState()) {
    on<FetchPublicServicesEvent>(_onFetchPublicServices);
  }

  final GetPublicServicesUseCase _getPublicServicesUseCase;

  FutureOr<void> _onFetchPublicServices(
    FetchPublicServicesEvent event,
    Emitter<PublicServicesState> emit,
  ) async {
    emit(
      state.copyWith(status: PublicServicesStatus.loading, clearError: true),
    );

    final Either<AppException, List<PublicServiceModel>> response =
        await _getPublicServicesUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: PublicServicesStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<PublicServiceModel> services) => emit(
        state.copyWith(
          status: PublicServicesStatus.success,
          services: services,
          clearError: true,
        ),
      ),
    );
  }
}
