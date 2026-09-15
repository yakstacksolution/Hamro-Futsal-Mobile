import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hamro_futsal/features/auth/domain/repository/authentication_repository.dart';
import 'package:hamro_futsal/features/auth/domain/usecase/authentication_usecase.dart';
import 'package:hamro_futsal/features/auth/presentation/authentication_bloc/authentication_bloc.dart';

class _UnusedRepository extends Fake implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('plugins.flutter.io/google_sign_in');

  setUp(() => dotenv.loadFromString(envString: 'ENV=test'));
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final code in ['10', '7']) {
    test('Google SDK error $code retains a safe support reference', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'signIn') {
              throw PlatformException(
                code: 'sign_in_failed',
                message:
                    'com.google.android.gms.common.api.ApiException: '
                    '$code: private-account@example.com',
              );
            }
            return null;
          });
      final bloc = AuthenticationBloc(AuthUseCase(_UnusedRepository()));
      final failure = bloc.stream.firstWhere(
        (state) => state.googleLoginStatus == AuthStatus.failure,
      );
      bloc.add(const GoogleLoginEvent());
      final state = await failure;
      expect(state.errorMessage, contains('(Google $code)'));
      expect(state.errorMessage, isNot(contains('private-account')));
      if (code == '10') {
        expect(state.errorMessage, contains('not configured'));
      }
      await bloc.close();
    });
  }
}
