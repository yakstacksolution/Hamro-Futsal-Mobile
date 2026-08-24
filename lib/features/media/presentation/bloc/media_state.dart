part of 'media_bloc.dart';

enum MediaStatus { idle, loading, success, failure }

final class MediaState extends Equatable {
  const MediaState({
    this.fetchStatus = MediaStatus.idle,
    this.createStatus = MediaStatus.idle,
    this.items = const <MediaModel>[],
    this.errorMessage,
    this.successMessage,
  });

  final MediaStatus fetchStatus;
  final MediaStatus createStatus;
  final List<MediaModel> items;
  final String? errorMessage;
  final String? successMessage;

  MediaState copyWith({
    MediaStatus? fetchStatus,
    MediaStatus? createStatus,
    List<MediaModel>? items,
    String? errorMessage,
    String? successMessage,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return MediaState(
      fetchStatus: fetchStatus ?? this.fetchStatus,
      createStatus: createStatus ?? this.createStatus,
      items: items ?? this.items,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    fetchStatus,
    createStatus,
    items,
    errorMessage,
    successMessage,
  ];
}
