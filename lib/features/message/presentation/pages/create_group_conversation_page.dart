import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_app_bar.dart';
import 'package:hamro_futsal/core/widgets/custom_button.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/model/registered_user_page_model.dart';
import 'package:hamro_futsal/features/message/data/repositories/message_repository_impl.dart';
import 'package:hamro_futsal/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_futsal/features/message/presentation/utils/pagination_trigger.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

typedef RegisteredUsersLoader =
    Future<RegisteredUserPageModel> Function({
      required int page,
      required int perPage,
      required String search,
    });

/// Full-page create-group flow.
///
/// Pushed as its own route rather than shown in a sheet: the form is long —
/// a name, a searchable member list and selected-member chips — and a sheet
/// fought the keyboard for what little height was left.
/// Pops a [GroupConversationDraft] on submit, or null when abandoned.
class CreateGroupConversationPage extends StatefulWidget {
  const CreateGroupConversationPage({
    super.key,
    required this.participants,
    required this.currentUserId,
    this.useCase,
    this.registeredUsersLoader,
  });

  /// Optional seed while the registered-users endpoint loads. Direct tests and
  /// legacy callers can still pass this without a [useCase].
  final Iterable<ParticipantModel> participants;
  final int currentUserId;
  final MessageUseCase? useCase;
  final RegisteredUsersLoader? registeredUsersLoader;

