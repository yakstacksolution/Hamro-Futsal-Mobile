/// Server-side slices of `GET /auth/opponent-requests?tab=…`.
///
/// The backend decides what belongs in each slice, so the three sections of
/// the requests list are three separate calls rather than one list filtered
/// on-device.
enum OpponentRequestTab { needOpponent, myRequests, settled }

extension OpponentRequestTabX on OpponentRequestTab {
  /// Value sent as the `tab` query parameter.
  String get query => switch (this) {
    OpponentRequestTab.needOpponent => 'need_opponent',
    OpponentRequestTab.myRequests => 'my_requests',
    OpponentRequestTab.settled => 'settled',
  };

  /// Rows of `my_requests` belong to the caller by definition; the other tabs
  /// carry other teams' requests, so ownership is left to the payload.
  bool get isOwnedByCaller => this == OpponentRequestTab.myRequests;
}
