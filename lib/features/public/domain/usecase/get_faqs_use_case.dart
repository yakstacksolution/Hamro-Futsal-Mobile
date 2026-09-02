import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/public/data/model/public_faq_model.dart';
import 'package:hamro_futsal/features/public/domain/repository/public_repository.dart';

final class GetFaqsUseCase {
  const GetFaqsUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<PublicFaqModel>>> call() async =>
      await repository.getFaqs();
}
