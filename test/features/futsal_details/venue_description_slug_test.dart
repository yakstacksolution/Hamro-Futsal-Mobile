import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/api/api_client/result.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/data_source/futsal_details_remote_data_source.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/venue_description_model.dart';
import 'package:hamro_futsal/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';

void main() {
  test('the repository addresses the venue by slug, not by id', () async {
    final _SpyDataSource source = _SpyDataSource();
    final FutsalDetailsRepositoryImpl repository = FutsalDetailsRepositoryImpl(
      remoteDataSource: source,
    );

    final Either<AppException, VenueDescriptionModel> result = await repository
        .getVenueDescription(venueSlug: 'dhanawantary-sports');

    expect(source.requestedSlug, 'dhanawantary-sports');
    result.fold(
      (AppException error) => fail(error.errorMessage),
      (VenueDescriptionModel model) =>
          expect(model.description, 'A fine pitch'),
    );
  });

  test(
    'the slug is passed through untouched, whatever it looks like',
    () async {
      final _SpyDataSource source = _SpyDataSource();
      final FutsalDetailsRepositoryImpl repository =
          FutsalDetailsRepositoryImpl(remoteDataSource: source);

      // A numeric-looking slug must still travel as the slug it is — the point
      // of the change is that the path segment is no longer an id.
      await repository.getVenueDescription(venueSlug: '38');
      expect(source.requestedSlug, '38');
    },
  );
}

final class _SpyDataSource implements FutsalDetailsRemoteDataSource {
  String? requestedSlug;

  @override
  Future<Result> getVenueDescription({required String venueSlug}) async {
    requestedSlug = venueSlug;
    return Result<dynamic, dynamic>.success(<String, dynamic>{
      'data': <String, dynamic>{'description': 'A fine pitch'},
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
