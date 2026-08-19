import 'package:dartz/dartz.dart';
import 'package:hamro_footsall/core/helper/exception_helper.dart';
import 'package:hamro_footsall/features/app_update/domain/entities/app_update_check.dart';

abstract class AppUpdateRepository {
  /// Resolves the installed build against the published one.
  ///
  /// Returns a left only when the update state could not be determined at all
  /// *and* the caller asked for a user-visible check; the automatic launch check
  /// treats an unreachable source as "up to date" so a network blip never
  /// blocks the app.
  Future<Either<AppException, AppUpdateCheck>> checkForUpdate();

  /// Whether the optional-update prompt should be shown for [check], honouring
  /// a previous "Later". Forced updates always return true.
  bool shouldPrompt(AppUpdateCheck check);

  /// Records a "Later" for this specific version, suppressing the prompt until
  /// [duration] has passed. A newer version clears the snooze automatically.
  Future<void> snooze(AppUpdateCheck check, {Duration duration});
}
