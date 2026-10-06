library;

import 'package:hamro_futsal/core/routers/deep_link_target.dart';

class LinkSpan {
  const LinkSpan({
    required this.start,
    required this.end,
    required this.text,
    required this.uri,
    required this.target,
  });

  final int start;
  final int end;

  final String text;

  final Uri uri;

  final DeepLinkTarget? target;

  bool get isInternal => target != null;
}

final RegExp _linkPattern = RegExp(
  r'(?:(?:https?|hamrofutsal)://|www\.)[^\s<>"]+',
  caseSensitive: false,
);

const String _trailingPunctuation = '.,;:!?\'"’”';

List<LinkSpan> findLinkSpans(String body) {
  if (body.isEmpty) return const <LinkSpan>[];

  final List<LinkSpan> spans = <LinkSpan>[];
  for (final RegExpMatch match in _linkPattern.allMatches(body)) {
    final int start = match.start;
    final String raw = match.group(0)!;
    final String trimmed = _trimTrailing(raw);
    if (trimmed.isEmpty) continue;

    final Uri? uri = Uri.tryParse(
      trimmed.toLowerCase().startsWith('www.') ? 'https://$trimmed' : trimmed,
    );
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) continue;

    spans.add(
      LinkSpan(
        start: start,
        end: start + trimmed.length,
        text: trimmed,
        uri: uri,
        target: DeepLinkTarget.parse(uri),
      ),
    );
  }
  return spans;
}

String _trimTrailing(String value) {
  String result = value;
  while (result.isNotEmpty) {
    final String last = result[result.length - 1];
    final bool isPunctuation = _trailingPunctuation.contains(last);
    final bool isUnmatchedCloser =
        (last == ')' && !result.contains('(')) ||
        (last == ']' && !result.contains('[')) ||
        (last == '}' && !result.contains('{'));
    if (!isPunctuation && !isUnmatchedCloser) break;
    result = result.substring(0, result.length - 1);
  }
  return result;
}
