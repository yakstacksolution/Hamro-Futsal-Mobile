import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/help_video_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_faq_model.dart';
import 'package:hamro_futsal/features/public/data/model/public_help_model.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_faqs_use_case.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_helps_use_case.dart';
import 'package:hamro_futsal/features/public/domain/usecase/get_youtube_videos_use_case.dart';

part 'support_event.dart';
part 'support_state.dart';

/// Drives the Help & FAQ page — FAQs, help topics and videos load
/// independently so one failing fetch never blocks another tab.
class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc(
    this._getFaqsUseCase,
    this._getHelpsUseCase,
    this._getYoutubeVideosUseCase,
  ) : super(const SupportState()) {
    on<FetchFaqsEvent>(_onFetchFaqs);
    on<FetchHelpsEvent>(_onFetchHelps);
    on<FetchVideosEvent>(_onFetchVideos);
  }

  final GetFaqsUseCase _getFaqsUseCase;
  final GetHelpsUseCase _getHelpsUseCase;
  final GetYoutubeVideosUseCase _getYoutubeVideosUseCase;

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

  FutureOr<void> _onFetchVideos(
    FetchVideosEvent event,
    Emitter<SupportState> emit,
  ) async {
    try {
      await _fetchVideos(event, emit);
    } finally {
      final Completer<void>? completer = event.completer;
      if (completer != null && !completer.isCompleted) completer.complete();
    }
  }

  Future<void> _fetchVideos(
    FetchVideosEvent event,
    Emitter<SupportState> emit,
  ) async {
    // A pull-to-refresh keeps the current list on screen instead of
    // flashing back to the full-page spinner.
    if (!event.isRefresh || state.videos.isEmpty) {
      emit(state.copyWith(videosStatus: SupportStatus.loading));
    }

    final Either<AppException, List<HelpVideo>> response =
        await _getYoutubeVideosUseCase();

    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          // A failed refresh leaves the videos already shown in place.
          videosStatus: state.videos.isNotEmpty && event.isRefresh
              ? SupportStatus.success
              : SupportStatus.failure,
          videosError: failure.errorMessage,
        ),
      ),
      (List<HelpVideo> videos) => emit(
        state.copyWith(videosStatus: SupportStatus.success, videos: videos),
      ),
    );
  }
}
