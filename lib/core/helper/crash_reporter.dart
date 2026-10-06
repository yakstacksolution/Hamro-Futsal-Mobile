import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

abstract final class CrashReporter {
  static void install() {
    // Debug sessions report errors that release builds cannot hit — a hot
    // reload leaves instances built before a new field was added holding null
    // in a non-nullable slot — and those were being filed as fatal crashes.
    unawaited(
      FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode),
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

  @visibleForTesting
  static bool isHandledError(Object error) {
    return error is DioException ||
        error is SocketException ||
        error is HttpException ||
        error is TimeoutException;
  }

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
