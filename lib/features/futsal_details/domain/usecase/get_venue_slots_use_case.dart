import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/time_slot_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetVenueSlotsUseCase {
  const GetVenueSlotsUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, List<TimeSlotModel>>> call({
    required int venueId,
    required String date,
  }) async => await repository.getVenueSlots(venueId: venueId, date: date);
}
