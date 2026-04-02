part of 'media_bloc.dart';

sealed class MediaEvent extends Equatable {
  const MediaEvent();

  @override
  List<Object?> get props => <Object?>[];
}

final class FetchMediaEvent extends MediaEvent {
  const FetchMediaEvent();
}

final class CreateMediaEvent extends MediaEvent {
  const CreateMediaEvent(this.mediaFiles);

  final List<String> mediaFiles;

  @override
  List<Object?> get props => <Object?>[mediaFiles];
}

final class ClearMediaFeedbackEvent extends MediaEvent {
  const ClearMediaFeedbackEvent();
}
