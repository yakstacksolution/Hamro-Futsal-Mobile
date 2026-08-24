import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/core/utils/upload_part.dart';

abstract class MediaRemoteDataSource {
  Future<Result> getMedia();
  Future<Result> createMedia(List<UploadAttachment> mediaFiles);
}

final class MediaRemoteDataSourceImpl extends MediaRemoteDataSource {
  @override
  Future<Result> getMedia() async =>
      await Client.instance().getAuthManager().getMedia();

  @override
  Future<Result> createMedia(List<UploadAttachment> mediaFiles) async {
    try {
      validateUploadBatch(mediaFiles);
    } on UploadValidationException catch (error) {
      return Result.error(DataError(error.message, 0, null));
    }

    final List<MultipartFile> files = mediaFiles
        .map((attachment) {
          final MultipartFile multipartFile = buildUploadPart(attachment);
          if (kDebugMode) {
            debugPrint(
              'UPLOAD FILE endpoint=/media field=media_files '
              'name=${attachment.filename} bytes=${attachment.size}',
            );
          }
          return multipartFile;
        })
        .toList(growable: false);

    final FormData formData = FormData.fromMap(<String, dynamic>{
      'media_files': files,
    }, ListFormat.multiCompatible);

    return await Client.instance().getAuthManager().createMedia(formData);
  }
}
