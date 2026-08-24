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

  /// Requests per server-side tab (`need_opponent` | `my_requests` |
  /// `settled`). Each tab is its own call, so each keeps its own rows, status
  /// and error rather than being filtered out of one shared list.
  final Map<OpponentRequestTab, List<OpponentRequestModel>> tabRequests;
  final Map<OpponentRequestTab, OpponentMatchStatus> tabStatuses;
  final Map<OpponentRequestTab, String?> tabErrors;

  /// Pagination per tab: the last page fetched, whether the server says more
  /// exist, and the total it reported. A tab not yet fetched has no entry.
  final Map<OpponentRequestTab, int> tabPages;
  final Map<OpponentRequestTab, bool> tabHasMore;
  final Map<OpponentRequestTab, int> tabTotals;

  /// True while a *next* page is being appended — distinct from [tabStatuses],
  /// which covers the first page. Appending must not blank the rows already on
  /// screen, so the two states are tracked apart.
  final Map<OpponentRequestTab, bool> tabLoadingMore;

  /// The `summary` block the requests endpoint sends beside every page: how
  /// many rows each tab holds. One tab's call therefore answers for all of
  /// them, so the chips carry their counts from the first load instead of
  /// filling in as each section is opened. Null until the first page lands.
  final OpponentRequestSummaryModel? requestSummary;

  int pageFor(OpponentRequestTab tab) => tabPages[tab] ?? 0;

  bool hasMoreFor(OpponentRequestTab tab) => tabHasMore[tab] ?? false;

  bool isLoadingMore(OpponentRequestTab tab) => tabLoadingMore[tab] ?? false;

  /// The server's total for the tab: its own `pagination.total` once that tab
  /// has been fetched, otherwise the count the shared `summary` reported for
  /// it, and the rows in hand only when neither has arrived.
  int totalFor(OpponentRequestTab tab) =>
      tabTotals[tab] ??
      requestSummary?.countFor(tab) ??
      requestsFor(tab).length;

  /// Per-request load state for the invitations review screen, keyed by request
  /// id. The invitations themselves live on the request row, so the list stays
  /// in one place; only their fetch state is tracked here.
  final Map<String, OpponentMatchStatus> invitationStatuses;
  final Map<String, String?> invitationErrors;

  /// The confirmed match read back from
  /// `/auth/opponent-requests/{id}/match-details`, keyed by request id, with
  /// its own fetch state. The list row stays the fallback: it already carries
  /// enough to draw the screen while this call is in flight.
  final Map<String, OpponentMatchDetailsModel> matchDetails;
  final Map<String, OpponentMatchStatus> matchDetailStatuses;
  final Map<String, String?> matchDetailErrors;

  OpponentMatchDetailsModel? matchDetailsFor(String requestId) =>
      matchDetails[requestId];

  OpponentMatchStatus matchDetailStatusFor(String requestId) =>
      matchDetailStatuses[requestId] ?? OpponentMatchStatus.initial;

  String? matchDetailErrorFor(String requestId) =>
      matchDetailErrors[requestId];

  bool isLoadingMatchDetails(String requestId) =>
      matchDetailStatusFor(requestId) == OpponentMatchStatus.loading;

  OpponentMatchStatus invitationStatusFor(String requestId) =>
      invitationStatuses[requestId] ?? OpponentMatchStatus.initial;

  String? invitationErrorFor(String requestId) => invitationErrors[requestId];

  bool isLoadingInvitations(String requestId) =>
      invitationStatusFor(requestId) == OpponentMatchStatus.loading;

  bool hasLoadedInvitations(String requestId) =>
      invitationStatusFor(requestId) == OpponentMatchStatus.success;

  /// Returns a copy with one request's invitation fetch state replaced, and
  /// optionally that request's [invitations] patched into every loaded tab.
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

  /// Rows of one tab; empty until that tab has been fetched.
  List<OpponentRequestModel> requestsFor(OpponentRequestTab tab) =>
      tabRequests[tab] ?? const [];

  /// A tab not yet fetched is `initial` — the UI spins rather than showing an
  /// empty state for a call that has not happened.
  OpponentMatchStatus statusFor(OpponentRequestTab tab) =>
      tabStatuses[tab] ?? OpponentMatchStatus.initial;

  String? errorFor(OpponentRequestTab tab) => tabErrors[tab];

  bool isLoadingTab(OpponentRequestTab tab) =>
      statusFor(tab) == OpponentMatchStatus.loading;

  bool hasLoadedTab(OpponentRequestTab tab) =>
      statusFor(tab) == OpponentMatchStatus.success;

  /// Returns a copy with one tab's slice replaced, optionally along with the
  /// pagination cursor that slice came from.
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

  /// The default section — what the list shows on open.
  List<OpponentRequestModel> get requests =>
      requestsFor(OpponentRequestTab.needOpponent);
  OpponentMatchStatus get requestsStatus =>
      statusFor(OpponentRequestTab.needOpponent);
  List<OpponentRequestModel> get myRequests =>
      requestsFor(OpponentRequestTab.myRequests);
  OpponentMatchStatus get myRequestsStatus =>
      statusFor(OpponentRequestTab.myRequests);
  String? get myRequestsError => errorFor(OpponentRequestTab.myRequests);

  /// Player positions from `GET /positions`. Empty until loaded — the UI
  /// falls back to [PlayerPositionModel.defaults].
  final List<PlayerPositionModel> positions;

  /// Opponent levels from `GET /opponent-levels`. Empty until loaded — the
  /// UI falls back to [OpponentLevelModel.defaults].
  final List<OpponentLevelModel> levels;

  /// State of the wizard's first step, which opens the request on the server
  /// (`POST /auth/opponent-requests`) before the user reaches step two.
  final OpponentMatchStatus matchStepStatus;

  /// State of the wizard's second step, which attaches the venue to the
  /// already-opened request (`PUT /auth/opponent-requests/{id}/venue`).
  final OpponentMatchStatus venueStepStatus;

  /// State of the wizard's third step, which replaces the cost split on the
  /// already-opened request (`PUT /auth/opponent-requests/{id}/cost`).
  final OpponentMatchStatus costStepStatus;

  /// Failure from the cost step alone, so it only surfaces on that step.
  final String? costStepError;

  bool get isSavingCostStep => costStepStatus == OpponentMatchStatus.loading;

  /// State of the requester confirming an opponent
  /// (`POST /auth/opponent-requests/{id}/invitations/{invitationId}/accept`).
  /// The match is only real once this succeeds, so the invitations page waits
  /// on it before telling the requester the match is confirmed.
  final OpponentMatchStatus selectOpponentStatus;

  /// Failure from that call alone, so it surfaces on the invitations page
  /// rather than as a generic list error.
  final String? selectOpponentError;

  bool get isSelectingOpponent =>
      selectOpponentStatus == OpponentMatchStatus.loading;

  /// State of the publish call that ends the wizard
  /// (`POST /auth/opponent-requests/{id}/publish`).
  final OpponentMatchStatus publishStatus;

  /// Failure from publishing alone, so it only surfaces on the wizard.
  final String? publishError;

  bool get isPublishing => publishStatus == OpponentMatchStatus.loading;

  /// Id of the request opened by that step. Empty until it succeeds; once set,
  /// re-submitting the step patches this id instead of opening a second one.
  final String draftRequestId;

  /// State of the single-request fetch that hydrates a resumed draft.
  final OpponentMatchStatus draftStatus;

  /// The server's copy of the draft being completed, once fetched.
  final OpponentRequestModel? draftDetail;

  /// Failure from that fetch alone, so it only surfaces on the wizard.
  final String? draftError;

  bool get isLoadingDraft => draftStatus == OpponentMatchStatus.loading;

  /// Failure from the match step alone, kept apart from [errorMessage] so a
  /// list-level error does not surface on the wizard and vice versa.
  final String? matchStepError;

  /// Failure from the venue step alone, kept apart from the others so it only
  /// surfaces on that step.
  final String? venueStepError;

  final String? errorMessage;

  /// One-shot confirmation from the server (e.g. the delete endpoint's
  /// `message`). The screen shows it as a snackbar and clears it.
  final String? successMessage;

  bool get isSavingMatchStep => matchStepStatus == OpponentMatchStatus.loading;

  bool get isSavingVenueStep => venueStepStatus == OpponentMatchStatus.loading;

  bool get hasDraftRequest => draftRequestId.isNotEmpty;

  bool get isLoadingMyRequests => isLoadingTab(OpponentRequestTab.myRequests);

  /// True once the "my requests" tab has produced a list.
  bool get hasMyRequests => hasLoadedTab(OpponentRequestTab.myRequests);

  /// True while any tab is still fetching its rows. A screen that looks a
  /// request up by id cannot tell "not fetched yet" from "gone" on its own, so
  /// it asks this before reporting the request missing.
  bool get isLoadingAnyRequests =>
      tabStatuses.values.any((s) => s == OpponentMatchStatus.loading);

  /// Looks a request up by id across every fetched tab — a card opened from
  /// one section may not exist in the others.
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
