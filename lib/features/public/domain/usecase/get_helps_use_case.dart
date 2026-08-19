import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_help_model.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';

final class GetHelpsUseCase {
  const GetHelpsUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<PublicHelpModel>>> call() async =>
      await repository.getHelps();
}
