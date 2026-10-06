part of 'opponent_match_bloc.dart';

enum OpponentMatchStatus { initial, loading, success, failure }

final class OpponentMatchState extends Equatable {
  const OpponentMatchState({
    this.teamsStatus = OpponentMatchStatus.initial,
    this.venuesStatus = OpponentMatchStatus.initial,
    this.tabRequests = const {},
    this.tabStatuses = const {},
    this.tabErrors = const {},
    this.tabPages = const {},
    this.tabHasMore = const {},
    this.tabTotals = const {},
    this.tabLoadingMore = const {},
    this.requestSummary,
    this.invitationStatuses = const {},
    this.invitationErrors = const {},
    this.matchDetails = const {},
    this.matchDetailStatuses = const {},
    this.matchDetailErrors = const {},
    this.teams = const [],
    this.venues = const [],
    this.positions = const [],
    this.levels = const [],
    this.matchStepStatus = OpponentMatchStatus.initial,
    this.venueStepStatus = OpponentMatchStatus.initial,
    this.costStepStatus = OpponentMatchStatus.initial,
    this.selectOpponentStatus = OpponentMatchStatus.initial,
    this.selectOpponentError,
    this.costStepError,
    this.publishStatus = OpponentMatchStatus.initial,
    this.publishError,
    this.draftRequestId = '',
    this.draftStatus = OpponentMatchStatus.initial,
    this.draftDetail,
    this.draftError,
    this.matchStepError,
    this.venueStepError,
    this.errorMessage,
    this.successMessage,
  });

  final OpponentMatchStatus teamsStatus;
  final OpponentMatchStatus venuesStatus;

  final Map<OpponentRequestTab, List<OpponentRequestModel>> tabRequests;
  final Map<OpponentRequestTab, OpponentMatchStatus> tabStatuses;
  final Map<OpponentRequestTab, String?> tabErrors;

  final Map<OpponentRequestTab, int> tabPages;
  final Map<OpponentRequestTab, bool> tabHasMore;
  final Map<OpponentRequestTab, int> tabTotals;

  final Map<OpponentRequestTab, bool> tabLoadingMore;

  final OpponentRequestSummaryModel? requestSummary;

  int pageFor(OpponentRequestTab tab) => tabPages[tab] ?? 0;

  bool hasMoreFor(OpponentRequestTab tab) => tabHasMore[tab] ?? false;

  bool isLoadingMore(OpponentRequestTab tab) => tabLoadingMore[tab] ?? false;

  int totalFor(OpponentRequestTab tab) =>
      tabTotals[tab] ??
      requestSummary?.countFor(tab) ??
      requestsFor(tab).length;

  final Map<String, OpponentMatchStatus> invitationStatuses;
  final Map<String, String?> invitationErrors;

  final Map<String, OpponentMatchDetailsModel> matchDetails;
  final Map<String, OpponentMatchStatus> matchDetailStatuses;
  final Map<String, String?> matchDetailErrors;

  OpponentMatchDetailsModel? matchDetailsFor(String requestId) =>
      matchDetails[requestId];

  OpponentMatchStatus matchDetailStatusFor(String requestId) =>
      matchDetailStatuses[requestId] ?? OpponentMatchStatus.initial;

  String? matchDetailErrorFor(String requestId) => matchDetailErrors[requestId];

  bool isLoadingMatchDetails(String requestId) =>
      matchDetailStatusFor(requestId) == OpponentMatchStatus.loading;

  OpponentMatchStatus invitationStatusFor(String requestId) =>
      invitationStatuses[requestId] ?? OpponentMatchStatus.initial;

  String? invitationErrorFor(String requestId) => invitationErrors[requestId];

  bool isLoadingInvitations(String requestId) =>
      invitationStatusFor(requestId) == OpponentMatchStatus.loading;

  bool hasLoadedInvitations(String requestId) =>
      invitationStatusFor(requestId) == OpponentMatchStatus.success;

  OpponentMatchState withInvitations(
    String requestId, {
    OpponentMatchStatus? status,
    String? error,
    List<OpponentInvitationModel>? invitations,
    bool clearError = false,
  }) => copyWith(
    tabRequests: invitations == null
        ? tabRequests
        : {
            for (final entry in tabRequests.entries)
              entry.key: [
                for (final r in entry.value)
                  if (r.id == requestId)
                    r.copyWith(invitations: invitations)
                  else
                    r,
              ],
          },
    invitationStatuses: status == null
        ? invitationStatuses
        : {...invitationStatuses, requestId: status},
    invitationErrors: clearError || error != null
        ? {...invitationErrors, requestId: clearError ? null : error}
        : invitationErrors,
  );
  final List<TeamModel> teams;
  final List<String> venues;

