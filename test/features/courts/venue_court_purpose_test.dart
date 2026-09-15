import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_futsal/features/courts/domain/model/venue_court_purpose.dart';
import 'package:hamro_futsal/features/courts/domain/repository/venue_court_repository.dart';
import 'package:hamro_futsal/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_futsal/features/courts/presentation/bloc/venue_court/venue_court_bloc.dart';
import 'package:hamro_futsal/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

void main() {
  test('the query value is what the endpoint expects', () {
    expect(VenueCourtPurpose.booking.query, 'booking');
    expect(VenueCourtPurpose.myVenues.query, 'my_venues');
  });

  test('every fetch from a bloc carries the bloc\'s purpose', () async {
    final _RecordingRepository repository = _RecordingRepository(pages: 1);
    final VenueCourtBloc bloc = VenueCourtBloc(
      GetVenueCourtUseCase(repository),
      purpose: VenueCourtPurpose.myVenues,
    );
    addTearDown(bloc.close);

    bloc.add(const FetchVenueCourtEvent());
    await bloc.stream.firstWhere(
      (VenueCourtState s) => s.status == VenueCourtStatus.success,
    );

    expect(repository.purposes, <VenueCourtPurpose>[
      VenueCourtPurpose.myVenues,
    ]);
  });

  // The picker walks every page, so the purpose has to survive the paging loop
  // and not just the first request.
  test('getAllVenueCourts sends the purpose on every page', () async {
    final _RecordingRepository repository = _RecordingRepository(pages: 3);

    final result = await GetVenueCourtUseCase(
      repository,
    ).getAllVenueCourts(purpose: VenueCourtPurpose.booking);

    expect(result.isRight(), isTrue);
    expect(repository.purposes.length, 3);
    expect(repository.purposes, everyElement(VenueCourtPurpose.booking));
  });
}

/// Records the purpose of every call, and reports [pages] pages so the
/// paging loop actually runs.
final class _RecordingRepository implements VenueCourtRepository {
  _RecordingRepository({required this.pages});

  final int pages;
  final List<VenueCourtPurpose> purposes = <VenueCourtPurpose>[];

  @override
  Future<Either<AppException, VenueCourtPageModel>> getVenueCourt({
    required int page,
    required int perPage,
    required VenueCourtPurpose purpose,
  }) async {
    purposes.add(purpose);
    return right(
      VenueCourtPageModel(
        items: <VenueCourtModel>[
          VenueCourtModel(
            id: page,
            title: 'Venue $page',
            address: 'Kathmandu',
            phone: '',
            status: 'active',
            courts: const <CourtDraft>[],
          ),
        ],
        currentPage: page,
        lastPage: pages,
        perPage: perPage,
        total: pages,
        hasMorePages: page < pages,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
