import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hamro_futsal/core/theme/app_colors.dart';
import 'package:hamro_futsal/core/theme/futsal_theme.dart';
import 'package:hamro_futsal/core/utils/dimens.dart';
import 'package:hamro_futsal/core/utils/string_constants.dart';
import 'package:hamro_futsal/core/widgets/custom_bottom_sheet.dart';
import 'package:hamro_futsal/core/widgets/custom_text_field.dart';
import 'package:hamro_futsal/features/message/data/model/conversation_model.dart';
import 'package:hamro_futsal/features/message/data/repositories/message_repository_impl.dart';
import 'package:hamro_futsal/features/message/domain/usecase/message_usecase.dart';
import 'package:hamro_futsal/features/message/presentation/pages/create_group_conversation_page.dart'
    show RegisteredUsersLoader;
import 'package:hamro_futsal/features/message/presentation/utils/pagination_trigger.dart';
import 'package:hamro_futsal/features/message/presentation/widgets/group_member_widgets.dart';

/// Adding people to a group that already exists. Creating one is a full page
/// — see `CreateGroupConversationPage` — because that form is far longer; this
/// one is a single list, which a sheet suits.
///
/// Both surfaces pick from the same source: the registered-users endpoint,
/// paged and searched the same way, so the people offered here are the people
/// offered there rather than only the handful already met in the inbox.
const double _kAddMembersSheetHeightFactor = 0.86;

Future<List<int>?> showAddGroupMembersSheet({
  required BuildContext context,
  required Iterable<ParticipantModel> participants,
  required Set<int> excludedUserIds,
  MessageUseCase? useCase,
  RegisteredUsersLoader? registeredUsersLoader,
}) {
  final candidates = <int, ParticipantModel>{};

  for (final participant in participants) {
    if (participant.userId > 0 &&
        !excludedUserIds.contains(participant.userId)) {
      candidates[participant.userId] = participant;
    }
  }

  final sortedCandidates = candidates.values.toList(growable: false)
    ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  return showAppBottomSheet<List<int>>(
    context: context,
    builder: (_) => AddGroupMembersForm(
      candidates: sortedCandidates,
      excludedUserIds: excludedUserIds,
      useCase: registeredUsersLoader == null
          ? useCase ?? MessageUseCase(MessageRepositoryImpl())
          : useCase,
      registeredUsersLoader: registeredUsersLoader,
    ),
  );
}

@visibleForTesting
class AddGroupMembersForm extends StatefulWidget {
  const AddGroupMembersForm({
    super.key,
    required this.candidates,
    required this.excludedUserIds,
    this.useCase,
    this.registeredUsersLoader,
  });

  /// Seed rows shown while the endpoint loads — the people already known from
  /// the inbox. They are merged with, not replaced by, the loaded page.
  final List<ParticipantModel> candidates;
  final Set<int> excludedUserIds;
  final MessageUseCase? useCase;
  final RegisteredUsersLoader? registeredUsersLoader;

  @override
  State<AddGroupMembersForm> createState() => _AddGroupMembersFormState();
}

class _AddGroupMembersFormState extends State<AddGroupMembersForm> {
  static const int _registeredUsersPerPage = 15;
  static const Duration _searchDebounceDelay = Duration(milliseconds: 450);

  final Set<int> _selected = <int>{};
  final TextEditingController _search = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<int, ParticipantModel> _known = <int, ParticipantModel>{};

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

  int get _totalMemberCount => _selected.length + widget.excludedUserIds.length;

  bool get _isFull => _totalMemberCount >= kMaxGroupMembers;

  bool get _canSubmit =>
      _selected.isNotEmpty && _totalMemberCount <= kMaxGroupMembers;

  /// Everyone offerable: the seed rows plus every loaded page, minus the
  /// people already in the group.
  List<ParticipantModel> get _candidates {
    final byUserId = <int, ParticipantModel>{};
    for (final participant in widget.candidates.followedBy(_remoteCandidates)) {
      if (participant.userId > 0 &&
          !widget.excludedUserIds.contains(participant.userId)) {
        byUserId[participant.userId] = participant;
      }
    }
    return byUserId.values.toList(growable: false);
  }