  List<OpponentRequestModel> requestsFor(OpponentRequestTab tab) =>
      tabRequests[tab] ?? const [];

  OpponentMatchStatus statusFor(OpponentRequestTab tab) =>
      tabStatuses[tab] ?? OpponentMatchStatus.initial;

  String? errorFor(OpponentRequestTab tab) => tabErrors[tab];

  bool isLoadingTab(OpponentRequestTab tab) =>
      statusFor(tab) == OpponentMatchStatus.loading;

  bool hasLoadedTab(OpponentRequestTab tab) =>
      statusFor(tab) == OpponentMatchStatus.success;

  OpponentMatchState withTab(
    OpponentRequestTab tab, {
    List<OpponentRequestModel>? requests,
    OpponentMatchStatus? status,
    String? error,
    bool clearError = false,
    int? page,
    bool? hasMore,
    int? total,
    bool? loadingMore,
    OpponentRequestSummaryModel? summary,
  }) => copyWith(
    tabRequests: requests == null
        ? tabRequests
        : {...tabRequests, tab: requests},
    tabStatuses: status == null ? tabStatuses : {...tabStatuses, tab: status},
    tabErrors: clearError || error != null
        ? {...tabErrors, tab: clearError ? null : error}
        : tabErrors,
    tabPages: page == null ? tabPages : {...tabPages, tab: page},
    tabHasMore: hasMore == null ? tabHasMore : {...tabHasMore, tab: hasMore},
    tabTotals: total == null ? tabTotals : {...tabTotals, tab: total},
    tabLoadingMore: loadingMore == null
        ? tabLoadingMore
        : {...tabLoadingMore, tab: loadingMore},
    requestSummary: summary,
  );

  List<OpponentRequestModel> get requests =>
      requestsFor(OpponentRequestTab.needOpponent);
  OpponentMatchStatus get requestsStatus =>
      statusFor(OpponentRequestTab.needOpponent);
  List<OpponentRequestModel> get myRequests =>
      requestsFor(OpponentRequestTab.myRequests);
  OpponentMatchStatus get myRequestsStatus =>
      statusFor(OpponentRequestTab.myRequests);
  String? get myRequestsError => errorFor(OpponentRequestTab.myRequests);

  final List<PlayerPositionModel> positions;

  final List<OpponentLevelModel> levels;

  final OpponentMatchStatus matchStepStatus;

  final OpponentMatchStatus venueStepStatus;

  final OpponentMatchStatus costStepStatus;

  final String? costStepError;

  bool get isSavingCostStep => costStepStatus == OpponentMatchStatus.loading;

  final OpponentMatchStatus selectOpponentStatus;

  final String? selectOpponentError;

  bool get isSelectingOpponent =>
      selectOpponentStatus == OpponentMatchStatus.loading;

  final OpponentMatchStatus publishStatus;

  final String? publishError;

  bool get isPublishing => publishStatus == OpponentMatchStatus.loading;

  final String draftRequestId;

  final OpponentMatchStatus draftStatus;

  final OpponentRequestModel? draftDetail;

  final String? draftError;

  bool get isLoadingDraft => draftStatus == OpponentMatchStatus.loading;

  final String? matchStepError;

  final String? venueStepError;

  final String? errorMessage;

  final String? successMessage;

  bool get isSavingMatchStep => matchStepStatus == OpponentMatchStatus.loading;

  bool get isSavingVenueStep => venueStepStatus == OpponentMatchStatus.loading;

  bool get hasDraftRequest => draftRequestId.isNotEmpty;

  bool get isLoadingMyRequests => isLoadingTab(OpponentRequestTab.myRequests);

  bool get hasMyRequests => hasLoadedTab(OpponentRequestTab.myRequests);

  bool get isLoadingAnyRequests =>
      tabStatuses.values.any((s) => s == OpponentMatchStatus.loading);

  OpponentRequestModel? requestById(String id) {
    for (final rows in tabRequests.values) {
      for (final r in rows) {
        if (r.id == id) return r;
      }
    }
    return null;
  }

  int get openRequestCount => requests.where((r) => r.status.isOpen).length;

