import 'package:flutter/foundation.dart';

/// App-wide wishlist venue ids.
///
/// Seeded from the profile (`/auth/me` → `wishlists`) and flipped
/// optimistically on toggle. Every heart (home cards, wishlist tab, venue
/// details gallery) listens to [ids], so they stay in sync across routes —
/// including pages outside the dashboard's bloc scope.
class WishlistStore {
  WishlistStore._();

  static final WishlistStore instance = WishlistStore._();

  final ValueNotifier<Set<int>> ids = ValueNotifier<Set<int>>(<int>{});

  void seed(List<int> venueIds) => ids.value = <int>{...venueIds};

  bool contains(int? venueId) =>
      venueId != null && ids.value.contains(venueId);

  /// Local flip only — persistence is the caller's job.
  void toggleLocal(int venueId) {
    final Set<int> next = <int>{...ids.value};
    if (!next.remove(venueId)) next.add(venueId);
    ids.value = next;
  }

  void clear() => ids.value = <int>{};
}
