library;

class MentionCandidate {
  const MentionCandidate({required this.userId, required this.name});

  final int userId;
  final String name;

  String get handle => name.trim();

  bool matchesQuery(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return name.toLowerCase().contains(needle);
  }
}

class ResolvedMentions {
  const ResolvedMentions({
    this.userIds = const <int>[],
    this.mentionAll = false,
  });

  final List<int> userIds;

  final bool mentionAll;

  bool get isEmpty => userIds.isEmpty && !mentionAll;
}

class MentionSpan {
  const MentionSpan({
    required this.start,
    required this.end,
    required this.text,
    this.userId,
    this.isAll = false,
  });

  final int start;
  final int end;

  final String text;

  final int? userId;
  final bool isAll;
}

const Set<String> kMentionAllTokens = <String>{'all', 'everyone', 'channel'};

bool _isNameChar(String ch) {
  return RegExp(r"[A-Za-z0-9_.'-]").hasMatch(ch);
}

List<MentionSpan> findMentionSpans(
  String body,
  List<MentionCandidate> candidates,
) {
  // No candidates means no mentionable conversation — a direct chat — so `@`
  // there is an ordinary character, `@all` included.
  if (body.isEmpty || candidates.isEmpty) return const <MentionSpan>[];

  final List<MentionCandidate> byLongestName =
      List<MentionCandidate>.from(candidates)..sort(
        (MentionCandidate a, MentionCandidate b) =>
            b.handle.length.compareTo(a.handle.length),
      );
  final String lower = body.toLowerCase();
  final List<MentionSpan> spans = <MentionSpan>[];

  int index = 0;
  while (index < body.length) {
    final int at = body.indexOf('@', index);
    if (at < 0) break;

    // `a@b` is an email, not a mention: an `@` only opens one at a word start.
    final bool atWordStart = at == 0 || !_isNameChar(body[at - 1]);
    if (!atWordStart) {
      index = at + 1;
      continue;
    }

    MentionSpan? matched;

    for (final String token in kMentionAllTokens) {
      if (lower.startsWith('@$token', at) &&
          _endsCleanly(body, at + token.length + 1)) {
        matched = MentionSpan(
          start: at,
          end: at + token.length + 1,
          text: body.substring(at, at + token.length + 1),
          isAll: true,
        );
        break;
      }
    }

    if (matched == null) {
      for (final MentionCandidate candidate in byLongestName) {
        final String handle = candidate.handle;
        if (handle.isEmpty) continue;
        if (lower.startsWith('@${handle.toLowerCase()}', at) &&
            _endsCleanly(body, at + handle.length + 1)) {
          matched = MentionSpan(
            start: at,
            end: at + handle.length + 1,
            text: body.substring(at, at + handle.length + 1),
            userId: candidate.userId,
          );
          break;
        }
      }
    }

    if (matched == null) {
      index = at + 1;
      continue;
    }

    spans.add(matched);
    index = matched.end;
  }

  return spans;
}

ResolvedMentions resolveMentions(
  String body,
  List<MentionCandidate> candidates,
) {
  final List<MentionSpan> spans = findMentionSpans(body, candidates);
  if (spans.isEmpty) return const ResolvedMentions();

  final bool all = spans.any((MentionSpan span) => span.isAll);
  final List<int> ids = <int>[];
  for (final MentionSpan span in spans) {
    final int? id = span.userId;
    if (id != null && !ids.contains(id)) ids.add(id);
  }
  return ResolvedMentions(userIds: ids, mentionAll: all);
}

bool _endsCleanly(String body, int end) {
  if (end >= body.length) return true;
  return !_isNameChar(body[end]);
}

({int start, String query})? activeMentionQuery(String text, int caret) {
  if (caret < 0 || caret > text.length) return null;

  int index = caret - 1;
  while (index >= 0) {
    final String ch = text[index];
    if (ch == '@') {
      final bool atWordStart = index == 0 || !_isNameChar(text[index - 1]);
      if (!atWordStart) return null;
      return (start: index, query: text.substring(index + 1, caret));
    }
    // A query may hold spaces ("@Dilli Bh"), but not a newline.
    if (ch == '\n') return null;
    // Give up after a reasonable name length rather than scanning the message.
    if (caret - index > 32) return null;
    index--;
  }
  return null;
}

({String text, int caret}) insertMention({
  required String text,
  required int start,
  required int caret,
  required String handle,
}) {
  final String before = text.substring(0, start);
  final String after = text.substring(caret);
  final String inserted = '@$handle ';
  return (
    text: '$before$inserted$after',
    caret: before.length + inserted.length,
  );
}
