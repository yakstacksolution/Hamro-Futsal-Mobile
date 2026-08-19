import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hamro_footsall/core/api/api_client/booking_type_payload.dart';
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
    String bookingType,
  });
  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
    String bookingType,
  });
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
    String bookingType = BookingTypePayload.regular,
  }) async => await Client.instance().getAuthManager().getAvailableCourts(
    venueId: venueId,
    selectDate: selectDate,
    slotStartTime: slotStartTime,
    slotEndTime: slotEndTime,
    bookingType: bookingType,
  );

  @override
  Future<Result> getVenueSlots({
    required int venueId,
    required String date,
    String bookingType = BookingTypePayload.regular,
  }) async => await Client.instance().getAuthManager().getVenueSlots(
    venueId: venueId,
    date: date,
    bookingType: bookingType,
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

    // Payment proof travels as multipart `payment_proof`, built from the bytes
    // captured when the user attached it. Reading the path again here is what
    // used to produce a 0-byte upload: by the time Confirm is pressed, the
    // picker's cached file may already have been reclaimed by the OS.
    final Uint8List? proofBytes = request.paymentProofBytes;
    final String? proofPath = request.paymentProofPath;
    if (proofBytes != null && proofBytes.isNotEmpty) {
      fields['payment_proof'] = MultipartFile.fromBytes(
        proofBytes,
        filename:
            request.paymentProofName ??
            proofPath?.split(Platform.pathSeparator).last ??
            'payment_proof.jpg',
      );
    } else if (proofPath != null && proofPath.isNotEmpty) {
      // Callers that only have a path (no bytes) still work, but the file has
      // to be readable right now.
      final File proof = File(proofPath);
      final int size = await proof.exists() ? await proof.length() : 0;
      if (size == 0) {
        return Result.error(
          DataError(
            'The payment proof could not be read. Please attach it again.',
            0,
            null,
          ),
        );
      }
      fields['payment_proof'] = await MultipartFile.fromFile(
        proofPath,
        filename: proofPath.split(Platform.pathSeparator).last,
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
