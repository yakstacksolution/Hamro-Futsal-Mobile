import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/api/api_client/result.dart';
import 'package:hamro_footsall/core/api/client.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';

abstract class FutsalDetailsRemoteDataSource {
  Future<Result> getHostedBy({required int venueId});
  Future<Result> getVenueDescription({required int venueId});
  Future<Result> getVenueAmenitiesFacilities({required int venueId});
  Future<Result> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotStartTime,
    String? slotEndTime,
  });
  Future<Result> getVenueSlots({required int venueId, required String date});
  Future<Result> getCourtPaymentQr({required int courtId});
  Future<Result> createBooking(CreateBookingRequest request);
  Future<Result> getRecurringAvailability({required Map<String, dynamic> data});
  Future<Result> createBookingHold({required Map<String, dynamic> data});
  Future<Result> releaseBookingHold({required String holdToken});
}

final class FutsalDetailsRemoteDataSourceImpl
    extends FutsalDetailsRemoteDataSource {
  @override
  Future<Result> getHostedBy({required int venueId}) async =>
      await Client.instance().getAuthManager().getVenueHostedBy(venueId);

  @override
  Future<Result> getVenueDescription({required int venueId}) async =>
      await Client.instance().getAuthManager().getVenueDescription(venueId);

  @override
  Future<Result> getVenueAmenitiesFacilities({required int venueId}) async =>
      await Client.instance().getAuthManager().getVenueAmenitiesFacilities(
        venueId,
      );

  @override
  Future<Result> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotStartTime,
    String? slotEndTime,
  }) async => await Client.instance().getAuthManager().getAvailableCourts(
    venueId: venueId,
    selectDate: selectDate,
    slotStartTime: slotStartTime,
    slotEndTime: slotEndTime,
  );

  @override
  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
  }) async => await Client.instance().getAuthManager().getVenueSlots(
    venueId: venueId,
    date: date,
  );

  @override
  Future<Result> getCourtPaymentQr({required int courtId}) async =>
      await Client.instance().getAuthManager().getCourtPaymentQr(
        courtId: courtId,
      );

  @override
  Future<Result> createBooking(CreateBookingRequest request) async {
    final Map<String, dynamic> fields = request.toFields()
      ..removeWhere((_, dynamic value) => value == null);

    final String? proofPath = request.paymentProofPath;
    if (proofPath != null && proofPath.isNotEmpty) {
      fields['payment_proof'] = await MultipartFile.fromFile(
        proofPath,
        filename: proofPath.split('/').last,
      );
    }

    return await Client.instance().getAuthManager().createBooking(
      FormData.fromMap(fields),
    );
  }

  @override
  Future<Result> getRecurringAvailability({
    required Map<String, dynamic> data,
  }) async =>
      await Client.instance().getAuthManager().getRecurringAvailability(data);

  @override
  Future<Result> createBookingHold({
    required Map<String, dynamic> data,
  }) async => await Client.instance().getAuthManager().createBookingHold(data);

  @override
  Future<Result> releaseBookingHold({required String holdToken}) async =>
      await Client.instance().getAuthManager().releaseBookingHold(holdToken);
}
