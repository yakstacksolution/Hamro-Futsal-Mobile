import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/core/helper/crash_reporter.dart';

void main() {
  group('CrashReporter.isHandledError', () {
    test('an API failure is handled, not a crash', () {
      expect(
        CrashReporter.isHandledError(
          DioException(
            requestOptions: RequestOptions(path: '/wishlist'),
            response: Response<dynamic>(
              requestOptions: RequestOptions(path: '/wishlist'),
              statusCode: 401,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        isTrue,
      );
    });

    test('losing the network is handled too', () {
      expect(
        CrashReporter.isHandledError(const SocketException('no route')),
        isTrue,
      );
      expect(CrashReporter.isHandledError(TimeoutException('slow')), isTrue);
    });

    test('anything else stays fatal', () {
      expect(CrashReporter.isHandledError(StateError('boom')), isFalse);
      expect(CrashReporter.isHandledError(TypeError()), isFalse);
    });
  });

  group('CrashReporter.isLayoutError', () {
    test('a RenderFlex overflow is a layout defect, not a crash', () {
      expect(
        CrashReporter.isLayoutError(
          FlutterErrorDetails(
            exception: FlutterError(
              'A RenderFlex overflowed by 1.5 pixels on the right.',
            ),
            library: 'rendering library',
            context: ErrorDescription('during layout'),
          ),
        ),
        isTrue,
      );
    });

    test('a widget build failure is still fatal', () {
      expect(
        CrashReporter.isLayoutError(
          FlutterErrorDetails(
            exception: TypeError(),
            library: 'widgets library',
            context: ErrorDescription('building BlocBuilder'),
          ),
        ),
        isFalse,
      );
    });
  });
}
