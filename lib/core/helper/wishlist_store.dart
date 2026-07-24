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

  /// Venue ids with an in-flight toggle whose API round-trip has not resolved
  /// yet. While a venue is pending, a [seed] from a (possibly stale) server
  /// response must not clobber the optimistic flip — otherwise the heart would
  /// briefly jump back before the toggle persists.
  final Set<int> _pending = <int>{};

  /// Replaces the set from a canonical source (profile / wishlist fetch), but
  /// preserves the optimistic decision for any venue whose toggle is still
  /// in flight so a slow server response can't revert a fresh tap.
  void seed(List<int> venueIds) {
    final Set<int> next = <int>{...venueIds};
    for (final int pendingId in _pending) {
      if (ids.value.contains(pendingId)) {
        next.add(pendingId);
      } else {
        next.remove(pendingId);
      }
    }
    ids.value = next;
  }

  bool contains(int? venueId) => venueId != null && ids.value.contains(venueId);

  /// Local flip only — persistence is the caller's job.
  void toggleLocal(int venueId) {
    final Set<int> next = <int>{...ids.value};
    if (!next.remove(venueId)) next.add(venueId);
    ids.value = next;
  }

  /// Marks [venueId] as having an in-flight toggle so [seed] won't overwrite it.
  void markPending(int venueId) => _pending.add(venueId);

  /// Clears the in-flight marker once the toggle's API call has resolved.
  void clearPending(int venueId) => _pending.remove(venueId);

  void clear() {
    _pending.clear();
    ids.value = <int>{};
  }
}
