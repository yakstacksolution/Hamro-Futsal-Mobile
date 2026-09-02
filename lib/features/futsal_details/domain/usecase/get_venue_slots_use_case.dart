import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/api/api_client/booking_type_payload.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetVenueSlotsUseCase {
  const GetVenueSlotsUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, List<TimeSlotModel>>> call({
    required int venueId,
    required String date,
    String bookingType = BookingTypePayload.regular,
  }) async => await repository.getVenueSlots(
    venueId: venueId,
    date: date,
    bookingType: bookingType,
  );
}
