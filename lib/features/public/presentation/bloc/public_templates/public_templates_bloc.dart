import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_public_templates_use_case.dart';
part 'public_templates_event.dart';
part 'public_templates_state.dart';

class PublicTemplatesBloc
    extends Bloc<PublicTemplatesEvent, PublicTemplatesState> {
  PublicTemplatesBloc(this._getPublicTemplatesUseCase)
    : super(const PublicTemplatesState()) {
    on<FetchPublicTemplatesEvent>(_onFetchPublicTemplates);
  }

  final GetPublicTemplatesUseCase _getPublicTemplatesUseCase;

  FutureOr<void> _onFetchPublicTemplates(
    FetchPublicTemplatesEvent event,
    Emitter<PublicTemplatesState> emit,
  ) async {
    emit(
      state.copyWith(status: PublicTemplatesStatus.loading, clearError: true),
    );

    final Either<AppException, List<PublicTemplateModel>> response =
        await _getPublicTemplatesUseCase.getTemplates();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          status: PublicTemplatesStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<PublicTemplateModel> templates) => emit(
        state.copyWith(
          status: PublicTemplatesStatus.success,
          templates: templates,
          clearError: true,
        ),
      ),
    );
  }
}
