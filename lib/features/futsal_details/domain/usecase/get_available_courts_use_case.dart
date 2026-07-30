import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/api/api_client/booking_type_payload.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/available_courts_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetAvailableCourtsUseCase {
  const GetAvailableCourtsUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, AvailableCourtsModel>> getAvailableCourts({
    required int venueId,
    required String selectDate,
    String? slotStartTime,
    String? slotEndTime,
    String bookingType = BookingTypePayload.regular,
  }) async => await repository.getAvailableCourts(
    venueId: venueId,
    selectDate: selectDate,
    slotStartTime: slotStartTime,
    slotEndTime: slotEndTime,
    bookingType: bookingType,
  );
}