  /// Pushes the page and returns the draft the user submitted, if any.
  static Future<GroupConversationDraft?> open(
    BuildContext context, {
    required Iterable<ParticipantModel> participants,
    required int currentUserId,
    MessageUseCase? useCase,
    RegisteredUsersLoader? registeredUsersLoader,
  }) {
    final byUserId = <int, ParticipantModel>{};
    for (final participant in participants) {
      if (participant.userId > 0 && participant.userId != currentUserId) {
        byUserId[participant.userId] = participant;
      }
    }
    final candidates = byUserId.values.toList(growable: false)
      // Online first, then by name: the people who can answer now are the
      // ones a pickup game is usually built from.
      ..sort((a, b) {
        if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return Navigator.of(context).push<GroupConversationDraft>(
      MaterialPageRoute<GroupConversationDraft>(
        builder: (_) => CreateGroupConversationPage(
          participants: candidates,
          currentUserId: currentUserId,
          useCase: registeredUsersLoader == null
              ? useCase ?? MessageUseCase(MessageRepositoryImpl())
              : useCase,
          registeredUsersLoader: registeredUsersLoader,
        ),
      ),
    );
  }

  @override
  State<CreateGroupConversationPage> createState() =>
      _CreateGroupConversationPageState();
}

class _CreateGroupConversationPageState
    extends State<CreateGroupConversationPage> {
  static const int _registeredUsersPerPage = 15;

  /// Long enough that a burst of typing is one request, short enough that the
  /// list answers while the user is still looking at it. Three seconds felt
  /// like the search was ignoring them.
  static const Duration _searchDebounceDelay = Duration(milliseconds: 450);

  final TextEditingController _title = TextEditingController();
  final TextEditingController _search = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final Map<int, ParticipantModel> _knownParticipants =
      <int, ParticipantModel>{};

  /// Insertion-ordered so the chip strip reads in the order people were
  /// picked, which is the order the user remembers choosing them in.
  final Set<int> _selected = <int>{};

  /// Guards the registered-users endpoint: without it a short list re-triggers
  /// its own "load more" after every page and walks straight into a 429.
  final PaginationTrigger _pagination = PaginationTrigger();

  Timer? _searchDebounce;
  List<ParticipantModel> _remoteCandidates = const <ParticipantModel>[];
  bool _loadingInitial = false;
  bool _loadingMore = false;
  bool _hasMoreUsers = false;
  bool _queuedSearchReload = false;
  int _currentUserPage = 0;

  /// The search the list currently shows results for. A debounced search that
  /// lands back on it (typed then erased) sends nothing.
  String? _loadedSearch;
  int _requestSerial = 0;
  String? _error;
  String? _loadError;

  /// A query is in flight: the field shows a spinner so a slow search does not
  /// read as a search that did nothing.
  bool get _searching =>
      _usesRemoteMembers &&
      (_loadingInitial || _searchDebounce?.isActive == true) &&
      _search.text.trim().isNotEmpty;

  bool get _usesRemoteMembers =>
      widget.useCase != null || widget.registeredUsersLoader != null;

  List<ParticipantModel> get _seedCandidates =>
      widget.participants is List<ParticipantModel>
      ? widget.participants as List<ParticipantModel>
      : widget.participants.toList(growable: false);

  List<ParticipantModel> get _candidates {
    final byUserId = <int, ParticipantModel>{};
    for (final participant in _seedCandidates.followedBy(_remoteCandidates)) {
      if (participant.userId > 0 &&
          participant.userId != widget.currentUserId) {
        byUserId[participant.userId] = participant;
      }
    }
    return byUserId.values.toList(growable: false);
  }

  int get _selectedCount => _selected.length;

  bool get _isFull => _selectedCount >= kMaxGroupMembers;

  /// The rows to show for the current query.
  ///
  /// The server does the searching, but the list also carries seed rows from
  /// the inbox and the pages loaded before the query changed. Those were shown
  /// unfiltered, so typing a name appeared to do nothing — the same faces
  /// stayed on screen. Filtering locally as well keeps only rows that match
  /// what was typed, whoever supplied them.
  List<ParticipantModel> get _visibleCandidates {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _candidates;

    return _candidates
        .where((participant) {
          return participant.name.toLowerCase().contains(query) ||
              participant.email.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  /// Chips follow the pick order, not the list order.
  List<ParticipantModel> get _selectedMembers {
    final byUserId = <int, ParticipantModel>{
      ..._knownParticipants,
      for (final participant in _candidates) participant.userId: participant,
    };
    return <ParticipantModel>[
      for (final id in _selected)
        if (byUserId[id] case final participant?) participant,
    ];
  }

  @override
  void initState() {
    super.initState();
    _rememberParticipants(_seedCandidates);
    if (_usesRemoteMembers) {
      unawaited(_loadRegisteredUsers(reset: true));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _titleFocus.dispose();
    _title.dispose();
    _search.dispose();
    super.dispose();
  }

  void _rememberParticipants(Iterable<ParticipantModel> participants) {
    for (final participant in participants) {
      if (participant.userId > 0) {
        _knownParticipants[participant.userId] = participant;
      }
    }
  }

  Future<void> _loadRegisteredUsers({required bool reset}) async {
    if (!_usesRemoteMembers) return;
    if (_loadingInitial || _loadingMore) {
      if (reset) _queuedSearchReload = true;
      return;
    }

    final int page = reset ? 1 : _currentUserPage + 1;
    final int serial = ++_requestSerial;
    final String search = _search.text.trim();

    setState(() {
      _loadError = null;
      if (reset) {
        _pagination.reset();
        _loadingInitial = true;
        _currentUserPage = 0;
        _hasMoreUsers = false;
        _remoteCandidates = const <ParticipantModel>[];
      } else {
        _loadingMore = true;
      }
    });

    final loader = widget.registeredUsersLoader;
    if (!mounted || serial != _requestSerial) return;

    try {
      final pageResult = loader == null
          ? await widget.useCase!
                .getRegisteredUsers(
                  page: page,
                  perPage: _registeredUsersPerPage,
                  search: search,
                )
                .then(
                  (result) => result.fold(
                    (failure) => throw _RegisteredUsersLoadException(
                      failure.errorMessage,
                    ),
                    (pageResult) => pageResult,
                  ),
                )
          : await loader(
              page: page,
              perPage: _registeredUsersPerPage,
              search: search,
            );
      if (!mounted || serial != _requestSerial) return;
      setState(() {
        _loadingInitial = false;
        _loadingMore = false;
        _loadedSearch = search;
        // Never move backwards: a page number the server echoes wrong would
        // otherwise make "load more" ask for the same page again.
        _currentUserPage = pageResult.currentPage < page
            ? page
            : pageResult.currentPage;
        _hasMoreUsers = pageResult.hasMorePages && pageResult.items.isNotEmpty;
        final byUserId = <int, ParticipantModel>{
          if (!reset)
            for (final participant in _remoteCandidates)
              participant.userId: participant,
          for (final participant in pageResult.items)
            participant.userId: participant,
        };
        _remoteCandidates = byUserId.values.toList(growable: false);
        _rememberParticipants(_remoteCandidates);
      });
    } on _RegisteredUsersLoadException catch (failure) {
      if (!mounted || serial != _requestSerial) return;
      setState(() {
        _loadingInitial = false;
        _loadingMore = false;
        _loadError = failure.message;
      });
    } catch (_) {
      if (!mounted || serial != _requestSerial) return;
      setState(() {
        _loadingInitial = false;
        _loadingMore = false;
        _loadError = 'Could not load users.';
      });
    }
    // A standing error stops the auto-pager (see [PaginationTrigger]); the
    // user retries from the footer, which is also what a 429's "try again in
    // N seconds" needs.
    if (_queuedSearchReload) {
      _queuedSearchReload = false;
      unawaited(_loadRegisteredUsers(reset: true));
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    // A pending timer is part of "searching", so the field has to rebuild when
    // one starts as well as when the request lands.
    if (_usesRemoteMembers) {
      _searchDebounce = Timer(_searchDebounceDelay, () {
        final bool unchanged =
            _search.text.trim() == _loadedSearch && _loadError == null;
        if (unchanged) {
          // Rebuild so the field's "searching" spinner stops.
          if (mounted) setState(() {});
          return;
        }
        unawaited(_loadRegisteredUsers(reset: true));
      });
    }
    setState(() {
      _error = null;
      if (_usesRemoteMembers) _loadError = null;
    });
  }

  bool _onScroll(ScrollNotification notification) {
    final bool canLoad =
        _usesRemoteMembers &&
        _hasMoreUsers &&
        !_loadingInitial &&
        !_loadingMore &&
        _loadError == null;
    if (_pagination.shouldLoadMore(notification, canLoad: canLoad)) {
      unawaited(_loadRegisteredUsers(reset: false));
    }
    return false;
  }

  void _submit() {
    final title = _title.text.trim();

    if (title.isEmpty) {
      setState(() => _error = 'Enter a group name.');
      _titleFocus.requestFocus();
      return;
    }

    if (title.length > 255) {
      setState(() => _error = 'Group name must be 255 characters or fewer.');
      _titleFocus.requestFocus();
      return;
    }

    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one member.');
      return;
    }

    if (_selected.length > kMaxGroupMembers) {
      setState(() {
        _error = 'A group can contain at most $kMaxGroupMembers members.';
      });
      return;
    }

    Navigator.of(context).pop(
      GroupConversationDraft(
        title: title,
        participantIds: _selected.toList(growable: false),
      ),
    );
  }

  void _toggleParticipant(ParticipantModel participant) {
    final bool isSelected = _selected.contains(participant.userId);

    // Adding past the cap is refused where the tap happened, rather than only
    // at submit time once the form has scrolled away.
    if (!isSelected && _isFull) {
      HapticFeedback.heavyImpact();
      setState(() => _error = StringConstants.groupMemberLimitReached);
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _error = null;

      if (isSelected) {
        _selected.remove(participant.userId);
      } else {
        _selected.add(participant.userId);
      }
    });
  }

  /// Adds everyone currently listed — the whole pool, or just the search
  /// results when a query narrowed it. Stops at the cap rather than refusing.
  void _selectAllVisible() {
    HapticFeedback.selectionClick();
    setState(() {
      _error = null;
      for (final participant in _visibleCandidates) {
        if (_selected.length >= kMaxGroupMembers) {
          _error = StringConstants.groupMemberLimitReached;
          break;
        }
        _selected.add(participant.userId);
      }
    });
  }

  void _clearSelection() {
    HapticFeedback.selectionClick();
    setState(() {
      _selected.clear();
      _error = null;
    });
  }

  void _clearSearch() {
    _search.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LightColor.cardColor,
      appBar: CustomAppBar(title: StringConstants.createGroup),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildScrollableContent()),
                  _buildBottomAction(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: AppDimens.paddingX16),
        children: [
          const SizedBox(height: AppDimens.paddingX14),
          Text(
            StringConstants.nameTheGroupAndChooseWhoIsInIt,
            style: FutsalTheme.getTextTheme(
              context,
            ).bodyTextSmall?.copyWith(color: LightColor.secondaryTextColor),
          ),
          const SizedBox(height: AppDimens.paddingX16),
          _buildGroupNameField(),
          const SizedBox(height: AppDimens.paddingX16),
          _buildMembersHeader(),
          if (_isFull || _selectedCount == 0) ...[
            const SizedBox(height: AppDimens.paddingX4),
            Semantics(
              liveRegion: true,
              child: Text(
                _isFull
                    ? StringConstants.groupFull
                    : 'Tap to add up to $kMaxGroupMembers people.',
                style: FutsalTheme.getTextTheme(context).bodyTextSmall
                    ?.copyWith(
                      color: _isFull
                          ? LightColor.redColor
                          : LightColor.secondaryTextColor,
                      fontWeight: _isFull ? FontWeight.w600 : FontWeight.w400,
                    ),
              ),
            ),
          ],
          const SizedBox(height: AppDimens.paddingX10),
          if (_usesRemoteMembers || _candidates.isNotEmpty) ...[
            _buildSearchField(),
            const SizedBox(height: AppDimens.paddingX10),
          ],
          if (_selected.isNotEmpty) ...[
            GroupSelectedMembersStrip(
              members: _selectedMembers,
              onRemove: _toggleParticipant,
            ),
            const SizedBox(height: AppDimens.paddingX12),
          ],
          _buildMembersList(),
          const SizedBox(height: AppDimens.paddingX16),
        ],
      ),
    );
  }

  Widget _buildGroupNameField() {
    return CustomTextField(
      controller: _title,
      focusNode: _titleFocus,
      textCapitalization: TextCapitalization.words,
      onChanged: (_) => setState(() => _error = null),
      labelText: StringConstants.groupName,
      hintText: StringConstants.eGWeekendFutsalTeam,
      textInputAction: TextInputAction.next,
      ensureVisibleOnFocus: true,
    );
  }

  /// "Members" with the one action that applies right now: clear what is
  /// selected, or add everyone listed when nothing is.
  Widget _buildMembersHeader() {
    final bool canSelectAll =
        _visibleCandidates.isNotEmpty &&
        !_isFull &&
        _visibleCandidates.any((p) => !_selected.contains(p.userId));

    return GroupSectionHeader(
      title: StringConstants.addMembers,
      countLabel: _selectedCount == 0
          ? null
          : '$_selectedCount/$kMaxGroupMembers',
      trailingLabel: _selectedCount > 0
          ? StringConstants.clearAll
          : canSelectAll
          ? StringConstants.selectAll
          : null,
      trailingColor: LightColor.brandTextColor,
      onTrailingTap: _selectedCount > 0
          ? _clearSelection
          : canSelectAll
          ? _selectAllVisible
          : null,
    );
  }

  Widget _buildSearchField() {
    return CustomTextField(
      controller: _search,
      onChanged: _onSearchChanged,
      textInputAction: TextInputAction.search,
      labelText: StringConstants.searchMembers,
      hintText: StringConstants.searchByNameOrEmail,
      icon: Icons.search_rounded,
      isRequired: false,
      suffixIcon: _searching
          ? const Padding(
              padding: EdgeInsets.all(AppDimens.paddingX12),
              child: SizedBox(
                width: AppDimens.sizeX16,
                height: AppDimens.sizeX16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _search.text.isEmpty
          ? null
          : IconButton(
              tooltip: StringConstants.clearSearch,
              onPressed: _clearSearch,
              icon: const Icon(Icons.close_rounded),
            ),
    );
  }

  Widget _buildMembersList() {
    if (_loadingInitial && _candidates.isEmpty) {
      return const GroupMembersLoadingCard();
    }

    if (_loadError != null && _candidates.isEmpty) {
      return GroupMembersErrorCard(
        message: _loadError!,
        onRetry: () => unawaited(_loadRegisteredUsers(reset: true)),
      );
    }

    if (_candidates.isEmpty) {
      return GroupEmptyStateCard(
        icon: Icons.person_search_outlined,
        title: _usesRemoteMembers
            ? 'No users found'
            : StringConstants.noMembersFound,
        message: _usesRemoteMembers
            ? 'Registered users will appear here.'
            : StringConstants.startAConversationFirstThenCreateAGroupFromIt,
      );
    }

    final List<ParticipantModel> visible = _visibleCandidates;

    if (visible.isEmpty) {
      return const GroupEmptyStateCard(
        icon: Icons.search_off_rounded,
        title: StringConstants.noMatchingMembers,
        message: StringConstants.trySearchingWithAnotherNameOrEmail,
      );
    }

    // Laid out, not scrolled: the page owns the only scroll, so every row is
    // reachable with one gesture.
    return Container(
      decoration: BoxDecoration(
        color: LightColor.cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        border: Border.all(color: LightColor.dividerColor),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: LightColor.shadowColor.withValues(alpha: 0.04),
            blurRadius: AppDimens.sizeX10,
            offset: const Offset(0, AppDimens.sizeX2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimens.radiusX12),
        child: Column(
          children: [
            const SizedBox(height: AppDimens.paddingX4),
            for (int index = 0; index < visible.length; index++) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 67,
                  endIndent: AppDimens.paddingX12,
                  color: LightColor.dividerColor.withValues(alpha: 0.55),
                ),
              GroupMemberTile(
                participant: visible[index],
                selected: _selected.contains(visible[index].userId),
                disabled: _isFull && !_selected.contains(visible[index].userId),
                onTap: () => _toggleParticipant(visible[index]),
              ),
            ],
            if (_loadingMore || _loadError != null)
              GroupMembersFooter(
                loading: _loadingMore,
                error: _loadError,
                onRetry: () => unawaited(_loadRegisteredUsers(reset: false)),
              ),
            const SizedBox(height: AppDimens.paddingX4),
          ],
        ),
      ),
    );
  }

  /// The button stays live even when the form is incomplete: [_submit] names
  /// what is missing in the banner above it. Handing it `null` instead left a
  /// button that looked pressable, did nothing, and said nothing.
  Widget _buildBottomAction() {
    return GroupBottomActionContainer(
      error: _error,
      child: CustomButton(
        text: StringConstants.createGroupAction,
        onPressed: _submit,
        minHeight: 50,
        borderRadius: AppDimens.radiusX12,
      ),
    );
  }
}

class _RegisteredUsersLoadException implements Exception {
  const _RegisteredUsersLoadException(this.message);

  final String message;
}