  OpponentMatchState copyWith({
    OpponentMatchStatus? teamsStatus,
    OpponentMatchStatus? venuesStatus,
    Map<OpponentRequestTab, List<OpponentRequestModel>>? tabRequests,
    Map<OpponentRequestTab, OpponentMatchStatus>? tabStatuses,
    Map<OpponentRequestTab, String?>? tabErrors,
    Map<OpponentRequestTab, int>? tabPages,
    Map<OpponentRequestTab, bool>? tabHasMore,
    Map<OpponentRequestTab, int>? tabTotals,
    Map<OpponentRequestTab, bool>? tabLoadingMore,
    OpponentRequestSummaryModel? requestSummary,
    Map<String, OpponentMatchStatus>? invitationStatuses,
    Map<String, OpponentMatchDetailsModel>? matchDetails,
    Map<String, OpponentMatchStatus>? matchDetailStatuses,
    Map<String, String?>? matchDetailErrors,
    Map<String, String?>? invitationErrors,
    List<TeamModel>? teams,
    List<String>? venues,
    List<PlayerPositionModel>? positions,
    List<OpponentLevelModel>? levels,
    OpponentMatchStatus? matchStepStatus,
    OpponentMatchStatus? venueStepStatus,
    OpponentMatchStatus? costStepStatus,
    String? costStepError,
    bool clearCostStepError = false,
    OpponentMatchStatus? selectOpponentStatus,
    String? selectOpponentError,
    bool clearSelectOpponentError = false,
    OpponentMatchStatus? publishStatus,
    String? publishError,
    bool clearPublishError = false,
    String? draftRequestId,
    OpponentMatchStatus? draftStatus,
    OpponentRequestModel? draftDetail,
    bool clearDraftDetail = false,
    String? draftError,
    bool clearDraftError = false,
    String? matchStepError,
    bool clearMatchStepError = false,
    String? venueStepError,
    bool clearVenueStepError = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return OpponentMatchState(
      teamsStatus: teamsStatus ?? this.teamsStatus,
      venuesStatus: venuesStatus ?? this.venuesStatus,
      tabRequests: tabRequests ?? this.tabRequests,
      tabStatuses: tabStatuses ?? this.tabStatuses,
      tabErrors: tabErrors ?? this.tabErrors,
      tabPages: tabPages ?? this.tabPages,
      tabHasMore: tabHasMore ?? this.tabHasMore,
      tabTotals: tabTotals ?? this.tabTotals,
      tabLoadingMore: tabLoadingMore ?? this.tabLoadingMore,
      requestSummary: requestSummary ?? this.requestSummary,
      invitationStatuses: invitationStatuses ?? this.invitationStatuses,
      matchDetails: matchDetails ?? this.matchDetails,
      matchDetailStatuses: matchDetailStatuses ?? this.matchDetailStatuses,
      matchDetailErrors: matchDetailErrors ?? this.matchDetailErrors,
      invitationErrors: invitationErrors ?? this.invitationErrors,
      teams: teams ?? this.teams,
      venues: venues ?? this.venues,
      positions: positions ?? this.positions,
      levels: levels ?? this.levels,
      matchStepStatus: matchStepStatus ?? this.matchStepStatus,
      venueStepStatus: venueStepStatus ?? this.venueStepStatus,
      costStepStatus: costStepStatus ?? this.costStepStatus,
      costStepError: clearCostStepError
          ? null
          : costStepError ?? this.costStepError,
      selectOpponentStatus: selectOpponentStatus ?? this.selectOpponentStatus,
      selectOpponentError: clearSelectOpponentError
          ? null
          : selectOpponentError ?? this.selectOpponentError,
      publishStatus: publishStatus ?? this.publishStatus,
      publishError: clearPublishError
          ? null
          : publishError ?? this.publishError,
      draftRequestId: draftRequestId ?? this.draftRequestId,
      draftStatus: draftStatus ?? this.draftStatus,
      draftDetail: clearDraftDetail ? null : draftDetail ?? this.draftDetail,
      draftError: clearDraftError ? null : draftError ?? this.draftError,
      matchStepError: clearMatchStepError
          ? null
          : matchStepError ?? this.matchStepError,
      venueStepError: clearVenueStepError
          ? null
          : venueStepError ?? this.venueStepError,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
    teamsStatus,
    venuesStatus,
    tabRequests,
    tabStatuses,
    tabErrors,
    tabPages,
    tabHasMore,
    tabTotals,
    tabLoadingMore,
    requestSummary,
    invitationStatuses,
    matchDetails,
    matchDetailStatuses,
    matchDetailErrors,
    invitationErrors,
    teams,
    venues,
    positions,
    levels,
    matchStepStatus,
    venueStepStatus,
    costStepStatus,
    selectOpponentStatus,
    selectOpponentError,
    costStepError,
    publishStatus,
    publishError,
    draftRequestId,
    draftStatus,
    draftDetail,
    draftError,
    matchStepError,
    venueStepError,
    errorMessage,
    successMessage,
  ];
}
