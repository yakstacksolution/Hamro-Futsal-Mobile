import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/public/data/model/public_template_model.dart';
import 'package:hamro_footsall/features/public/domain/repository/public_repository.dart';

final class GetPublicTemplatesUseCase {
  const GetPublicTemplatesUseCase(this.repository);

  final PublicRepository repository;

  Future<Either<AppException, List<PublicTemplateModel>>> getTemplates() async =>
      await repository.getTemplates();
}
