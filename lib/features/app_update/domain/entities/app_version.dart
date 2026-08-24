import 'package:equatable/equatable.dart';

/// A dotted release version (`1.4.2`), compared numerically segment by segment.
///
/// Store and backend version strings are not reliably three segments — a build
/// may be published as `2`, `2.1` or `1.4.2+18` — so parsing tolerates any
/// segment count, ignores a `+build` suffix and any pre-release tag, and treats
/// missing segments as zero. That makes `1.4` and `1.4.0` equal rather than
/// prompting an endless update loop.
final class AppVersion extends Equatable implements Comparable<AppVersion> {
  const AppVersion(this.segments, {this.raw = ''});

  /// Numeric segments, most significant first. Never empty.
  final List<int> segments;

  /// The original string, kept for display so users see exactly what the
  /// store shows them.
  final String raw;

  static const AppVersion zero = AppVersion(<int>[0], raw: '0');

  /// Parses [value], returning null when it holds no usable number at all.
  /// Never throws — an unparsable manifest must not break app launch.
  static AppVersion? tryParse(String? value) {
    final String trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) return null;

    // Drop a `+build` / `-beta.1` suffix and any leading `v`.
    final String core = trimmed
        .replaceFirst(RegExp(r'^[vV]'), '')
        .split(RegExp(r'[+\-\s_]'))
        .first;

    final List<int> parsed = <int>[];
    for (final String part in core.split('.')) {
      // Tolerate segments such as `2a` by keeping their leading digits.
      final Match? digits = RegExp(r'^\d+').firstMatch(part.trim());
      if (digits == null) break;
      parsed.add(int.parse(digits.group(0)!));
    }

    if (parsed.isEmpty) return null;
    return AppVersion(parsed, raw: trimmed);
  }

  int _segmentAt(int index) => index < segments.length ? segments[index] : 0;

  @override
  int compareTo(AppVersion other) {
    final int length = segments.length > other.segments.length
        ? segments.length
        : other.segments.length;
    for (int i = 0; i < length; i++) {
      final int diff = _segmentAt(i) - other._segmentAt(i);
      if (diff != 0) return diff > 0 ? 1 : -1;
    }
    return 0;
  }

  bool operator >(AppVersion other) => compareTo(other) > 0;
  bool operator <(AppVersion other) => compareTo(other) < 0;
  bool operator >=(AppVersion other) => compareTo(other) >= 0;
  bool operator <=(AppVersion other) => compareTo(other) <= 0;

  @override
  String toString() => raw.isEmpty ? segments.join('.') : raw;

  @override
  List<Object?> get props => <Object?>[
    // Compare on the normalised numeric form so `1.4` == `1.4.0`.
    segments.length > 4
        ? segments.sublist(0, 4)
        : <int>[...segments, ...List<int>.filled(4 - segments.length, 0)],
  ];
}
