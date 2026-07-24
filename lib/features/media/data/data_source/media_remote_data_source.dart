import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/features/media/utils/heic_to_png_jpg.dart';

abstract class MediaRemoteDataSource {
  Future<Result> getMedia();
  Future<Result> createMedia(List<String> mediaFiles);
}

final class MediaRemoteDataSourceImpl extends MediaRemoteDataSource {
  @override
  Future<Result> getMedia() async =>
      await Client.instance().getAuthManager().getMedia();

  @override
  Future<Result> createMedia(List<String> mediaFiles) async {
    final List<MultipartFile> files = await Future.wait(
      mediaFiles.map((String path) async {
        final String uploadPath = await heicToPngJpg(path);
        final File file = File(uploadPath);
        final String fileName = uploadPath.split('/').last;

        final int fileSize = await file.exists() ? await file.length() : 0;
        if (fileSize == 0) {
          throw StateError('Cannot upload an empty media file: $fileName');
        }

        final MultipartFile multipartFile = await MultipartFile.fromFile(
          uploadPath,
          filename: fileName,
        );
        debugPrint(
          'LOCAL MEDIA FILE name=$fileName size=$fileSize '
          'multipartSize=${multipartFile.length}',
        );
        return multipartFile;
      }),
    );

    final FormData formData = FormData.fromMap(<String, dynamic>{
      'media_files': files,
    }, ListFormat.multiCompatible);

    return await Client.instance().getAuthManager().createMedia(formData);
  }
}
