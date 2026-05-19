import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/domain/repository/venue_court_repository.dart';

final class GetVenueCourtUseCase {
  const GetVenueCourtUseCase(this._repository);

  final VenueCourtRepository _repository;

  Future<Either<AppException, List<VenueCourtModel>>> call() async =>
      await _repository.getVenueCourt();
}
