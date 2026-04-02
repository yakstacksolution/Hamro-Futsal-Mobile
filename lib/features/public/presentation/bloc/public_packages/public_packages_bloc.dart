import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_package_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_packages_use_case.dart';

part 'public_packages_event.dart';
part 'public_packages_state.dart';

class PublicPackagesBloc
    extends Bloc<PublicPackagesEvent, PublicPackagesState> {
  PublicPackagesBloc(this._getPublicPackagesUseCase)
    : super(const PublicPackagesState()) {
    on<FetchPublicPackagesEvent>(_onFetchPublicPackages);
  }

  final GetPublicPackagesUseCase _getPublicPackagesUseCase;

  FutureOr<void> _onFetchPublicPackages(
    FetchPublicPackagesEvent event,
    Emitter<PublicPackagesState> emit,
  ) async {
    emit(
      state.copyWith(status: PublicPackagesStatus.loading, clearError: true),
    );

    final Either<AppException, List<PublicPackageModel>> response =
        await _getPublicPackagesUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: PublicPackagesStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<PublicPackageModel> packages) => emit(
        state.copyWith(
          status: PublicPackagesStatus.success,
          packages: packages,
          clearError: true,
        ),
      ),
    );
  }
}