  /// The rows to show for the current query.
  ///
  /// The server searches, but the list also holds seed rows from the inbox and
  /// pages loaded before the query changed; showing those unfiltered made the
  /// search look broken. Everything on screen has to match what was typed.
  List<ParticipantModel> get _visibleCandidates {
    final String query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return _candidates;
    return _candidates
        .where(
          (participant) =>
              participant.name.toLowerCase().contains(query) ||
              participant.email.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    for (final participant in widget.candidates) {
      _known[participant.userId] = participant;
    }
    if (_usesRemoteMembers) {
      unawaited(_loadRegisteredUsers(reset: true));
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController.dispose();
    _search.dispose();
    super.dispose();
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
        _currentUserPage = pageResult.currentPage;
        _hasMoreUsers = pageResult.hasMorePages;
        final byUserId = <int, ParticipantModel>{
          if (!reset)
            for (final participant in _remoteCandidates)
              participant.userId: participant,
          for (final participant in pageResult.items)
            participant.userId: participant,
        };
        _remoteCandidates = byUserId.values.toList(growable: false);
        for (final participant in _remoteCandidates) {
          _known[participant.userId] = participant;
        }
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
      _searchDebounce = Timer(
        _searchDebounceDelay,
        () => unawaited(_loadRegisteredUsers(reset: true)),
      );
    }
    setState(() {
      _error = null;
      if (_usesRemoteMembers) _loadError = null;
    });
  }

  void _clearSearch() {
    _search.clear();
    _onSearchChanged('');
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
    if (_selected.isEmpty) {
      setState(() => _error = 'Select at least one new member.');
      return;
    }

    if (_totalMemberCount > kMaxGroupMembers) {
      setState(() {
        _error = 'A group can contain at most $kMaxGroupMembers members.';
      });
      return;
    }

    Navigator.of(context).pop(_selected.toList(growable: false));
  }

  void _toggleParticipant(ParticipantModel participant) {
    HapticFeedback.selectionClick();

    setState(() {
      _error = null;

      if (_selected.contains(participant.userId)) {
        _selected.remove(participant.userId);
      } else {
        _selected.add(participant.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredHeight =
            MediaQuery.sizeOf(context).height * _kAddMembersSheetHeightFactor;
        return SizedBox(
          height: math.min(preferredHeight, constraints.maxHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimens.paddingX14),
              _buildSearchField(),
              const SizedBox(height: AppDimens.paddingX14),
              Expanded(child: _buildContent()),
              _buildBottomAction(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final textTheme = FutsalTheme.getTextTheme(context);
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: LightColor.secondaryColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
          child: const Icon(
            Icons.person_add_alt_1_rounded,
            color: LightColor.secondaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: AppDimens.paddingX12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                StringConstants.addMembersTitle,
                style: textTheme.bodyTextLarge?.copyWith(
                  color: LightColor.primaryTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                _selected.isEmpty
                    ? 'Choose people to add in this group'
                    : '${_selected.length} selected',
                style: textTheme.bodyTextSmall?.copyWith(
                  color: _selected.isEmpty
                      ? LightColor.secondaryTextColor
                      : LightColor.secondaryColor,
                  fontWeight: _selected.isEmpty
                      ? FontWeight.w400
                      : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: StringConstants.close,
          style: IconButton.styleFrom(
            backgroundColor: LightColor.background,
            foregroundColor: LightColor.secondaryTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, size: 20),
        ),
      ],
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

  Widget _buildContent() {
    if (_loadingInitial && _candidates.isEmpty) {
      return const GroupMembersLoadingCard();
    }

    if (_loadError != null && _candidates.isEmpty) {
      return GroupMembersErrorCard(
        message: _loadError!,
        onRetry: () => unawaited(_loadRegisteredUsers(reset: true)),
      );
    }

    final List<ParticipantModel> visible = _visibleCandidates;

    if (visible.isEmpty) {
      return GroupEmptyStateCard(
        icon: _search.text.trim().isEmpty
            ? Icons.person_search_outlined
            : Icons.search_off_rounded,
        title: _search.text.trim().isEmpty
            ? StringConstants.noMembersAvailable
            : StringConstants.noMatchingMembers,
        message: _search.text.trim().isEmpty
            ? StringConstants.thereAreNoNewPeopleAvailableToAddInThisGroup
            : StringConstants.trySearchingWithAnotherNameOrEmail,
      );
    }

    // One card holding the rows, exactly as the create-group page draws them:
    // the sheet itself is the only other surface, so nothing nests.
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: ListView(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.only(bottom: AppDimens.paddingX16),
        children: [
          Container(
            decoration: BoxDecoration(
              color: LightColor.cardColor,
              borderRadius: BorderRadius.circular(AppDimens.radiusX12),
              border: Border.all(color: LightColor.dividerColor),
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
                      // The cap counts the members already in the group, so
                      // rows go unselectable as soon as one more would exceed
                      // it.
                      disabled:
                          _isFull && !_selected.contains(visible[index].userId),
                      onTap: () => _toggleParticipant(visible[index]),
                    ),
                  ],
                  if (_loadingMore || _loadError != null)
                    GroupMembersFooter(
                      loading: _loadingMore,
                      error: _loadError,
                      onRetry: () =>
                          unawaited(_loadRegisteredUsers(reset: false)),
                    ),
                  const SizedBox(height: AppDimens.paddingX4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return GroupBottomActionContainer(
      error: _error,
      child: FilledButton.icon(
        onPressed: _canSubmit ? _submit : null,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(
          _selected.isEmpty
              ? 'Add members'
              : 'Add ${_selected.length} ${_selected.length == 1 ? 'member' : 'members'}',
        ),
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: LightColor.secondaryColor,
          disabledBackgroundColor: LightColor.secondaryColor.withValues(
            alpha: 0.35,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusX12),
          ),
        ),
      ),
    );
  }
}

class _RegisteredUsersLoadException implements Exception {
  const _RegisteredUsersLoadException(this.message);

  final String message;
}
