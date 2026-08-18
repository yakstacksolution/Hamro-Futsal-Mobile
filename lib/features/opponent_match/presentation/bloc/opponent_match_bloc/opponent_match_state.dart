part of 'opponent_match_bloc.dart';

enum OpponentMatchStatus { initial, loading, success, failure }

final class OpponentMatchState extends Equatable {
  const OpponentMatchState({
    this.teamsStatus = OpponentMatchStatus.initial,
    this.venuesStatus = OpponentMatchStatus.initial,
    this.tabRequests = const {},
    this.tabStatuses = const {},
    this.tabErrors = const {},
    this.teams = const [],
    this.venues = const [],
    this.positions = const [],
    this.levels = const [],
    this.matchStepStatus = OpponentMatchStatus.initial,
    this.venueStepStatus = OpponentMatchStatus.initial,
    this.costStepStatus = OpponentMatchStatus.initial,
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

  /// Returns a copy with one tab's slice replaced.
  OpponentMatchState withTab(
    OpponentRequestTab tab, {
    List<OpponentRequestModel>? requests,
    OpponentMatchStatus? status,
    String? error,
    bool clearError = false,
  }) => copyWith(
    tabRequests: requests == null
        ? tabRequests
        : {...tabRequests, tab: requests},
    tabStatuses: status == null ? tabStatuses : {...tabStatuses, tab: status},
    tabErrors: clearError || error != null
        ? {...tabErrors, tab: clearError ? null : error}
        : tabErrors,
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
    List<TeamModel>? teams,
    List<String>? venues,
    List<PlayerPositionModel>? positions,
    List<OpponentLevelModel>? levels,
    OpponentMatchStatus? matchStepStatus,
    OpponentMatchStatus? venueStepStatus,
    OpponentMatchStatus? costStepStatus,
    String? costStepError,
    bool clearCostStepError = false,
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
    teams,
    venues,
    positions,
    levels,
    matchStepStatus,
    venueStepStatus,
    costStepStatus,
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
