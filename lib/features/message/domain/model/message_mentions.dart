/// Mentions in a chat message: `@Ram` targets one participant, `@all` targets
/// every one of them.
///
/// The body is the source of truth. A mention only counts when the text still
/// contains the `@name` that produced it, so deleting the text deletes the
/// mention — the alternative, tracking ids as the user edits, silently sends
/// mentions for names that are no longer on screen.
library;

/// Someone who can be mentioned: a participant of the conversation.
class MentionCandidate {
  const MentionCandidate({required this.userId, required this.name});

  final int userId;
  final String name;

  /// The token typed after `@`, with the spaces the name itself has.
  String get handle => name.trim();

  bool matchesQuery(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return name.toLowerCase().contains(needle);
  }
}

/// What a body resolves to when it is sent.
class ResolvedMentions {
  const ResolvedMentions({
    this.userIds = const <int>[],
    this.mentionAll = false,
  });

  /// Participants named in the body, in the order they first appear.
  final List<int> userIds;

  /// True when the body says `@all` (or `@everyone`).
  final bool mentionAll;

  bool get isEmpty => userIds.isEmpty && !mentionAll;
}

/// One `@…` run found in a body.
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

  /// The matched text including the leading `@`.
  final String text;

  /// The participant it resolves to, or null for `@all`.
  final int? userId;
  final bool isAll;
}

/// The tokens that mean "everyone".
const Set<String> kMentionAllTokens = <String>{'all', 'everyone', 'channel'};

/// A character that can continue a name being typed after `@`.
bool _isNameChar(String ch) {
  return RegExp(r"[A-Za-z0-9_.'-]").hasMatch(ch);
}

/// Finds every `@mention` in [body] that resolves against [candidates].
///
/// Names can contain spaces ("Dilli Bhandari"), so the longest candidate that
/// matches at a given `@` wins; that stops `@Dilli` swallowing a mention of
/// `@Dilli Bhandari` and leaving a stray surname behind.
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

/// The mention payload for a body: `mentions` ids and the `mention_all` flag.
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

/// True when a mention ends at a boundary rather than mid-word, so `@Rama`
/// does not count as a mention of `@Ram`.
bool _endsCleanly(String body, int end) {
  if (end >= body.length) return true;
  return !_isNameChar(body[end]);
}

/// The `@query` the caret sits in, or null when the caret is not writing one.
///
/// Used by the composer to decide whether to offer the participant list, and
/// what to filter it by.
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

/// Replaces the `@query` at [start]..[caret] with `@Name ` and returns the new
/// text and where the caret should land.
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
