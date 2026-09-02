import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/category_filter_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetCategoryFilterUseCase {
  const GetCategoryFilterUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<CategoryFilterModel>>> call() async =>
      await repository.getCategoryFilter();
}
