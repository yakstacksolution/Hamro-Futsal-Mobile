import 'package:flutter/foundation.dart';
import 'package:hamro_footsall/core/helper/share_preferences.dart';

/// The user's most recent venue searches, capped at [maxEntries] and persisted
/// locally via [AppSettings]. The home search bar listens to [searches] so the
/// "Recent Searches" panel stays in sync as entries are added or removed.
///
/// Mirrors [WishlistStore]: a single shared, reactive source of truth.
class RecentSearchStore {
  RecentSearchStore._();

  static final RecentSearchStore instance = RecentSearchStore._();

  /// Newest first.
  static const int maxEntries = 3;

  final ValueNotifier<List<String>> searches = ValueNotifier<List<String>>(
    const <String>[],
  );

  /// Hydrates from local storage. Safe to call repeatedly.
  void load() {
    searches.value = List<String>.unmodifiable(AppSettings().recentVenueSearches);
  }

  /// Records [term] as the most recent search, de-duplicating
  /// case-insensitively and trimming the list to [maxEntries].
  void add(String term) {
    final String trimmed = term.trim();
    if (trimmed.isEmpty) return;
    final List<String> next = <String>[
      trimmed,
      for (final String s in searches.value)
        if (s.toLowerCase() != trimmed.toLowerCase()) s,
    ];
    if (next.length > maxEntries) next.removeRange(maxEntries, next.length);
    _commit(next);
  }

  void remove(String term) {
    final List<String> next = <String>[
      for (final String s in searches.value)
        if (s.toLowerCase() != term.toLowerCase()) s,
    ];
    _commit(next);
  }

  void clear() => _commit(const <String>[]);

  void _commit(List<String> next) {
    searches.value = List<String>.unmodifiable(next);
    AppSettings().recentVenueSearches = next;
  }
}
