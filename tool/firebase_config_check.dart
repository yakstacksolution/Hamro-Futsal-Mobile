import 'dart:io';

final RegExp _googleApiKey = RegExp(
  'AI'
  'za[0-9A-Za-z_-]{35}',
);

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart tool/firebase_config_check.dart '
      '<android/app/google-services.json|ios/Runner/GoogleService-Info.plist>',
    );
    exit(64);
  }

  final File file = File(args.first);
  if (!file.existsSync()) {
    stderr.writeln('Missing Firebase config: ${file.path}');
    exit(1);
  }

  final String contents = file.readAsStringSync();
  if (contents.contains('REPLACE_WITH_') || !_googleApiKey.hasMatch(contents)) {
    stderr.writeln(
      'Invalid Firebase config: ${file.path}\n'
      'It contains placeholders or no valid Google API key. Restore this file '
      'from your local secret store or CI secret before building.',
    );
    exit(1);
  }
}
