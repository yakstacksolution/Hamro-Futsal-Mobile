import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/recurring_availability_model.dart';
import 'package:hamro_footsall/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class CheckRecurringAvailabilityUseCase {
  const CheckRecurringAvailabilityUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, RecurringAvailabilityModel>>
  checkRecurringAvailability({
    required int? venueId,
    required int? courtId,
    required String bookingDate,
    required String slotStartTime,
    String? slotEndTime,
    List<String> recurringDates = const <String>[],
  }) async => await repository.checkRecurringAvailability(
    venueId: venueId,
    courtId: courtId,
    bookingDate: bookingDate,
    slotStartTime: slotStartTime,
    slotEndTime: slotEndTime,
    recurringDates: recurringDates,
  );
}
