import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_hosted_by_use_case.dart';

part 'hosted_by_event.dart';
part 'hosted_by_state.dart';

class HostedByBloc extends Bloc<HostedByEvent, HostedByState> {
  HostedByBloc(this._getHostedByUseCase) : super(const HostedByState()) {
    on<FetchHostedByEvent>(_onFetchHostedBy);
  }

  final GetHostedByUseCase _getHostedByUseCase;

  FutureOr<void> _onFetchHostedBy(
    FetchHostedByEvent event,
    Emitter<HostedByState> emit,
  ) async {
    emit(state.copyWith(status: HostedByStatus.loading, clearError: true));

    final Either<AppException, HostedByModel> response =
        await _getHostedByUseCase(venueId: event.venueId);

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: HostedByStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (HostedByModel hostedBy) => emit(
        state.copyWith(
          status: HostedByStatus.success,
          hostedBy: hostedBy,
          clearError: true,
        ),
      ),
    );
  }
}
