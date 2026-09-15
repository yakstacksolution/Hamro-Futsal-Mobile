import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_futsal/features/courts/domain/repository/venue_court_repository.dart';
import 'package:hamro_futsal/features/courts/domain/model/venue_court_purpose.dart';
import 'package:hamro_futsal/features/courts/domain/usecase/get_venue_court_use_case.dart';
import 'package:hamro_futsal/features/courts/presentation/bloc/venue_court/venue_court_bloc.dart';
import 'package:hamro_futsal/features/courts/presentation/pages/venue_courts_list_page_widget.dart';

/// One venue with the given name and status, shaped like
/// `/auth/get-venue-courts`.
String _venuesResponse(List<({String name, String status})> venues) {
  return jsonEncode(<String, dynamic>{
    'status': 'success',
    'data': <String, dynamic>{
      'venues': <Map<String, dynamic>>[
        for (final (int index, ({String name, String status}) venue)
            in venues.indexed)
          <String, dynamic>{
            'id': index + 1,
            'main_step': venue.status == 'active' ? 2 : 0,
            'sub_step': venue.status == 'active' ? 2 : 0,
            'futsal_name': venue.name,
            'slug': venue.name.toLowerCase().replaceAll(' ', '-'),
            'phone': '9800000000',
            'email': 'venue@example.com',
            'futsal_address': venue.status == 'active' ? 'Kathmandu' : null,
            'cover_image_media': null,
            'status': venue.status,
            'courts': <dynamic>[],
          },
      ],
      'pagination': <String, dynamic>{
        'current_page': 1,
        'last_page': 1,
        'per_page': 10,
        'total': venues.length,
        'has_more_pages': false,
      },
    },
  });
}

Future<void> _pumpVenues(
  WidgetTester tester,
  List<({String name, String status})> venues,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(411, 1400);
  addTearDown(tester.view.reset);

  final VenueCourtBloc bloc = VenueCourtBloc(
    GetVenueCourtUseCase(_StubVenueCourtRepository(_venuesResponse(venues))),
    purpose: VenueCourtPurpose.myVenues,
  )..add(const FetchVenueCourtEvent());
  addTearDown(bloc.close);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? _) => MaterialApp(
        home: Scaffold(body: VenueCourtsListPage(bloc: bloc)),
      ),
    ),
  );
  // Fixed pumps: the empty-state shimmer animates forever.
  for (int i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('an inactive venue is badged Inactive, never Approved', (
    WidgetTester tester,
  ) async {
    await _pumpVenues(tester, <({String name, String status})>[
      (name: 'Susan test futsal', status: 'inactive'),
    ]);

    expect(tester.takeException(), isNull);
    expect(find.text('Susan test futsal'), findsOneWidget);
    expect(find.text(StringConstants.inactive), findsOneWidget);
    expect(
      find.text(StringConstants.approved),
      findsNothing,
      reason: 'an inactive venue must not claim to be approved',
    );
  });

  testWidgets('an active venue is badged Active', (WidgetTester tester) async {
    await _pumpVenues(tester, <({String name, String status})>[
      (name: 'Dhanawantary Sports', status: 'active'),
    ]);

    expect(tester.takeException(), isNull);
    expect(find.text(StringConstants.active), findsOneWidget);
    expect(find.text(StringConstants.approved), findsNothing);
  });

  testWidgets('each venue keeps its own status', (WidgetTester tester) async {
    await _pumpVenues(tester, <({String name, String status})>[
      (name: 'Live venue', status: 'active'),
      (name: 'Draft venue', status: 'inactive'),
      (name: 'Waiting venue', status: 'pending'),
    ]);

    expect(tester.takeException(), isNull);
    expect(find.text(StringConstants.active), findsOneWidget);
    expect(find.text(StringConstants.inactive), findsOneWidget);
    expect(find.text(StringConstants.pending), findsOneWidget);
    expect(find.text(StringConstants.approved), findsNothing);
  });

  testWidgets('an explicitly approved venue still reads Approved', (
    WidgetTester tester,
  ) async {
    await _pumpVenues(tester, <({String name, String status})>[
      (name: 'Signed off venue', status: 'approved'),
    ]);

    expect(tester.takeException(), isNull);
    expect(find.text(StringConstants.approved), findsOneWidget);
  });

  testWidgets('an unknown status falls back to Inactive', (
    WidgetTester tester,
  ) async {
    await _pumpVenues(tester, <({String name, String status})>[
      (name: 'Odd venue', status: 'something_new'),
    ]);

    expect(tester.takeException(), isNull);
    expect(find.text(StringConstants.inactive), findsOneWidget);
    expect(find.text(StringConstants.approved), findsNothing);
  });
}

/// Serves one canned `/auth/get-venue-courts` body; nothing else is called.
final class _StubVenueCourtRepository implements VenueCourtRepository {
  _StubVenueCourtRepository(this.body);

  final String body;

  @override
  Future<Either<AppException, VenueCourtPageModel>> getVenueCourt({
    required int page,
    required int perPage,
    required VenueCourtPurpose purpose,
  }) async {
    purposes.add(purpose);
    return right(
      VenueCourtPageModel.fromResponse(
        jsonDecode(body) as Map<String, dynamic>,
      ),
    );
  }

  /// Every purpose this stub was asked for, so a test can assert the page sent
  /// the right one.
  final List<VenueCourtPurpose> purposes = <VenueCourtPurpose>[];

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}
