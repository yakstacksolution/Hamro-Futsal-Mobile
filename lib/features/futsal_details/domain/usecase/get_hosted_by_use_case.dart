import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/futsal_details/data/model/hosted_by_model.dart';
import 'package:hamro_futsal/features/futsal_details/domain/repository/futsal_details_repository.dart';

final class GetHostedByUseCase {
  const GetHostedByUseCase(this.repository);

  final FutsalDetailsRepository repository;

  Future<Either<AppException, HostedByModel>> call({
    required int venueId,
  }) async => await repository.getHostedBy(venueId: venueId);
}
