import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_model.dart';
import 'package:hamro_footsall/features/courts/data/model/venue_court_page_model.dart';
import 'package:hamro_footsall/features/courts/domain/repository/venue_court_repository.dart';
import 'package:hamro_footsall/features/vendor/presentation/models/vendor_onboarding_drafts.dart';

final class GetVenueCourtUseCase {
  const GetVenueCourtUseCase(this._repository);

  final VenueCourtRepository _repository;

  Future<Either<AppException, VenueCourtPageModel>> call({
    required int page,
    int perPage = 10,
  }) async => await _repository.getVenueCourt(page: page, perPage: perPage);

  /// Loads every page for flows that need the complete venue set in a picker.
  Future<Either<AppException, List<VenueCourtModel>>> getAllVenueCourts({
    int perPage = 10,
  }) async {
    final List<VenueCourtModel> all = <VenueCourtModel>[];
    int page = 1;
    while (true) {
      final result = await call(page: page, perPage: perPage);
      final AppException? failure = result.fold((error) => error, (_) => null);
      if (failure != null) return left(failure);
      final VenueCourtPageModel current = result.getOrElse(
        () => const VenueCourtPageModel(
          items: <VenueCourtModel>[],
          currentPage: 1,
          lastPage: 1,
          perPage: 10,
          total: 0,
          hasMorePages: false,
        ),
      );
      all.addAll(current.items);
      if (!current.hasMorePages || current.currentPage >= current.lastPage) {
        return right(List<VenueCourtModel>.unmodifiable(all));
      }
      page = current.currentPage + 1;
    }
  }

  Future<Either<AppException, CourtDraft>> getCourtDetails(int courtId) async =>
      await _repository.getCourtDetails(courtId);

  Future<Either<AppException, List<SlotPricingDraft>>> getCourtSlots(
    int courtId,
  ) async => await _repository.getCourtSlots(courtId);

  Future<Either<AppException, List<SlotPricingDraft>>> createCourtSlot(
    Map<String, dynamic> data,
  ) async => await _repository.createCourtSlot(data);

  Future<Either<AppException, List<SlotPricingDraft>>> updateCourtSlot(
    Map<String, dynamic> data,
  ) async => await _repository.updateCourtSlot(data);

  Future<Either<AppException, List<SlotPricingDraft>>> deleteCourtSlot(
    Map<String, dynamic> data,
  ) async => await _repository.deleteCourtSlot(data);

  Future<Either<AppException, Unit>> updateCourtStatus(
    Map<String, dynamic> data,
  ) async => await _repository.updateCourtStatus(data);

  Future<Either<AppException, Unit>> deleteCourt(int courtId) async =>
      await _repository.deleteCourt(courtId);
}
