import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_footsall/core/api/api_client/booking_type_payload.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/features/futsal_details/data/data_source/futsal_details_remote_data_source.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_footsall/features/futsal_details/data/repositories/futsal_details_repository_impl.dart';
import 'package:hamro_footsall/features/futsal_details/domain/usecase/get_venue_slots_use_case.dart';

void main() {
  late _FakeDataSource dataSource;
  late GetVenueSlotsUseCase useCase;

  setUp(() {
    dataSource = _FakeDataSource();
    useCase = GetVenueSlotsUseCase(
      FutsalDetailsRepositoryImpl(remoteDataSource: dataSource),
    );
  });

  test('a walk-in asks for the manual slot list', () async {
    await useCase(
      venueId: 2,
      date: '2026-08-11',
      bookingType: BookingTypePayload.manual,
    );

    expect(dataSource.lastBookingType, 'manual');
    expect(dataSource.lastVenueId, 2);
    expect(dataSource.lastDate, '2026-08-11');
  });

  test('a player booking asks for the regular slot list', () async {
    await useCase(
      venueId: 2,
      date: '2026-08-11',
      bookingType: BookingTypePayload.regular,
    );

    expect(dataSource.lastBookingType, 'regular');
  });

  test('the type defaults to regular when the caller omits it', () async {
    // A vendor's walk-in may see slots a player cannot, so the safe default is
    // the narrower list.
    await useCase(venueId: 2, date: '2026-08-11');

    expect(dataSource.lastBookingType, 'regular');
  });

  test('BookingTypePayload maps the manual flag both ways', () {
    expect(BookingTypePayload.of(isManual: true), 'manual');
    expect(BookingTypePayload.of(isManual: false), 'regular');
  });
}

/// Records what the repository asked for; every other endpoint is unused here.
final class _FakeDataSource implements FutsalDetailsRemoteDataSource {
  int? lastVenueId;
  String? lastDate;
  String? lastBookingType;

  @override
  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
    String bookingType = BookingTypePayload.regular,
  }) async {
    lastVenueId = venueId;
    lastDate = date;
    lastBookingType = bookingType;
    return Result.success(<String, dynamic>{
      'data': <String, dynamic>{'slots': <dynamic>[]},
    });
  }

  @override
  Future<Result> getHostedBy({required int venueId}) =>
      throw UnimplementedError();

  @override
  Future<Result> getVenueDescription({required int venueId}) =>
      throw UnimplementedError();

  @override
  Future<Result> getVenueAmenitiesFacilities({required int venueId}) =>
      throw UnimplementedError();

  @override
  Future<Result> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotStartTime,
    String? slotEndTime,
    String bookingType = BookingTypePayload.regular,
  }) => throw UnimplementedError();

  @override
  Future<Result> getCourtPaymentQr({required int courtId}) =>
      throw UnimplementedError();

  @override
  Future<Result> createBooking(CreateBookingRequest request) =>
      throw UnimplementedError();

  @override
  Future<Result> getRecurringAvailability({
    required Map<String, dynamic> data,
  }) => throw UnimplementedError();

  @override
  Future<Result> createBookingHold({required Map<String, dynamic> data}) =>
      throw UnimplementedError();

  @override
  Future<Result> releaseBookingHold({required String holdToken}) =>
      throw UnimplementedError();
}
