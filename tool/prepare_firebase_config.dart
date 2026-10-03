import 'dart:convert';
import 'dart:io';

const String _androidTarget = 'android/app/google-services.json';
const String _iosTarget = 'ios/Runner/GoogleService-Info.plist';

void main() {
  final bool android = _writeConfig(
    target: _androidTarget,
    fileEnv: 'FIREBASE_ANDROID_CONFIG_FILE',
    rawEnv: 'FIREBASE_ANDROID_GOOGLE_SERVICES_JSON',
    base64Env: 'FIREBASE_ANDROID_GOOGLE_SERVICES_JSON_BASE64',
    localPaths: const <String>[
      'secrets/android/google-services.json',
      'android/app/google-services.local.json',
    ],
    validator: _validateAndroid,
  );

  final bool ios = _writeConfig(
    target: _iosTarget,
    fileEnv: 'FIREBASE_IOS_CONFIG_FILE',
    rawEnv: 'FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST',
    base64Env: 'FIREBASE_IOS_GOOGLE_SERVICE_INFO_PLIST_BASE64',
    localPaths: const <String>[
      'secrets/ios/GoogleService-Info.plist',
      'ios/Runner/GoogleService-Info.local.plist',
    ],
    validator: _validateIos,
  );

  if (!android && !ios) {
    stdout.writeln(
      'No Firebase config secrets found. Place local files under secrets/ or '
      'set FIREBASE_* config environment variables.',
    );
  }
}

bool _writeConfig({
  required String target,
  required String fileEnv,
  required String rawEnv,
  required String base64Env,
  required List<String> localPaths,
  required void Function(String) validator,
}) {
  String? contents;
  final String? envFile = _nonBlank(Platform.environment[fileEnv]);
  if (envFile != null) {
    contents = File(envFile).readAsStringSync();
  }
  contents ??= _nonBlank(Platform.environment[rawEnv]);
  final String? encoded = _nonBlank(Platform.environment[base64Env]);
  if (contents == null && encoded != null) {
    contents = utf8.decode(
      base64.decode(encoded.replaceAll(RegExp(r'\s+'), '')),
    );
  }
  if (contents == null) {
    for (final String path in localPaths) {
      final File file = File(path);
      if (file.existsSync()) {
        contents = file.readAsStringSync();
        break;
      }
    }
  }
  if (contents == null) return false;

  validator(contents);
  File(target)
    ..createSync(recursive: true)
    ..writeAsStringSync(contents.endsWith('\n') ? contents : '$contents\n');
  stdout.writeln('Wrote $target from secure config source.');
  return true;
}

String? _nonBlank(String? value) {
  final String? trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

void _validateAndroid(String contents) {
  final Object? decoded = jsonDecode(contents);
  if (decoded is! Map || decoded['client'] is! List) {
    throw const FormatException(
      'Android Firebase config must be google-services.json.',
    );
  }
}

void _validateIos(String contents) {
  if (!contents.contains('<key>API_KEY</key>') ||
      !contents.contains('<key>GOOGLE_APP_ID</key>')) {
    throw const FormatException(
      'iOS Firebase config must be GoogleService-Info.plist.',
    );
  }
  // FirebaseInstallations aborts the app at launch when API_KEY is not a real
  // Google API key, so reject placeholders here instead of shipping a crash.
  if (contents.contains('REPLACE_WITH_') ||
      !RegExp(r'<key>API_KEY</key>\s*<string>AIza[0-9A-Za-z_-]{35}</string>')
          .hasMatch(contents)) {
    throw const FormatException(
      'iOS Firebase config has a placeholder or invalid API_KEY.',
    );
  }
}
