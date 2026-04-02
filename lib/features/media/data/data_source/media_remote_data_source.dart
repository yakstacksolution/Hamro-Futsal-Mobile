import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';

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
        final String fileName = path.split('/').last;
        return MultipartFile.fromFile(path, filename: fileName);
      }),
    );

    final FormData formData = FormData.fromMap(
      files.length == 1
          ? <String, dynamic>{'media_file': files.first}
          : <String, dynamic>{'media_files': files},
    );

    return await Client.instance().getAuthManager().createMedia(formData);
  }
}
