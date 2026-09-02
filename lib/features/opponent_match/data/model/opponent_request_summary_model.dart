import 'package:equatable/equatable.dart';
import 'package:hamro_futsal/features/opponent_match/data/model/opponent_request_tab.dart';

/// The `summary` block of `/auth/opponent-requests?tab=…`: how many rows every
/// tab holds, not just the one that was asked for.
///
/// One call therefore answers for all four chips, so the counts are on screen
/// from the first page instead of appearing one at a time as the user swipes
/// each section into view.
class OpponentRequestSummaryModel extends Equatable {
  const OpponentRequestSummaryModel({
    this.all = 0,
    this.myRequests = 0,
    this.needOpponent = 0,
    this.invitations = 0,
    this.settled = 0,
  });

  final int all;
  final int myRequests;
  final int needOpponent;
  final int invitations;
  final int settled;

  factory OpponentRequestSummaryModel.fromJson(Map<String, dynamic> json) {
    int intOf(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value?.toString().trim() ?? '') ?? 0;
    }

    return OpponentRequestSummaryModel(
      all: intOf(json['all']),
      myRequests: intOf(json['my_requests']),
      needOpponent: intOf(json['need_opponent']),
      invitations: intOf(json['invitation'] ?? json['invitations']),
      settled: intOf(json['settled']),
    );
  }

  /// The count for one chip's tab.
  int countFor(OpponentRequestTab tab) => switch (tab) {
    OpponentRequestTab.needOpponent => needOpponent,
    OpponentRequestTab.myRequests => myRequests,
    OpponentRequestTab.invitations => invitations,
    OpponentRequestTab.settled => settled,
  };

  @override
  List<Object?> get props => [
    all,
    myRequests,
    needOpponent,
    invitations,
    settled,
  ];
}
