import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/media/data/model/media_model.dart';
import 'package:hamro_footsall/features/media/domain/repository/media_repository.dart';

final class MediaUseCase {
  const MediaUseCase(this.repository);

  final MediaRepository repository;

  Future<Either<AppException, List<MediaModel>>> getMedia() async =>
      await repository.getMedia();

  Future<Either<AppException, List<MediaModel>>> createMedia(
    List<String> mediaFiles,
  ) async => await repository.createMedia(mediaFiles);
}
