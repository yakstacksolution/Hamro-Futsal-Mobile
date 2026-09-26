import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/help_video_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetYoutubeVideosUseCase {
  const GetYoutubeVideosUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<HelpVideo>>> call() async =>
      await repository.getYoutubeVideos();
}
