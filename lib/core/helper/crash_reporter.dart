import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Decides what reaches Crashlytics as a *fatal* crash.
///
/// Everything still gets reported — visibility is not the problem. The problem
/// is that routing every error through `recordFlutterFatalError` files things
/// that never killed the app as crashes: a 1.5px layout overflow, or a 401 that
/// the API layer already turned into an error state on screen. Those drown out
/// the real crashes and make the crash-free-users number meaningless.
///
/// So: an error the app is known to handle, or one that only affects a frame's
/// layout, is recorded non-fatal; everything else stays fatal.
abstract final class CrashReporter {
  /// Installs the framework and platform error handlers.
  static void install() {
    // Debug sessions report errors that release builds cannot hit — a hot
    // reload leaves instances built before a new field was added holding null
    // in a non-nullable slot — and those were being filed as fatal crashes.
    unawaited(
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        !kDebugMode,
      ),
    );

    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      unawaited(
        FirebaseCrashlytics.instance.recordFlutterError(
          details,
          fatal: !_isLayoutError(details),
        ),
      );
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          fatal: !isHandledError(error),
        ),
      );
      return true;
    };
  }

  /// An error the app already has a user-facing path for. It should not be
  /// reaching the zone at all, but it is not a crash when it does.
  ///
  /// * [DioException] — the API layer turns these into `DataError`, including
  ///   the 401 that triggers a token refresh or a sign-out.
  /// * [SocketException] / [HttpException] / [TimeoutException] — no network.
  @visibleForTesting
  static bool isHandledError(Object error) {
    return error is DioException ||
        error is SocketException ||
        error is HttpException ||
        error is TimeoutException;
  }

  /// A "RenderFlex overflowed by N pixels" (or any other layout/paint
  /// assertion). It is a visual defect worth fixing, not a crash: the frame
  /// still renders and the user carries on.
  @visibleForTesting
  static bool isLayoutError(FlutterErrorDetails details) =>
      _isLayoutError(details);

  static bool _isLayoutError(FlutterErrorDetails details) {
    final String library = details.library ?? '';
    if (library == 'rendering library') return true;

    final String message = details.exceptionAsString().toLowerCase();
    return message.contains('overflowed by') ||
        message.contains('overflowing') ||
        (details.context?.toString().toLowerCase().contains('during layout') ??
            false);
  }
}
