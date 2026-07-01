import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/booking_result_model.dart';
import 'package:hamro_footsall/features/futsal_details/data/model/create_booking_request.dart';
import 'package:hamro_footsall/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class CreateBookingUseCase {
  const CreateBookingUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, BookingResultModel>> createBooking(
    CreateBookingRequest request,
  ) async => await repository.createBooking(request);
}
