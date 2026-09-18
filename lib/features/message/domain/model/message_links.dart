/// Links inside a chat message body.
///
/// A shared venue arrives in a conversation as plain text — the sender pasted
/// what the share sheet gave them — so the body has to be scanned to know
/// which runs of it are links and which of those the app owns. Detection is
/// kept here, away from the widget, so the tricky parts (trailing punctuation,
/// `www.` without a scheme) can be tested without pumping a bubble.
library;

import 'package:hamro_futsal/core/routers/deep_link_target.dart';
/// One URL found in a body.
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

  /// The matched text exactly as it appears in the body.
  final String text;

  /// [text] as a launchable URI — `www.x.com` gains the `https://` it omits.
  final Uri uri;

  /// Non-null when this link opens a screen inside the app rather than the
  /// browser.
  final DeepLinkTarget? target;

  bool get isInternal => target != null;
}

/// `https://…`, `hamrofutsal://…` or a bare `www.…`.
///
/// Deliberately narrow: a token only counts as a link when it carries a scheme
/// the app can launch or the `www.` that universally means one. Guessing at
/// bare `something.com` turns ordinary sentences ("hi.Are you coming") into
/// links.
final RegExp _linkPattern = RegExp(
  r'(?:(?:https?|hamrofutsal)://|www\.)[^\s<>"]+',
  caseSensitive: false,
);

/// Trailing characters that end a sentence rather than a URL.
const String _trailingPunctuation = '.,;:!?\'"’”';

/// Finds every link in [body], in the order it appears.
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

/// Drops the punctuation a sentence leaves stuck to a URL — "see
/// https://hamrofutsal.com/venues/un-park-futsal." is a link and a full stop.
/// A closing bracket is only dropped when the URL does not open one itself, so
/// a link that legitimately ends in `)` survives.
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
