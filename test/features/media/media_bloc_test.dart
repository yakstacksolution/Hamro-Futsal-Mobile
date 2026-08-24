import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/core/utils/upload_attachment.dart';
import 'package:hamro_footsall/features/media/data/model/media_model.dart';
import 'package:hamro_footsall/features/media/domain/repository/media_repository.dart';
import 'package:hamro_footsall/features/media/domain/usecase/media_use_case.dart';
import 'package:hamro_footsall/features/media/presentation/bloc/media_bloc.dart';

void main() {
  test('successful media upload becomes a remote media reference', () async {
    final _FakeMediaRepository repository = _FakeMediaRepository();
    final MediaBloc bloc = MediaBloc(MediaUseCase(repository));
    addTearDown(bloc.close);
    final UploadAttachment local = UploadAttachment(
      filename: 'venue.jpg',
      bytes: Uint8List.fromList(<int>[1, 2, 3]),
      sourcePath: '/temporary/venue.jpg',
    );

    bloc.add(CreateMediaEvent(<UploadAttachment>[local]));
    final MediaState state = await bloc.stream.firstWhere(
      (MediaState state) => state.createStatus == MediaStatus.success,
    );

    expect(repository.uploads.single, same(local));
    expect(state.items.single.url, 'https://cdn.example.test/venue.jpg');
    expect(state.items.single.id, '71');
  });
}

final class _FakeMediaRepository implements MediaRepository {
  List<UploadAttachment> uploads = const <UploadAttachment>[];

  @override
  Future<Either<AppException, List<MediaModel>>> getMedia() async =>
      right(const <MediaModel>[]);

  @override
  Future<Either<AppException, List<MediaModel>>> createMedia(
    List<UploadAttachment> mediaFiles,
  ) async {
    uploads = mediaFiles;
    return right(const <MediaModel>[
      MediaModel(
        id: '71',
        userId: '4',
        name: 'venue.jpg',
        filePath: 'media/venue.jpg',
        url: 'https://cdn.example.test/venue.jpg',
        extension: 'jpg',
        size: 3,
        mediaType: 'image',
        visibility: 'private',
      ),
    ]);
  }
}
