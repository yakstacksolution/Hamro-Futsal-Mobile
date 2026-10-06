import 'package:dartz/dartz.dart';
import 'package:hamro_futsal/core/helper/exception_helper.dart';
import 'package:hamro_futsal/features/app_update/domain/entities/app_update_check.dart';

abstract class AppUpdateRepository {
  Future<Either<AppException, AppUpdateCheck>> checkForUpdate();

  bool shouldPrompt(AppUpdateCheck check);

  Future<void> snooze(AppUpdateCheck check, {Duration duration});
}
