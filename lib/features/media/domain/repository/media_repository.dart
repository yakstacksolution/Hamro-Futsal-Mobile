import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/media/data/model/media_model.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';

abstract class MediaRepository {
  Future<Either<AppException, List<MediaModel>>> getMedia();
  Future<Either<AppException, List<MediaModel>>> createMedia(
    List<UploadAttachment> mediaFiles,
  );
}
