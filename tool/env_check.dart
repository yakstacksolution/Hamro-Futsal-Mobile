// Compares `.env.staging` with `.env.production`.
//
// A key present in one file and missing from the other is the failure mode
// that matters: `dotenv.env['X']` returns null and the call site falls back to
// an empty string or a default, so the app quietly runs with the wrong value
// rather than failing. Run with `make env-check`.
import 'dart:io';

const List<String> _files = <String>['.env.staging', '.env.production'];

/// Keys that may be blank: the app has a documented fallback for each.
const Set<String> _optional = <String>{'IOS_APP_STORE_ID', 'APP_STORE_COUNTRY'};

/// Keys whose values are expected to be the same in both environments.
const Set<String> _sharedByDesign = <String>{
  'APP_NAME',
  'APP_STORE_COUNTRY',
  'IOS_APP_STORE_ID',
  'REVERB_PORT',
  'REVERB_SCHEME',
  'REVERB_MESSAGE_EVENT',
  'REVERB_TYPING_EVENT',
};

Map<String, String> _read(String path) {
  final File file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('missing $path');
    exit(1);
  }
  final Map<String, String> values = <String, String>{};
  for (final String line in file.readAsLinesSync()) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#') || !trimmed.contains('=')) {
      continue;
    }
    final int split = trimmed.indexOf('=');
    values[trimmed.substring(0, split).trim()] = trimmed
        .substring(split + 1)
        .trim();
  }
  return values;
}

void main() {
  final Map<String, String> staging = _read(_files[0]);
  final Map<String, String> production = _read(_files[1]);

  int problems = 0;

  final Set<String> onlyStaging = staging.keys.toSet()
    ..removeAll(production.keys);
  final Set<String> onlyProduction = production.keys.toSet()
    ..removeAll(staging.keys);

  for (final String key in onlyStaging) {
    problems++;
    stdout.writeln('MISSING in .env.production: $key');
  }
  for (final String key in onlyProduction) {
    problems++;
    stdout.writeln('MISSING in .env.staging: $key');
  }

  for (final String key in staging.keys.where(production.containsKey)) {
    if (staging[key] != production[key]) continue;
    if (_sharedByDesign.contains(key)) continue;
    stdout.writeln(
      'SAME VALUE in both files: $key '
      '— intended? staging and production should not share it',
    );
  }

  for (final MapEntry<String, String> entry in staging.entries) {
    if (entry.value.isEmpty && !_optional.contains(entry.key)) {
      problems++;
      stdout.writeln('EMPTY in .env.staging: ${entry.key}');
    }
  }
  for (final MapEntry<String, String> entry in production.entries) {
    if (entry.value.isEmpty && !_optional.contains(entry.key)) {
      problems++;
      stdout.writeln('EMPTY in .env.production: ${entry.key}');
    }
  }

  stdout.writeln(
    problems == 0
        ? 'env-check: ${staging.length} keys, both files agree.'
        : 'env-check: $problems problem(s).',
  );
  exit(problems == 0 ? 0 : 1);
}
