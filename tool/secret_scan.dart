import 'dart:io';

final RegExp _googleApiKey = RegExp(
  'AI'
  'za[0-9A-Za-z_-]{35}',
);

final RegExp _assignedSecret = RegExp(
  r'^\s*([A-Z0-9_]*(?:SECRET|TOKEN|PRIVATE_KEY|PASSWORD|API_KEY)[A-Z0-9_]*)\s*=\s*(.+?)\s*$',
);

const Set<String> _allowedSecretValues = <String>{'', '""', "''"};

const Set<String> _ignoredFiles = <String>{'tool/secret_scan.dart'};

const List<String> _extensions = <String>[
  '.dart',
  '.env',
  '.json',
  '.kts',
  '.plist',
  '.swift',
  '.yaml',
  '.yml',
];

bool _shouldScan(File file) {
  final String path = file.path.replaceAll('\\', '/');
  return _extensions.any(path.endsWith);
}

void main() {
  final List<String> findings = <String>[];
  final List<String> tracked = Process.runSync('git', <String>[
    'ls-files',
  ]).stdout.toString().split('\n');

  for (final String path in tracked.where((String p) => p.trim().isNotEmpty)) {
    if (_ignoredFiles.contains(path)) continue;
    final File entity = File(path);
    if (!entity.existsSync() || !_shouldScan(entity)) continue;
    final List<String> lines;
    try {
      lines = entity.readAsLinesSync();
    } catch (_) {
      continue;
    }
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i];
      if (_googleApiKey.hasMatch(line)) {
        findings.add('${entity.path}:${i + 1}: Google API key pattern');
      }
      final RegExpMatch? secret = _assignedSecret.firstMatch(line);
      if (secret == null) continue;
      final String value = secret.group(2)!.trim();
      if (_allowedSecretValues.contains(value)) continue;
      if (value.startsWith('REPLACE_WITH_')) continue;
      findings.add('${entity.path}:${i + 1}: non-empty ${secret.group(1)}');
    }
  }

  if (findings.isEmpty) {
    stdout.writeln('secret-scan: no committed secrets found.');
    return;
  }

  stderr.writeln('secret-scan: found possible committed secrets:');
  for (final String finding in findings) {
    stderr.writeln('  $finding');
  }
  exitCode = 1;
}
