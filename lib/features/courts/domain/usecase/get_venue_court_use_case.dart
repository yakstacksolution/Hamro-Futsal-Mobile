import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/domain/repository/venue_court_repository.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

final class GetVenueCourtUseCase {
  const GetVenueCourtUseCase(this._repository);

  final VenueCourtRepository _repository;

  Future<Either<AppException, List<VenueCourtModel>>> call() async =>
      await _repository.getVenueCourt();

  Future<Either<AppException, CourtDraft>> getCourtDetails(int courtId) async =>
      await _repository.getCourtDetails(courtId);
}
