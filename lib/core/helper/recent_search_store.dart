import 'package:flutter/foundation.dart';
import 'package:hamro_futsal/core/helper/share_preferences.dart';

class RecentSearchStore {
  RecentSearchStore._();

  static final RecentSearchStore instance = RecentSearchStore._();

  static const int maxEntries = 3;

  final ValueNotifier<List<String>> searches = ValueNotifier<List<String>>(
    const <String>[],
  );

  void load() {
    searches.value = List<String>.unmodifiable(
      AppSettings().recentVenueSearches,
    );
  }

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
