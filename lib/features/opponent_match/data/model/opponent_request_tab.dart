enum OpponentRequestTab { needOpponent, myRequests, invitations, settled }

extension OpponentRequestTabX on OpponentRequestTab {
  String get query => switch (this) {
    OpponentRequestTab.needOpponent => 'need_opponent',
    OpponentRequestTab.myRequests => 'my_requests',
    OpponentRequestTab.invitations => 'invitation',
    OpponentRequestTab.settled => 'settled',
  };

  bool get isOwnedByCaller => this == OpponentRequestTab.myRequests;
}
