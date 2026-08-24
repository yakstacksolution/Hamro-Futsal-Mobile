import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/media/data/model/media_model.dart';
import 'package:hamro_footsall/features/media/domain/usecase/media_use_case.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';

part 'media_event.dart';
part 'media_state.dart';

class MediaBloc extends Bloc<MediaEvent, MediaState> {
  MediaBloc(this._mediaUseCase) : super(const MediaState()) {
    on<FetchMediaEvent>(_onFetchMedia);
    on<CreateMediaEvent>(_onCreateMedia);
    on<ClearMediaFeedbackEvent>(_onClearFeedback);
  }

  final MediaUseCase _mediaUseCase;

  FutureOr<void> _onFetchMedia(
    FetchMediaEvent event,
    Emitter<MediaState> emit,
  ) async {
    emit(
      state.copyWith(
        fetchStatus: MediaStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final Either<AppException, List<MediaModel>> response = await _mediaUseCase
        .getMedia();
    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          fetchStatus: MediaStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<MediaModel> items) => emit(
        state.copyWith(
          fetchStatus: MediaStatus.success,
          items: items,
          clearErrorMessage: true,
        ),
      ),
    );
  }

  FutureOr<void> _onCreateMedia(
    CreateMediaEvent event,
    Emitter<MediaState> emit,
  ) async {
    emit(
      state.copyWith(
        createStatus: MediaStatus.loading,
        clearErrorMessage: true,
        clearSuccessMessage: true,
      ),
    );

    final Either<AppException, List<MediaModel>> response = await _mediaUseCase
        .createMedia(event.mediaFiles);
    response.fold(
      (AppException failure) => emit(
        state.copyWith(
          createStatus: MediaStatus.failure,
          errorMessage: failure.errorMessage,
        ),
      ),
      (List<MediaModel> items) => emit(
        state.copyWith(
          createStatus: MediaStatus.success,
          items: <MediaModel>[...items, ...state.items],
          successMessage: 'Media uploaded successfully.',
          clearErrorMessage: true,
        ),
      ),
    );
  }

  FutureOr<void> _onClearFeedback(
    ClearMediaFeedbackEvent event,
    Emitter<MediaState> emit,
  ) {
    emit(
      state.copyWith(
        clearErrorMessage: true,
        clearSuccessMessage: true,
        createStatus: MediaStatus.idle,
      ),
    );
  }
}
