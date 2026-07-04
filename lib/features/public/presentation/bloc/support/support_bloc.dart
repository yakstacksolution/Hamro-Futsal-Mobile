import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_faq_model.dart';
import 'package:hamro_footsall/features/public/data/model/public_help_model.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_faqs_use_case.dart';
import 'package:hamro_footsall/features/public/domain/usecase/get_helps_use_case.dart';

part 'support_event.dart';
part 'support_state.dart';

/// Drives the Help & FAQ page — FAQs and help topics load independently so
/// one failing fetch never blocks the other tab.
class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc(this._getFaqsUseCase, this._getHelpsUseCase)
    : super(const SupportState()) {
    on<FetchFaqsEvent>(_onFetchFaqs);
    on<FetchHelpsEvent>(_onFetchHelps);
  }

  final GetFaqsUseCase _getFaqsUseCase;
  final GetHelpsUseCase _getHelpsUseCase;

  FutureOr<void> _onFetchFaqs(
    FetchFaqsEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(faqsStatus: SupportStatus.loading));

    final Either<AppException, List<PublicFaqModel>> response =
        await _getFaqsUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          faqsStatus: SupportStatus.failure,
          faqsError: failure.errorMessage,
        ),
      ),
      (List<PublicFaqModel> faqs) =>
          emit(state.copyWith(faqsStatus: SupportStatus.success, faqs: faqs)),
    );
  }

  FutureOr<void> _onFetchHelps(
    FetchHelpsEvent event,
    Emitter<SupportState> emit,
  ) async {
    emit(state.copyWith(helpsStatus: SupportStatus.loading));

    final Either<AppException, List<PublicHelpModel>> response =
        await _getHelpsUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          helpsStatus: SupportStatus.failure,
          helpsError: failure.errorMessage,
        ),
      ),
      (List<PublicHelpModel> helps) => emit(
        state.copyWith(helpsStatus: SupportStatus.success, helps: helps),
      ),
    );
  }
}
